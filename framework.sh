# Functions utilized by other utilities and directly by end users

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

function _hle() {
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

function _err() {
    _hle -c 1 "$(_prepend_callstack -n 2 "$@")" >&2
}

function _warn() {
    _hle -c 3 "$(_prepend_callstack -n 2 "$@")" >&2
}

function _succ() {
    _hle -c 2 "$@"
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
        _warn "Too many arguments provided, using the first one only"
        input="$1"
    elif (( "$#" == 1 )); then
        input="$1"
    else
        # Reads from standard input until EOF
        input="$(cat)"
    fi

    # Check for non-empty input if required
    if [[ "$non_empty" == "true" ]] && [[ -z "$input" ]]; then
        _err "Empty input"
        return 1
    fi

    echo "$input"
}

# TODO: add Linux support
function _save2clipboard() {
    local input

    # Get input
    input="$(_get_input -n "$@")" || return 1

    # Save input to clipboard depending on the OS
    case "$OSTYPE" in
    "darwin"*)
        pbcopy <<< "$input" || return 1
        ;;
    *)
        _err "save2clipboard does not support $OSTYPE"
        return 1
        ;;
    esac

    _succ "Text saved to clipboard"
}
