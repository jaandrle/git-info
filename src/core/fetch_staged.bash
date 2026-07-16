fetch_staged() {
	# shellcheck disable=SC2178
	local -n out=$1
	out=()
	local stat file
	while IFS=$'\t' read -r stat file || [[ -n "$stat" ]]; do
		[[ -z "$file" ]] && continue
		# shellcheck disable=SC2034
		out["$file"]="$stat"
	done < <(git diff --cached --name-status 2>/dev/null)
}
