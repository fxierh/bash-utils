# https://en.wikipedia.org/wiki/ANSI_escape_code#OSC

function wint() {
    printf '\033]0;%s\007' "$1"
}
