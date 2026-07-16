source ../../core/consts.bash # COLOR_ACCENT, COLOR_KO, COLOR_NOTE, COLOR_OK, COLOR_RESET, COLOR_WARN
source ../fmt.bash # fmt_hash, fmt_hashes
echo_file_entry() { # Prints a file entry with consistent formatting
	local status="$1"
	local file="$2"
	local context="$3" # unstaged, staged, or stashed
	local hash="${4:-}"    # Optional: last commit hash (or multiple hashes)
	local numstat="${5:-}" # Optional: numstat string
	
	local color=''
	local status_char=''
	local hash_display=''
	
	status_char="${status:0:1}"
	
	# Set color based on status
	case "$status_char" in
		'M') color="${COLOR_WARN}" ;;
		'D') color="${COLOR_KO}"    ;;
		'A') color="${COLOR_OK}"    ;;
		*)   color="${COLOR_ACCENT}" ;;
	esac
	
	# Set hash display
	if [[ -n "$hash" ]]; then
		if [[ "$hash" == *','* ]]; then
			# Multiple hashes - use fmt_hashes
			hash_display="$(fmt_hashes "$hash")"
		else
			# Single hash - use fmt_hash
			hash_display="$(fmt_hash "$hash")"
		fi
	else
		hash_display="${COLOR_NOTE}new file${COLOR_RESET}"
	fi
	
	# Print the formatted file entry
	if [[ "$context" == 'staged' || "$context" == 'commit' ]]; then
		printf "${SEP}│   %s ${color}%s${COLOR_RESET}\n" \
			"$status_char" "$file"
	else
		printf "${SEP}    %s ${color}%s${COLOR_RESET} ${COLOR_NOTE}%s …${COLOR_RESET} %b\n" \
			"$status_char" "$file" "$numstat" "$hash_display"
	fi
}
