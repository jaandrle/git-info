source ./fetch_numstat.bash
source ./fetch_staged.bash
cache_files() {
	local -n __numstat_cache=$1;      fetch_numstat "$1"
	local -n __staged_files_cache=$2; fetch_staged "$2"
	local -n _has_unstaged=$3
	local -n _has_staged=$4
	(( ${#__numstat_cache[@]} > 0 ))      && _has_unstaged=true
	(( ${#__staged_files_cache[@]} > 0 )) && _has_staged=true
}
