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
(test $? != 0) && echo "update system and installing packages failed" && exit 1

echo "updating user permissions for ability to use tor"
groups | grep debian-tor || su - -c "usermod -a -G debian-tor ${USER}; exit"
(test $? != 0) && echo "updating permission for user ability to use tor failed" && exit 1

echo "making directory(~/dexsetup) and downloading all dexsetup files"
mkdir -p ~/dexsetup/dexsetup \
&& cd ~/dexsetup/dexsetup \
&& proxychains4 git clone https://github.com/nnmfnwl/dexsetup.git ./ \
&& git checkout merge.2025.02.06 \
&& chmod 755 setup* \
&& chmod 755 ./src/setup*.sh
(test $? != 0) && echo "downloading dexsetup failed. Already installed?" && exit 1

echo "Software dependencies installation"
./setup.dependencies.sh clibuild clitools guibuild guitools
(test $? != 0) && echo "Installing dependency packages failed" && exit 1

echo "Proxychains configuration file update"
./setup.cfg.proxychains.sh install
(test $? != 0) && echo "proxychains config file update failed" && exit 1

echo "SKIP Setting up VNC client password"
# tigervncpasswd
(test $? != 0) && echo "setup vnc password failed" && exit 1

echo "SKIP configure tigervnc server to start automatically with computer"
# grep "^:1=${USER}$" /etc/tigervnc/vncserver.users || su - -c "echo \":1=${USER}\" >> /etc/tigervnc/vncserver.users; systemctl start tigervncserver@:1.service; systemctl enable tigervncserver@:1.service"
(test $? != 0) && echo "configure vng server to start automatically after restart failed" && exit 1

echo "Building wallets from official repositories"
./setup.cc.wallet.sh ./src/cfg.cc.blocknet.sh install
(test $? != 0) && echo "build blocknet wallet failed " && exit 1

./setup.cc.wallet.sh ./src/cfg.cc.litecoin.sh install
(test $? != 0) && echo "build litecoin wallet failed" && exit 1

./setup.cc.wallet.sh ./src/cfg.cc.bitcoin.sh install
(test $? != 0) && echo "build bitcoin wallet failed" && exit 1

#./setup.cc.wallet.sh ./src/cfg.cc.verge.sh install
(test $? != 0) && echo "build verge wallet failed" && exit 1

./setup.cc.wallet.sh ./src/cfg.cc.dogecoin.sh install
(test $? != 0) && echo "build dogecoin wallet failed" && exit 1

./setup.cc.wallet.sh ./src/cfg.cc.pivx.sh download install
(test $? != 0) && echo "download pivx wallet failed" && exit 1

./setup.cc.wallet.sh ./src/cfg.cc.dash.sh install
(test $? != 0) && echo "build dash wallet failed" && exit 1

#./setup.cc.wallet.sh ./src/cfg.cc.lbrycrd.leveldb.sh install
(test $? != 0) && echo "build lbry leveldb wallet failed" && exit 1

#./setup.cc.wallet.sh ./src/cfg.cc.lbrycrd.sqlite.sh install
(test $? != 0) && echo "build lbry sqlite wallet failed" && exit 1

./setup.cc.wallet.sh ./src/cfg.cc.pocketcoin.sh install
(test $? != 0) && echo "build pkoin wallet failed" && exit 1

#./setup.cc.wallet.sh ./src/cfg.cc.particl.sh install
(test $? != 0) && echo "build particle wallet failed" && exit 1

echo "Wallets profiling setup"
./setup.cc.wallet.profile.sh ./src/cfg.cc.blocknet.sh ~/.blocknet_staking wallet_block_staking
(test $? != 0) && echo "make blocknet wallet staking profile failed" && exit 1
./setup.cc.wallet.profile.sh ./src/cfg.cc.pocketcoin.sh ~/.pocketcoin_staking wallet_pkoin_staking
(test $? != 0) && echo "make pocketcoin (bastyon) wallet staking profile failed" && exit 1
./setup.cc.wallet.profile.sh ./src/cfg.cc.pivx.sh ~/.pivx_staking/ wallet_pivx_staking
(test $? != 0) && echo "make pivx wallet staking profile failed" && exit 1

./setup.cc.wallet.profile.sh ./src/cfg.cc.blocknet.sh
(test $? != 0) && echo "make blocknet wallet dex profile failed" && exit 1
./setup.cc.wallet.profile.sh ./src/cfg.cc.litecoin.sh
(test $? != 0) && echo "make litecoin wallet dex profile failed" && exit 1
./setup.cc.wallet.profile.sh ./src/cfg.cc.bitcoin.sh
(test $? != 0) && echo "make bitcoin wallet dex profile failed" && exit 1
#./setup.cc.wallet.profile.sh ./src/cfg.cc.verge.sh
(test $? != 0) && echo "make verge wallet dex profile failed" && exit 1
./setup.cc.wallet.profile.sh ./src/cfg.cc.dogecoin.sh
(test $? != 0) && echo "make dogecoin wallet dex profile failed" && exit 1
./setup.cc.wallet.profile.sh ./src/cfg.cc.pivx.sh
(test $? != 0) && echo "make pivx wallet dex profile failed" && exit 1
./setup.cc.wallet.profile.sh ./src/cfg.cc.dash.sh
(test $? != 0) && echo "make dash wallet dex profile failed" && exit 1
#./setup.cc.wallet.profile.sh ./src/cfg.cc.lbrycrd.leveldb.sh
(test $? != 0) && echo "make lbry leveldb wallet dex profile failed" && exit 1
#./setup.cc.wallet.profile.sh ./src/cfg.cc.lbrycrd.sqlite.sh
(test $? != 0) && echo "make lbry sqlite wallet dex profile failed" && exit 1
./setup.cc.wallet.profile.sh ./src/cfg.cc.pocketcoin.sh
(test $? != 0) && echo "make pocketcoin wallet dex profile failed" && exit 1
#./setup.cc.wallet.profile.sh ./src/cfg.cc.particl.sh
(test $? != 0) && echo "make particl wallet dex profile failed" && exit 1

echo "DEXBOT trading strategies setup"
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.block.ltc.sh strategy1      blocknet01   litecoin01
(test $? != 0) && echo "make BLOCK LTC trading startegy1 failed" && exit 1
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.bitcoin.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.btc.ltc.sh strategy1         bitcoin01    litecoin02
(test $? != 0) && echo "make BTC LTC trading startegy1 failed" && exit 1
#./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.verge.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.xvg.ltc.sh strategy1           verge01      litecoin03
(test $? != 0) && echo "make XVG LTC trading startegy1 failed" && exit 1
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.dogecoin.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.doge.ltc.sh strategy1       dogecoin01   litecoin04
(test $? != 0) && echo "make DOGE LTC trading startegy1 failed" && exit 1
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.pivx.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.pivx.ltc.sh strategy1           pivx01       litecoin05
(test $? != 0) && echo "make PIVX LTC trading startegy1 failed" && exit 1
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.dash.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.dash.ltc.sh strategy1           dash01       litecoin06
(test $? != 0) && echo "make DASH LTC trading startegy1 failed" && exit 1
#./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.lbrycrd.leveldb.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.lbc.ltc.sh strategy1 lbrycrd01    litecoin07
(test $? != 0) && echo "make LBC LTC trading startegy1 failed" && exit 1
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.pocketcoin.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.pkoin.ltc.sh strategy1    pocketcoin01 litecoin08
(test $? != 0) && echo "make PKOIN LTC trading startegy1 failed" && exit 1
#./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.particl.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.part.ltc.sh strategy1    particl01 litecoin09
(test $? != 0) && echo "make PART LTC trading startegy1 failed" && exit 1

echo "download BlockDX from official repositories:"
./setup.cc.blockdx.sh download install
(test $? != 0) && echo "setup BlockDX failed" && exit 1

echo "create blockdx firejail sandbox profile start script "
./setup.cc.blockdx.profile.sh
(test $? != 0) && echo "setup BlockDX profile failed" && exit 1

echo "Start/stop/update scripts with GNU Screen terminal multiplexer setup"
./setup.screen.sh install
(test $? != 0) && echo "Start/stop/update scripts with GNU Screen terminal multiplexer setup failed" && exit 1
