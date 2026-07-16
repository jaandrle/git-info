fetch_numstat() {
	# shellcheck disable=SC2178
	local -n out=$1
	out=()
	local line
	while IFS= read -r line || [[ -n "$line" ]]; do
		local additions='' deletions='' file=''
		read -r additions deletions file <<< "$line"
		[[ -z "$file" ]] && continue
		# shellcheck disable=SC2034
		out["$file"]="${additions}+${deletions}-"
	done < <(git diff --numstat 2>/dev/null)
}
