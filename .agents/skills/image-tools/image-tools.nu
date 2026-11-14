#!/usr/bin/env nu

def images-in [directory: path, extensions: list<string>] {
  let files = (
    ls $directory
    | where {|entry| ($entry.name | path expand | path type) == "file" }
    | get name
  )

  $extensions
  | each {|extension|
    $files
    | where {|file| ($file | path parse | get extension) == $extension }
    | sort
  }
  | flatten
}

def image-info [file: path] {
  ^magick identify -format '%f: %wx%h, %b\n' $file
}

# Download Pixiv images with gallery-dl authentication configured.
def "main download" [
  pixiv_id: string # Numeric Pixiv artwork ID.
  output_dir: path = "." # Directory for downloaded originals.
] {
  if $pixiv_id !~ '^\d+$' {
    error make {msg: $"invalid Pixiv ID: ($pixiv_id)"}
  }

  mkdir $output_dir
  print $"Downloading Pixiv #($pixiv_id)..."
  (
    ^gallery-dl $"https://www.pixiv.net/artworks/($pixiv_id)"
      --directory $output_dir
      --filename "{id}_p{num}.{extension}"
      --filter "extension in ('png', 'jpg', 'jpeg', 'webp')"
  )

  print $"\nDownloaded to: ($output_dir)"
  let files = (
    ls $output_dir
    | where {|entry| ($entry.name | path basename | str starts-with $pixiv_id) }
  )

  if ($files | is-empty) {
    print "(no files matched expected pattern)"
  } else {
    $files
  }
}

# Compress an image to WebP without upscaling.
def "main compress" [
  input: path # Source image.
  output_dir: path = "assets/images/article-covers" # Output directory.
  max_width: int = 1920 # Maximum width in pixels.
  quality: int = 85 # WebP quality from 0 to 100.
] {
  if ($input | path expand | path type) != "file" {
    error make {msg: $"file not found: ($input)"}
  }

  let stem = $input | path parse | get stem
  let output = $output_dir | path join $"($stem).webp"
  mkdir $output_dir
  (
    ^magick $input
      -resize $"($max_width)x>"
      -quality $quality
      $output
  )
  image-info $output
}

# Inspect image dimensions and file sizes with ImageMagick.
def "main info" [
  target: path # Image file or directory containing images.
] {
  if ($target | path expand | path type) == "dir" {
    for file in (images-in $target ["webp", "png", "jpg", "jpeg"]) {
      image-info $file
    }
  } else if ($target | path expand | path type) == "file" {
    image-info $target
  } else {
    error make {msg: $"not found: ($target)"}
  }
}

# Compress all PNG, JPG, JPEG and WebP images in a directory.
def "main batch" [
  input_dir: path # Directory containing source images.
  output_dir: path = "assets/images/article-covers" # Output directory.
  max_width: int = 1920 # Maximum width in pixels.
  quality: int = 85 # WebP quality from 0 to 100.
] {
  if ($input_dir | path expand | path type) != "dir" {
    error make {msg: $"directory not found: ($input_dir)"}
  }

  let files = images-in $input_dir ["png", "jpg", "jpeg", "webp"]

  for file in $files {
    main compress $file $output_dir $max_width $quality
  }

  print $"\nCompressed ($files | length) image\(s\) to ($output_dir)"
}

# Download, compress and inspect images from the repository root.
# Requires ImageMagick 7 for image operations and gallery-dl for downloads.
def main [] {
  help main
}
