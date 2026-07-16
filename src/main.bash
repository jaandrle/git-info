source ./ui/echo/index.bash
source ./ui/echoComponent/index.bash
main() {
	local opt="${1:-}"
	if [[ "$opt" == "--version" || "$opt" == "-v" ]]; then
		echo "$VERSION"
		exit 0
	fi
	if [[ "$opt" == "help" || "$opt" == "--help" || "$opt" == "-h" ]]; then
		echo_usage
		exit 0
	fi
	is_gitRepo
	# Parse flags
	local show_files=false
	while getopts "f" opt; do
		case $opt in
			f)
				show_files=true
				;;
			\?)
				echo "Invalid option: -$OPTARG" >&2
				exit 1
				;;
		esac
	done
	
	# Detect default branch
	local DEFAULT_BRANCH
	DEFAULT_BRANCH=$(get_defaultBranch)
	
	# Pre-fetch numstat and staged files
	declare -A numstat_cache staged_files_cache
	fetch_numstat numstat_cache
	fetch_staged staged_files_cache
	
	local has_unstaged=false
	local has_staged=false
	if [[ -n "${numstat_cache:+x}" || -n "${staged_files_cache:+x}" ]]; then
		if [[ ${#numstat_cache[@]} -gt 0 ]]; then
			has_unstaged=true
		fi
		if [[ ${#staged_files_cache[@]} -gt 0 ]]; then
			has_staged=true
		fi
	else
		if git status --short --no-branch 2>/dev/null | grep -q .; then
			has_unstaged=true
		fi
		if git diff --cached --name-status 2>/dev/null | grep -q .; then
			has_staged=true
		fi
	fi
	
	echoComponent_inProgress
	echoComponent_unstaged "$has_unstaged" "$DEFAULT_BRANCH" numstat_cache
	echo -e "$SEP"
	echoComponent_stashed "$DEFAULT_BRANCH"
	
	if [[ $has_staged == true ]]; then
		echo_header 'staged' 'staged changes'
		for file in "${!staged_files_cache[@]}"; do
			local STAT="${staged_files_cache[$file]:0:1}"
			echo_file_entry "$STAT" "$file" 'staged'
		done
		echo -e "${SEP}│"
	fi
	
	# Dynamic Commit Groups
	local CURRENT_GROUP
	CURRENT_GROUP=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')
	if [[ ${#staged_files_cache[@]} -gt 0 ]]; then
		echo_header 'stacked' "$CURRENT_GROUP"
	else
		echo_header 'branch' "$CURRENT_GROUP"
	fi
	local TARGET_HASH=''
	local TARGET_REF=''
	
	# Cache branch contains checks
	declare -A branch_contains_cache
	
	while IFS='|' read -r HASH REFS MSG AUTHT AUTHU; do
		if [[ -z "$HASH" ]]; then # ?no log history ⇒ no commits
			continue
		fi
		if [[ -n "$REFS" ]]; then # Clean refs: remove HEAD pointers and tag prefixes using bash string replacement
			local CLEAN_REFS
			CLEAN_REFS="${REFS//HEAD -> /}"
			CLEAN_REFS="${CLEAN_REFS//tag: /}"

			# Check if we hit the target/upstream branch
			if [[ "$CLEAN_REFS" == *"$DEFAULT_BRANCH"* ]]; then
				TARGET_HASH="$HASH"
				# Extract target ref
				IFS=',' read -ra REFS_ARRAY <<< "$CLEAN_REFS"
				for ref in "${REFS_ARRAY[@]}"; do
					ref="${ref#"${ref%%[![:space:]]*}"}"  # trim leading whitespace
					if [[ "$ref" == "$DEFAULT_BRANCH" ]]; then
						TARGET_REF="$ref"
						break 2
					fi
				done
			fi

			# Detect a new local branch label (Stacked branches) using bash array
			local NEW_GROUP=''
			IFS=',' read -ra REFS_ARRAY <<< "$CLEAN_REFS"
			for ref in "${REFS_ARRAY[@]}"; do
				ref="${ref#"${ref%%[![:space:]]*}"}"  # trim leading whitespace
				if [[ "$ref" != *"origin/"* && "$ref" != *"gitbutler/"* && "$ref" != "$CURRENT_GROUP" ]]; then
					NEW_GROUP="$ref"
					break
				fi
				done
			if [[ -n "$NEW_GROUP" && "$NEW_GROUP" != "$CURRENT_GROUP" ]]; then
				CURRENT_GROUP="$NEW_GROUP"
				echo -e "${SEP}│"
				echo_header 'stacked' "$CURRENT_GROUP"
			fi
		fi

		# Cache branch contains check result
		if [[ -z "${branch_contains_cache[$HASH]:-}" ]]; then
			if git branch -r --contains "$HASH" 2>/dev/null | grep -q 'origin/'; then
				branch_contains_cache["$HASH"]='1'
			else
				branch_contains_cache["$HASH"]='0'
			fi
		fi

		local DOT
		DOT=$(echo_remote_status "${branch_contains_cache[$HASH]:-}")
		echo -e "${SEP}$DOT   $(fmt_hash "$HASH") $MSG $(fmt_auth "$AUTHU" "$AUTHT")"
		
		# Show commit files if -f flag is provided
		if [[ "$show_files" == true ]]; then
			while IFS= read -r line; do
				if [[ -n "$line" ]]; then
					local STAT
					local FILE
					
					STAT="${line:0:1}"
					FILE="${line:2}"
					
					[[ -z "$FILE" ]] && continue
					
					# Use echo_file_entry function with commit context
					echo_file_entry "$STAT" "$FILE" 'commit'
				fi
			done < <(git show --name-status --format='' "$HASH" 2>/dev/null || echo '')
		fi
	done < <(git log --format='%h|%D|%s|%ar|%an' HEAD 2>/dev/null || echo '')
	
	# Footer Section 
	if [[ -z "$TARGET_HASH" ]]; then
		TARGET_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo '')
		TARGET_REF='unknown'
	fi
	if [[ -z "$TARGET_HASH" ]]; then
		TARGET_REF='unknown remote'
		echo -e "├╯\n$SEP"
		echo -e "┴ $(fmt_label accent "$TARGET_REF")"
	else
		local TARGET_DATE=''
		local TARGET_MSG=''
		local TARGET_AUTHOR=''
		# Fetch target commit info in one call if not already cached
		if [[ -z "$TARGET_DATE" || -z "$TARGET_MSG" ]]; then
			local target_info
			target_info=$(git show -s --format='%ar|%an|%s' "$TARGET_HASH" 2>/dev/null || echo '')
			IFS='|' read -r TARGET_DATE TARGET_AUTHOR TARGET_MSG <<< "$target_info"
		fi
		
		echo -e "├╯\n$SEP"
		echo -e "┴ $(fmt_hash "$TARGET_HASH") $(fmt_label accent "$TARGET_REF") ${TARGET_MSG} $(fmt_auth "$TARGET_AUTHOR" "$TARGET_DATE")"
	fi
	
	local HINT=''
	local IN_PROGRESS_OP
	IN_PROGRESS_OP=$(get_inProgress)
	if [[ -n "$IN_PROGRESS_OP" ]]; then
		case "$IN_PROGRESS_OP" in
			'rebase')      HINT='resolve conflicts, `git add`, then `git rebase --continue`' ;;
			'merge')       HINT='resolve conflicts, `git add`, then `git commit`' ;;
			'cherry-pick') HINT='resolve conflicts, `git add`, then `git cherry-pick --continue`' ;;
			'revert')      HINT='resolve conflicts, `git add`, then `git revert --continue`' ;;
		esac
	else
		if $has_staged; then
			HINT='run `git commit` to commit staged changes'
		elif $has_unstaged; then
			HINT='run `git diff` to see changes, `git add` to stage'
		elif [[ -z "$TARGET_HASH" ]]; then # ≡ no commits, no remote
			HINT='run `git add` to stage files (you may also need to set a remote: `git remote add origin <url>`)'
		fi
	fi
	if [[ -n "$HINT" ]]; then
		echo -e "\n\e[37m${COLOR_NOTE}Hint: ${HINT}${COLOR_RESET}"
	fi
}
