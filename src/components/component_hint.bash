source ../core/consts.bash # COLOR_NOTE, COLOR_RESET
source ../core/get_inProgress.bash
component_hint() {
	local -r has_staged="$1"
	local -r has_unstaged="$2"
	local -r TARGET_HASH="$3"
	local HINT=''
	local IN_PROGRESS_OP
	IN_PROGRESS_OP=$(get_inProgress)
	if [[ -n "$IN_PROGRESS_OP" ]]; then
		# shellcheck disable=SC2016
		case "$IN_PROGRESS_OP" in
			'rebase')      HINT='resolve conflicts, `git add`, then `git rebase --continue`' ;;
			'merge')       HINT='resolve conflicts, `git add`, then `git commit`' ;;
			'cherry-pick') HINT='resolve conflicts, `git add`, then `git cherry-pick --continue`' ;;
			'revert')      HINT='resolve conflicts, `git add`, then `git revert --continue`' ;;
		esac
	else
		# shellcheck disable=SC2016
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
