source ../core/consts.bash # COLOR_NOTE, COLOR_RESET
source ../core/get_inProgress.bash
component_hint() {
	local -r has_staged="$1"
	local -r has_unstaged="$2"
	local -r TARGET_HASH="$3"
	local HINT='' COLOR="${COLOR_ACCENT}"
	local IN_PROGRESS_OP
	IN_PROGRESS_OP=$(get_inProgress)
	if [[ -n "$IN_PROGRESS_OP" ]]; then
		COLOR="${COLOR_WARN}"
		local CONTINUE="git $IN_PROGRESS_OP --continue"
		# shellcheck disable=SC2016
		HINT='resolve conflicts → `git add` → `'"$CONTINUE"'`'
	else
		# shellcheck disable=SC2016
		if $has_staged; then
			HINT='commit staged changes → `git commit`'
		elif $has_unstaged; then
			HINT='review changes → `git diff` · stage files → `git add`'
		elif [[ -z "$TARGET_HASH" ]]; then # ≡ no commits, no remote
			HINT='stage files → `git add` · add remote → `git remote add origin <url>`'
		fi
	fi
	if [[ -n "$HINT" ]]; then
		# Dim the action separators (`→`) to keep commands prominent
		HINT="${HINT//→/${COLOR_DIM}→${COLOR_RESET}}"
		echo -e "\n${COLOR_STRONG}${COLOR}Next:${COLOR_RESET} ${HINT}${COLOR_RESET}"
	fi
}
