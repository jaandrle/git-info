source ../../core/consts.bash # COLOR_RESET
source ../echo/echo_file_entry.bash
echoComponent_unstaged() {
	echo_header 'unstaged' 'unstaged changes'
	local -r _has_unstaged="$1"
	if [[ $_has_unstaged == false ]]; then
		local COLOR_EMPHASIS="\e[3m"
		echo -e "${SEP}    ${COLOR_EMPHASIS}no changes${COLOR_RESET}"
	fi
	local -r _default_branch="$2"
	local -n _numstat_cache="$3"
	local line
	git status --short --no-branch 2>/dev/null | while IFS= read -r line; do
		local STAT
		local FILE
		local LAST_HASH
		local NUMSTAT
		
		STAT="${line:0:2}"
		FILE="${line:3}"

		[[ -z "$FILE" ]] && continue
		[[ "${STAT:1:1}" == " " ]] && continue

		local UNSTAGED_STAT="${STAT:1:1}"
		if [[ "$STAT" == '?' || "$STAT" == 'A' || "$UNSTAGED_STAT" == '?' || "$UNSTAGED_STAT" == 'A' ]]; then
			LAST_HASH=''
			UNSTAGED_STAT='A'
			NUMSTAT=''
		else
			# Fetch and format all hashes that touched this file, limited to DEFAULT_BRANCH
			local RAW_HASHES
			RAW_HASHES=$(git log --format='%h' "$_default_branch"..HEAD -- "$FILE" 2>/dev/null | tr '\n' ',' | sed 's/,$//')
			LAST_HASH="$RAW_HASHES"
			# Get numstat from cache
			NUMSTAT=${_numstat_cache["$FILE"]:-}
		fi

		echo_file_entry "$UNSTAGED_STAT" "$FILE" 'unstaged' "$LAST_HASH" "$NUMSTAT"
	done
}
