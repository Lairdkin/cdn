FontColor_Red="\033[31m"
FontColor_Red_Bold="\033[1;31m"
FontColor_Green="\033[32m"
FontColor_Green_Bold="\033[1;32m"
FontColor_Yellow="\033[33m"
FontColor_Yellow_Bold="\033[1;33m"
FontColor_Purple="\033[35m"
FontColor_Purple_Bold="\033[1;35m"
FontColor_Suffix="\033[0m"


log() {
    local LEVEL="$1"
    local MSG="$2"
    case "${LEVEL}" in
    INFO)
        local LEVEL="[${FontColor_Green}${LEVEL}${FontColor_Suffix}]"
        local MSG="${LEVEL} ${MSG}"
        ;;
    WARN)
        local LEVEL="[${FontColor_Yellow}${LEVEL}${FontColor_Suffix}]"
        local MSG="${LEVEL} ${MSG}"
        ;;
    ERROR)
        local LEVEL="[${FontColor_Red}${LEVEL}${FontColor_Suffix}]"
        local MSG="${LEVEL} ${MSG}"
        ;;
    *) ;;
    esac
    echo -e "${MSG}"
}

download_config() {
      local regin="$1"
      wget -O /etc/XrayR/custom_outbound.json https://raw.githubusercontent.com/Lairdkin/cdn/main/xrayr/custom_outbound_${regin}.json
      wget -O /etc/XrayR/route.json https://raw.githubusercontent.com/Lairdkin/cdn/main/xrayr/route_${regin}.json
      sed -i 's/RouteConfigPath:\s#/RouteConfigPath:/' /etc/XrayR/config.yml
      sed -i 's/OutboundConfigPath:\s#/OutboundConfigPath:/' /etc/XrayR/config.yml
      log INFO "配置文件下载完毕"
}

config_warp() {
      rm -rf /usr/local/bin/.netflix_session
      warp_config="/etc/XrayR/warp.sh"
      if [ ! -f "$warp_config" ]; then
            bash <(curl -fsSL git.io/warp.sh) proxy
            wget -O /etc/XrayR/warp.sh https://raw.githubusercontent.com/Lairdkin/cdn/main/warp.sh
            wget -O /etc/XrayR/warpcron https://raw.githubusercontent.com/Lairdkin/cdn/main/xrayr/warpcron
            chmod 777 /etc/XrayR/warpcron
            sed -i '/warp/d' /var/spool/cron/crontabs/root  
            echo "*/5 * * * *  /etc/XrayR/warpcron >> /root/warp.log 2>&1" >> /var/spool/cron/crontabs/root  
            log INFO "初始化warp ip 请耐心等待"
            /bin/bash /etc/XrayR/warp.sh
            log INFO "warp配置完成"
      fi     
}

uninstall_warp() {
      rm -rf /usr/local/bin/.netflix_session
      warp_config="/etc/XrayR/warp.sh"
      if [ -f "$warp_config" ]; then
            bash <(curl -fsSL git.io/warp.sh) uninstall
            rm /etc/XrayR/warp.sh 
            rm /etc/XrayR/warpcron
            sed -i '/warp/d' /var/spool/cron/crontabs/root  
            download_config default
            log INFO "warp删除成功"
      fi     
}



config_tor(){
    apt install -y tor
    sed -i '/Nodes/d' /etc/tor/torrc
    echo "ExcludeNodes {cn},{hk},{mo},{kp},{ir},{sy},{pk},{cu},{vn}" >> /etc/tor/torrc
    echo "StrictNodes 1" >> /etc/tor/torrc
    service tor restart
    log INFO "tor配置完成"
}



unlockhk() {
    download_config hk
    /usr/bin/XrayR restart
    log INFO "香港流媒体解锁配置完成"
}


unlocktw() {
    download_config tw
    /usr/bin/XrayR restart
    log INFO "台湾流媒体解锁配置完成"
}


unlockjp() {
    download_config jp
    /usr/bin/XrayR restart
    log INFO "日本流媒体解锁配置完成"
}


unlockus() {
    config_warp
    download_config us
    /usr/bin/XrayR restart
    log INFO "美国流媒体解锁配置完成"
}


unlocksg() {
    download_config sg
    /usr/bin/XrayR restart
    log INFO "新加坡流媒体解锁配置完成"
}

unlockwarp() {
    config_warp
    download_config warp
    /usr/bin/XrayR restart
    log INFO "warp解锁配置完成"
}

unlocktor() {
    config_tor
    download_config tor
    /usr/bin/XrayR restart
    log INFO "tor配置完成"
}

Print_Usage() {
    echo -e "
萝卜&咸鱼云流媒体解锁脚本

USAGE:
    bash <(curl -fsSL https://github.com/Lairdkin/cdn/blob/main/xrayr/unlock.sh) [SUBCOMMAND]

SUBCOMMANDS:
    hk       安装香港流媒体解锁
    jp       安装日本流媒体解锁
    us       安装美国流媒体解锁
    sg       安装新加坡流媒体解锁
    warp     安装warp通用流媒体解锁
    tor      安装tor节点分流
    rmwarp   删除warp
 "
}


if [ $# -ge 1 ]; then
    case ${1} in
    hk)
        unlockhk
        ;;
    jp)
        unlockjp
        ;;
    sg)
        unlocksg
        ;;
    tw)
        unlocktw
        ;;
    us)
        unlockus
        ;;
    warp)
        unlockwarp
        ;;
    tor)
        unlocktor
        ;;
    rmwarp)
        uninstall_warp
        ;;
    *)
        log ERROR "Invalid Parameters: $*"
        Print_Usage
        exit 1
        ;;
    esac
else
    Print_Usage
fi
