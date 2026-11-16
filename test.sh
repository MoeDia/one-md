#!/usr/bin/env bash
# test.sh: checks the file and the installer, in a throw-away home. Exit 0 only if everything passes.
set -Eeuo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
fails=0
t() { local n=$1; shift; if "$@" >/dev/null 2>&1; then echo "ok   $n"; else echo "FAIL $n"; fails=$((fails + 1)); fi; }
tn() { local n=$1; shift; if "$@" >/dev/null 2>&1; then echo "FAIL $n"; fails=$((fails + 1)); else echo "ok   $n"; fi; }

# The file itself
lines=$(wc -l <"$here/CLAUDE.md")
t "CLAUDE.md is under the 200 lines Claude Code's docs recommend ($lines)" test "$lines" -lt 200
t "it starts with a title" grep -q '^# ' "$here/CLAUDE.md"
tn "no unfinished placeholders" grep -qiE 'TODO|FIXME|XXX|lorem' "$here/CLAUDE.md"
tn "no secrets or keys in it" grep -qE '(sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|BEGIN [A-Z ]*PRIVATE KEY)' "$here/CLAUDE.md"
t "every section has content" python3 -c 'import re,sys; t=open(sys.argv[1]).read(); parts=re.split(r"^## .*$",t,flags=re.M)[1:]; sys.exit(0 if parts and all(p.strip() for p in parts) else 1)' "$here/CLAUDE.md"
tn "no personal names or projects in it" grep -qiE '\b(dia|mohamed|eldoush|fluvia|dialpip|extracto|fedokawaii|triad)\b' "$here/CLAUDE.md"
t "every section is described in the README" python3 -c 'import re,sys; s=re.findall(r"^## (.+)$",open(sys.argv[1]).read(),re.M); r=open(sys.argv[2]).read(); sys.exit(0 if s and all(("| "+x+" |") in r for x in s) else 1)' "$here/CLAUDE.md" "$here/README.md"
t "the README names no section the file lacks" python3 -c 'import re,sys; s=set(re.findall(r"^## (.+)$",open(sys.argv[1]).read(),re.M)); r=open(sys.argv[2]).read(); t=r[r.index("| Section"):].split("\n\n")[0]; rows=[l.split("|")[1].strip() for l in t.splitlines()[2:]]; sys.exit(0 if rows and all(x in s for x in rows) else 1)' "$here/CLAUDE.md" "$here/README.md"
if command -v shellcheck >/dev/null; then t "shellcheck" shellcheck -S style "$here/install.sh" "$here/test.sh"; fi

# The installer, in a throw-away home
h=$(mktemp -d); trap 'rm -rf "$h"' EXIT
run() { HOME=$h "$here/install.sh" "$@"; }
t "installs into an empty home" run
t "the installed file is identical" cmp -s "$here/CLAUDE.md" "$h/.claude/CLAUDE.md"
t "running again changes nothing" bash -c "HOME=$h '$here/install.sh' | grep -q 'Already up to date'"
tn "and makes no backup" bash -c "ls $h/.claude/CLAUDE.md.bak-* 2>/dev/null | grep -q ."
echo "my own rules" >"$h/.claude/CLAUDE.md"; sleep 1
t "replaces a different file" run
t "but keeps it as a backup" bash -c "grep -q 'my own rules' $h/.claude/CLAUDE.md.bak-*"
t "uninstall brings the backup back" run --uninstall
t "the old file is back" grep -q 'my own rules' "$h/.claude/CLAUDE.md"
rm -f "$h/.claude/CLAUDE.md"; ln -s /dev/null "$h/.claude/CLAUDE.md"
tn "a home-manager link is never overwritten" run
t "and is left as it was" test -L "$h/.claude/CLAUDE.md"
rm -f "$h/.claude/CLAUDE.md"
t "uninstall with nothing there is fine" run --uninstall
mv "$here/CLAUDE.md" "$h/hidden"; tn "refuses when CLAUDE.md is missing" run; mv "$h/hidden" "$here/CLAUDE.md"

echo; if ((fails)); then echo "$fails failed"; exit 1; fi; echo "All passed."
