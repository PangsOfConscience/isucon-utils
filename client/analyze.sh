#!/bin/bash

DEFAULT_ALP_OPTS=""

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

    ssh -F ${script_dir}/.sshconfig $server "/home/isucon/isucon-utils/server/deploy.sh $user \"$alp_opts\""
}

main "$@"
