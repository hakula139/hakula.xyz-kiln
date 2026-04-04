#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Image Tools for hakula.xyz-kiln
# ==============================================================================
# Download, compress, and inspect images for article covers and site assets.
#
# Subcommands:
#   download    Download a Pixiv artwork via gallery-dl
#   compress    Convert / resize an image to WebP via ImageMagick 7
#   info        Show image dimensions and file size
#   batch       Compress all images in a directory
# ==============================================================================

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

readonly COVERS_DIR="static/images/article-covers"
readonly DEFAULT_MAX_WIDTH=1920
readonly DEFAULT_QUALITY=85

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

die() {
  printf 'error: %s\n' "$1" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

human_size() {
  local bytes="$1"
  if ((bytes >= 1048576)); then
    printf '%.1fMB' "$(echo "scale=1; ${bytes}/1048576" | bc)"
  else
    printf '%dKB' "$((bytes / 1024))"
  fi
}

file_size() {
  if [[ "$(uname)" == "Darwin" ]]; then
    stat -f%z "$1"
  else
    stat --format=%s "$1"
  fi
}

# ------------------------------------------------------------------------------
# Subcommands
# ------------------------------------------------------------------------------

cmd_download() {
  local pixiv_id="$1" output_dir="${2:-.}"
  require_cmd gallery-dl

  [[ "${pixiv_id}" =~ ^[0-9]+$ ]] || die "invalid Pixiv ID: ${pixiv_id}"

  mkdir -p "${output_dir}"
  local url="https://www.pixiv.net/artworks/${pixiv_id}"
  echo "Downloading Pixiv #${pixiv_id}..."
  gallery-dl "${url}" \
    --dest "${output_dir}" \
    --filename "{id}_{num}.{extension}" \
    --filter "extension in ('png', 'jpg', 'jpeg', 'webp')"

  echo ""
  echo "Downloaded to: ${output_dir}"
  ls -lh "${output_dir}/${pixiv_id}"* 2>/dev/null || echo "(no files matched expected pattern)"
}

cmd_compress() {
  local input="$1"
  local output_dir="${2:-${COVERS_DIR}}"
  local max_width="${3:-${DEFAULT_MAX_WIDTH}}"
  local quality="${4:-${DEFAULT_QUALITY}}"
  require_cmd magick

  [[ -f "${input}" ]] || die "file not found: ${input}"

  local basename
  basename="$(basename "${input%.*}")"
  local output="${output_dir}/${basename}.webp"

  mkdir -p "${output_dir}"
  magick "${input}" -resize "${max_width}x>" -quality "${quality}" "${output}"

  local size dims
  size=$(file_size "${output}")
  dims=$(magick identify -format "%wx%h" "${output}")
  echo "${basename}.webp: ${dims}, $(human_size "${size}")"
}

cmd_info() {
  local target="$1"
  require_cmd magick

  if [[ -d "${target}" ]]; then
    for f in "${target}"/*.webp "${target}"/*.png "${target}"/*.jpg; do
      [[ -f "${f}" ]] || continue
      local size dims
      size=$(file_size "${f}")
      dims=$(magick identify -format "%wx%h" "${f}")
      printf '%-40s %10s  %s\n' "$(basename "${f}")" "${dims}" "$(human_size "${size}")"
    done
  elif [[ -f "${target}" ]]; then
    local size dims
    size=$(file_size "${target}")
    dims=$(magick identify -format "%wx%h" "${target}")
    echo "$(basename "${target}"): ${dims}, $(human_size "${size}")"
  else
    die "not found: ${target}"
  fi
}

cmd_batch() {
  local input_dir="$1"
  local output_dir="${2:-${COVERS_DIR}}"
  local max_width="${3:-${DEFAULT_MAX_WIDTH}}"
  local quality="${4:-${DEFAULT_QUALITY}}"

  [[ -d "${input_dir}" ]] || die "directory not found: ${input_dir}"

  local count=0
  for f in "${input_dir}"/*.png "${input_dir}"/*.jpg "${input_dir}"/*.jpeg "${input_dir}"/*.webp; do
    [[ -f "${f}" ]] || continue
    cmd_compress "${f}" "${output_dir}" "${max_width}" "${quality}"
    ((count++))
  done
  echo ""
  echo "Compressed ${count} image(s) to ${output_dir}"
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

usage() {
  cat <<'EOF'
Usage: image-tools.sh <command> [args...]

Commands:
  download    <PIXIV_ID> [OUTPUT_DIR]
  compress    <INPUT_FILE> [OUTPUT_DIR] [MAX_WIDTH] [QUALITY]
  info        <FILE_OR_DIR>
  batch       <INPUT_DIR> [OUTPUT_DIR] [MAX_WIDTH] [QUALITY]

Defaults:
  OUTPUT_DIR   static/images/article-covers
  MAX_WIDTH    1920   (no upscaling; images narrower than this are unchanged)
  QUALITY      85     (WebP quality 0-100)

Examples:
  image-tools.sh download 94175799
  image-tools.sh compress ~/Pictures/cover.png
  image-tools.sh compress ~/Pictures/bg.png static/images 3840 90
  image-tools.sh info static/images/article-covers
  image-tools.sh batch /tmp/pixiv-originals

Prerequisites:
  magick       ImageMagick 7 (for compress, info, batch)
  gallery-dl   Pixiv downloader (for download; needs Pixiv auth configured)
EOF
}

main() {
  [[ $# -ge 1 ]] || {
    usage
    exit 1
  }

  local command="$1"
  shift

  case "${command}" in
    download)
      [[ $# -ge 1 ]] || die "usage: download <PIXIV_ID> [OUTPUT_DIR]"
      cmd_download "$@"
      ;;
    compress)
      [[ $# -ge 1 ]] || die "usage: compress <INPUT_FILE> [OUTPUT_DIR] [MAX_WIDTH] [QUALITY]"
      cmd_compress "$@"
      ;;
    info)
      [[ $# -ge 1 ]] || die "usage: info <FILE_OR_DIR>"
      cmd_info "$@"
      ;;
    batch)
      [[ $# -ge 1 ]] || die "usage: batch <INPUT_DIR> [OUTPUT_DIR] [MAX_WIDTH] [QUALITY]"
      cmd_batch "$@"
      ;;
    help | --help | -h)
      usage
      ;;
    *)
      die "unknown command: ${command} (run with 'help' for usage)"
      ;;
  esac
}

main "$@"
