source ./fetch_numstat.bash
source ./fetch_staged.bash
cache_files() {
	local -n __numstat_cache=$1
	fetch_numstat "$1"
	local -n __staged_files_cache=$2
	fetch_staged "$2"
	local -n _has_unstaged=$3
	local -n _has_staged=$4
	if [[ -n "${_numstat_cache:+x}" || -n "${__staged_files_cache:+x}" ]]; then
		if [[ ${#_numstat_cache[@]} -gt 0 ]]; then
			_has_unstaged=true
		fi
		if [[ ${#__staged_files_cache[@]} -gt 0 ]]; then
			_has_staged=true
		fi
	else
		if git status --short --no-branch 2>/dev/null | grep -q .; then
			_has_unstaged=true
		fi
		if git diff --cached --name-status 2>/dev/null | grep -q .; then
			_has_staged=true
		fi
	fi
}
