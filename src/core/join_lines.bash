join_lines() {
	local first=1 line
	while IFS= read -r line; do
		if (( first )); then
			first=0
		else
			printf ','
		fi
		printf '%s' "$line"
	done
}
