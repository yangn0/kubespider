#!/bin/sh

set -e

# 1.Echo logo
cat << "EOF"
 _          _                     _     _
| | ___   _| |__   ___  ___ _ __ (_) __| | ___ _ __
| |/ / | | | '_ \ / _ \/ __| '_ \| |/ _` |/ _ \ '__|
|   <| |_| | |_) |  __/\__ \ |_) | | (_| |  __/ |
|_|\_\\__,_|_.__/ \___||___/ .__/|_|\__,_|\___|_|
                           |_|  
EOF
echo "[INFO] Start to deploy with default configuration..."

# 2.Check env
ret=`docker version`
if [[ $? != 0 ]]; then
    echo "[ERROR] Please install docker"
    exit 1
fi

# 3.Create necessary directory
mkdir -p ${HOME}/kubespider/nas/
mkdir -p ${HOME}/kubespider/motrix/
cp -r ./.kubespider ${HOME}/

# 4.Deploy aria2
docker run -d \
    --name aria2-pro \
    --restart unless-stopped \
    --log-opt max-size=1m \
    --network host \
    -e PUID=$UID \
    -e PGID=$GID \
    -e RPC_SECRET=kubespider \
    -e RPC_PORT=6800 \
    -e LISTEN_PORT=6888 \
    -v ${HOME}/kubespider/aria2/:/config \
    -v ${HOME}/kubespider/nas/:/downloads/ \
    p3terx/aria2-pro

# 5.Deploy kubespider
if [[ ${KUBESPIDER_VERSION} == "" ]]; then
    export KUBESPIDER_VERSION="latest"
fi
docker run -itd --name kubespider \
    -p 3800:3800 \
    -v ${HOME}/.kubespider:/root/.kubespider \
    --network=host \
    --restart unless-stopped \
    cesign/kubespider:${KUBESPIDER_VERSION}

# 6.Give other info
echo "[INFO] Deploy successful, check the information:"
echo "*******************************************"
echo "Kubespider config path: ${HOME}/.kubespider/"
echo "Download file path: ${HOME}/kubespider/nas/"
echo "Kubespider webhook address: http://<server_ip>:3080"
echo "Aria2 server address: http://<server_ip>:6800/jsonrpc, you can use any gui or webui to connect it"
echo "Aria2 default secret is:kubespider"
echo "*******************************************"