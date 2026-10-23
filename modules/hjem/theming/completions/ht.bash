# bash completion for ht and its aliases.
_ht() {
	local exe cur root name dir base
	local -a themes

	exe=${COMP_WORDS[0]##*/}
	cur=${COMP_WORDS[COMP_CWORD]}
	root=$(dirname "$(dirname "$(readlink -f -- "$(type -P "${COMP_WORDS[0]}")")")")

	for dir in "$root"/themes/*/; do
		[[ -d $dir ]] || continue
		base=${dir%/}
		themes+=("${base##*/}")
	done

	case $exe in
	ht-set)
		COMPREPLY=($(compgen -W "${themes[*]}" -- "$cur"))
		return
		;;
	ht-reload)
		COMPREPLY=($(compgen -W "--if-changed" -- "$cur"))
		return
		;;
	ht-list)
		COMPREPLY=($(compgen -W "--help" -- "$cur"))
		return
		;;
	esac

	if ((COMP_CWORD == 1)); then
		COMPREPLY=($(compgen -W "list set reload --help" -- "$cur"))
		return
	fi

	name=${COMP_WORDS[1]}
	case $name in
	set) COMPREPLY=($(compgen -W "${themes[*]}" -- "$cur")) ;;
	reload) COMPREPLY=($(compgen -W "--if-changed" -- "$cur")) ;;
	esac
}

complete -F _ht ht ht-set ht-reload ht-list
