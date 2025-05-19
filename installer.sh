#!/bin/bash

echo "This will be dexsetup cli installer script"

echo "Would you like to continue with this very experimental script? :-))) yes?"
read var_q
if [[ "${var_q}" == "yes" ]]; then
    echo "Ok, we continue"
    sleep 1
else
    echo "The installer has been cancelled"
    exit 0
fi

echo "updating system and installing packages git proxychains tor torsocks"
su - -c "apt update; apt full-upgrade; apt install git proxychains4 tor torsocks; exit"

echo "updating user permissions for ability to use tor"
groups | grep debian-tor || su - -c "usermod -a -G debian-tor ${USER}; exit"

echo "making directory(~/dexsetup) and downloading all dexsetup files"
mkdir -p ~/dexsetup/dexsetup \
&& cd ~/dexsetup/dexsetup \
&& proxychains4 git clone https://github.com/nnmfnwl/dexsetup.git ./ \
&& git checkout merge.2025.02.06 \
&& chmod 755 setup* \
&& chmod 755 ./src/setup*.sh

echo "Software dependencies installation"
./setup.dependencies.sh clibuild clitools guibuild guitools

echo "Proxychains configuration file update"
./setup.cfg.proxychains.sh install

echo "SKIP Setting up VNC client password"
# tigervncpasswd

echo "SKIP configure tigervnc server to start automatically with computer"
# grep "^:1=${USER}$" /etc/tigervnc/vncserver.users || su - -c "echo \":1=${USER}\" >> /etc/tigervnc/vncserver.users; systemctl start tigervncserver@:1.service; systemctl enable tigervncserver@:1.service"

echo "Building wallets from official repositories"
./setup.cc.wallet.sh ./src/cfg.cc.blocknet.sh install
./setup.cc.wallet.sh ./src/cfg.cc.litecoin.sh install
./setup.cc.wallet.sh ./src/cfg.cc.bitcoin.sh install
#./setup.cc.wallet.sh ./src/cfg.cc.verge.sh install
./setup.cc.wallet.sh ./src/cfg.cc.dogecoin.sh install
./setup.cc.wallet.sh ./src/cfg.cc.pivx.sh download install
./setup.cc.wallet.sh ./src/cfg.cc.dash.sh install
#./setup.cc.wallet.sh ./src/cfg.cc.lbrycrd.leveldb.sh install
#./setup.cc.wallet.sh ./src/cfg.cc.lbrycrd.sqlite.sh install
./setup.cc.wallet.sh ./src/cfg.cc.pocketcoin.sh install
#./setup.cc.wallet.sh ./src/cfg.cc.particl.sh install

echo "Wallets profiling setup"

./setup.cc.wallet.profile.sh ./src/cfg.cc.blocknet.sh ~/.blocknet_staking wallet_block_staking
./setup.cc.wallet.profile.sh ./src/cfg.cc.pocketcoin.sh ~/.pocketcoin_staking wallet_pkoin_staking
./setup.cc.wallet.profile.sh ./src/cfg.cc.pivx.sh ~/.pivx_staking/ wallet_pivx_staking

./setup.cc.wallet.profile.sh ./src/cfg.cc.blocknet.sh
./setup.cc.wallet.profile.sh ./src/cfg.cc.litecoin.sh
./setup.cc.wallet.profile.sh ./src/cfg.cc.bitcoin.sh
#./setup.cc.wallet.profile.sh ./src/cfg.cc.verge.sh
./setup.cc.wallet.profile.sh ./src/cfg.cc.dogecoin.sh
./setup.cc.wallet.profile.sh ./src/cfg.cc.pivx.sh
./setup.cc.wallet.profile.sh ./src/cfg.cc.dash.sh
#./setup.cc.wallet.profile.sh ./src/cfg.cc.lbrycrd.leveldb.sh
#./setup.cc.wallet.profile.sh ./src/cfg.cc.lbrycrd.sqlite.sh
./setup.cc.wallet.profile.sh ./src/cfg.cc.pocketcoin.sh
#./setup.cc.wallet.profile.sh ./src/cfg.cc.particl.sh

echo "DEXBOT trading strategies setup"
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.block.ltc.sh strategy1      blocknet01   litecoin01

./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.bitcoin.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.btc.ltc.sh strategy1         bitcoin01    litecoin02

#./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.verge.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.xvg.ltc.sh strategy1           verge01      litecoin03

./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.dogecoin.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.doge.ltc.sh strategy1       dogecoin01   litecoin04

./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.pivx.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.pivx.ltc.sh strategy1           pivx01       litecoin05

./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.dash.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.dash.ltc.sh strategy1           dash01       litecoin06

#./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.lbrycrd.leveldb.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.lbc.ltc.sh strategy1 lbrycrd01    litecoin07

./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.pocketcoin.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.pkoin.ltc.sh strategy1    pocketcoin01 litecoin08

#./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.particl.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.part.ltc.sh strategy1    particl01 litecoin09

echo "download BlockDX from official repositories:"
./setup.cc.blockdx.sh download install

echo "create blockdx firejail sandbox profile start script "
./setup.cc.blockdx.profile.sh

echo "Start/stop/update scripts with GNU Screen terminal multiplexer setup"
./setup.screen.sh install
