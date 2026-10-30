import argparse
import colorsys
import csv
import math
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Literal

from PIL import Image, ImageDraw, ImageFont


Color = tuple[int, int, int]
WHITE = (255, 255, 255)
TEXT = (31, 41, 55)
MUTED = (107, 114, 128)
RED = (231, 0, 11)
YELLOW = (255, 240, 133)
SCORE_COLORS = {
    '文本': (0, 176, 240),
    '系统': (255, 182, 40),
    '影像': (99, 195, 132),
    '声音': (99, 142, 198),
    '总评': (255, 85, 90),
}
EXTERNAL_COLUMNS = {'EGS', 'BGM', 'BGM 评', 'ΔBGM'}
DATE_COLUMNS = {'完成日期', '初次完成日期'}


@dataclass
class CellStyle:
    display: str
    background: Color = WHITE
    foreground: Color = TEXT
    bold: bool = False
    align: Literal['left', 'center', 'right'] = 'center'


def positive_int(value: str) -> int:
    number = int(value)
    if number <= 0:
        raise argparse.ArgumentTypeError('must be greater than zero')
    return number


def load_table(path: Path) -> tuple[list[str], list[dict[str, str]]]:
    with path.open(encoding='utf-8-sig', newline='') as source:
        reader = csv.reader(source, strict=True)
        headers = next(reader, [])
        if (
            not headers
            or any(not name for name in headers)
            or len(set(headers)) != len(headers)
        ):
            raise ValueError('CSV must have nonempty, unique column names')
        if not {'作品名称', '总评'} <= set(headers) or '#' in headers:
            raise ValueError(
                'CSV requires 作品名称 and 总评 columns, without a # column'
            )
        rows = []
        for index, values in enumerate(reader, 2):
            if len(values) != len(headers):
                raise ValueError(f'CSV row {index} has the wrong number of fields')
            row = dict(zip(headers, values, strict=True))
            for name in SCORE_COLORS.keys() | {'个人差', 'ΔBGM'}:
                if name in row and not math.isfinite(float(row[name])):
                    raise ValueError(f'CSV row {index}: {name} must be finite')
            rows.append({'#': str(index - 1), **row})
    if not rows:
        raise ValueError('CSV contains no data rows')
    return ['#', *headers], rows


def load_font(family: str, style: str, size: int) -> ImageFont.FreeTypeFont:
    result = subprocess.run(
        [
            'fc-match',
            '--format=%{family}\n%{file}\n%{index}',
            f'{family}:style={style}',
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    matched, path, index = result.stdout.splitlines()
    if family.casefold() not in {
        name.strip().casefold() for name in matched.split(',')
    }:
        raise ValueError(f'font family {family!r} is unavailable (matched {matched!r})')
    return ImageFont.truetype(path, size, index=int(index))


def blend(color: Color, alpha: float) -> Color:
    return tuple(round(255 * (1 - alpha) + channel * alpha) for channel in color)


def cell_style(name: str, row: dict[str, str], latest: str) -> CellStyle:
    value = row[name]
    cell = CellStyle(value)
    if name == '作品名称':
        cell.align = 'left'
        if latest and row.get('完成日期') == latest:
            cell.background = YELLOW
    elif name in SCORE_COLORS:
        cell.align = 'left'
    elif name == '评级':
        t = max(0, min(float(row['总评']) / 100, 1))
        cell.background = tuple(
            round(channel * 255)
            for channel in colorsys.hls_to_rgb((1 - t) * 2 / 3, 0.85 - t * 0.25, 0.7)
        )
    elif name == '个人差':
        t = max(0, min(float(value) / 5, 1))
        cell.background = (round(255 * (1 - t)),) * 3
        if t > 0.5:
            cell.foreground = WHITE
    elif name == 'ΔBGM':
        score = float(value)
        color = (40, 133, 255) if score > 0 else (255, 113, 40)
        cell.background = blend(color, min(abs(score) / 3, 1) * 0.6)
    elif name == '分级':
        for suffix, tier in [('G!!', 6), ('G!', 5), ('G', 4), ('!!', 3), ('!', 2)]:
            if value.endswith(suffix):
                cell.display = value[: -len(suffix)]
                cell.foreground = RED
                cell.bold = tier >= 3
                if tier == 4:
                    cell.background = YELLOW
                elif tier == 5:
                    cell.background, cell.foreground = RED, (0, 0, 0)
                elif tier == 6:
                    cell.background = (23, 23, 23)
                break
        else:
            if value == 'All':
                cell.foreground = MUTED
    elif name in {'EGS', 'BGM'} and value.startswith('~'):
        cell.foreground = MUTED
    elif name in DATE_COLUMNS:
        cell.align = 'right'
    return cell


def column_widths(
    headers: list[str],
    rows: list[dict[str, str]],
    regular: ImageFont.FreeTypeFont,
    bold: ImageFont.FreeTypeFont,
    scale: int,
) -> dict[str, int]:
    padding = 14 * scale
    widths = {
        name: math.ceil(
            max(bold.getlength(name), *(regular.getlength(row[name]) for row in rows))
        )
        + 2 * padding
        for name in headers
    }
    score_width = max(
        widths.get('评级', 0), *(widths[h] for h in SCORE_COLORS if h in widths)
    )
    for name in SCORE_COLORS.keys() & widths.keys():
        widths[name] = score_width + 8 * scale
    external_width = max(
        (widths[h] for h in EXTERNAL_COLUMNS if h in widths), default=0
    )
    for name in EXTERNAL_COLUMNS & widths.keys():
        widths[name] = external_width
    return widths


def text_position(
    left: int,
    width: int,
    text_width: float,
    padding: int,
    align: str,
) -> float:
    if align == 'left':
        return left + padding
    if align == 'right':
        return left + width - padding - text_width
    return left + (width - text_width) / 2


def render_table(
    headers: list[str],
    rows: list[dict[str, str]],
    regular: ImageFont.FreeTypeFont,
    bold: ImageFont.FreeTypeFont,
    scale: int,
) -> Image.Image:
    padding, margin = 14 * scale, 12 * scale
    row_height, header_height = 48 * scale, 52 * scale
    widths = column_widths(headers, rows, regular, bold, scale)
    positions = [margin]
    for name in headers:
        positions.append(positions[-1] + widths[name])
    height = 2 * margin + header_height + len(rows) * row_height
    image = Image.new('RGB', (positions[-1] + margin, height), WHITE)
    draw = ImageDraw.Draw(image)
    latest = max((row.get('完成日期', '') for row in rows), default='')

    def label(cell: CellStyle, col: int, top: int, height: int) -> None:
        font = bold if cell.bold else regular
        width = widths[headers[col]]
        length = font.getlength(cell.display)
        x = text_position(positions[col], width, length, padding, cell.align)
        ascent, descent = font.getmetrics()
        baseline = top + (height - ascent - descent) / 2 + ascent
        draw.text(
            (round(x), round(baseline)),
            cell.display,
            font=font,
            fill=cell.foreground,
            anchor='ls',
        )

    for col, name in enumerate(headers):
        draw.rectangle(
            (positions[col], margin, positions[col + 1], margin + header_height),
            fill=(229, 231, 235),
        )
        align = (
            'left'
            if name == '作品名称'
            else 'right'
            if name in DATE_COLUMNS
            else 'center'
        )
        cell = CellStyle(name, bold=True, align=align)
        label(cell, col, margin, header_height)
    for index, row in enumerate(rows):
        top = margin + header_height + index * row_height
        for col, name in enumerate(headers):
            left, right = positions[col], positions[col + 1]
            cell = cell_style(name, row, latest)
            draw.rectangle((left, top, right, top + row_height), fill=cell.background)
            if name in SCORE_COLORS:
                fraction = max(0, min(float(row[name]) / 100, 1))
                draw.rectangle(
                    (
                        left,
                        top,
                        left + round((right - left) * fraction),
                        top + row_height,
                    ),
                    fill=blend(SCORE_COLORS[name], 0.4),
                )
            label(cell, col, top, row_height)
    bottom = height - margin
    grid = (209, 213, 219)
    for x in positions:
        draw.line((x, margin, x, bottom), fill=grid, width=scale)
    for y in [
        margin,
        *(margin + header_height + i * row_height for i in range(len(rows) + 1)),
    ]:
        draw.line((margin, y, positions[-1], y), fill=grid, width=scale)
    return image


def main() -> None:
    parser = argparse.ArgumentParser(
        description='Export a score-table CSV as a full PNG.'
    )
    parser.add_argument(
        'csv', type=Path, help='score-table CSV, in the desired row order'
    )
    parser.add_argument(
        '-o', '--output', type=Path, required=True, help='output PNG path'
    )
    parser.add_argument(
        '--font-family', default='Sarasa Gothic SC', help='fontconfig family'
    )
    parser.add_argument(
        '--scale', type=positive_int, default=2, help='raster scale (default: 2)'
    )
    args = parser.parse_args()
    try:
        headers, rows = load_table(args.csv)
        regular = load_font(args.font_family, 'Regular', 28 * args.scale)
        bold = load_font(args.font_family, 'Bold', 28 * args.scale)
        image = render_table(headers, rows, regular, bold, args.scale)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        image.save(args.output, format='PNG', optimize=True, dpi=(96 * args.scale,) * 2)
    except (OSError, ValueError, csv.Error, subprocess.CalledProcessError) as error:
        parser.exit(2, f'error: {error}\n')
    print(f'{args.output}: {image.width} × {image.height}, {len(rows)} rows')


if __name__ == '__main__':
    main()
