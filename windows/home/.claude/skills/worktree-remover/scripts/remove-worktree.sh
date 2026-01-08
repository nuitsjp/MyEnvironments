#!/usr/bin/env bash
# remove-worktree.sh - Remove a worktree and output its branch name
# Usage: ./remove-worktree.sh <worktree-path>
# Output: Prints the branch name associated with the removed worktree

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <worktree-path>" >&2
    exit 1
fi

WORKTREE_PATH="${1%/}"

# Get worktree list and find the branch
BRANCH_NAME=""
CURRENT_WORKTREE=""

while IFS= read -r line; do
    if [[ "$line" =~ ^worktree\ (.+)$ ]]; then
        CURRENT_WORKTREE="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^branch\ refs/heads/(.+)$ ]]; then
        if [[ "$CURRENT_WORKTREE" == "$WORKTREE_PATH" ]] || [[ "$CURRENT_WORKTREE" == "$(realpath "$WORKTREE_PATH" 2>/dev/null || echo "")" ]]; then
            BRANCH_NAME="${BASH_REMATCH[1]}"
            break
        fi
    fi
done < <(git worktree list --porcelain)

if [[ -z "$BRANCH_NAME" ]]; then
    # Try with realpath
    RESOLVED_PATH=$(realpath "$WORKTREE_PATH" 2>/dev/null || echo "")
    if [[ -n "$RESOLVED_PATH" ]]; then
        while IFS= read -r line; do
            if [[ "$line" =~ ^worktree\ (.+)$ ]]; then
                CURRENT_WORKTREE="${BASH_REMATCH[1]}"
            elif [[ "$line" =~ ^branch\ refs/heads/(.+)$ ]]; then
                if [[ "$CURRENT_WORKTREE" == "$RESOLVED_PATH" ]]; then
                    BRANCH_NAME="${BASH_REMATCH[1]}"
                    break
                fi
            fi
        done < <(git worktree list --porcelain)
    fi
fi

if [[ -z "$BRANCH_NAME" ]]; then
    echo "Error: Worktree not found: $WORKTREE_PATH" >&2
    exit 1
fi

# Remove worktree
if ! git worktree remove "$WORKTREE_PATH"; then
    echo "Error: Failed to remove worktree: $WORKTREE_PATH" >&2
    exit 1
fi

# Output branch name for optional deletion
echo "$BRANCH_NAME"
