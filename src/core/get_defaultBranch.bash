get_defaultBranch() { # Detects the default branch from remote
	local default_branch=''
	local remote='origin'
	
	# Method 1: Check local config for default branch (fast, no network)
	default_branch=$(git config "remote.$remote.branch.default" 2>/dev/null || true)
	if [[ -n "$default_branch" ]]; then
		echo "$remote/$default_branch"
		return
	fi
	
	# Method 2: Try to get from git symbolic-ref (very fast)
	local head_ref
	head_ref=$(git symbolic-ref "refs/remotes/$remote/HEAD" 2>/dev/null || true)
	if [[ -n "$head_ref" ]]; then
		echo "${head_ref#refs/remotes/}"
		return
	fi
	
	# Method 3: Fallback to common default branches
	local common_branches=("main" "master" "develop" "trunk")
	for branch in "${common_branches[@]}"; do
		if git show-ref --verify --quiet "refs/remotes/$remote/$branch" 2>/dev/null; then
			echo "$remote/$branch"
			return
		fi
	done
	
	# Method 4: Ultimate fallback
	echo "$remote/main"
}
