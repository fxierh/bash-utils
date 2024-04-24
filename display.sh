function hle() {
    # Check if tput is available and supports at least 8 colors
    if command -v tput >/dev/null && [[ $(tput colors) -ge 8 ]]; then
        # Set the text color to yellow
        tput setaf 3
        echo "$@"
        # reset text formatting
        tput sgr0
        return
    fi

    # Fallback to plain echo if conditions are not met
    echo "$@"
}
