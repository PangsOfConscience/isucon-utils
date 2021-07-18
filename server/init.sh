#!/usr/bin/env bash
#
# サーバに必要な分析ツール類などをインストールする

set -eux

add_auhorized_keys() {
    local -r ssh_dir="/home/isucon/.ssh"
    if [ ! -e $ssh_dir ]; then
        mkdir $ssh_dir
    fi
    curl https://github.com/kuwata0037.keys >>$ssh_dir/authorized_keys
    curl https://github.com/karrybit.keys >>$ssh_dir/authorized_keys
    curl https://github.com/44smkn.keys >>$ssh_dir/authorized_keys
}

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
    echo "/etc/nginx/conf.d/log_format.conf has been created!"
}

add_slow_query_config() {
    echo '[mysqld]
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 0' | sudo tee -a /etc/mysql/my.cnf >/dev/null
    echo "add slow query config to /etc/mysql/my.cnf"
}

main() {
    local webhook_url=$1
    local -r script_dir=$(
        cd $(dirname $0)
        pwd
    )
    echo $webhook_url >${script_dir}/webhook_url.txt
    add_auhorized_keys
    install_alp
    install_pt_query_digest
    install_graphviz
    change_nginx_logformat
    add_slow_query_config
}

main "$@"
