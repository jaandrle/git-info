is_gitRepo() {
	git rev-parse --show-toplevel > /dev/null 2>&1;
	local -r result=$?
	if [[ $result != 0 ]]; then
		>&2 echo 'Not a git repository'
		exit $result
	fi
}
