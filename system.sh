# shellcheck disable=SC2016
# shellcheck disable=SC2123

# Restore $PATH for login shells
function _repath_login() {
    # Source system-wide profiles
    source /etc/profile || return 1

    # Source the first available user profile
    if [ -f "$HOME/.bash_profile" ]; then
        source "$HOME/.bash_profile" || return 1
    elif [ -f "$HOME/.bash_login" ]; then
        source "$HOME/.bash_login" || return 1
    elif [ -f "$HOME/.profile" ]; then
        source "$HOME/.profile" || return 1
    fi
}

# Restore $PATH for non-login shells
function _repath_non_login() {
    if [ -f "$HOME/.bashrc" ]; then
        source "$HOME/.bashrc" || return 1
    fi
}

function repath() {
    local login_shell=true

    # Parse options
    local OPTIND
    while getopts "n" opt; do
        case $opt in
        n)
            login_shell=false
            ;;
        \?)
            return 1
            ;;
        esac
    done
    shift $((OPTIND - 1))

    # Restore $PATH depending on whether the shell is a login shell or not
    if [[ "$login_shell" = true ]]; then
        _repath_login || return 1
    else
        _repath_non_login || return 1
    fi

    # Deduplication
    PATH="$(dedup -d ':' "$PATH")"
    PROMPT_COMMAND="$(dedup -d '; ' "$PROMPT_COMMAND")"

    echo '$PATH restored to:'
    echo "$PATH"
}

function add2path() {
    local add_to_beginning=false
    local path_to_add

    # Parse options
    local opt
    local OPTIND
    while getopts "b" opt; do
        case $opt in
        b)
            add_to_beginning=true
            ;;
        \?)
            return 1
            ;;
        esac
    done
    shift $((OPTIND - 1))

    # Abort if no path is specified
    path_to_add="$1"
    if [[ -z "$path_to_add" ]]; then
        err "No path specified"
        return 1
    fi

    # Abort if the path to add already exists in $PATH
    if [[ ":$PATH:" = *":$path_to_add:"* ]]; then
        echo "$path_to_add already exists in \$PATH, doing nothing"
        return 0
    fi

    # Error out if the path to add is relative
    if [[ "$path_to_add" != /* ]]; then
        err "Should not add relative path ($path_to_add) to \$PATH"
        return 1
    fi

    # Add to path
    if [[ "$add_to_beginning" = "true" ]]; then
        PATH="$path_to_add:$PATH"
    else
        PATH="$PATH:$path_to_add"
    fi

    succ "$path_to_add added to \$PATH"
}
