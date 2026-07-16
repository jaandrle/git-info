source ./core/get_defaultBranch.bash
source ./core/process_cliStart.bash
source ./core/cache_files.bash
source ./components/index.bash

main() {
	local show_files=false
	process_cliStart show_files "$@"
	local -r DEFAULT_BRANCH=$(get_defaultBranch)
	local -A _numstat_cache _staged_files_cache
	local has_unstaged=false has_staged=false
	cache_files _numstat_cache _staged_files_cache has_unstaged has_staged
	
	component_inProgress
	component_unstaged "$has_unstaged" "$DEFAULT_BRANCH" _numstat_cache
	component_stashed "$DEFAULT_BRANCH"
	component_staged "$has_staged" _staged_files_cache
	local TARGET_HASH='' TARGET_REF=''
	component_branches \
		"$DEFAULT_BRANCH" "$show_files" "${#_staged_files_cache[@]}" \
		TARGET_HASH TARGET_REF # sideeffect
	component_branchRoot "$TARGET_HASH" "$TARGET_REF"
	component_hint "$has_staged" "$has_unstaged" "$TARGET_HASH"
}
