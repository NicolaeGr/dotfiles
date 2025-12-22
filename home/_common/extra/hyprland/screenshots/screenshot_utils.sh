#!/usr/bin/env zsh
export WLR_RENDERER_ALLOW_SOFTWARE=1
set -euo pipefail

local home_relative_img_path=".cache/hyprshot"
_tmp() {
	local tmp_dir="${HOME}/${home_relative_img_path}"
	mkdir -p "$tmp_dir"
	echo "$tmp_dir/tmp.png"
}

_out() {
	local suffix=${1:-screenshot}
	local dir="$HOME/Media/images/Screenshots"
	mkdir -p "$dir"
	echo "$dir/$(date '+%F-%H%M%S')_${suffix}.png"
}

_notify() {
	local msg="$1"
	local custom_icon="$HOME/.config/hypr/icons/screenshot.png"

	if [[ -f $custom_icon ]]; then
		notify-send -i "$custom_icon" "Screenshot" "$msg"
	else
		notify-send -i camera-photo "Screenshot" "$msg"
	fi
}

satty_edit() {
	local input="$1"
	local output="$2"

	satty \
		--filename "$input" \
		--output-filename "$output" \
		--save-after-copy \
		--early-exit \
		--copy-command "wl-copy" \
		--disable-notifications

	[[ -f $output ]]
}

full() {
	local tmp=$(_tmp)
	local out=$(_out full)

	hyprshot --freeze --mode output --silent -o /home/nicolae -f "$home_relative_img_path/tmp.png"

	if satty_edit "$tmp" "$out"; then
		_notify "Full saved & copied"
	else
		echo "Cancelled"
	fi

	rm -f "$tmp"
}

region() {
	local tmp=$(_tmp)
	local out=$(_out region)

	hyprshot --freeze --mode region --silent -o /home/nicolae -f "$home_relative_img_path/tmp.png"

	if ! [[ -s $tmp ]]; then
		echo "Selection cancelled"
		rm -f "$tmp"
		return 1
	fi

	if satty_edit "$tmp" "$out"; then
		_notify "Region saved & copied"
	fi

	rm -f "$tmp"
}

window() {
	local suffix=${1:-window}
	local tmp=$(_tmp)
	local out=$(_out "$suffix")

	hyprshot --freeze --mode window --silent -o /home/nicolae -f "$home_relative_img_path/tmp.png"

	if satty_edit "$tmp" "$out"; then
		_notify "Window saved & copied"
	else
		echo "Cancelled"
	fi

	rm -f "$tmp"
}

case "${1:-}" in
full) full ;;
region) region ;;
window) window "${2:-}" ;;
*)
	echo "Usage: $0 {full|region|window} [suffix]"
	exit 1
	;;
esac
