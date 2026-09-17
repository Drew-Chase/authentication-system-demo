#!/usr/bin/env bash
# Renames this template from "tavern-php-template" to a project name of your choosing.
# Usage: ./scripts/rename.sh [new-name] [--yes]
set -euo pipefail

OLD_SLUG="tavern-php-template"
OLD_SPACED="tavern php template"
OLD_TITLE="TAVERN Stack - Tailwindcss + React + HeroUI + Vite + Typescript"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXCLUDES=(.git node_modules vendor dist .idea)

NEW_SLUG="${1:-}"
ASSUME_YES=0
for arg in "$@"; do
    [ "$arg" = "--yes" ] || [ "$arg" = "-y" ] && ASSUME_YES=1
done
[ "${NEW_SLUG}" = "--yes" ] || [ "${NEW_SLUG}" = "-y" ] && NEW_SLUG=""

if [ -z "$NEW_SLUG" ]; then
    read -r -p "New project name: " NEW_SLUG
fi

# Normalize to an npm/composer-safe slug: lowercase, non-alphanumerics collapsed to dashes.
NEW_SLUG="$(printf '%s' "$NEW_SLUG" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')"

if [ -z "$NEW_SLUG" ]; then
    echo "error: name must contain at least one letter or digit" >&2
    exit 1
fi
if [ "$NEW_SLUG" = "$OLD_SLUG" ]; then
    echo "Project is already named '$OLD_SLUG'. Nothing to do."
    exit 0
fi

# Human-readable variants derived from the slug.
NEW_SPACED="${NEW_SLUG//-/ }"
NEW_TITLE="$(printf '%s' "$NEW_SPACED" | sed -E 's/(^| )([a-z])/\1\u\2/g')"

find_targets() {
    local args=(find "$ROOT")
    for dir in "${EXCLUDES[@]}"; do
        args+=(-name "$dir" -prune -o)
    done
    args+=(-type f -print)
    "${args[@]}"
}

mapfile -t FILES < <(find_targets | while read -r f; do
    # Skip the rename scripts themselves — they hold the patterns as literals.
    case "$(basename "$f")" in
        rename.sh | rename.ps1) continue ;;
    esac
    if grep -qIl -e "$OLD_SLUG" -e "$OLD_SPACED" -e "$OLD_TITLE" "$f" 2>/dev/null; then
        printf '%s\n' "$f"
    fi
done)

if [ "${#FILES[@]}" -eq 0 ]; then
    echo "No files reference '$OLD_SLUG'. Nothing to do."
    exit 0
fi

echo "Renaming '$OLD_SLUG' -> '$NEW_SLUG' (display: '$NEW_TITLE') in:"
printf '  %s\n' "${FILES[@]#"$ROOT"/}"

if [ "$ASSUME_YES" -eq 0 ]; then
    read -r -p "Proceed? [y/N] " reply
    case "$reply" in
        [yY] | [yY][eE][sS]) ;;
        *)
            echo "Aborted."
            exit 1
            ;;
    esac
fi

for f in "${FILES[@]}"; do
    # Longest/most specific pattern first so the page title isn't half-replaced.
    sed -i \
        -e "s|$OLD_TITLE|$NEW_TITLE|g" \
        -e "s|$OLD_SLUG|$NEW_SLUG|g" \
        -e "s|$OLD_SPACED|$NEW_SPACED|g" \
        "$f"
done

echo "Done. Review the diff with 'git diff' before committing."
echo "Note: the containing folder and the git remote are not renamed."
