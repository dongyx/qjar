#!/bin/sh

set -e
d="$(mktemp -d)"
trap '[ -d "$d" ] && rm -rf "$d"' EXIT
trap 'exit 1' TERM INT HUP

help() {
cat <<\.
usage:

qjar [<options>] [<cmd>] <file> ...
qjar [<options>] -f <cmdfile> <file> ...
qjar -h|-v

options:

-i <awk>	set which awk interpreter qjar uses
		default: "awk"

-k <ks>		set the separator between key and value
		default: "[ \t]+"

-r <rs>		set the separator between records
		<rs> will be passed to awk as the RS variable
		default: ""

-h		print the brief usage and exit

-v		print the version and exit
.
}

awkstr() {
	printf '%s' "$1" | sed 's/\\/\\\\/g;s/"/\\"/g;$! s/$/\\n/g'
}

awk="awk"
ks='[\t ]+'
rs=''
while getopts 'i:k:r:f:hv' opt; do
	case $opt in
	f)	cmdfile="$OPTARG";;
	i)	awk="$OPTARG";;
	k)	ks="$OPTARG";;
	r)	rs="$OPTARG";;
	h)	help
		exit 0;;
	v)	echo '__version__'
		exit 0;;
	?)	help >&2
		exit 1;;
	esac
done
shift $(($OPTIND - 1))
progname="$cmdfile"
if [ -z "$cmdfile" ]; then
	if [ $# -eq 0 ]; then
		echo qjar: cmd or cmdfile is required
		help >&2
		exit 1
	fi
	cmdfile="$d/cmdfile"
	progname="$1"
	printf '%s\n' "$1" >"$cmdfile"
	shift
elif [ "$cmdfile" = - ]; then
	echo cmdfile name can\'t be - >&2
	exit 1
fi
if [ $# -eq 0 ]; then
	echo qjar: files are required
	help >&2
	exit 1;
fi
for i in "$@"; do
	if [ "$i" = - ]; then
		echo file name can\'t be - >&2
		exit 1
	fi
done

"$awk" -v RS="$rs" -v KS="$ks" -F '\n' '{
	for (i = 1; i <= NF; i++) {
		if ($i == "")
			continue
		if (0 == match($i, KS)) {
			print "illegal line:", $i | "cat >&2"
			exit 1
		}
		key = substr($i, 1, RSTART - 1);
		if (key !~ /^[a-zA-Z_][a-zA-Z0-9_]*$/) {
			print "illegal key name:", key | "cat >&2"
			exit 1
		}
		if (!a[key]++)
			print key
	}
}' "$@" >"$d/keyset"

(
echo 'BEGIN {'
echo "	ARGV[0] = \"`awkstr "$progname"`\""
echo '}'
echo '{'
for key in `cat "$d/keyset"`; do
echo "	$key" = '""'
done
echo '	for (i = 1; i <= NF; i++) {'
echo '		if ($i == "")'
echo '			continue'
for key in `cat "$d/keyset"`; do
echo "		if (substr(\$i, 1, match(\$i, KS) - 1) == \"$key\")"
echo "			$key = substr(\$i, RSTART + RLENGTH)"
done
echo '	}'
echo '}'
) >"$d/awkcmd"
cat "$cmdfile" >>"$d/awkcmd"

"$awk" -v RS="$rs" -v KS="$ks" -F '\n' -f "$d/awkcmd" "$@"
