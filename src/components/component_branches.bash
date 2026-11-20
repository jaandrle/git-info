source ../core/consts.bash # SEP
source ../ui/fmt.bash # fmt_hash, fmt_auth
source ../ui/echo_file_entry.bash
source ../ui/echo_header.bash
source ../ui/echo_remote_status.bash
component_branches() {
	local -r DEFAULT_BRANCH=$1
	local -r show_files=$2
	local -r staged_files_count=$3
	local -n _target_hash=$4
	local -n _target_ref=$5
	local -r MAX_COMMITS=15
	local -r MAX_MONTHS=3
	local -A MONTH_COUNTS=()
	local -a MONTH_ORDER=()
	local group_count=0
	
	# Prints and resets the collapsed month summary for the current group
	_flushMonths() {
		local month shown=0 older_count=0
		for month in "${MONTH_ORDER[@]}"; do
			if (( shown < MAX_MONTHS )); then
				echo -e "${SEP}┊   ${COLOR_NOTE}$month · ${MONTH_COUNTS[$month]} commits${COLOR_RESET}"
				(( shown++ ))
			else
				(( older_count += ${MONTH_COUNTS[$month]} ))
			fi
		done
		if (( older_count > 0 )); then
			echo -e "${SEP}┊   ${COLOR_NOTE}older   · $older_count commits${COLOR_RESET}"
		fi
		MONTH_COUNTS=()
		MONTH_ORDER=()
		group_count=0
		return 0
	}
	# Dynamic Commit Groups
	local current_group
	current_group=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')
	if [[ "$staged_files_count" -gt 0 ]]; then
		echo_header 'stacked' "$current_group"
	else
		echo_header 'branch' "$current_group"
	fi
	
	# Pre-compute set of commits reachable from any remote branch (O(1) lookup)
	local -A on_remote_set
	while read -r h; do
		on_remote_set["$h"]=1
	done < <(git rev-list --remotes --abbrev-commit --abbrev=7 2>/dev/null)
	
	local HASH REFS MSG AUTHT AUTHU DATEYM
	while IFS='|' read -r HASH REFS MSG AUTHT AUTHU DATEYM; do
		if [[ -z "$HASH" ]]; then # ?no log history ⇒ no commits
			continue
		fi
		if [[ -n "$REFS" ]]; then # Clean refs: remove HEAD pointers and tag prefixes using bash string replacement
			local CLEAN_REFS
			CLEAN_REFS="${REFS//HEAD -> /}"
			CLEAN_REFS="${CLEAN_REFS//tag: /}"

			# Check if we hit the target/upstream branch
			if [[ "$CLEAN_REFS" == *"$DEFAULT_BRANCH"* ]]; then
				_target_hash="$HASH"
				# Extract target ref
				IFS=',' read -ra REFS_ARRAY <<< "$CLEAN_REFS"
				for ref in "${REFS_ARRAY[@]}"; do
					ref="${ref#"${ref%%[![:space:]]*}"}"  # trim leading whitespace
					if [[ "$ref" == "$DEFAULT_BRANCH" ]]; then
						_target_ref="$ref"
						_flushMonths
						break 2
					fi
				done
			fi

			# Detect a new local branch label (Stacked branches) using bash array
			local NEW_GROUP=''
			IFS=',' read -ra REFS_ARRAY <<< "$CLEAN_REFS"
			for ref in "${REFS_ARRAY[@]}"; do
				ref="${ref#"${ref%%[![:space:]]*}"}"  # trim leading whitespace
				if [[ "$ref" != *"origin/"* && "$ref" != *"gitbutler/"* && "$ref" != "$current_group" ]]; then
					NEW_GROUP="$ref"
					break
				fi
				done
			if [[ -n "$NEW_GROUP" && "$NEW_GROUP" != "$current_group" ]]; then
				_flushMonths
				current_group="$NEW_GROUP"
				echo -e "${SEP}│"
				echo_header 'stacked' "$current_group"
			fi
		fi

		# Collapse commits beyond the limit into per-month buckets
		if (( group_count >= MAX_COMMITS )); then
			if [[ -z "${MONTH_COUNTS[$DATEYM]+x}" ]]; then
				MONTH_ORDER+=("$DATEYM")
			fi
			(( MONTH_COUNTS[$DATEYM]++ ))
			continue
		fi
		(( group_count++ ))

		local DOT
		DOT=$(echo_remote_status "${on_remote_set[$HASH]:-0}")
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
	done < <(git log --date=format:'%Y-%m' --format='%h|%D|%s|%ar|%an|%ad' HEAD 2>/dev/null || echo '')
}
