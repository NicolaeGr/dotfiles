#!/usr/bin/env bash
set -euo pipefail

SELF=$(readlink -f -- "${BASH_SOURCE[0]}")
ROOT=$(cd -- "$(dirname -- "$SELF")/.." && pwd)
THEMES="$ROOT/themes"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/ht"
ACTIVE="$STATE/active"
APPLIED="$STATE/applied"
SELECTED="$STATE/theme"
DEFAULT="@default@"

die() {
	printf 'ht: %s\n' "$*" >&2
	exit 1
}

usage() {
	cat <<EOF
Usage: ht <action>

Actions:
  list [--json]         List themes and the active one
  set <theme>           Apply a theme
  reload [--if-changed] Reapply the active theme

The aliases ht-list, ht-set and ht-reload call the same actions.
EOF
}

selected_theme() {
	# The selected name is stored separately from the active symlink so a
	# rebuild or GC cannot make an existing selection look unset.
	if [[ -f $SELECTED ]]; then
		printf '%s' "$(<"$SELECTED")"
	elif [[ -L $ACTIVE ]]; then
		basename -- "$(readlink -f -- "$ACTIVE" 2>/dev/null || true)"
	fi
}

list_themes() {
	local dir theme selected

	selected=$(selected_theme)

	printf 'Themes:\n'
	for dir in "$THEMES"/*; do
		[[ -d $dir ]] || continue
		theme="${dir##*/}"
		if [[ $theme == "$selected" ]]; then
			printf '  %s (active)\n' "$theme"
		else
			printf '  %s\n' "$theme"
		fi
	done
}

json_string() {
	local value=$1
	value=${value//\\/\\\\}
	value=${value//\"/\\\"}
	value=${value//$'\n'/\\n}
	value=${value//$'\r'/\\r}
	value=${value//$'\t'/\\t}
	printf '"%s"' "$value"
}

json_fields() {
	local dir=$1 theme=$2 selected=$3 variant badge

	variant="dark"
	[[ -f $dir/variant ]] && variant=$(<"$dir/variant")

	badge=""
	[[ $theme == "$selected" ]] && badge="active"

	printf '{"id":%s,"name":%s,"description":%s,"thumbnail":%s,"badge":%s,"theme":%s}\n' \
		"$(json_string "$theme")" \
		"$(json_string "$theme")" \
		"$(json_string "$variant")" \
		"$(json_string "$dir/preview.svg")" \
		"$(json_string "$badge")" \
		"$(json_string "$theme")"
}

list_themes_json() {
	local dir theme selected

	selected=$(selected_theme)

	# The active theme comes first so client-side search shows the current
	# selection before the rest of the list when the query is empty.
	for dir in "$THEMES"/*; do
		[[ -d $dir ]] || continue
		theme="${dir##*/}"
		[[ $theme == "$selected" ]] || continue
		json_fields "$dir" "$theme" "$selected"
	done

	for dir in "$THEMES"/*; do
		[[ -d $dir ]] || continue
		theme="${dir##*/}"
		[[ $theme != "$selected" ]] || continue
		json_fields "$dir" "$theme" "$selected"
	done
}

apply_theme() {
	local theme="$1"
	local if_changed="$2"
	local target="$THEMES/$theme"
	local hook
	local -a failed=()

	[[ -n $theme ]] || die "no theme selected"
	[[ -d $target ]] || die "unknown theme: $theme"

	mkdir -p "$STATE"

	if command -v flock >/dev/null 2>&1; then
		exec 9>"$STATE/lock"
		flock 9
	fi

	ln -sfn "$target" "$STATE/active.next.$$"
	mv -Tf "$STATE/active.next.$$" "$ACTIVE"
	printf '%s\n' "$theme" >"$SELECTED.tmp"
	mv -f "$SELECTED.tmp" "$SELECTED"

	# Re-running the hooks is skippable, repairing the state is not. This
	# keeps reload pointed at the current store after a rebuild.
	if ((if_changed)) && [[ -f $APPLIED && $(<"$APPLIED") == "$target" ]]; then
		return 0
	fi

	printf '%s\n' "$target" >"$APPLIED.tmp"
	mv -f "$APPLIED.tmp" "$APPLIED"

	export HT_THEME="$theme"
	export HT_THEME_DIR="$target"
	export HT_ACTIVE="$ACTIVE"
	export HT_ROOT="$ROOT"
	export HT_VARIANT

	if [[ -f $target/variant ]]; then
		HT_VARIANT=$(<"$target/variant")
	else
		HT_VARIANT=$(
			awk -F= '/^[[:space:]]*(mode|theme_type)[[:space:]]*=/ {
          gsub(/[ "\047]/, "", $2)
          print $2
          exit
        }' "$target/colors.toml" 2>/dev/null || true
		)
	fi
	HT_VARIANT="${HT_VARIANT:-dark}"

	shopt -s nullglob
	for hook in "$ROOT"/libexec/*.sh; do
		if ! "$hook"; then
			failed+=("${hook##*/}")
		fi
	done

	if ((${#failed[@]} > 0)); then
		printf 'ht: theme %s applied, but these hooks failed: %s\n' "$theme" "${failed[*]}" >&2
		return 1
	fi

	printf 'ht: %s (%s)\n' "$theme" "$HT_VARIANT"
}

action=""
if_changed=0
json=0

case "${0##*/}" in
ht-set)
	action=set
	;;
ht-reload)
	action=reload
	;;
ht-list)
	action=list
	;;
*)
	action="${1:-list}"
	if (($# > 0)); then
		shift
	fi
	;;
esac

args=("$@")

for arg in "${args[@]}"; do
	case "$arg" in
	-h | --help)
		usage
		exit 0
		;;
	esac
done

case "$action" in
list)
	for arg in "${args[@]}"; do
		if [[ $arg == "--json" ]]; then
			json=1
		fi
	done
	if ((json)); then
		list_themes_json
	else
		list_themes
	fi
	;;
set)
	apply_theme "${args[0]:-}" 0
	;;
reload)
	if ((${#args[@]} > 0)); then
		for arg in "${args[@]}"; do
			if [[ $arg == "--if-changed" ]]; then
				if_changed=1
			fi
		done
	fi
	if [[ -f $SELECTED ]]; then
		theme=$(<"$SELECTED")
	elif [[ -L $ACTIVE ]]; then
		theme=$(basename -- "$(readlink -f -- "$ACTIVE" 2>/dev/null || true)")
	else
		theme="$DEFAULT"
	fi

	if [[ -z $theme ]]; then
		theme="$DEFAULT"
	elif [[ ! -d $THEMES/$theme ]]; then
		printf 'ht: theme %s is no longer available, using %s\n' "$theme" "$DEFAULT" >&2
		theme="$DEFAULT"
	fi
	apply_theme "$theme" "$if_changed"
	;;
*)
	usage
	exit 2
	;;
esac
