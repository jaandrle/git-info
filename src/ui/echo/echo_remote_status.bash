source ../../core/consts.bash # COLOR_OK, COLOR_RESET
echo_remote_status() { # Checks remote status for the commit dot 
	local -r status="${1:-}" # 1 = on remote, 0 = not on remote
	if [[ "$status" == '1' ]]; then
		echo -e "${COLOR_OK}●${COLOR_RESET}"
	else
		echo -e "${COLOR_RESET}◐${COLOR_RESET}"
	fi
}
