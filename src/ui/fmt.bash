source ../core/consts.bash # COLOR_ACCENT, COLOR_DIM, COLOR_NOTE, COLOR_RESET, COLOR_SECTION, COLOR_SECTION_ALT, COLOR_STRONG
fmt_hash() { # formats a 7-char hash with first 4 chars in accent color, last 3 dimmed 
	local -r hash="$1"
	echo -ne "${COLOR_ACCENT}${hash:0:4}${COLOR_DIM}${hash:4:3}${COLOR_RESET}"
}
fmt_hashes() { # formats multiple hashes separated by space
	local -r hashes="$1"
	local result=''
	local IFS=','
	for hash in $hashes; do
		if [[ -n "$result" ]]; then
			result="$result "
		fi
		result="$result$(fmt_hash "$hash")"
	done
	echo -ne "$result"
}
fmt_label() {
	local -r mode="${1:-accent}" # accent, normal
	local -r label="${2:-}"
	local color="${COLOR_SECTION}"
	if [[ "$mode" == 'normal' ]]; then
		color="${COLOR_SECTION_ALT}"
	fi
	printf "[${COLOR_STRONG}${color}%s${COLOR_RESET}]" \
		"$label"
}
fmt_auth() {
	local -r user="$1"
	local -r relative="$2"
	printf "$COLOR_NOTE(%s · %s)${COLOR_RESET}" \
		"$user" "$relative"
}
