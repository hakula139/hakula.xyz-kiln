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
BLACK: Color = (0, 0, 0)
BLUE: Color = (40, 133, 255)
DARK: Color = (23, 23, 23)
GRID: Color = (209, 213, 219)
HEADER: Color = (229, 231, 235)
MUTED: Color = (107, 114, 128)
ORANGE: Color = (255, 113, 40)
RED: Color = (231, 0, 11)
TEXT: Color = (31, 41, 55)
WHITE: Color = (255, 255, 255)
YELLOW: Color = (255, 240, 133)

SCORE_COLORS: dict[str, Color] = {
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
    align: Literal['left', 'center', 'right'] = 'center'


def positive_int(value: str) -> int:
    number = int(value)

    if number <= 0:
        raise argparse.ArgumentTypeError('must be greater than zero')

    return number


def load_table(path: Path) -> tuple[list[str], list[dict[str, str]]]:
    with path.open(encoding='utf-8-sig', newline='') as source:
        reader = csv.DictReader(source)
        rows = [{'#': str(index), **row} for index, row in enumerate(reader, 1)]

    return list(rows[0]), rows


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


def cell_style(name: str, row: dict[str, str], is_latest: bool) -> CellStyle:
    value = row[name]
    cell = CellStyle(value)

    match name:
        case '作品名称':
            cell.align = 'left'

            if is_latest:
                cell.background = YELLOW

        case '评级':
            t = max(0, min(float(row['总评']) / 100, 1))
            cell.background = tuple(
                round(channel * 255)
                for channel in colorsys.hls_to_rgb(
                    (1 - t) * 2 / 3, 0.85 - t * 0.25, 0.7
                )
            )

        case '个人差':
            t = max(0, min(float(value) / 5, 1))
            cell.background = (round(255 * (1 - t)),) * 3

            if t > 0.5:
                cell.foreground = WHITE

        case 'ΔBGM':
            score = float(value)
            color = BLUE if score > 0 else ORANGE
            cell.background = blend(color, min(abs(score) / 3, 1) * 0.6)

        case '分级':
            for suffix in ['G!!', 'G!', 'G', '!!', '!']:
                if value.endswith(suffix):
                    cell.display = value[: -len(suffix)]
                    cell.foreground = RED

                    match suffix:
                        case 'G':
                            cell.background = YELLOW
                        case 'G!':
                            cell.background, cell.foreground = RED, BLACK
                        case 'G!!':
                            cell.background = DARK

                    break
            else:
                if value == 'All':
                    cell.foreground = MUTED

        case 'EGS' | 'BGM':
            if value.startswith('~'):
                cell.foreground = MUTED

        case _ if name in SCORE_COLORS:
            cell.align = 'left'

        case _ if name in DATE_COLUMNS:
            cell.align = 'right'

    return cell


def column_widths(
    headers: list[str],
    rows: list[dict[str, str]],
    body_font: ImageFont.FreeTypeFont,
    header_font: ImageFont.FreeTypeFont,
    title_font: ImageFont.FreeTypeFont,
    scale: int,
) -> dict[str, int]:
    padding = 14 * scale
    widths = {}

    for name in headers:
        font = title_font if name == '作品名称' else body_font
        features = [] if name == '作品名称' else ['tnum']

        widths[name] = (
            math.ceil(
                max(
                    header_font.getlength(name, features=features),
                    *(font.getlength(row[name], features=features) for row in rows),
                )
            )
            + 2 * padding
        )

    score_width = max(
        widths[name] for name in (SCORE_COLORS.keys() | {'评级'}) & widths.keys()
    )

    for name in SCORE_COLORS.keys() & widths.keys():
        widths[name] = score_width + 8 * scale

    external_width = max(widths[h] for h in EXTERNAL_COLUMNS if h in widths)

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
    match align:
        case 'left':
            return left + padding
        case 'right':
            return left + width - padding - text_width
        case _:
            return left + (width - text_width) / 2


def render_table(
    headers: list[str],
    rows: list[dict[str, str]],
    body_font: ImageFont.FreeTypeFont,
    header_font: ImageFont.FreeTypeFont,
    title_font: ImageFont.FreeTypeFont,
    scale: int,
) -> Image.Image:
    padding, margin = 14 * scale, 12 * scale
    row_height, header_height = 48 * scale, 52 * scale
    widths = column_widths(headers, rows, body_font, header_font, title_font, scale)

    positions = [margin]

    for name in headers:
        positions.append(positions[-1] + widths[name])

    height = 2 * margin + header_height + len(rows) * row_height
    image = Image.new('RGB', (positions[-1] + margin, height), WHITE)
    draw = ImageDraw.Draw(image)
    date_column = next(name for name in headers if name in DATE_COLUMNS)
    latest = max(row[date_column] for row in rows)

    def label(
        cell: CellStyle,
        col: int,
        top: int,
        height: int,
        font: ImageFont.FreeTypeFont,
    ) -> None:
        width = widths[headers[col]]
        features = [] if headers[col] == '作品名称' else ['tnum']
        length = font.getlength(cell.display, features=features)
        x = text_position(positions[col], width, length, padding, cell.align)
        ascent, descent = font.getmetrics()
        baseline = top + (height - ascent - descent) / 2 + ascent

        draw.text(
            (round(x), round(baseline)),
            cell.display,
            font=font,
            fill=cell.foreground,
            anchor='ls',
            features=features,
        )

    for col, name in enumerate(headers):
        draw.rectangle(
            (positions[col], margin, positions[col + 1], margin + header_height),
            fill=HEADER,
        )

        match name:
            case '作品名称':
                align = 'left'
            case _ if name in DATE_COLUMNS:
                align = 'right'
            case _:
                align = 'center'

        cell = CellStyle(name, align=align)
        label(cell, col, margin, header_height, header_font)

    for index, row in enumerate(rows):
        top = margin + header_height + index * row_height

        for col, name in enumerate(headers):
            left, right = positions[col], positions[col + 1]
            cell = cell_style(name, row, row[date_column] == latest)
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

            font = title_font if name == '作品名称' else body_font
            label(cell, col, top, row_height, font)

    bottom = height - margin

    for x in positions:
        draw.line((x, margin, x, bottom), fill=GRID, width=scale)

    for y in [
        margin,
        *(margin + header_height + i * row_height for i in range(len(rows) + 1)),
    ]:
        draw.line((margin, y, positions[-1], y), fill=GRID, width=scale)

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
        '--scale', type=positive_int, default=4, help='raster scale (default: 4)'
    )

    args = parser.parse_args()

    headers, rows = load_table(args.csv)
    body_font = load_font('Sarasa Gothic SC', 'Regular', 28 * args.scale)
    header_font = load_font('Sarasa Gothic SC', 'SemiBold', 28 * args.scale)
    title_font = load_font('Shippori Mincho', 'SemiBold', 28 * args.scale)
    image = render_table(headers, rows, body_font, header_font, title_font, args.scale)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    image.save(args.output, format='PNG', optimize=True, dpi=(96 * args.scale,) * 2)
    print(f'{args.output}: {image.width} × {image.height}, {len(rows)} rows')


if __name__ == '__main__':
    main()
