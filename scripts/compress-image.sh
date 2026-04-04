#!/usr/bin/env bash
set -euo pipefail

# Compress and convert images to WebP using ImageMagick 7.
#
# Usage:
#   ./scripts/compress-image.sh <input> [output_dir] [max_width] [quality]
#
# Defaults: output_dir = cwd, max_width = 1920, quality = 85
# If the image is narrower than max_width, it is not upscaled.

input="${1:?Usage: compress-image.sh <input> [output_dir] [max_width] [quality]}"
output_dir="${2:-.}"
max_width="${3:-1920}"
quality="${4:-85}"

basename="$(basename "${input%.*}")"
output="${output_dir}/${basename}.webp"

mkdir -p "$output_dir"
magick "$input" -resize "${max_width}x>" -quality "$quality" "$output"

size=$(stat -f%z "$output" 2>/dev/null || stat -c%s "$output")
dims=$(magick identify -format "%wx%h" "$output")
echo "${basename}.webp: ${dims}, $((size / 1024))KB"
