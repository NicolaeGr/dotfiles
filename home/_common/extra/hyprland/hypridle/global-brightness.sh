#!/usr/bin/env bash

STATE_FILE="/tmp/monitor_brightness_state.ddc"
INTERNAL_FILE="/tmp/monitor_brightness_state.internal"

get_buses() {
	ddcutil detect 2>/dev/null | awk '/I2C bus:/ {print $3}' | sed 's|/dev/i2c-||'
}

save_and_dim() {
	rm -f "$STATE_FILE" "$INTERNAL_FILE"

	# Save internal brightness
	brightnessctl -m >"$INTERNAL_FILE" 2>/dev/null

	# Save DDC brightness as bus:value
	for bus in $(get_buses); do
		value=$(ddcutil -b "$bus" getvcp 10 2>/dev/null |
			grep -oP 'current value\s*=\s*\K[0-9]+')
		if [[ $value =~ ^[0-9]+$ ]]; then
			echo "$bus:$value" >>"$STATE_FILE"
		fi
	done

	# Dim internal
	backlight=$(brightnessctl -l | awk '/backlight/ {print $1; exit}')
	[ -n "$backlight" ] && brightnessctl -d "$backlight" set 10 2>/dev/null

	# Dim DDC
	for bus in $(get_buses); do
		ddcutil -b "$bus" setvcp 10 10 >/dev/null 2>&1
	done
}

restore() {
	# Restore internal
	if [ -f "$INTERNAL_FILE" ]; then
		brightnessctl -m <"$INTERNAL_FILE" 2>/dev/null
	fi

	# Restore DDC
	if [ -f "$STATE_FILE" ]; then
		while IFS=: read -r bus value; do
			[[ $value =~ ^[0-9]+$ ]] &&
				ddcutil -b "$bus" setvcp 10 "$value" >/dev/null 2>&1
		done <"$STATE_FILE"
	fi

	# Clean up state files
	rm -f "$STATE_FILE" "$INTERNAL_FILE"
}

case "$1" in
dim) save_and_dim ;;
restore) restore ;;
esac
