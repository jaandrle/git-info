source ../core/consts.bash # COLOR_RESET, COLOR_STRONG, COLOR_SECTION, COLOR_SECTION_ALT, SEP
source ../core/join_lines.bash
source ../ui/echo_file_entry.bash

_format_numstat() {
	local added deleted
	read -r added deleted _ || return
	printf '%s+%s-' "$added" "$deleted"
}
component_stashed() {
	local -r _default_branch="$1"
	local stashed_entries
	stashed_entries=$(git stash list --format='%gd:%gs' 2>/dev/null || echo '')
	if [[ -z "$stashed_entries" ]]; then
		return
	fi
	local stash_index stash_branch stash_message count=0
	while IFS=':' read -r stash_index stash_branch stash_message; do
		# On branch → branch
		stash_branch="${stash_branch/On /}"
		stash_message="${stash_message#"${stash_message%%[![:space:]]*}"}"
		if [[ -n "$stash_index" ]]; then
			if (( count++ == 0 )); then
				echo -e "${SEP}"
			fi
			# Create section header for each stash with formatted index
			printf "├┄┄ [${COLOR_STRONG}${COLOR_SECTION}%s${COLOR_RESET} ${COLOR_SECTION_ALT}%s${COLOR_RESET}] %s\n" \
				"$stash_branch" "$stash_index" "$stash_message"
			
				# Show stash files if available - similar to unstaged/staged format
				local stash_files
				stash_files=$(git stash show --include-untracked --name-status "$stash_index" 2>/dev/null)
				if [[ -n "$stash_files" ]]; then
					local line
					while IFS= read -r line; do
						if [[ -n "$line" ]]; then
							local STAT
							local FILE
							local LAST_HASH
							local NUMSTAT
							
							STAT="${line:0:1}"
							FILE="${line:2}"
							
							[[ -z "$FILE" ]] && continue
							
							if [[ "$STAT" == 'A' ]]; then
								LAST_HASH=''
								NUMSTAT=''
							else
								# Fetch and format the last hash to touch this file 
								local RAW_HASHES
								RAW_HASHES=$(git log --format='%h' "$_default_branch".."$stash_index" -- "$FILE" 2>/dev/null | join_lines)
								LAST_HASH="$RAW_HASHES"
								# Get numstat for this file
								NUMSTAT=$(git diff --numstat "$stash_index^..$stash_index" -- "$FILE" 2>/dev/null | _format_numstat || echo '')
							fi
							
							echo_file_entry "$STAT" "$FILE" 'stashed' "$LAST_HASH" "$NUMSTAT"
						fi
						done <<< "$stash_files"
				fi
		fi
	done <<< "$stashed_entries"
}
