# git-info

A Git status tool inspired by [GitButler](https://gitbutler.com/) CLI command
`but status`. This tool provides a colorful and informative overview of your
Git repository's status, including unstaged changes, staged changes, commit
history, and branch information.

## Features

- **Unstaged Changes**: Shows modified, added, and deleted files with their last commit hash and change statistics.
- **Staged Changes**: Lists files that are staged for commit.
- **Commit History**: Displays recent commits with their hash, message, author, and date.
- **Branch Information**: Shows the current branch and its relationship to the default branch.
- **In-Progress Operations**: Detects and displays ongoing Git operations like rebase, merge, cherry-pick, or revert.
- **Colorful Output**: Uses a consistent color scheme for better readability.

## UI Elements

- **`╭┄ [section]`**: Section headers for unstaged changes, staged changes, and branch information
- **`┊`**: Vertical separator line
- **`●`**: Commit that exists on remote (green)
- **`◐`**: Commit that doesn't exist on remote yet (gray)
- **`! operation`**: In-progress Git operation (rebase, merge, cherry-pick, revert)
- **`M`**: Modified file
- **`A`**: Added file
- **`D`**: Deleted file
- **`┴ hash [branch]`**: Footer showing target branch and latest commit
- **`Hint:`**: Contextual hint based on current repository state

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/jaandrle/git-info.git
   ```
2. Navigate to the repository:
   ```bash
   cd git-info
   ```
3. Make the script executable:
   ```bash
   chmod u+x git-info
   ```
4. Optionally, add it to your PATH for easy access.

## Usage

Run the script from within a Git repository:
```bash
./git-info
```

For help:
```bash
./git-info help
```

## Example Output
```
╭┄ [unstaged changes]
┊   M git-info 13+3- … 6089a06
┊   A README.md  … new file
┊
┊╭┄ [main]
┊●   6089a06 :zap: Improves UI staged+branch (11 minutes ago · Jan Andrle)
┊●   bc095a5 :bug: Ensures proper (un)stage detection (19 minutes ago · Jan Andrle)
┊●   12d3561 :zap: Makes hint align with repo state (49 minutes ago · Jan Andrle)
┊●   eb0837e :zap: Adds inprogress operation info (68 minutes ago · Jan Andrle)
┊●   9245e17 :zap: Improves speed (mainly due to nettwork) (79 minutes ago · Jan Andrle)
┊●   16d63dc :zap: Adds edition info (2 hours ago · Jan Andrle)
┊●   02b65ce :tv: Adds bs/lint (2 hours ago · Jan Andrle)
┊●   e241b19 :zap: Implements deafult branch detection (2 hours ago · Jan Andrle)
┊●   35628de :bug: Improves code quality (2 hours ago · Jan Andrle)
┊●   ee9c860 :zap: Initial commit (2 hours ago · Jan Andrle)
├╯
┊
┴ 6089a06 [origin/main] 2026-03-20 :zap: Improves UI staged+branch

Hint: run `git diff` to see changes, `git add` to stage
```

## Dependencies

- Git
- Bash (tested on Bash 5.0+)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## TODO
- [ ] :zap: ensure all commits listed for unstaged files
- [ ] :bug: wrong UI/UX when local/remote branch are aligned
- [ ] :zap: `-f` flag for including also files
