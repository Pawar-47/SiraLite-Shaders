#!/usr/bin/env bash
#
# Structural checks for the shader sources.
#
# The pack in shaders/ is a modified MakeUp - Ultra Fast (LGPL-3.0). Its
# conventions differ from a hand-written pack: entry points are GLSL 120 and are
# thin wrappers that include a body from common/, lib/ or src/, and render
# targets are declared with DRAWBUFFERS comments inside those bodies. The checks
# below match those conventions.
#
# These are NOT a GLSL compiler. They cannot tell you whether the pack compiles
# on a GPU, only whether the files are internally consistent.
#
# Usage: bash tools/check_shaders.sh

set -u

cd "$(dirname "$0")/.." || exit 1

fail=0
sources=$(find shaders -type f \( -name '*.glsl' -o -name '*.fsh' -o -name '*.vsh' \) | sort)

# 1. Every program entry point starts with a #version directive. This pack
#    targets GLSL 120, which both OptiFine and Iris accept.
for f in shaders/*.fsh shaders/*.vsh; do
	first=$(grep -m1 -v '^[[:space:]]*$' "$f")
	case "$first" in
		'#version '*) ;;
		*)
			echo "ERROR $f: first line must be a #version directive, found: $first"
			fail=1
			;;
	esac
done

# 2. Every entry point includes its body: all of them are wrappers in this pack,
#    so a wrapper with no #include is a file that silently renders nothing.
for f in shaders/*.fsh shaders/*.vsh; do
	if ! grep -q '#include "' "$f"; then
		echo "ERROR $f: no #include; entry points here are wrappers around a body"
		fail=1
	fi
done

# 3. Preprocessor conditionals must balance in every source file. A missing
#    #endif is the most common way an edit silently breaks a whole program.
#    Upstream ships a mix of LF and CRLF files, so trailing \r is stripped
#    before comparing: "#endif\r" is not "#endif".
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

# 4. Every #include must resolve inside shaders/. A renamed or deleted lib file
#    otherwise only shows up as a compile error in game.
missing=$(grep -h -o '#include "[^"]*"' $sources |
	sed 's/.*"\(.*\)"/\1/' | sort -u |
	while read -r inc; do
		[ -f "shaders$inc" ] || echo "ERROR missing include: $inc"
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
