#!/usr/bin/env bash
set -euo pipefail

min_width="${WALLPAPER_MIN_WIDTH:-1280}"
min_height="${WALLPAPER_MIN_HEIGHT:-720}"
max_bytes="${WALLPAPER_MAX_BYTES:-20971520}"

if command -v identify >/dev/null 2>&1; then
  identify_cmd=(identify)
elif command -v magick >/dev/null 2>&1; then
  identify_cmd=(magick identify)
else
  echo "wallpaper check: ImageMagick is required (identify or magick)." >&2
  exit 1
fi

failures=0
checked=0

check_file() {
  local file="$1"
  local size dimensions width height
  if size="$(stat -c '%s' -- "$file" 2>/dev/null)"; then
    :
  else
    size="$(stat -f '%z' "$file")"
  fi

  if (( size > max_bytes )); then
    printf 'REJECT %s: %s bytes exceeds %s bytes\n' "$file" "$size" "$max_bytes" >&2
    failures=$((failures + 1))
    return
  fi

  if ! dimensions="$("${identify_cmd[@]}" -format '%w %h' -- "$file" 2>/dev/null)"; then
    printf 'REJECT %s: file is not a readable image\n' "$file" >&2
    failures=$((failures + 1))
    return
  fi

  read -r width height <<< "$dimensions"
  if (( width < min_width || height < min_height )); then
    printf 'REJECT %s: dimensions %sx%s are below minimum %sx%s\n' \
      "$file" "$width" "$height" "$min_width" "$min_height" >&2
    failures=$((failures + 1))
    return
  fi

  checked=$((checked + 1))
}

while IFS= read -r -d '' file; do
  check_file "$file"
done < <(
  git diff --cached --name-only -z --diff-filter=ACMR -- \
    '*.jpg' '*.jpeg' '*.png' '*.webp' '*.JPG' '*.JPEG' '*.PNG' '*.WEBP'
)

if (( failures > 0 )); then
  printf 'wallpaper check: %s file(s) rejected; commit aborted.\n' "$failures" >&2
  exit 1
fi

printf 'wallpaper check: %s staged image(s) passed.\n' "$checked"
