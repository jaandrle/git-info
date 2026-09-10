source ../core/consts.bash # COLOR_WARN, COLOR_ACCENT, COLOR_RESET
source ../core/get_inProgress.bash

component_inProgress() { # Renders rebase/merge/cherry-pick/revert in progress
	local operation=''
	local step=''
	local total=''

	operation=$(get_inProgress)

	if [[ -z "$operation" ]]; then
		return 0
	fi

	# Get step/total for rebase operations
	if [[ -d .git/rebase-merge ]]; then
		step=$(cat .git/rebase-merge/msgnum 2>/dev/null || echo '1')
		total=$(cat .git/rebase-merge/end 2>/dev/null || echo '?')
		# Override operation to show "rebase -i" for interactive
		if [[ -f .git/rebase-merge/interactive ]]; then
			operation='rebase -i'
		fi
	elif [[ -d .git/rebase-apply ]]; then
		step=$(cat .git/rebase-apply/next 2>/dev/null || echo '1')
		total=$(cat .git/rebase-apply/last 2>/dev/null || echo '?')
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
