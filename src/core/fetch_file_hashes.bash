#!/usr/bin/env bash
# fetch_file_hashes.bash - Efficiently fetch commit hashes for multiple files
# Usage: fetch_file_hashes <output_assoc_array_name> <default_branch> <commit_range_end> [file1 file2 ...]
# If no files specified, uses all changed files in the range
# Output: associative array mapping filename -> comma-separated list of commit hashes

_nul_lines() {
    local line
    while IFS= read -r line; do
        printf '%s\0' "$line"
    done
}
fetch_file_hashes() {
	local -n _out=$1
	local _default_branch="$2"
	local _commit_range_end="$3"
	shift 3
	local _files=("$@")

	_out=()

	# If no specific files provided, get all changed files in the range
	if [[ ${#_files[@]} -eq 0 ]]; then
		# Get all files changed between default_branch and commit_range_end
		local all_files
		all_files=$(git log --name-only --format='' "$_default_branch".."$_commit_range_end" 2>/dev/null | sort -u | _nul_lines)
		[[ -z "$all_files" ]] && return
		_files=()
		while IFS= read -r -d '' file; do
			_files+=("$file")
		done <<< "$all_files"
	fi

	# Single git log call to get all hashes for all files
	# Format: <hash>\t<filename>
	local log_output
	log_output=$(git log --name-only --format='%h' "$_default_branch".."$_commit_range_end" -- "${_files[@]}" 2>/dev/null)
	
	[[ -z "$log_output" ]] && return

	local current_hash=''
	local filename=''
	
	while IFS= read -r line; do
		# Lines starting with a hash (7 hex chars) are commit hashes
		if [[ "$line" =~ ^[0-9a-f]{7,}$ ]]; then
			current_hash="$line"
		# Lines that are file paths (not hashes) are filenames
		elif [[ -n "$current_hash" && -n "$line" ]]; then
			filename="$line"
			if [[ -n "${_out[$filename]:-}" ]]; then
				_out["$filename"]="${_out[$filename]},$current_hash"
			else
				_out["$filename"]="$current_hash"
			fi
		fi
	done <<< "$log_output"
}
