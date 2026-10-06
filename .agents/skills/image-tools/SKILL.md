---
name: image-tools
description: Download, compress, and inspect images for article covers and site assets. Use when adding new article covers (from Pixiv or other sources), upgrading existing images to higher quality, or checking image dimensions / file sizes.
---

# Image Tools

Run commands from the repository root.

**Script**: `.agents/skills/image-tools/image-tools.sh`, with every operation implemented as a subcommand. Run with `help` for full usage.

## Prerequisites

- `magick`: ImageMagick 7 (compress, info, batch)
- `gallery-dl`: Pixiv downloader (download, needs Pixiv auth configured)

## Workflow

### Adding a New Article Cover from Pixiv

1. Download the original from Pixiv:

   ```bash
   .agents/skills/image-tools/image-tools.sh download <PIXIV_ID>
   ```

2. Compress to WebP at 1920px wide (default):

   ```bash
   .agents/skills/image-tools/image-tools.sh compress <PIXIV_ID>_p0.png
   ```

   Output goes to `assets/images/article-covers/<PIXIV_ID>_p0.webp` by default.

3. Reference in frontmatter:

   ```toml
   [featured_image]
   src = "/assets/images/article-covers/<PIXIV_ID>_p0.webp"
   ```

### Upgrading the Background Image

```bash
.agents/skills/image-tools/image-tools.sh compress ~/path/to/source.png assets/images 3840 90
```

This outputs a 4K WebP at quality 90.

### Batch Processing

Compress all images in a directory at once:

```bash
.agents/skills/image-tools/image-tools.sh batch /tmp/pixiv-originals
```

### Inspecting Images

Check dimensions and file sizes:

```bash
.agents/skills/image-tools/image-tools.sh info assets/images/article-covers
```

## Conventions

- Article covers: 1920px max width, quality 85, WebP format
- Background image: 3840px (4K), quality 90
- Filenames: `<PIXIV_ID>_p0` for Pixiv-sourced images, descriptive name for others
- All images stored under `assets/images/`
