#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$(readlink -f "$0")")/../bootstrap.sh"

function usage() {
    echo "Usage: ${0##*/} [flat_options]"
}

while true; do
    echo "Enter multiline input (press Ctrl-D when done, press Ctrl-C to exit): "
    input=$(cat)

    # Check if input is empty
    if [[ -z "$input" ]]; then
        _err "Empty input"
        continue
    fi

    # Process the input using the flat with options passed if any
    if ! flat "$@" "$input"; then
        _err "Failed to process input with flat."
    fi

    # Add an empty line for readability
    echo
done
