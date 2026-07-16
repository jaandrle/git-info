echo_usage() {
	local usage
	read -r -d '' usage <<-'USAGE'
		Git status inspired by GitButler CLI.
		
		Usage:
		  git-info [options]
		  git-info help        Show this help message
		
		Description:
		  A colorful and informative Git status tool that displays unstaged changes,
		  staged changes, commit history, and branch information.
		
		Options:
		  -f                Show files for each commit in history
		  -h, --help        Show this help message
		  --version         Show version information
		
		UI Elements:
		  ╭┄ [section]     Section headers (branch/staged/unstaged)
		  ●                Commit on remote (green)
		  ◐                Commit not on remote yet
		  ! operation      In-progress Git operation
		  M/A/D            File status (Modified/Added/Deleted)
		  ┴ hash [branch]  Footer with target branch info
		  Hint:            Contextual hint
	USAGE
	echo "$usage"
}
