#!/usr/bin/env bash
#
# Structural checks for a shader pack.
#
# Defaults to the pack this repository ships (shaders/), which is a modified
# MakeUp - Ultra Fast. Pass a directory to check any other pack locally, for
# example a tuned copy that must never be committed:
#
#   bash tools/check_shaders.sh
#   bash tools/check_shaders.sh Local/bsl
#
# The checks match the conventions these packs share: entry points are thin
# wrappers with a #version line that include a body, and conditionals must
# balance. They are NOT a GLSL compiler: they cannot tell you whether the pack
# compiles on a GPU, looks right or runs fast.

set -u

cd "$(dirname "$0")/.." || exit 1

target="${1:-shaders}"

if [ ! -d "$target" ]; then
	echo "ERROR: '$target' is not a directory"
	exit 1
fi

echo "Checking $target"

fail=0
sources=$(find "$target" -type f \( -name '*.glsl' -o -name '*.fsh' -o -name '*.vsh' -o -name '*.csh' \) | sort)

# 1. Every program entry point starts with a #version directive.
for f in "$target"/*.fsh "$target"/*.vsh "$target"/*.csh; do
	[ -f "$f" ] || continue
	first=$(grep -m1 -v '^[[:space:]]*$' "$f")
	case "$first" in
		'#version '*) ;;
		*)
			echo "ERROR $f: first line must be a #version directive, found: $first"
			fail=1
			;;
	esac
done

# 2. Every entry point includes its body: in these packs they are all wrappers,
#    so a wrapper with no #include is a program that silently does nothing.
for f in "$target"/*.fsh "$target"/*.vsh "$target"/*.csh; do
	[ -f "$f" ] || continue
	if ! grep -q '#include "' "$f"; then
		echo "ERROR $f: no #include; entry points here are wrappers around a body"
		fail=1
	fi
done

# 3. Preprocessor conditionals must balance in every source file. A missing
#    #endif is the most common way an edit silently breaks a whole program.
#    Packs ship a mix of LF and CRLF files, so trailing \r is stripped before
#    comparing: "#endif\r" is not "#endif".
for f in $sources; do
	if ! awk -v file="$f" '
		{ sub(/\r$/, "") }
		/^[[:space:]]*#/ {
			if ($1 == "#if" || $1 == "#ifdef" || $1 == "#ifndef") depth++
			else if ($1 == "#endif") depth--
			if (depth < 0) {
				printf "ERROR %s: #endif without a matching #if\n", file
				exit 1
			}
		}
		END {
			if (depth != 0) {
				printf "ERROR %s: %d unclosed #if/#ifdef/#ifndef\n", file, depth
				exit 1
			}
		}
	' "$f"; then
		fail=1
	fi
done

# 4. Every #include must resolve inside the pack. A renamed or deleted lib file
#    otherwise only shows up as a compile error in game.
missing=$(grep -h -o '#include "[^"]*"' $sources |
	sed 's/.*"\(.*\)"/\1/' | sort -u |
	while read -r inc; do
		[ -f "$target$inc" ] || echo "ERROR missing include: $inc"
	done)
if [ -n "$missing" ]; then
	echo "$missing"
	fail=1
fi

# 5. Report the size of what was checked, so the log is meaningful.
count=$(echo "$sources" | wc -l | tr -d ' ')
echo "Checked $count shader source files."

if [ "$fail" -ne 0 ]; then
	echo ""
	echo "Shader source checks FAILED."
	exit 1
fi

echo "All shader source checks passed."
