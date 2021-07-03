#!/usr/bin/env bash
#
# サーバに必要な分析ツール類などをインストールする

set -eux

install_alp() {
    curl -sL -o alp.zip https://github.com/tkuchiki/alp/releases/download/v1.0.3/alp_linux_amd64.zip
    unzip alp.zip
    rm -f alp.zip
    sudo install -o root -g root -m 0755 alp /usr/local/bin/alp
    alp --version && echo "Success Install alp 🎉"
}

install_with_pkgsys() {
    local name=$1

    local yum_cmd=$(which yum)
    local apt_cmd=$(which apt)

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
    pt-query-digest --version && echo "Success Install pt-query-digest 🎉"
}

# https://blog.zoe.tools/entry/2020/07/26/181836
# pprofの依存ライブラリ
install_graphviz() {
    install_with_pkgsys graphviz
    dot -V && echo "Success Install graphviz 🎉"
}

change_nginx_logformat() {
    echo 'log_format ltsv "time:$time_local"
                "\thost:$remote_addr"
                "\tforwardedfor:$http_x_forwarded_for"
                "\treq:$request"
                "\tstatus:$status"
                "\tmethod:$request_method"
                "\turi:$request_uri"
                "\tsize:$body_bytes_sent"
                "\treferer:$http_referer"
                "\tua:$http_user_agent"
                "\treqtime:$request_time"
                "\tcache:$upstream_http_x_cache"
                "\truntime:$upstream_http_x_runtime"
                "\tapptime:$upstream_response_time"
                "\tvhost:$host";
access_log /var/log/nginx/access.log ltsv;' | sudo tee /etc/nginx/conf.d/log_format.conf >/dev/null
    chmod 744 /etc/nginx/conf.d/log_format.conf
    echo "/etc/nginx/conf.d/log_format.conf has been created!"
}

main() {
    install_alp
    install_pt_query_digest
    install_graphviz
    change_nginx_logformat
}

main "$@"
