#!/usr/bin/env bash

set -euo pipefail

function usage() {
    echo "Usage: ${0##*/} [install|uninstall] script_directory"
}

# Install scripts
function install_scripts() {
    local base_name
    local script

    echo "Installing scripts..."
    while IFS= read -r -d '' script; do
        base_name=$(basename "$script" .sh)
        sudo ln -sfn "$script" "$script_directory/$base_name"
    done < <(find "$project_root_directory/scripts" -type f -name '*.sh' -print0)
    echo "Scripts installed to $script_directory."
}

# Uninstall scripts
function uninstall_scripts() {
    local base_name
    local script

    echo "Uninstalling scripts..."
    while IFS= read -r -d '' script; do
        base_name=$(basename "$script" .sh)
        sudo rm -f "$script_directory/$base_name"
    done < <(find ./scripts -type f -name '*.sh' -print0)
    echo "Scripts uninstalled from $script_directory."
}

# Main
if (( $# != 2 )); then
    usage
    exit 1
fi

action="$1"
script_directory="$2"
project_root_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Handling command line option
case "$action" in
install)
    install_scripts
    ;;
uninstall)
    uninstall_scripts
    ;;
*)
    usage
    exit 1
    ;;
esac
