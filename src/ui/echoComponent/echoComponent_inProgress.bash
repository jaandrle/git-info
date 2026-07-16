source ../../core/consts.bash # COLOR_WARN, COLOR_ACCENT, COLOR_RESET
echoComponent_inProgress() { # Renders rebase/merge/cherry-pick/revert in progress
	local state_dir=''
	local operation=''
	local step=''
	local total=''

	if [[ -d .git/rebase-merge ]]; then
		state_dir='.git/rebase-merge'
		if [[ -f "$state_dir/interactive" ]]; then
			operation='rebase -i'
		else
			operation='rebase'
		fi
		step=$(cat "$state_dir/msgnum" 2>/dev/null || echo '1')
		total=$(cat "$state_dir/end" 2>/dev/null || echo '?')
	elif [[ -d .git/rebase-apply ]]; then
		state_dir='.git/rebase-apply'
		operation='rebase'
		step=$(cat "$state_dir/next" 2>/dev/null || echo '1')
		total=$(cat "$state_dir/last" 2>/dev/null || echo '?' )
	elif [[ -f .git/MERGE_HEAD ]]; then
		operation='merge'
		step=''
		total=''
	elif [[ -f .git/CHERRY_PICK_HEAD ]]; then
		operation='cherry-pick'
		step=''
		total=''
	elif [[ -f .git/REVERT_HEAD ]]; then
		operation='revert'
		step=''
		total=''
	fi

	if [[ -z "$operation" ]]; then
		return 0
	fi
	
	local color="${COLOR_WARN}"
	if [[ "$operation" == 'merge' ]]; then
		color="${COLOR_ACCENT}"
	fi
	if [[ -n "$step" && -n "$total" && "$total" != "?" ]]; then
		echo -e "${color}! $operation ($step/$total)${COLOR_RESET}"
	else
		echo -e "${color}! $operation${COLOR_RESET}"
	fi
	echo
}
