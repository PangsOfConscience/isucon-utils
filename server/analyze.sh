#!/bin/bash

# 分析をかける
main() {
    local -r user=$1
    local -r alp_command_opts=$2
    local -r script_dir=$(
        cd $(dirname $0)
        pwd
    )
    current=$(date +"%H-%M-%S")
    alp_file_name="alp-${user}-${current}"

    sudo mkdir -p /www/data/logs
    echo "<html><body><pre style=\"font-family: 'Courier New', Consolas\">" >/www/data/${alp_file_name}.html
    cat /var/log/nginx/access.log | alp ltsv ${alp_command_opts} >>/www/data/${alp_file_name}.html

    TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    EIP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
    ${script_dir}/notify.sh "Analysis done! Please check http://${EIP}:9091/${alp_file_name}.html"
}

main "$@"
