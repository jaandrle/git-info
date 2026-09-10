source ../ui/echo_header.bash
source ../ui/echo_file_entry.bash
component_staged(){
	local -r has_staged="$1"
	if [[ $has_staged == false ]]; then
		return
	fi
	local -n __staged_files_cache=$2
	echo_header 'staged' 'staged changes'
	while IFS= read -r file; do
		local STAT="${__staged_files_cache[$file]:0:1}"
		echo_file_entry "$STAT" "$file" 'staged'
	done < <(printf '%s\n' "${!__staged_files_cache[@]}" | sort)
	echo -e "${SEP}│"
}
