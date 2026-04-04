#!/usr/bin/env bash

CACHE_DIR="$HOME/.cache/brightness"
STATE_FILE="$CACHE_DIR/monitor_brightness_state.ddc"
INTERNAL_FILE="$CACHE_DIR/monitor_brightness_state.internal"

log_debug() {
	if [[ ${DEBUG:-} == "1" || ${DEBUG,,} == "true" ]]; then
		echo "[DEBUG] $*" >&2
	fi
}

get_buses() {
	log_debug "Detecting I2C buses"
	ddcutil detect 2>/dev/null | awk '/I2C bus:/ {print $3}' | sed 's|/dev/i2c-||'
}

save_and_dim() {
	log_debug "Starting save_and_dim"
	mkdir -p "$CACHE_DIR"
	log_debug "Ensured cache directory exists: $CACHE_DIR"
	rm -f "$STATE_FILE" "$INTERNAL_FILE"
	log_debug "Cleared previous state files: $STATE_FILE, $INTERNAL_FILE"

	# Save internal brightness
	brightnessctl -m >"$INTERNAL_FILE" 2>/dev/null
	log_debug "Saved internal brightness to $INTERNAL_FILE"

	# Save DDC brightness as bus:value
	for bus in $(get_buses); do
		log_debug "Reading DDC value for bus $bus"
		value=$(ddcutil -b "$bus" getvcp 10 2>/dev/null |
			grep -oP 'current value\s*=\s*\K[0-9]+')
		if [[ $value =~ ^[0-9]+$ ]]; then
			echo "$bus:$value" >>"$STATE_FILE"
			log_debug "Saved DDC bus $bus value $value to $STATE_FILE"
		else
			log_debug "Skipping bus $bus: no valid value"
		fi
	done

	# Dim internal
	backlight=$(brightnessctl -l | awk '/backlight/ {print $1; exit}')
	if [ -n "$backlight" ]; then
		brightnessctl -d "$backlight" set 10 2>/dev/null
		log_debug "Dimmed internal backlight $backlight to 10"
	else
		log_debug "No internal backlight device found"
	fi

	# Dim DDC
	for bus in $(get_buses); do
		ddcutil -b "$bus" setvcp 10 10 >/dev/null 2>&1
		log_debug "Dimmed DDC bus $bus to 10"
	done
	log_debug "Finished save_and_dim"
}

restore() {
	log_debug "Starting restore"
	# Restore internal
	if [ -f "$INTERNAL_FILE" ]; then
		brightnessctl -m <"$INTERNAL_FILE" >/dev/null 2>/dev/null
		log_debug "Restored internal brightness from $INTERNAL_FILE"
	else
		log_debug "Internal state file not found: $INTERNAL_FILE"
	fi

	# Restore DDC
	if [ -f "$STATE_FILE" ]; then
		while IFS=: read -r bus value; do
			if [[ $value =~ ^[0-9]+$ ]]; then
				ddcutil -b "$bus" setvcp 10 "$value" >/dev/null 2>&1
				log_debug "Restored DDC bus $bus to $value"
			else
				log_debug "Skipping invalid DDC value for bus $bus: '$value'"
			fi
		done <"$STATE_FILE"
		log_debug "Restored DDC values from $STATE_FILE"
	else
		log_debug "State file not found: $STATE_FILE"
	fi

	# Clean up state files
	rm -f "$STATE_FILE" "$INTERNAL_FILE"
	log_debug "Removed state files: $STATE_FILE, $INTERNAL_FILE"
	log_debug "Finished restore"
}

case "$1" in
dim) save_and_dim ;;
restore) restore ;;
esac
