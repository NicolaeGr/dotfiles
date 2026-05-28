#!/usr/bin/env zsh
set -euo pipefail

export WLR_RENDERER_ALLOW_SOFTWARE=1

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

wait_for_file() {
	local file="$1"

	# wait until file exists and has content
	for _ in {1..100}; do
		[[ -s $file ]] && return 0
		sleep 0.05
	done

	return 1
}

shot() {
	local mode="$1"
	local suffix="${2:-$mode}"

	local tmp
	tmp="$(mktemp "$CACHE_DIR/shot-XXXXXX.png")"

	local out="$OUT_DIR/$(date '+%F-%H%M%S')_${suffix}.png"

	hyprshot \
		--freeze \
		--silent \
		--mode "$mode" \
		-o "$CACHE_DIR" \
		-f "$(basename "$tmp")"

	if ! wait_for_file "$tmp"; then
		notify "Screenshot failed"
		rm -f "$tmp"
		return 1
	fi

	satty \
		--filename "$tmp" \
		--output-filename "$out" \
		--save-after-copy \
		--early-exit \
		--copy-command "wl-copy" \
		--disable-notifications

	if [[ -f $out ]]; then
		notify "Saved & copied"
	fi

	rm -f "$tmp"
}

case "${1:-}" in
full)
	shot output full
	;;
region)
	shot region region
	;;
window)
	shot window "${2:-window}"
	;;
*)
	echo "Usage: $0 {full|region|window}"
	exit 1
	;;
esac
