#!/usr/bin/env bash
# install.sh: puts this repo's CLAUDE.md at ~/.claude/CLAUDE.md, where Claude Code loads it in every session.
# Safe to run again. A different file already there is kept as a dated backup.
#   ./install.sh              install or update
#   ./install.sh --uninstall  remove it, and bring back the newest backup if there is one
set -Eeuo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
src=$here/CLAUDE.md
dir=$HOME/.claude
dst=$dir/CLAUDE.md

[[ -s $src ]] || { echo "CLAUDE.md is missing next to install.sh." >&2; exit 1; }

# A link means another tool manages this file (for example a dotfiles repo), so it's left alone.
if [[ -L $dst ]]; then
  echo "$dst is a link to another file. Update that file instead, or remove the link and run this again." >&2
  exit 1
fi

if [[ ${1:-} == --uninstall ]]; then
  [[ -e $dst ]] || { echo "Nothing to remove."; exit 0; }
  latest=$(find "$dir" -maxdepth 1 -name 'CLAUDE.md.bak-*' | sort | tail -1)
  if [[ -n $latest ]]; then mv -f "$latest" "$dst"; echo "Removed, and restored $(basename "$latest")."
  else rm -f "$dst"; echo "Removed."; fi
  exit 0
fi

mkdir -p "$dir"
if [[ -e $dst ]] && cmp -s "$src" "$dst"; then
  echo "Already up to date: $dst"
  exit 0
fi
if [[ -e $dst ]]; then
  backup=$dst.bak-$(date +%Y%m%d-%H%M%S)
  cp -p "$dst" "$backup"
  echo "Kept your old file as $(basename "$backup")."
fi
tmp=$(mktemp "$dir/.CLAUDE.md.XXXXXX")
cp "$src" "$tmp"
chmod 644 "$tmp"
mv -f "$tmp" "$dst"
echo "Installed: $dst"
echo "Check it in Claude Code with: /memory"
