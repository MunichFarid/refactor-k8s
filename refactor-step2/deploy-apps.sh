#!/usr/bin/env bash
set -o pipefail
set -o nounset
set -o errexit

err_report() {
    echo "Exited with error on line $1"
}
trap 'err_report $LINENO' ERR

function print_help {
    echo "usage: $0 --action ACTION"
    echo "Install the Apps."
    echo "-h,--help print this help."
    echo "--action Specify the action to perform (e.g., install (default), uninstall, template or dry-run)."
}

POSITIONAL=()

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--help)
            print_help
            exit 1
            ;;
        --action)
            HELM_ACTION=$2
            shift
            shift
            ;;
        *)    # unknown option
            POSITIONAL+=("$1") # save it in an array for later
            shift # past argument
            ;;
    esac
done

HELM_ACTION="${HELM_ACTION:-}"

if [ -z "$HELM_ACTION" ]; then
    # Defaults to install
    HELM_ACTION="install"
fi

if [[ "$HELM_ACTION" == "uninstall" ]]; then
    helm uninstall app-nginx-tw
    helm uninstall app-nginx-blue
else
    helm dependency build app-nginx-tw
    helm dependency build app-nginx-blue
    helm upgrade -i app-nginx-tw app-nginx-tw -f config/common.yaml
    helm upgrade -i app-nginx-blue app-nginx-blue -f config/common.yaml
fi
