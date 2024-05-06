# Functions utilized by other utilities and directly by end users
# shellcheck disable=SC2034

function hle() {
    local color

    # Parse options
    local OPTIND
    while getopts "c:" opt; do
        case $opt in
        c)
            color="$OPTARG"
            ;;
        \?)
            return 1
            ;;
        esac
    done
    shift $((OPTIND - 1))

    # Check if a color is specified and that the terminal supports coloring.
    if [[ -n "$color" ]] && command -v tput >/dev/null && [[ $(tput colors) -ge 8 ]]; then
        # Set the text color
        tput setaf "$color"
        echo "$@"
        # reset text formatting
        tput sgr0
        return
    fi

    # Fallback to plain echo if conditions are not met
    echo "$@"
}

function err() {
    hle -c 1 "$@" >&2
}

function warn() {
    hle -c 3 "$@"
}

function succ() {
    hle -c 2 "$@"
}

# https://en.wikipedia.org/wiki/ANSI_escape_code#OSC
function wint() {
    printf '\033]0;%s\007' "$1"
}

function beep() {
    echo -ne "\a"
}

function notify() {
    local broadcast
    local broadcast_msg
    local num_beeps=3

    # Parse options
    local OPTIND
    while getopts "b:w:" opt; do
        case $opt in
        b)
            num_beeps="$OPTARG"
            ;;
        w)
            broadcast="true"
            broadcast_msg="$OPTARG"
            ;;
        \?)
            return 1
            ;;
        esac
    done
    shift $((OPTIND - 1))

    # Check if any command is provided
    if [ "$#" -eq 0 ]; then
        err "No command provided, exiting"
        return 1
    fi

    # Execute the command
    "$@"
    local exit_status=$?

    # Broad if requested
    if [[ "$broadcast" = "true" ]]; then
        wall <<< "${broadcast_msg:-"Command '$*' terminated with exit status $exit_status"}"
    fi

    # Make a number of beeps
    for i in $(seq 1 "$num_beeps"); do
        beep
    done

    # Return the status of the command
    return $exit_status
}
