#!/usr/bin/env bash
#
# Render one Omarchy-style .tpl file.
#
# The palette resolver and the template renderer follow
# omarchy-theme-color and omarchy-theme-set-templates, so a template from
# Omarchy's default/themed directory renders without changes.
set -euo pipefail

COLORS_FILE=""
TEMPLATE=""
OUTPUT=""
THEME_NAME="theme"

usage() {
	echo "Usage: render.sh --colors FILE --template FILE --output FILE [--name NAME]" >&2
}

while (($# > 0)); do
	case "$1" in
	--colors)
		COLORS_FILE="${2:-}"
		shift 2
		;;
	--template)
		TEMPLATE="${2:-}"
		shift 2
		;;
	--output)
		OUTPUT="${2:-}"
		shift 2
		;;
	--name)
		THEME_NAME="${2:-}"
		shift 2
		;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		usage
		exit 2
		;;
	esac
done

if [[ -z $COLORS_FILE || -z $TEMPLATE || -z $OUTPUT ]]; then
	usage
	exit 2
fi

if [[ ! -f $COLORS_FILE || ! -f $TEMPLATE ]]; then
	echo "render.sh: missing colors or template file" >&2
	exit 1
fi

declare -A C=()
declare -A V=()

mix_color() {
	local start="${1#\#}"
	local end="${2#\#}"
	local amount="$3"

	awk -v start="$start" -v end="$end" -v amount="$amount" '
    function hex_value(char) {
      return index("0123456789abcdef", tolower(char)) - 1
    }

    function hex_pair_to_int(hex, idx) {
      return hex_value(substr(hex, idx, 1)) * 16 + hex_value(substr(hex, idx + 1, 1))
    }

    BEGIN {
      if (amount ~ /%$/) {
        sub(/%$/, "", amount)
        amount = amount / 100
      } else {
        amount += 0
        if (amount > 1) amount = amount / 100
      }

      if (amount < 0) amount = 0
      if (amount > 1) amount = 1

      start_r = hex_pair_to_int(start, 1)
      start_g = hex_pair_to_int(start, 3)
      start_b = hex_pair_to_int(start, 5)
      end_r = hex_pair_to_int(end, 1)
      end_g = hex_pair_to_int(end, 3)
      end_b = hex_pair_to_int(end, 5)

      red = int(start_r * (1 - amount) + end_r * amount + 0.5)
      green = int(start_g * (1 - amount) + end_g * amount + 0.5)
      blue = int(start_b * (1 - amount) + end_b * amount + 0.5)

      printf "#%02x%02x%02x\n", red, green, blue
    }
  '
}

trim() {
	local value="$1"

	value="${value#"${value%%[![:space:]]*}"}"
	value="${value%"${value##*[![:space:]]}"}"
	REPLY="$value"
}

parse_colors_file() {
	local key value

	while IFS='=' read -r key value; do
		key="${key//[\"\' ]/}"
		[[ $key && $key != \#* ]] || continue

		if [[ $value == *[\"\']* ]]; then
			value="${value#*[\"\']}"
			value="${value%%[\"\']*}"
		else
			value="${value#"${value%%[![:space:]]*}"}"
			value="${value%"${value##*[![:space:]]}"}"
		fi

		if [[ ! $key =~ ^[A-Za-z0-9_-]+$ ]]; then
			echo "render.sh: skipping key with unsupported characters: $key" >&2
			continue
		fi

		if [[ ! $value =~ ^[A-Za-z0-9#(),._+/%\ -]*$ ]]; then
			echo "render.sh: skipping $key: unsupported characters in value" >&2
			continue
		fi

		C["$key"]="$value"
	done <"$COLORS_FILE"
}

alias_color() {
	local key="$1"
	local fallback="$2"

	[[ ${C["$key"]:-} ]] || C["$key"]="${C["$fallback"]:-}"
}

resolve_mode() {
	local bg_hex lum

	[[ ${C[mode]:-} ]] || C[mode]="${C[theme_type]:-}"
	[[ ${C[mode]:-} ]] && return

	if [[ -f "$(dirname "$COLORS_FILE")/light.mode" ]]; then
		C[mode]="light"
	elif [[ ${C[background]:-} =~ ^#[0-9A-Fa-f]{6}$ ]]; then
		bg_hex="${C[background]#\#}"
		lum=$(($(printf "%d" "0x${bg_hex:0:2}") + $(printf "%d" "0x${bg_hex:2:2}") + $(printf "%d" "0x${bg_hex:4:2}")))
		((lum > 382)) && C[mode]="light" || C[mode]="dark"
	else
		C[mode]="dark"
	fi
}

resolve_colors() {
	local key

	declare -A legacy_palette_alias=(
		[background]=bg
		[dark_background]=dark_bg
		[darker_background]=darker_bg
		[lighter_background]=lighter_bg
		[foreground]=fg
		[dark_foreground]=dark_fg
		[light_foreground]=light_fg
		[bright_foreground]=bright_fg
	)
	for key in "${!legacy_palette_alias[@]}"; do
		alias_color "$key" "${legacy_palette_alias[$key]}"
	done

	[[ ${C[background]:-} ]] || C[background]="${C[color0]:-}"
	[[ ${C[foreground]:-} ]] || C[foreground]="${C[color7]:-}"
	[[ ${C[background]:-} ]] && C[color0]="${C[background]}"
	[[ ${C[foreground]:-} ]] && C[color7]="${C[foreground]}"

	declare -A legacy_alias=(
		[red]=color1
		[green]=color2
		[yellow]=color3
		[blue]=color4
		[magenta]=color5
		[cyan]=color6
		[bright_red]=color9
		[bright_green]=color10
		[bright_yellow]=color11
		[bright_blue]=color12
		[bright_magenta]=color13
		[bright_cyan]=color14
	)
	for key in "${!legacy_alias[@]}"; do
		alias_color "$key" "${legacy_alias[$key]}"
	done
	alias_color magenta purple
	alias_color bright_magenta bright_purple

	[[ ${C[light_foreground]:-} ]] || C[light_foreground]="${C[color7]:-${C[foreground]:-}}"
	[[ ${C[bright_foreground]:-} ]] || C[bright_foreground]="${C[color15]:-${C[foreground]:-}}"
	C[cursor]="${C[bright_foreground]:-}"
	[[ ${C[lighter_background]:-} ]] || C[lighter_background]="${C[color0]:-${C[background]:-}}"
	[[ ${C[dark_foreground]:-} ]] || C[dark_foreground]="${C[color8]:-${C[foreground]:-}}"
	[[ ${C[muted]:-} ]] || C[muted]="${C[color8]:-${C[dark_foreground]:-}}"
	[[ ${C[selection]:-} ]] || C[selection]="${C[selection_background]:-${C[color8]:-${C[color0]:-${C[background]:-}}}}"
	[[ ${C[selection_background]:-} ]] || C[selection_background]="${C[selection]:-}"
	[[ ${C[selection_foreground]:-} ]] || C[selection_foreground]="${C[bright_foreground]:-}"
	[[ ${C[orange]:-} ]] || C[orange]="${C[yellow]:-}"
	[[ ${C[brown]:-} ]] || C[brown]="$(mix_color "${C[orange]:-}" "#000000" 50%)"

	[[ ${C[dark_background]:-} ]] || C[dark_background]="$(mix_color "${C[background]:-}" "#000000" 25%)"
	[[ ${C[darker_background]:-} ]] || C[darker_background]="$(mix_color "${C[background]:-}" "#000000" 50%)"
	[[ ${C[bright_red]:-} ]] || C[bright_red]="$(mix_color "${C[red]:-}" "#ffffff" 20%)"
	[[ ${C[bright_yellow]:-} ]] || C[bright_yellow]="$(mix_color "${C[yellow]:-}" "#ffffff" 20%)"
	[[ ${C[bright_green]:-} ]] || C[bright_green]="$(mix_color "${C[green]:-}" "#ffffff" 20%)"
	[[ ${C[bright_cyan]:-} ]] || C[bright_cyan]="$(mix_color "${C[cyan]:-}" "#ffffff" 20%)"
	[[ ${C[bright_blue]:-} ]] || C[bright_blue]="$(mix_color "${C[blue]:-}" "#ffffff" 20%)"
	[[ ${C[bright_magenta]:-} ]] || C[bright_magenta]="$(mix_color "${C[magenta]:-}" "#ffffff" 20%)"
	alias_color purple magenta
	alias_color bright_purple bright_magenta

	declare -A ansi_alias=(
		[color0]=background
		[color1]=red
		[color2]=green
		[color3]=yellow
		[color4]=blue
		[color5]=magenta
		[color6]=cyan
		[color7]=foreground
		[color8]=muted
		[color9]=bright_red
		[color10]=bright_green
		[color11]=bright_yellow
		[color12]=bright_blue
		[color13]=bright_magenta
		[color14]=bright_cyan
		[color15]=bright_foreground
	)
	for key in "${!ansi_alias[@]}"; do
		alias_color "$key" "${ansi_alias[$key]}"
	done

	for key in "${!legacy_palette_alias[@]}"; do
		if [[ ${C["$key"]:-} ]]; then
			C["${legacy_palette_alias[$key]}"]="${C["$key"]}"
		fi
	done

	resolve_mode
	C[theme_type]="${C[mode]}"
}

add_compat_colors() {
	local slug

	# Base16 names, so templates written against the old hjem engine keep
	# rendering. Values come from the Omarchy palette.
	[[ ${C[base00]:-} ]] || C[base00]="${C[background]:-}"
	if [[ ${C[mode]:-dark} == "light" ]]; then
		[[ ${C[base01]:-} ]] || C[base01]="${C[dark_background]:-${C[lighter_background]:-${C[background]:-}}}"
	else
		[[ ${C[base01]:-} ]] || C[base01]="${C[lighter_background]:-${C[dark_background]:-${C[background]:-}}}"
	fi
	[[ ${C[base02]:-} ]] || C[base02]="${C[selection]:-${C[lighter_background]:-${C[background]:-}}}"
	[[ ${C[base03]:-} ]] || C[base03]="${C[muted]:-${C[dark_foreground]:-}}"
	[[ ${C[base04]:-} ]] || C[base04]="${C[light_foreground]:-${C[foreground]:-}}"
	[[ ${C[base05]:-} ]] || C[base05]="${C[foreground]:-}"
	[[ ${C[base06]:-} ]] || C[base06]="${C[bright_foreground]:-${C[foreground]:-}}"
	[[ ${C[base07]:-} ]] || C[base07]="#ffffff"
	[[ ${C[base08]:-} ]] || C[base08]="${C[red]:-${C[foreground]:-}}"
	[[ ${C[base09]:-} ]] || C[base09]="${C[orange]:-${C[yellow]:-${C[foreground]:-}}}"
	[[ ${C[base0A]:-} ]] || C[base0A]="${C[yellow]:-${C[orange]:-${C[foreground]:-}}}"
	[[ ${C[base0B]:-} ]] || C[base0B]="${C[green]:-${C[foreground]:-}}"
	[[ ${C[base0C]:-} ]] || C[base0C]="${C[cyan]:-${C[foreground]:-}}"
	[[ ${C[base0D]:-} ]] || C[base0D]="${C[blue]:-${C[foreground]:-}}"
	[[ ${C[base0E]:-} ]] || C[base0E]="${C[magenta]:-${C[foreground]:-}}"
	[[ ${C[base0F]:-} ]] || C[base0F]="${C[brown]:-${C[orange]:-${C[foreground]:-}}}"

	slug="${THEME_NAME,,}"
	slug="${slug//[^a-z0-9]+/-}"
	slug="${slug#-}"
	slug="${slug%-}"

	C[name]="$THEME_NAME"
	C[variant]="${C[mode]:-dark}"
	C["scheme-name"]="$THEME_NAME"
	C["scheme-author"]="hjem"
	C["scheme-description"]="$THEME_NAME"
	C["scheme-slug"]="$slug"
	C["scheme-system"]="ht"
	if [[ ${C[mode]:-dark} == "light" ]]; then
		C[is_dark]="false"
	else
		C[is_dark]="true"
	fi
}

hex_to_rgb() {
	local hex="${1#\#}"

	printf -v REPLY "%d,%d,%d" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

add_template_value() {
	local key="$1"
	local value="$2"

	V["{{ $key }}"]="$value"
	V["{{ ${key}_strip }}"]="${value#\#}"
	V["{{ $key-hex }}"]="${value#\#}"

	if [[ $value =~ ^#[0-9A-Fa-f]{6}$ ]]; then
		hex_to_rgb "$value"
		V["{{ ${key}_rgb }}"]="$REPLY"
	fi
}

resolve_theme_ref() {
	local ref="$1"
	local fallback="${2:-}"

	if [[ -n ${C["$ref"]+_} ]]; then
		REPLY="${C["$ref"]}"
	elif [[ -n $fallback && -n ${C["$fallback"]+_} ]]; then
		REPLY="${C["$fallback"]}"
	elif [[ -n $fallback ]]; then
		REPLY="$fallback"
	else
		REPLY="$ref"
	fi
}

resolve_gradient_color() {
	trim "$1"
	if [[ -n ${C["$REPLY"]+_} ]]; then
		REPLY="${C["$REPLY"]}"
	fi
}

parse_gradient() {
	local spec="$1"
	local part
	local -a parts

	GRADIENT_COLORS=()
	GRADIENT_ANGLE=""

	read -ra parts <<<"$spec"
	for part in "${parts[@]}"; do
		[[ -n $part ]] || continue

		if [[ $part =~ ^-?[0-9]+([.][0-9]+)?deg$ ]]; then
			GRADIENT_ANGLE="${part%deg}"
		else
			resolve_gradient_color "$part"
			GRADIENT_COLORS+=("$REPLY")
		fi
	done
}

color_to_shell_hex() {
	local color r g b

	resolve_gradient_color "$1"
	color="$REPLY"

	if [[ $color =~ ^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$ ]]; then
		REPLY="#${color:1:6}"
	elif [[ $color =~ ^[Rr][Gg][Bb][Aa]?\(([0-9A-Fa-f]{6})([0-9A-Fa-f]{2})?\)$ ]]; then
		REPLY="#${BASH_REMATCH[1]}"
	elif [[ $color =~ ^[Rr][Gg][Bb][Aa]?\(([0-9]+),([0-9]+),([0-9]+)(,[0-9.]+)?\)$ ]]; then
		r=${BASH_REMATCH[1]}
		g=${BASH_REMATCH[2]}
		b=${BASH_REMATCH[3]}
		((r > 255)) && r=255
		((g > 255)) && g=255
		((b > 255)) && b=255
		printf -v REPLY "#%02x%02x%02x" "$r" "$g" "$b"
	elif [[ $color =~ ^0x[0-9A-Fa-f]{8}$ ]]; then
		REPLY="#${color:2:6}"
	else
		REPLY="$color"
	fi
}

hypr_gradient_value() {
	local spec index value

	resolve_theme_ref "$1" "${2:-}"
	spec="$REPLY"
	parse_gradient "$spec"

	if ((${#GRADIENT_COLORS[@]} == 0)); then
		REPLY="\"$spec\""
	elif ((${#GRADIENT_COLORS[@]} == 1)); then
		REPLY="\"${GRADIENT_COLORS[0]}\""
	else
		value='{ colors = {'
		for index in "${!GRADIENT_COLORS[@]}"; do
			((index > 0)) && value+=','
			value+=" \"${GRADIENT_COLORS[$index]}\""
		done
		value+=' }'
		[[ -n $GRADIENT_ANGLE ]] && value+=", angle = $GRADIENT_ANGLE"
		REPLY="$value }"
	fi
}

gradient_start_value() {
	local spec

	resolve_theme_ref "$1" "${2:-}"
	spec="$REPLY"
	parse_gradient "$spec"

	if ((${#GRADIENT_COLORS[@]} == 0)); then
		color_to_shell_hex "$spec"
	else
		color_to_shell_hex "${GRADIENT_COLORS[0]}"
	fi
}

shell_gradient_value() {
	local spec index value=""

	resolve_theme_ref "$1" "${2:-}"
	spec="$REPLY"
	parse_gradient "$spec"

	if ((${#GRADIENT_COLORS[@]} == 0)); then
		REPLY="$spec"
		return
	fi

	for index in "${!GRADIENT_COLORS[@]}"; do
		((index > 0)) && value+=" "
		value+="${GRADIENT_COLORS[$index]}"
	done

	[[ -n $GRADIENT_ANGLE ]] && value+=" ${GRADIENT_ANGLE}deg"
	REPLY="$value"
}

add_mix_value() {
	local token="$1"
	local content fn start_key end_key amount start end value

	content="${token#\{\{}"
	content="${content%\}\}}"
	read -r fn start_key end_key amount <<<"$content"

	start="${C["$start_key"]:-}"
	end="${C["$end_key"]:-}"

	[[ $start =~ ^#[0-9A-Fa-f]{6}$ && $end =~ ^#[0-9A-Fa-f]{6}$ ]] || return 0
	[[ $fn == "mix" || $fn == "mix_strip" || $fn == "mix_rgb" ]] || return 0

	value="$(mix_color "$start" "$end" "$amount")"

	case "$fn" in
	mix_strip)
		value="${value#\#}"
		;;
	mix_rgb)
		hex_to_rgb "$value"
		value="$REPLY"
		;;
	esac

	V["$token"]="$value"
}

add_gradient_function_value() {
	local token="$1"
	local content fn key fallback

	content="${token#\{\{}"
	content="${content%\}\}}"
	read -r fn key fallback <<<"$content"

	case "$fn" in
	hypr_gradient)
		hypr_gradient_value "$key" "$fallback"
		;;
	gradient_start)
		gradient_start_value "$key" "$fallback"
		;;
	shell_gradient)
		shell_gradient_value "$key" "$fallback"
		;;
	*)
		return 0
		;;
	esac

	V["$token"]="$REPLY"
}

add_function_values() {
	local token
	local -A seen=()
	local mix_pattern gradient_pattern

	mix_pattern='\{\{[[:space:]]*mix(_strip|_rgb)?[[:space:]]+[A-Za-z0-9_]+[[:space:]]+[A-Za-z0-9_]+[[:space:]]+[0-9]+([.][0-9]+)?%?[[:space:]]*\}\}'
	gradient_pattern='\{\{[[:space:]]*(hypr_gradient|gradient_start|shell_gradient)[[:space:]]+[^}]+[[:space:]]*\}\}'

	while IFS= read -r token; do
		[[ -n ${seen[$token]:-} ]] && continue
		seen[$token]=1

		if [[ $token =~ ^$mix_pattern$ ]]; then
			add_mix_value "$token"
		else
			add_gradient_function_value "$token"
		fi
	done < <(grep -hEo "$mix_pattern|$gradient_pattern" "$TEMPLATE" 2>/dev/null || true)
}

render() {
	local value_table

	value_table="$(mktemp)"
	trap 'rm -f "$value_table"' RETURN

	local key
	for key in "${!V[@]}"; do
		printf '%s\037%s\n' "$key" "${V[$key]}" >>"$value_table"
	done

	mkdir -p "$(dirname "$OUTPUT")"

	awk -v value_table="$value_table" '
    function normalize(token, inner) {
      inner = token
      sub(/^\{\{/, "", inner)
      sub(/\}\}$/, "", inner)
      gsub(/^[ \t]+|[ \t]+$/, "", inner)
      return "{{ " inner " }}"
    }

    function render_line(line,    out, open, span, token, key) {
      out = ""
      while ((open = index(line, "{{")) > 0) {
        span = index(substr(line, open + 2), "}}")
        if (span == 0) break

        token = substr(line, open, span + 3)
        key = token
        if (!(key in values)) key = normalize(token)

        if (key in values) {
          out = out substr(line, 1, open - 1) values[key]
          line = substr(line, open + length(token))
        } else {
          out = out substr(line, 1, open)
          line = substr(line, open + 1)
        }
      }
      return out line
    }

    BEGIN {
      while ((getline row < value_table) > 0) {
        sep = index(row, "\037")
        values[substr(row, 1, sep - 1)] = substr(row, sep + 1)
      }
      close(value_table)
    }

    {
      printf "%s%s", render_line($0), RT
    }
  ' "$TEMPLATE" >"$OUTPUT"
}

parse_colors_file
resolve_colors
add_compat_colors

for key in "${!C[@]}"; do
	add_template_value "$key" "${C["$key"]}"
done

add_function_values
render
