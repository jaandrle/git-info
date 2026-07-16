fetch_numstat() {
	local -n out="$1"
	out=()
	local line
	while IFS= read -r line || [[ -n "$line" ]]; do
		local additions='' deletions='' file=''
		read -r additions deletions file <<< "$line"
		[[ -z "$file" ]] && continue
		out["$file"]="${additions}+${deletions}-"
	done < <(git diff --numstat 2>/dev/null)
}
