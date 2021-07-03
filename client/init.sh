#!/usr/bin/env bash
#
# ISUCON参加時にローカルPCでのセットアップを行う

set -eu

echo_err() {
    echo "$1" 1>&2
}

usage_exit() {
    prog="./$(basename $0)"
    echo_err "usage: $prog [OPTIONS...]"
    echo_err ""
    echo_err "options:"
    echo_err " -b  : Specify bastion server IP if you use"
    echo_err " -s  : Set servers that is separated by comma"
    echo_err " -p  : Set ssh port"
    exit 1
}

main() {
    local -r script_dir=$(
        cd $(dirname $0)
        pwd
    )

    # Default Value
    local bastion
    local servers
    local port=22

    while getopts b:s:p: OPT; do
        case $OPT in
        b)
            bastion=$OPTARG
            ;;
        s)
            servers=($OPTARG)
            ;;
        p)
            port=$OPTARG
            ;;
        h)
            usage_exit
            ;;
        \?)
            usage_exit
            ;;
        esac
    done

    echo "${servers[@]}"
    if [ -z "${servers[@]}" ]; then
        echo_err "You must specify -s option!"
        usage_exit
    fi

    local template
    if [ -z "$bastion" ]; then
        template=${script_dir}/tmpl/.sshconfig
    else
        template=${script_dir}/tmpl/.sshconfig_via_bastion
    fi

    # TODO: 他項目のsedも追加する
    cat $template | sed -e 's|<REPLACE_YOUR_BASTION_IP>|'${bastion}'|g' \
        -e 's|<REPLACE_YOUR_SERVER1_IP>|'${servers[0]:-REPLACE_YOUR_SERVER1_IP}'|g' \
        -e 's|<REPLACE_YOUR_SERVER2_IP>|'${servers[1]:-REPLACE_YOUR_SERVER2_IP}'|g' \
        -e 's|<REPLACE_YOUR_SERVER3_IP>|'${servers[2]:-REPLACE_YOUR_SERVER3_IP}'|g' \
        >${script_dir}/.sshconfig
}

main "$@"
