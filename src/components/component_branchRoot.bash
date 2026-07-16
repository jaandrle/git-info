source ../core/consts.bash # SEP
source ../ui/fmt.bash # fmt_label, fmt_auth, fmt_hash
component_branchRoot(){
	local TARGET_HASH=$1
	local TARGET_REF=$2
	if [[ -z "$TARGET_HASH" ]]; then
		TARGET_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo '')
		TARGET_REF='unknown'
	fi
	
	local line
	if [[ -z "$TARGET_HASH" ]]; then
		TARGET_REF='unknown remote'
		line="$(fmt_label accent "$TARGET_REF")"
	else
		local TARGET_DATE=''
		local TARGET_MSG=''
		local TARGET_AUTHOR=''
		# Fetch target commit info in one call if not already cached
		if [[ -z "$TARGET_DATE" || -z "$TARGET_MSG" ]]; then
			local target_info
			target_info=$(git show -s --format='%ar|%an|%s' "$TARGET_HASH" 2>/dev/null || echo '')
			IFS='|' read -r TARGET_DATE TARGET_AUTHOR TARGET_MSG <<< "$target_info"
		fi
		
		line="$(fmt_hash "$TARGET_HASH") $(fmt_label accent "$TARGET_REF") ${TARGET_MSG} $(fmt_auth "$TARGET_AUTHOR" "$TARGET_DATE")"
	fi
	echo -e "├╯"
	echo -e "┴ $line"
}
