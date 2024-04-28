# Functions utilized by other utilities and directly by end users
# shellcheck disable=SC2034

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

# https://en.wikipedia.org/wiki/ANSI_escape_code#OSC
function wint() {
    printf '\033]0;%s\007' "$1"
}

function beep() {
    echo -ne "\a"
}

function notify() {
    local num_notifications=3

    # Parse options
    local OPTIND
    while getopts "n:" opt; do
        case $opt in
        n)
            num_notifications=$OPTARG
            ;;
        \?)
            return 1
            ;;
        esac
    done
    shift $((OPTIND - 1))

    # Execute the command
    "$@"
    local exit_status=$?

    # Make a number of noises
    for i in $(seq 1 "$num_notifications"); do
        beep
    done

    # Return the status of the command
    return $exit_status
}
