#!/bin/bash

# Paths
WALLPAPER_DIR="$HOME/Pictures/Walls"
THUMB_DIR="$HOME/.cache/wallpaper_thumbs"
THUMB_SIZE="512x512"  # square OR change to 512x288 for wide format
mkdir -p "$THUMB_DIR"

# Generate thumbnails (PNG format) - FIXED to completely fill boxes
for img in "$WALLPAPER_DIR"/*.{jpg,jpeg,png}; do
    [ -e "$img" ] || continue
    base="$(basename "$img")"
    thumb="$THUMB_DIR/$base.png"
    if [ ! -f "$thumb" ]; then
        # CHANGED: Use crop instead of extent to completely fill the box
        magick "$img" -resize "$THUMB_SIZE^" -gravity center -extent "$THUMB_SIZE" "$thumb"
    fi
done

# Build Rofi list with icon and minimal text
choices=""
for img in "$WALLPAPER_DIR"/*.{jpg,jpeg,png}; do
    [ -e "$img" ] || continue
    base="$(basename "$img")"
    thumb="$THUMB_DIR/$base.png"
    
    # Use empty string as display text - no visible label
    choices+="\x00icon\x1f$thumb\x00info\x1f$img\n"
done

# Show Rofi with custom options to hide text better
chosen=$(echo -e "$choices" | rofi \
    -dmenu -show-icons -theme ~/.config/rofi/themes/bottom-dock.rasi \
    -i -p "Wallpaper" \
    -format 'i' \
    -theme-str 'element { padding: 0px; margin: 2px; border: 0px; } element-icon { padding: 0px; margin: 0px; border: 0px; size: 300px; }')

[ -z "$chosen" ] && exit

# Get the actual file path using rofi's info field
selected_img=""
current_index=0
for img in "$WALLPAPER_DIR"/*.{jpg,jpeg,png}; do
    [ -e "$img" ] || continue
    if [ "$current_index" -eq "$chosen" ]; then
        selected_img="$img"
        break
    fi
    ((current_index++))
done

# Check if file exists
if [ ! -f "$selected_img" ]; then
    echo "Error: Selected wallpaper not found: $selected_img"
    exit 1
fi

# Apply wallpaper and color scheme
swww img "$selected_img" --transition-type grow --transition-duration 1
wal -i "$selected_img"
