#!/usr/bin/env bash
# bootstrap.sh — Full Stack HQ one-line installer
#
# Preview first, without touching any host configuration:
#   curl -fsSL https://raw.githubusercontent.com/sabahattink/antigravity-fullstack-hq/main/bootstrap.sh | bash -s -- --dry-run
#
# The script fetches a temporary shallow checkout, runs install.sh with the
# same arguments, and removes the checkout afterwards. Every install.sh option
# is accepted. Pin a release or commit with FULL_STACK_HQ_REF=v1.3.0.

# Everything runs inside main so a truncated download never executes partially.
main() {
    set -euo pipefail

    local repo_url="${FULL_STACK_HQ_REPO_URL:-https://github.com/sabahattink/antigravity-fullstack-hq.git}"
    local ref="${FULL_STACK_HQ_REF:-main}"

    if ! command -v git >/dev/null 2>&1; then
        echo "Full Stack HQ needs git. Install git and run this command again." >&2
        exit 1
    fi

    # Global, so the EXIT trap can still see it after main returns.
    work_dir="$(mktemp -d "${TMPDIR:-/tmp}/full-stack-hq.XXXXXX")"
    trap 'rm -rf -- "$work_dir"' EXIT

    echo "Fetching Full Stack HQ ($ref) from $repo_url"
    git -C "$work_dir" init -q
    git -C "$work_dir" fetch -q --depth 1 "$repo_url" "$ref"
    git -C "$work_dir" -c advice.detachedHead=false checkout -q FETCH_HEAD
    echo "Using commit $(git -C "$work_dir" rev-parse --short HEAD)"

    # When this script arrives on stdin (curl | bash), the installer must not
    # read its prompt answers from the same pipe. Use the terminal when there is
    # one; otherwise answer "no" so existing instruction files are kept.
    if [[ -t 0 ]]; then
        bash "$work_dir/install.sh" "$@"
    elif (exec </dev/tty) 2>/dev/null; then
        bash "$work_dir/install.sh" "$@" </dev/tty
    else
        bash "$work_dir/install.sh" "$@" </dev/null
    fi
}

main "$@"
