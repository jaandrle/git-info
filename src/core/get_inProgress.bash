get_inProgress() { # Detects rebase/merge/cherry-pick/revert in progress and outputs operation type
	local state_dir=''
	local operation=''

	if [[ -d .git/rebase-merge ]]; then
		state_dir='.git/rebase-merge'
		if [[ -f "$state_dir/interactive" ]]; then
			operation='rebase'
		else
			operation='rebase'
		fi
	elif [[ -d .git/rebase-apply ]]; then
		operation='rebase'
	elif [[ -f .git/MERGE_HEAD ]]; then
		operation='merge'
	elif [[ -f .git/CHERRY_PICK_HEAD ]]; then
		operation='cherry-pick'
	elif [[ -f .git/REVERT_HEAD ]]; then
		operation='revert'
	fi

	echo "$operation"
}
