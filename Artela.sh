#!/bin/bash

# 检查命令是否存在
exists() {
  command -v "$1" >/dev/null 2>&1
}

# 检查curl是否安装，如果没有则安装
if exists curl; then
  echo 'curl 已安装'
else
  sudo apt update && sudo apt install curl -y
fi

# 设置变量
read -r -p "请输入节点名称: " NODE_MONIKER
export NODE_MONIKER=$NODE_MONIKER

# 更新和安装必要的软件
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev

# 安装Go
ver="1.20.3"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile
go version
sleep 1

# 安装所有二进制文件
cd $HOME
rm -rf artela
git clone https://github.com/artela-network/artela
cd artela
git checkout v0.4.7-rc6
make install

# 配置artelad
artelad config chain-id artela_11822-1
artelad init "$NODE_MONIKER" --chain-id artela_11822-1

# 获取初始文件和地址簿
curl -s https://t-ss.nodeist.net/artela/genesis.json > $HOME/.artelad/config/genesis.json
curl -s https://t-ss.nodeist.net/artela/addrbook.json > $HOME/.artelad/config/addrbook.json

# 配置节点
SEEDS=""
PEERS="b23bc610c374fd071c20ce4a2349bf91b8fbd7db@65.108.72.233:11656"
sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.artelad/config/config.toml

# 配置和快照
sed -i 's|^pruning *=.*|pruning = "custom"|g' $HOME/.artelad/config/app.toml
sed -i 's|^pruning-keep-recent  *=.*|pruning-keep-recent = "100"|g' $HOME/.artelad/config/app.toml
sed -i 's|^pruning-interval *=.*|pruning-interval = "10"|g' $HOME/.artelad/config/app.toml
sed -i 's|^snapshot-interval *=.*|snapshot-interval = 0|g' $HOME/.artelad/config/app.toml

# 配置最小燃料价格和普罗米修斯
sed -i 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.025art"|g' $HOME/.artelad/config/app.toml
sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.artelad/config/config.toml

# 创建服务文件
sudo tee /etc/systemd/system/artelad.service > /dev/null << EOF
[Unit]
Description=artela node
After=network-online.target

[Service]
User=$USER
ExecStart=$(which artelad) start
Restart=on-failure
RestartSec=10
LimitNOFILE=10000

[Install]
WantedBy=multi-user.target
EOF

# 重置Tendermint数据
artelad tendermint unsafe-reset-all --home $HOME/.artelad --keep-addr-book

# 安装lz4工具
sudo apt install snapd -y
sudo snap install lz4

# 下载并解压快照
curl -L https://t-ss.nodeist.net/artela/snapshot_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.artelad --strip-components 2

# 重新加载和启动服务
sudo systemctl daemon-reload
sudo systemctl enable artelad
sudo systemctl start artelad


# 完成设置
echo '====================== 安装完成 ==========================='
echo -e "\e[1;32m 检查状态: \e[0m\e[1;36m sudo systemctl status artelad \e[0m"
echo -e "\e[1;32m 查看日志: \e[0m\e[1;36m sudo journalctl -fu artelad -o cat \e[0m"
echo -e "\e[1;32m 检查同步状态: \e[0m\e[1;36m artelad status | jq .SyncInfo \e[0m"
