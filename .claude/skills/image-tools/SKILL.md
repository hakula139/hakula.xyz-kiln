# Image Tools

Download, compress, and inspect images for article covers and site assets. Use when adding new article covers (from Pixiv or other sources), upgrading existing images to higher quality, or checking image dimensions / file sizes.

**Script**: `.claude/skills/image-tools/image-tools.sh` — all operations are implemented as subcommands. Run with `help` for full usage.

## Prerequisites

- `magick` — ImageMagick 7 (compress, info, batch)
- `gallery-dl` — Pixiv downloader (download; needs Pixiv auth configured)

## Workflow

### Adding a New Article Cover from Pixiv

1. Download the original from Pixiv:

   ```bash
   ./image-tools.sh download <PIXIV_ID>
   ```

2. Compress to WebP at 1920px wide (default):

   ```bash
   ./image-tools.sh compress <PIXIV_ID>_p0.png
   ```

   Output goes to `static/images/article-covers/<PIXIV_ID>_p0.webp` by default. Rename to `<PIXIV_ID>.webp` if needed.

3. Reference in frontmatter:

   ```toml
   featured_image = "/images/article-covers/<PIXIV_ID>.webp"
   ```

### Upgrading the Background Image

```bash
./image-tools.sh compress ~/path/to/source.png static/images 3840 90
```

This outputs a 4K WebP at quality 90.

### Batch Processing

Compress all images in a directory at once:

```bash
./image-tools.sh batch /tmp/pixiv-originals
```

### Inspecting Images

Check dimensions and file sizes:

```bash
./image-tools.sh info static/images/article-covers
```

## Conventions

- Article covers: 1920px max width, quality 85, WebP format
- Background image: 3840px (4K), quality 90
- Filenames: Pixiv ID for Pixiv-sourced images, descriptive name for others
- All images stored under `static/images/`
