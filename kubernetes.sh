# shellcheck disable=SC2154

function extexp() {
    local job_id="$1"
    if [ -z "$job_id" ]; then
        echo "No flexy-install ID provided. Exiting."
        return 1
    fi

    # Extend the cluster expiration by calling Jenkins API
    if ! curl --insecure --silent "$default_ext_cluster_exp_api" \
        --user "$default_jenkins_uname:$default_jenkins_token" \
        --data "FLEXY_INSTALL_ID=$job_id" \
        --data "EXPIRES_IN_HOURS=35"; then
        echo "Failed to extend cluster expiration."
        return 1
    fi
    echo "Cluster expiration extended successfully."
}

function kget() {
    local job_id="$1"
    local target_kubeconfig_path="$2"
    if [ -z "$job_id" ]; then
        echo "No flexy-install ID provided. Exiting."
        return 1
    fi
    if [ -z "$target_kubeconfig_path" ]; then
        echo "No target kubeconfig path provided. Exiting."
        return 1
    fi

    # Download kubeconfig
    if ! wget --quiet --output-document "$target_kubeconfig_path" "${default_flexy_kubeconfig_url/JOBID/$job_id}"; then
        echo "Failed to download kubeconfig."
        return 1
    fi
    echo "Kubeconfig downloaded successfully."
}

function rekube() {
    local opt
    local job_id
    local extend_lifetime
    local target_kubeconfig_path="$default_target_kubeconfig_dir/kubeconfig"

    # Parse options
    local OPTIND
    while getopts "e" opt; do
        case $opt in
        e)
            extend_lifetime=true
            ;;
        \?)
            return 1
            ;;
        esac
    done
    shift $((OPTIND - 1))

    # Parse positional arguments
    job_id="$1"
    if [ -z "$job_id" ]; then
        # No job ID provided; move the kubeconfig from the download directory to the target directory.
        mv "$default_kubeconfig_download_dir"/kubeconfig "$target_kubeconfig_path" || return 1
    else
        # Job ID provided; download the kubeconfig file from the specified Jenkins job using the given job ID.
        kget "$job_id" "$target_kubeconfig_path" || return 1

        # Extend cluster expiration if requested
        if [[ "$extend_lifetime" = true ]]; then
            extexp "$job_id"
        fi
    fi

    echo "Rekubed to $target_kubeconfig_path !"
    export KUBECONFIG="$target_kubeconfig_path"
    oc version
}

function fdestroy() {
    local job_id="$1"
    if [ -z "$job_id" ]; then
        echo "No flexy-install ID provided. Exiting."
        return 1
    fi

    # Invoke flexy-destroy by calling Jenkins API
    if ! curl --insecure --silent "$default_flexy_destroy_api" \
        --user "$default_jenkins_uname:$default_jenkins_token" \
        --data "BUILD_NUMBER=$job_id"; then
        echo "Failed to invoke flexy-destroy."
        return 1
    fi
    echo "flexy-destroy invoked successfully."
}
