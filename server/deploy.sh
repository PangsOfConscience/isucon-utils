#!/usr/bin/env bash
#
# 通知を行いデプロイを開始します
set -ex

echo_err() {
    echo "$1" 1>&2
}

# https://blog.yuuk.io/entry/web-operations-isucon を参考に
main() {
    local -r user_name=$1
    local -r branch=$2
    local -r script_dir=$(
        cd $(dirname $0)
        pwd
    )

    source $HOME/.bash_profile # READ Environment Variable
    cd /home/isucon/isucari/webapp/go
    git checkout -B $branch origin/$branch
    git pull
    local -r commit_hash=$(git rev-parse --short HEAD)
    local -r commit_message=$(git log -1 --pretty='%s')
    ${script_dir}/notify.sh "${user_name}: deploying...\n\`\`\`target_branch: $branch\n$commit_hash\n$commit_message\`\`\`"
    make isucari
    sudo systemctl restart mysql
    sudo systemctl restart nginx
    ${script_dir}/notify.sh "${user_name}: deploy done!\`\`\`target_branch: $branch\n$commit_hash\n$commit_message\`\`\`"
}

main "$@"
