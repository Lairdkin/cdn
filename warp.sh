#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

COUNT=0
SESSION=/usr/local/bin/.netflix_session
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"

function Initialize {
    if [ -f $SESSION ]; then
        echo "Session file found. Terminating..."
        exit 0
    else
        echo "" > $SESSION
    fi
    echo -e "Automatic Stream Unlock Monitor Monkey Lite\n"
    Test
}

function Test {
    echo "Detecting Netflix Unlock..."        
    Netflix=$(curl -x socks5://127.0.0.1:40000 --user-agent "${UA_Browser}" -4 -fsL --write-out %{http_code} --output /dev/null --max-time 30 "https://www.netflix.com/title/70143836" 2>&1)
    echo 当前ip:$(curl -x socks5://127.0.0.1:40000 -4 ip.p3terx.com/ip -fsL)
    Analyse

}

function Analyse {
    echo "Netflix HTTP Response Code: $Netflix"
    if [[ "$Netflix" == "404" ]] || [[ "$Netflix" == "403" ]] || [[ "$Netflix" == "000" ]]; then
        ChangeIP
    else
        if [[ $COUNT -eq 0 ]]; then
            echo "No error found. Exiting..."
            rm -rf /usr/local/bin/.netflix_session
            exit 0
        else
            echo "Changing IP successed. Exiting..."
            rm -rf /usr/local/bin/.netflix_session
            exit 0
        fi
    fi
}

function ChangeIP {
    echo "Trying to change IP... Count: $COUNT"
    warp-cli --accept-tos register
    sleep 5s
    Test
}

Initialize
