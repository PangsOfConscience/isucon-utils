#!/bin/sh
#
# 通知を行いデプロイを開始します
set -ex

echo_err() {
    echo "$1" 1>&2
}

# https://blog.yuuk.io/entry/web-operations-isucon を参考に
main() {
    local -r user_name=$1
    local -r script_dir=$(
        cd $(dirname $0)
        pwd
    )

    cd ${HOME}/isucari/webapp/go
    git pull
    local -r commit_hash=$(git rev-parse --short HEAD)
    ${script_dir}/notify.sh "${user_name}: $commit_hash deploying..."
    make isucari
    sudo systemctl restart mysql
    sudo systemctl restart nginx
    ${script_dir}/notify.sh "${user_name}: $commit_hash deploy done!"
}

main "$@"
