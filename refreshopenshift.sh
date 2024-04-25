# shellcheck disable=SC2154

function rekube() {
    kubeid=$1

    # Ensure to replace "/path/to/bash-utils" with the actual path where you've cloned the repo
    OPENSHIFT_DIR="/path/to/kubeconfig"

    if [ -z "$1" ]; then
        # no parameter was provided, copy the kubeconfig under download to the environment variable.
        
        # Change to default download folder
        mv /Users/jitli/Downloads/kubeconfig "$OPENSHIFT_DIR"
        export KUBECONFIG="$OPENSHIFT_DIR/kubeconfig"
        echo "Moved kubeconfig file!"
        echo "rekubed !"
        echo "export KUBECONFIG=$OPENSHIFT_DIR/kubeconfig"
        oc version
    else
        # Download new kubeconfig file from JenkinsID
        rm -f "$OPENSHIFT_DIR/kubeconfig"
        wget -O "$OPENSHIFT_DIR/kubeconfig" "https://mastern-jenkins-csb-openshift-qe.apps.ocp-c1.prod.psi.redhat.com/job/ocp-common/job/Flexy-install/$kubeid/artifact/workdir/install-dir/auth/kubeconfig"
        export KUBECONFIG="$OPENSHIFT_DIR/kubeconfig"
        echo "rekubed !"
        echo "export KUBECONFIG=$OPENSHIFT_DIR/kubeconfig"
        oc version
    fi
}

