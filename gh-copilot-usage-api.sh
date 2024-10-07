#! /bin/bash

usage() {
    echo "Usage: $0 -o <org_name> -t <gh_token>"
    echo "Options:"
    echo "  -h, --help     Display this help message"
    exit 1
}

validate_arguments() {
    if [[ -z $ORG_NAME || -z $GH_TOKEN ]]; then
        echo "Error: Missing arguments"
        usage
    fi
}

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -h|--help)
        usage
        ;;
        -o|--org)
        ORG_NAME="$2"
        shift
        ;;
        -t|--token)
        GH_TOKEN="$2"
        shift
        ;;
        *)
        break
        ;;
    esac

    shift
done

validate_arguments

curl \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GH_TOKEN}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/orgs/${ORG_NAME}/copilot/usage"