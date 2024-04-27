# shellcheck disable=SC2016

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

    echo '$PATH restored to:'
    echo "$PATH"
}
