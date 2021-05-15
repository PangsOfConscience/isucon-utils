#!/usr/bin/env bash
#
# サーバに必要な分析ツール類などをインストールする

set -eux

install_alp() {
    curl -sL -o alp.zip https://github.com/tkuchiki/alp/releases/download/v1.0.3/alp_linux_amd64.zip
    unzip alp.zip
    rm -f alp.zip
    sudo install -o root -g root -m 0755 alp /usr/local/bin/alp
}

install_with_pkgsys() {
    local -r name=$1

    local -r yum_cmd=$(which yum)
    local -r apt_cmd=$(which apt)

    if [[ ! -z $yum_cmd ]]; then
        sudo yum install $name
    elif [[ ! -z $apt_cmd ]]; then
        sudo apt install $name
    else
        echo "can't find package system."
    fi
}

# https://www.percona.com/doc/percona-toolkit/3.0/installation.html
install_pt_query_digest() {
    install_with_pkgsys percona-toolkit
}

# https://blog.zoe.tools/entry/2020/07/26/181836
# pprofの依存ライブラリ
install_graphviz() {
    install_with_pkgsys graphviz
}

main() {
    install_alp
    install_pt_query_digest
    install_graphviz
}

main "$@"
