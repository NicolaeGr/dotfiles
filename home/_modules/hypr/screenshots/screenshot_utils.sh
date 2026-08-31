#!/usr/bin/env zsh
set -euo pipefail

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/hyprshot"
OUT_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
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

get_active_window_geometry() {
	hyprctl activewindow -j | jq -r '
        if .at then "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])" else empty end
    '
}

launch_satty() {
	local tmp="$1"
	local out="$2"

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

	# Only notify if Satty actually saved the file to OUT_DIR
	if [[ -f $out ]]; then
		notify "Saved & copied"
	else
		notify "Copied to clipboard (Discarded)"
	fi

	rm -f "$tmp"
}

shot_full() {
	local geom tmp out
	geom="$(get_active_monitor_geometry)"
	[[ -z $geom ]] && {
		notify "Could not determine active monitor"
		return 1
	}

	tmp="$(mktemp "$CACHE_DIR/shot-XXXXXX.png")"
	out="$OUT_DIR/$(date '+%F-%H%M%S')_full.png"

	grim -g "$geom" "$tmp"
	launch_satty "$tmp" "$out"
}

shot_region() {
	local freeze="${1:-false}"
	local tmp out region hyprpicker_pid=""

	tmp="$(mktemp "$CACHE_DIR/shot-XXXXXX.png")"
	out="$OUT_DIR/$(date '+%F-%H%M%S')_region.png"

	if [[ $freeze == "true" ]]; then
		# Freeze screen instantly via layer-shell
		hyprpicker -r -z &
		hyprpicker_pid=$!
		sleep 0.05 # Micro-delay to ensure layer-shell captures current frame
	fi

	# Run slurp to select the area
	if ! region="$(slurp)"; then
		[[ -n $hyprpicker_pid ]] && kill "$hyprpicker_pid" 2>/dev/null
		rm -f "$tmp"
		return 1
	fi

	# Kill the freeze overlay immediately once selection is made
	if [[ -n $hyprpicker_pid ]]; then
		kill "$hyprpicker_pid" 2>/dev/null
	fi

	grim -g "$region" "$tmp"
	launch_satty "$tmp" "$out"
}

shot_window() {
	local geom tmp out
	geom="$(get_active_window_geometry)"
	[[ -z $geom ]] && {
		notify "Could not find active window"
		return 1
	}

	tmp="$(mktemp "$CACHE_DIR/shot-XXXXXX.png")"
	out="$OUT_DIR/$(date '+%F-%H%M%S')_window.png"

	grim -g "$geom" "$tmp"
	launch_satty "$tmp" "$out"
}

case "${1:-}" in
full)
	shot_full
	;;
region)
	shot_region false
	;;
freeze)
	shot_region true
	;;
window)
	shot_window
	;;
*)
	echo "Usage: $0 {full|region|freeze|window}"
	exit 1
	;;
esac
