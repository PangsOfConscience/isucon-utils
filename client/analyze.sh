#!/bin/bash

DEFAULT_ALP_OPTS="--sort p50 -r -m '/upload/[0-9a-z]+.jpg,/items/[0-9]+.json,/new_items/[0-9]+.json,/users/[0-9]+.json,/transactions/[0-9]+.png,/static/*'"

main() {
    local -r server=$1
    local alp_opts=$DEFAULT_ALP_OPTS
    if [ $# -gt 1 ]; then
        alp_opts=$2
    fi
    local -r user=$USER

    local -r script_dir=$(
        cd $(dirname $0)
        pwd
    )

    ssh -F ${script_dir}/.sshconfig $server "/home/isucon/isucon-utils/server/analyze.sh $user \"$alp_opts\""
}

main "$@"
