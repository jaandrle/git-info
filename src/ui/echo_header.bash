source ./fmt.bash # fmt_label
echo_header() { # branch/section headers
	local type="$1"
	local label="$2"
	case "$type" in
		'unstaged') echo -e "╭┄┄ $(fmt_label normal "$label")" ;;
		'staged') echo -e "${SEP}╭┄┄ $(fmt_label normal "$label")" ;;
		'branch')   echo -e "${SEP}╭┄ $(fmt_label accent "$label")" ;;
		'stacked')  echo -e "${SEP}├┄ $(fmt_label accent "$label")" ;;
	esac
}
