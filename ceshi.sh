#!/bin/bash                                                                                                  
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

read -e -p "请输入链接端口(默认443) :" port
if [[ -z "${port}" ]]; then
port="443"
fi

read -e -p "请输入密码(默认随机生成) :" secret
if [[ -z "${secret}" ]]; then
secret=$(cat /proc/sys/kernel/random/uuid |sed 's/-//g')
echo -e "密码："
echo -e "$secret"
fi

read -e -p "请输入伪装域名(默认www.microsoft.com) :" domain
if [[ -z "${domain}" ]]; then
domain="www.microsoft.com"
fi
read -rp "你需要TAG标签吗(Y/N): " chrony_install
    [[ -z ${chrony_install} ]] && chrony_install="Y"
    case $chrony_install in
    [yY][eE][sS] | [yY])
        read -e -p "请输入TAG:" tag
        if [[ -z "${tag}" ]]; then
        echo "请输入TAG"
        fi
        echo -e "正在安装依赖: Docker... "
        echo y | bash <(curl -L -s https://raw.githubusercontent.com/xb0or/nginx-mtproxy/main/docker.sh)
        echo -e "正在下载nginx-mtproxy docker镜像文件 "
        wget https://doc-0k-60-docs.googleusercontent.com/docs/securesc/877vpl42ia2d1uscu7srsen8ivv0dk51/3hbulo2qorb371or0d9cs3p2p1d9htjd/1693878600000/01335232191774239238/01335232191774239238/1EpGq2B1tPihMeX7AWW5GzYmVdC6xwBmL?e=download&ax=AH3YgiCz_c-vuTPIWa2M2X1b2M69btE-9AuMrFBWdSjJp7yTmtxCvs-SsbuOOLaAwxiI9xKDHxpMu1uPQjiMwHD49tkC3MEO79YAYy3eDhTcNc5TabRPzPBFbVZcyt6PVtQ80xGjY25odShDHTyCguMqClZF9xeZmGx2_Jy-0wUeIT8C9YAY2khQXo2Jrmr27YbncUxztYgbWM33RAszGQ5QpEEdUo5YRhH7Yj70xxsUDJ4URQmLBKJv14msAfJmTnOyop3fCQI_B9JudL6XBScSYCt80PPEAicEmuVXjkUvz8pkppq9wQyEliJLOjHPFU4NywSuG4U4kca0jesre2sIHgZ9I8f5oRVkCDlrxLqoehZxVVW8GFPV1yXi1hhyjS6BBKj63ggQpQg1QVaIufA9PNcDz4W9Zosz4fTbWd0Shm3u8ABPaMxdU8ELWMBhEME5XobERVb1yeJA4Q4hpAzJA7O2CAzbcyPsxwsbn-27010zpPw-nDrHrQoz7SCFkJHMtF5pty8WF-Je7bEPmYzYB2iwomFWvojWWV6jgySqK5bT8Ikvy5VmNtrpkKBoJuA_e0Ja7yjC50XTO4kfI7hmruLWWbzSd7RbpttQhyiV1LTe9DE4Pt-AghuYrHNjSWdX6a-7BTryUGcvIUjgdzz77cumgTdgt0G-hyrRSElM0mjggH8cC_ZF1Kfnw8NnkN6NWoNLigHZIW8L_gyRGyvjljzjTV8oiaYhx8ONfs6RC24-H4AWBH2NH6C5LXS-6OzU5cdpiNuODMxDSxGHHH5oRmVwKQYgEDv7Ps5LHgNKdO7FlC3NcROZzrPwQcj3ZP5Oe-7OLD_C1KRe1DhurDrB1Yuhp2LLRaYQXuM-BTn2ssA8cZQJLc9soUWiOHw8TLIN8kGFQmRrr83h1D8kty9cfhWA9_WX40YbcFQ&uuid=dbd9defd-00f9-4360-b5d8-a8b00e8d25ae&authuser=0
        echo -e "正在安装nginx-mtproxy... "
        docker load -i ellermister_nginx-mtproxy.tar
        docker run --name nginx-mtproxy -d -e tag="$tag" -e secret="$secret" -e domain="$domain" -p 80:80 -p $port:$port ellermister/nginx-mtproxy
        ;;
    *)
    #-v /etc/nginx:/etc/nginx 
echo -e "正在安装依赖: Docker... "
echo y | bash <(curl -L -s https://cdn.jsdelivr.net/gh/xb0or/nginx-mtproxy@main/docker.sh)

echo -e "正在安装nginx-mtproxy... "
docker load -i ellermister_nginx-mtproxy.tar
docker run --name nginx-mtproxy -d -e secret="$secret" -e domain="$domain" -p 80:80 -p $port:$port ellermister/nginx-mtproxy
        ;;
    esac



echo -e "正在设置开机自启动... "
docker update --restart=always nginx-mtproxy
# echo -e "输入 docker logs nginx-mtproxy 获取链接信息"

    public_ip=$(curl -s http://ipv4.icanhazip.com)
    [ -z "$public_ip" ] && public_ip=$(curl -s ipinfo.io/ip --ipv4)
    domain_hex=$(xxd -pu <<< $domain | sed 's/0a//g')
    client_secret="ee${secret}${domain_hex}"
    echo -e "服务器IP：\033[31m$public_ip\033[0m"
    echo -e "服务器端口：\033[31m$port\033[0m"
    echo -e "MTProxy Secret:  \033[31m$client_secret\033[0m"
    echo -e "TG认证地址：http://${public_ip}:80/add.php"
    echo -e "TG一键链接: https://t.me/proxy?server=${public_ip}&port=${port}&secret=${client_secret}"
