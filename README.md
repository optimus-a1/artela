1，一键运行:wget -O Artela.sh https://raw.githubusercontent.com/optimus-a1/artela/main/Artela.sh && chmod +x Artela.sh && ./Artela.sh

2，设置环境变量：echo 'export PATH=$PATH:/home/lighthouse/go/bin' >> ~/.bashrc
source ~/.bashrc

3，节点安装完成后创建钱包
artelad keys add 钱包名

也可以导入其他钱包
artelad keys add 钱包名 --recover

4，将对应的助记词导入metamask,okx等钱包，获取对应的EVM钱包地址

5，进入官方Discord（https://discord.com/invite/artela）领水

6，创建验证者
artelad tx staking create-validator \
--amount 1art \
--from 钱包名字 \
--commission-rate 0.075 \
--commission-max-rate 0.1 \
--commission-max-change-rate 0.01 \
--min-self-delegation 1 \
--pubkey $(artelad tendermint show-validator) \
--moniker "自定义" \
--identity "自定义" \
--details "自定义" \
--chain-id artela_11822-1 \
--gas auto --gas-adjustment 1.5 \
--node tcp://47.254.66.177:26657 \
-y

7，创建验证人成功后，进入浏览器（https://test.explorer.ist/artela/staking）确认验证人信息

8，填写节点申请表格：https://atkty6pceir.typeform.com/to/o4359Rsd



日志查询：sudo journalctl -fu artelad -o cat


查询验证者信息：artelad status 2>&1 | jq .ValidatorInfo


钱包列表：artelad keys list


导入钱包：artelad keys add wallet --recover


查询钱包余额：artelad query bank balances 钱包地址


发送代币：artelad tx bank send 钱包地址 接收钱包地址 10000000uart


查询节点同步信息：artelad status 2>&1 | jq .SyncInfo






