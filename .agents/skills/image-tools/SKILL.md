---
name: image-tools
description: Download, compress, and inspect images for article covers and site assets. Use when adding new article covers (from Pixiv or other sources), upgrading existing images to higher quality, or checking image dimensions / file sizes.
---

# Image Tools

Run commands from the repository root.

Run `.agents/skills/image-tools/image-tools.nu --help` for commands, defaults, and prerequisites. Pixiv downloads require gallery-dl authentication.

## Workflow

### Adding a New Article Cover from Pixiv

1. Download the original from Pixiv:

   ```nushell
   .agents/skills/image-tools/image-tools.nu download <PIXIV_ID>
   ```

2. Compress the downloaded first-page file, using its actual extension:

   ```nushell
   .agents/skills/image-tools/image-tools.nu compress <PIXIV_ID>_p0.<EXTENSION>
   ```

   Output goes to `assets/images/article-covers/<PIXIV_ID>_p0.webp` by default.

3. Reference in frontmatter:

   ```toml
   [featured_image]
   src = "/assets/images/article-covers/<PIXIV_ID>_p0.webp"
   ```

### Upgrading the Background Image

```nushell
.agents/skills/image-tools/image-tools.nu compress ~/path/to/source.png assets/images 3840 90
```

Image locations and frontmatter follow [Format and typography](../../../content/AGENTS.md).
