# Functions utilized by other utilities and directly by end users
# shellcheck disable=SC2034

function _prepend_callstack() {
    # Default to skipping the current function name
    local n_skip=1

    # Parse options
    local opt
    local OPTIND
    while getopts "n:" opt; do
        case $opt in
        n)
            n_skip="$OPTARG"
            ;;
        \?)
            return 1
            ;;
        esac
    done
    shift $((OPTIND - 1))

    # Ensure provided value is a number
    if [[ ! $n_skip =~ ^[[:digit:]]+$ ]]; then
        echo "Error: Argument for -n must be a numeric value." >&2
        return 1
    fi

    local callstack="${FUNCNAME[*]:$n_skip}"
    if [[ -n "$callstack" ]]; then
        echo -n "${callstack// / <- }: "
    fi
    echo "$@"
}

function hle() {
    local color

    # Parse options
    local opt
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
    hle -c 1 "$(_prepend_callstack -n 2 "$@")" >&2
}

function warn() {
    hle -c 3 "$(_prepend_callstack -n 2 "$@")" >&2
}

function succ() {
    hle -c 2 "$@"
}

function _get_input() {
    local input
    local non_empty

    # Parse options
    local opt
    local OPTIND
    while getopts "n" opt; do
        case $opt in
        n)
            non_empty="true"
            ;;
        \?)
            return 1
            ;;
        esac
    done
    shift $((OPTIND - 1))

    # Read input based on the number of remaining arguments
    if (( "$#" > 1 )); then
        warn "Too many arguments provided, using the first one only"
        input="$1"
    elif (( "$#" == 1 )); then
        input="$1"
    else
        # Reads from standard input until EOF
        input="$(cat)"
    fi

    # Check for non-empty input if required
    if [[ "$non_empty" = "true" ]] && [[ -z "$input" ]]; then
        err "Empty input"
        return 1
    fi

    echo "$input"
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
    local opt
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

function dedup() {
    local input
    local delimiter

    # Parse options
    local opt
    local OPTIND
    while getopts "d:" opt; do
        case $opt in
        d)
            delimiter="$OPTARG"
            ;;
        \?)
            return 1
            ;;
        esac
    done
    shift $((OPTIND - 1))

    # Check if delimiter is empty
    if [[ -z "$delimiter" ]]; then
        err "Empty delimiter, exiting"
        return 1
    fi

    # Get input
    input="$(_get_input -n "$@")" || return 1

    # Use awk to process the string and remove duplicates
    local awk_command="
BEGIN {
    FS = \"$delimiter\"
    sep = \"\"
}
{
    for (i = 1; i <= NF; i++) {
        field=\$i
        if (!seen[field]++) {
            printf \"%s%s\", sep, field
            sep=FS
        }
    }
}"
    awk "$awk_command" <<< "$input"
}

# TODO: add Linux support
function save2clipboard() {
    local input

    # Get input
    input="$(_get_input -n "$@")" || return 1

    # Save input to clipboard depending on the OS
    case "$OSTYPE" in
    "darwin"*)
        pbcopy <<< "$input" || return 1
        ;;
    *)
        err "save2clipboard does not support $OSTYPE"
        return 1
        ;;
    esac

    succ "Text saved to clipboard"
}
