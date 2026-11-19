#!/usr/bin/env bash
#
# Structural checks for the SiraLite shader sources.
#
# These checks catch the mistakes that a human review of 30 small files misses:
# a missing #version line, an unbalanced brace, a fragment shader input that the
# vertex shader never writes, a broken #include path. They are NOT a GLSL
# compiler and they cannot tell you whether the shader looks right or runs fast.
#
# Usage: bash tools/check_shaders.sh

set -u

cd "$(dirname "$0")/.." || exit 1

fail=0

# 1. Every program must start with the GLSL version directive Iris needs for the
#    compatibility built-ins (gl_Vertex, gl_ModelViewMatrix, ftransform).
for f in shaders/*.vsh shaders/*.fsh; do
	first=$(grep -m1 -v '^[[:space:]]*$' "$f")
	if [ "$first" != "#version 330 compatibility" ]; then
		echo "ERROR $f: first line must be '#version 330 compatibility', found: $first"
		fail=1
	fi
done

# 2. Balanced braces and parentheses, ignoring nothing: comments in this project
#    are written to keep them balanced too, which doubles as a comment typo check.
for f in shaders/*.vsh shaders/*.fsh shaders/lib/*.glsl; do
	if ! awk -v file="$f" '
		{
			for (i = 1; i <= length($0); i++) {
				c = substr($0, i, 1)
				if (c == "{") o++
				else if (c == "}") o--
				else if (c == "(") p++
				else if (c == ")") p--
			}
		}
		END {
			if (o != 0 || p != 0) {
				printf "ERROR %s: unbalanced braces (%d) or parentheses (%d)\n", file, o, p
				exit 1
			}
		}
	' "$f"; then
		fail=1
	fi
done

# 3. Every fragment shader that writes to a buffer must say which one.
for f in shaders/gbuffers_*.fsh shaders/composite*.fsh shaders/shadow.fsh; do
	[ -f "$f" ] || continue
	if ! grep -q 'RENDERTARGETS' "$f"; then
		echo "ERROR $f: no RENDERTARGETS comment"
		fail=1
	fi
done

# 4. Every 'in' of a fragment shader needs a matching 'out' of its vertex shader.
#    Only lines that really declare a variable are considered, so a comment that
#    happens to start with the word "in" cannot trip the check.
for f in shaders/*.fsh; do
	v="${f%.fsh}.vsh"
	[ -f "$v" ] || continue
	problems=$(awk -v fsh="$f" -v vsh="$v" '
		BEGIN { types = "^(float|int|uint|bool|vec2|vec3|vec4|ivec2|ivec3|ivec4|uvec2|uvec3|uvec4|mat2|mat3|mat4)$" }
		FNR == NR {
			if ($1 == "out" && $2 ~ types) { n = $3; gsub(";", "", n); outs[n] = 1 }
			next
		}
		$1 == "in" && $2 ~ types {
			n = $3
			gsub(";", "", n)
			if (!(n in outs)) printf "ERROR %s: varying %s is not written by %s\n", fsh, n, vsh
		}
	' "$v" "$f")
	if [ -n "$problems" ]; then
		echo "$problems"
		fail=1
	fi
done

# 5. Every #include must resolve inside shaders/.
missing=$(grep -h -o '#include "[^"]*"' shaders/*.vsh shaders/*.fsh shaders/lib/*.glsl |
	sed 's/.*"\(.*\)"/\1/' | sort -u |
	while read -r inc; do
		[ -f "shaders$inc" ] || echo "ERROR missing include: $inc"
	done)
if [ -n "$missing" ]; then
	echo "$missing"
	fail=1
fi

# 6. An option must not be defined in two places with different values.
duplicates=$(grep -h -E '^[[:space:]]*(//)?#define [A-Z_0-9]+[[:space:]]' shaders/lib/*.glsl |
	sed -e 's|^[[:space:]]*//||' -e 's|^#define[[:space:]]*||' -e 's|[[:space:]]*//.*||' |
	awk '{ if ($1 != "") { if ($1 in seen && seen[$1] != $0) print "ERROR option " $1 " is defined twice with different values"; seen[$1] = $0 } }')
if [ -n "$duplicates" ]; then
	echo "$duplicates"
	fail=1
fi

if [ "$fail" -ne 0 ]; then
	echo ""
	echo "Shader source checks FAILED."
	exit 1
fi

echo "All shader source checks passed."
