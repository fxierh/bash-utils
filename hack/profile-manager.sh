#!/usr/bin/env bash

set -euo pipefail

function usage() {
    echo "Usage: ${0##*/} [add|remove] line_to_add_or_remove ..."
}

# Backup the profile
function backup_profile() {
    cp "$HOME/.bash_profile" "$HOME/.bash_profile.bak"
    echo "Backup of .bash_profile created at $HOME/.bash_profile.bak"
}

# Add configuration to the profile
function add_to_profile() {
    local line
    echo >> "$HOME/.bash_profile"
    for line in "$@"; do
        echo "$line" >> "$HOME/.bash_profile"
    done
    echo >> "$HOME/.bash_profile"
    echo "Configurations added to .bash_profile"
}

# Remove configuration from the profile
function remove_from_profile() {
    local line
    local updated_profile_content
    updated_profile_content="$(grep -Fxv -f <(printf "%s\n" "$@") "$HOME/.bash_profile")"
    echo "$updated_profile_content" > "$HOME/.bash_profile"
    echo "Configuration removed from .bash_profile"
}

# Main
if (( $# < 2 )); then
    usage
    exit 1
fi

action="$1"
if [[ "$action" != add && "$action" != remove ]]; then
    usage
    exit 1
fi
shift

backup_profile

case "$action" in
add)
    add_to_profile "$@"
    ;;
remove)
    remove_from_profile "$@"
    ;;
esac
