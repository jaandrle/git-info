fetch_staged() {
	local -n out="$1"
	out=()
	local stat file
	while IFS=$'\t' read -r stat file || [[ -n "$stat" ]]; do
		[[ -z "$file" ]] && continue
		out["$file"]="$stat"
	done < <(git diff --cached --name-status 2>/dev/null)
}
