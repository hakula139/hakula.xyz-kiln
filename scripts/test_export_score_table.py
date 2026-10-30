import tempfile
import unittest
from pathlib import Path

from export_score_table import (
    MUTED,
    RED,
    WHITE,
    YELLOW,
    cell_style,
    column_widths,
    load_font,
    load_table,
    render_table,
    text_position,
)


class TableTests(unittest.TestCase):
    def test_csv_preserves_quoted_titles_and_rejects_invalid_rows(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'scores.csv'
            path.write_text('作品名称,总评\n"Alpha, Beta",82.3\n', encoding='utf-8')
            headers, rows = load_table(path)
            self.assertEqual(headers, ['#', '作品名称', '总评'])
            self.assertEqual(
                rows, [{'#': '1', '作品名称': 'Alpha, Beta', '总评': '82.3'}]
            )
            for invalid in [
                '作品名称,总评\n',
                '作品名称,总评,总评\nAlpha,1,2\n',
                '作品名称,总评\nAlpha,1,2\n',
                '作品名称,总评\nAlpha,nan\n',
            ]:
                with self.subTest(csv=invalid):
                    path.write_text(invalid, encoding='utf-8')
                    with self.assertRaises(ValueError):
                        load_table(path)

    def test_warning_suffixes_and_sample_flags(self) -> None:
        for value, display, background, foreground, bold in [
            ('18+!', '18+', WHITE, RED, False),
            ('18+!!', '18+', WHITE, RED, True),
            ('18+G', '18+', YELLOW, RED, True),
            ('18+G!', '18+', RED, (0, 0, 0), True),
            ('18+G!!', '18+', (23, 23, 23), RED, True),
            ('All', 'All', WHITE, MUTED, False),
        ]:
            with self.subTest(value=value):
                cell = cell_style('分级', {'分级': value}, '')
                self.assertEqual(
                    (cell.display, cell.background, cell.foreground, cell.bold),
                    (display, background, foreground, bold),
                )
        self.assertEqual(cell_style('EGS', {'EGS': '~80'}, '').foreground, MUTED)

    def test_latest_marker_dates_and_delta_direction(self) -> None:
        row = {'作品名称': 'Alpha', '完成日期': '2026-01-02'}
        self.assertEqual(cell_style('作品名称', row, '2026-01-02').background, YELLOW)
        self.assertEqual(cell_style('作品名称', row, '2026-01-03').background, WHITE)
        self.assertEqual(cell_style('完成日期', row, '').align, 'right')
        self.assertEqual(text_position(10, 200, 56, 14, 'right'), 140)
        positive = cell_style('ΔBGM', {'ΔBGM': '+1.5'}, '').background
        negative = cell_style('ΔBGM', {'ΔBGM': '-1.5'}, '').background
        self.assertGreater(positive[2], positive[0])
        self.assertGreater(negative[0], negative[2])


class RenderTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.regular = load_font('Sarasa Gothic SC', 'Regular', 56)
        cls.bold = load_font('Sarasa Gothic SC', 'Bold', 56)

    def test_widths_and_long_titles_are_not_clipped(self) -> None:
        headers = ['作品名称', '文本', '总评', '评级', 'EGS', 'BGM', 'BGM 评', 'ΔBGM']
        rows = [
            dict(
                zip(
                    headers,
                    [
                        '長い作品名称 Alpha, Beta',
                        '110',
                        '99.9',
                        'SS+ / 10+',
                        '~80',
                        '8.50',
                        '10.00',
                        '+1.50',
                    ],
                    strict=True,
                )
            ),
            dict(
                zip(
                    headers,
                    ['Gamma', '9', '20.9', 'F+ / 1+', '77', '6.79', '1.18', '-5.61'],
                    strict=True,
                )
            ),
        ]
        widths = column_widths(headers, rows, self.regular, self.bold, 2)
        self.assertGreater(widths['文本'], widths['评级'])
        self.assertEqual(widths['文本'], widths['总评'])
        self.assertEqual(len({widths[h] for h in ['EGS', 'BGM', 'BGM 评', 'ΔBGM']}), 1)
        self.assertGreaterEqual(
            widths['作品名称'], self.regular.getlength(rows[0]['作品名称']) + 56
        )
        image = render_table(headers, rows, self.regular, self.bold, 2)
        self.assertEqual(image.width, sum(widths.values()) + 48)
        self.assertEqual(image.height, 344)
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'table.png'
            image.save(path)
            self.assertGreater(path.stat().st_size, 1000)

    def test_score_bars_and_full_cell_cap(self) -> None:
        headers = ['作品名称', '文本', '总评']
        rows = [{'作品名称': 'Alpha', '文本': '50', '总评': '110'}]
        image = render_table(headers, rows, self.regular, self.bold, 2)
        widths = column_widths(headers, rows, self.regular, self.bold, 2)
        score_left = 24 + widths['作品名称']
        self.assertNotEqual(image.getpixel((score_left + 10, 130)), WHITE)
        self.assertEqual(image.getpixel((score_left + widths['文本'] - 10, 130)), WHITE)
        self.assertNotEqual(image.getpixel((image.width - 34, 130)), WHITE)
        self.assertEqual(image.getpixel((image.width - 10, 130)), WHITE)


if __name__ == '__main__':
    unittest.main()
