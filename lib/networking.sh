# shellcheck disable=SC2154

function proxy() {
    http_proxy="$default_http_proxy" https_proxy="$default_https_proxy" no_proxy="$default_no_proxy" \
    HTTP_PROXY="$default_http_proxy" HTTPS_PROXY="$default_https_proxy" NO_PROXY="$default_no_proxy" "$@"
}
