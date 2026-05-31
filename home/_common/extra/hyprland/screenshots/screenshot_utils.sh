#!/usr/bin/env zsh
set -euo pipefail

CACHE_DIR="$HOME/.cache/hyprshot"
OUT_DIR="$HOME/Media/images/Screenshots"
ICON="$HOME/.config/hypr/icons/screenshot.png"

mkdir -p "$CACHE_DIR" "$OUT_DIR"

notify() {
	local msg="$1"

	if [[ -f $ICON ]]; then
		notify-send -i "$ICON" "Screenshot" "$msg"
	else
		notify-send -i camera-photo "Screenshot" "$msg"
	fi
}

get_active_monitor_geometry() {
	hyprctl monitors -j | jq -r '
		.[] | select(.focused == true) |
		"\(.x),\(.y) \(.width)x\(.height)"
	'
}

shot_full() {
	local geom tmp out

	geom="$(get_active_monitor_geometry)"
	if [[ -z $geom ]]; then
		notify "Could not determine active monitor"
		return 1
	fi

	tmp="$(mktemp "$CACHE_DIR/shot-XXXXXX.png")"
	out="$OUT_DIR/$(date '+%F-%H%M%S')_full.png"

	grim -g "$geom" "$tmp"

	[[ -s $tmp ]] || {
		notify "Screenshot failed (empty image)"
		rm -f "$tmp"
		return 1
	}

	satty \
		--filename "$tmp" \
		--output-filename "$out" \
		--save-after-copy \
		--early-exit \
		--copy-command "wl-copy" \
		--disable-notifications

	notify "Saved & copied"
	rm -f "$tmp"
}

shot_region() {
	local tmp out region

	tmp="$(mktemp "$CACHE_DIR/shot-XXXXXX.png")"
	out="$OUT_DIR/$(date '+%F-%H%M%S')_region.png"

	region="$(slurp)" || {
		notify "Cancelled"
		rm -f "$tmp"
		return 1
	}

	grim -g "$region" "$tmp"

	[[ -s $tmp ]] || {
		notify "Screenshot failed"
		rm -f "$tmp"
		return 1
	}

	satty \
		--filename "$tmp" \
		--output-filename "$out" \
		--save-after-copy \
		--early-exit \
		--copy-command "wl-copy" \
		--disable-notifications

	notify "Saved & copied"
	rm -f "$tmp"
}

case "${1:-}" in
full)
	shot_full
	;;
region)
	shot_region
	;;
window)
	shot_region
	;;
*)
	echo "Usage: $0 {full|region|window}"
	exit 1
	;;
esac
