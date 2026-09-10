source ./is_gitRepo.bash
source ../components/component_usage.bash
process_cliStart() {
	local -n _show_files=$1
	shift

	local colors=true

	# Colors only when stdout is a terminal.
	if [[ ! -t 1 ]]; then
		colors=false
	fi

	while (($#)); do
		case "$1" in
			-f)
				_show_files=true
				;;

			-c|--color|--colors)
				colors=true
				;;

			-fc|-cf)
				_show_files=true
				colors=true
				;;

			-v|--version)
				echo "$VERSION"
				exit 0
				;;

			-h|--help|help)
				component_usage
				exit 0
				;;

			--)
				shift
				break
				;;

			-*)
				echo "Invalid option: $1." >&2
				echo "Try '$0 --help' for usage." >&2
				exit 1
				;;

			*)
				echo "Unexpected argument: $1." >&2
				echo "Try '$0 --help' for usage." >&2
				exit 1
				;;
		esac

		shift
	done

	# Reject positional arguments unless you intend to support them.
	if (($#)); then
		echo "Unexpected argument: $1." >&2
		echo "Try '$0 --help' for usage." >&2
		exit 1
	fi

	is_gitRepo

	if [[ "$colors" == false ]]; then
		COLOR_ACCENT=''
		COLOR_SECTION=''
		COLOR_SECTION_ALT=''
		COLOR_STRONG=''
		COLOR_OK=''
		COLOR_WARN=''
		COLOR_KO=''
		COLOR_NOTE=''
		COLOR_RESET=''
		COLOR_DIM=''
	fi
}
