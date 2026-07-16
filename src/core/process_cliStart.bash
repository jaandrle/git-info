source ./is_gitRepo.bash
source ../components/component_usage.bash
process_cliStart(){
	local -n _show_files=$1
	shift
	local opt="${1:-}"
	if [[ "$opt" == "--version" || "$opt" == "-v" ]]; then
		echo "$VERSION"
		exit 0
	fi
	if [[ "$opt" == "help" || "$opt" == "--help" || "$opt" == "-h" ]]; then
		component_usage
		exit 0
	fi
	is_gitRepo
	# Parse flags
	while getopts "f" opt; do
		case $opt in
			f)
				_show_files=true
				;;
			?)
				[[ -n "$OPTARG" ]] && \
					echo "Invalid option: -${OPTARG}." >&2
				exit 1
				;;
		esac
	done
}
