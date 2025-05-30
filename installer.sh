#!/bin/bash

id | grep root && echo "ERROR >> IT IS NOT ALLOWED TO RUN THIS SCRIPT AS ROOT !!!" && exit 1

cat /etc/*release | grep -i -e debian > /dev/null && su_cmd="su -c " || su_cmd="sudo sh -c "

read -p ">>>> Would you like to continue with this experimental dexsetup installer script? [yes/else or enter for no]: " var_q
if [[ "${var_q}" == "yes" ]]; then
   echo "DEXSETUP installer continue..."
else
   echo "DEXSETUP installer been cancelled."
   exit 0
fi

read -p ">>>> Would you like to update system and install mandatory git proxychains tor and torsocks packages? [yes/else or enter for no]: " var_q
if [[ "${var_q}" == "yes" ]]; then
   apt_install_mandatory="apt update; apt full-upgrade; apt install git proxychains4 tor torsocks;"
   groups | grep debian-tor || usermod_a_g="usermod -a -G debian-tor ${USER};" || usermod_a_g=""
else
   apt_install_mandatory=""
   usermod_a_g=""
fi

if [[ "${apt_install_mandatory}" != "" ]] || [[ "${usermod_a_g}" != "" ]]; then
   echo "Operating system standard update: ${su_cmd} $apt_install_mandatory $usermod_a_g"
   ${su_cmd} "$apt_install_mandatory $usermod_a_g"
      (test $? != 0) && echo "update system, installing packages and updating user permissions to use tor failed" && exit 1
else
   echo "Operating system standard update not needed or cancelled"
fi

echo "making directory(~/dexsetup) and downloading all dexsetup files"
mkdir -p ~/dexsetup/dexsetup && cd ~/dexsetup/dexsetup
(test $? != 0) && echo "failed to change directory to dexsetup root dir" && exit 1

echo "downloading latest dexsetup version by git over anonymously over tor"
proxychains4 git clone https://github.com/nnmfnwl/dexsetup.git ./
if [[ ${?} != 0 ]]; then
   read -p ">>>> DEXSETUP seems already installed, would you like to continue and try to update? [yes/else or enter for no]: " var_q
   if [[ "${var_q}" == "yes" ]]; then
    
      echo "DEXSETUP reinstallation/update in progress"
      reinstall_yes="yes"
      git stash \
      && proxychains4 git pull
      (test $? != 0) && echo "update dexsetup by git failed. try again later" && exit 1
   else
      echo "DEXSETUP is already installed and installation cancelled."
      exit 0
   fi
fi

git checkout merge.2025.02.06 \
&& chmod 755 setup* \
&& chmod 755 ./src/setup*.sh
(test $? != 0) && echo "switch to experimental dexsetup version failed" && exit 1

read -p "$* Would you like to install or update software dependencies? [yes/else to no]: " var_q
if [[ "${var_q}" == "yes" ]]; then
    read -p "$* Would you like to install mandatory command line interface build packages? [yes/else to no]: " var_q
    if [[ "${var_q}" == "yes" ]]; then
        clibuild=clibuild
    else
        clibuild=""
    fi
    
    read -p "$* Would you like to install mandatory command line interface packages? [yes/else to no]: " var_q
    if [[ "${var_q}" == "yes" ]]; then
        clitools=clitools
    else
        clitools=""
    fi
    
    read -p "$* Would you like to install optional graphical user interface build packages? [yes/else to no]: " var_q
    if [[ "${var_q}" == "yes" ]]; then
        guibuild=guibuild
    else
        guibuild=""
    fi
    
    read -p "$* Would you like to install optional graphical user interface packages? [yes/else to no]: " var_q
    if [[ "${var_q}" == "yes" ]]; then
        guitools=guitools
    else
        guitools=""
    fi
    
   ./setup.dependencies.sh ${clibuild} ${clitools} ${guibuild} ${guitools}
   (test $? != 0) && echo "Installing dependency packages failed" && exit 1
fi

echo "Proxychains configuration file update"
./setup.cfg.proxychains.sh install
if [[ ${reinstall_yes} == "yes" ]]; then
   ./setup.cfg.proxychains.sh update
   (test $? != 0) && echo "proxychains config file update failed" && exit 1
fi

read -p "$* Would you like to setup VNC password? [yes/else or enter for no]: " var_q
if [[ "${var_q}" == "yes" ]]; then
   tigervncpasswd
   (test $? != 0) && echo "setup vnc password failed" && exit 1
fi   

read -p "$* Would you like to setup tigervnc server to start automatically after startup? [yes/else or enter for no]: " var_q
if [[ "${var_q}" == "yes" ]]; then
   grep "^:1=${USER}$" /etc/tigervnc/vncserver.users || ${su_cmd} "echo \":1=${USER}\" >> /etc/tigervnc/vncserver.users; systemctl start tigervncserver@:1.service; systemctl enable tigervncserver@:1.service"
   (test $? != 0) && echo "configure vng server to start automatically after restart failed" && exit 1
fi

echo "Building wallets from official repositories..."
read -p "$* Would you like to install or update Blocknet(BLOCK) wallet? [yes/else or enter for no]: " var_q
if [[ "${var_q}" == "yes" ]]; then
   ./setup.cc.wallet.sh ./src/cfg.cc.blocknet.sh install || ./setup.cc.wallet.sh ./src/cfg.cc.blocknet.sh update
   (test $? != 0) && echo "build blocknet wallet failed " && exit 1
fi

read -p "$* Would you like to install or update Litecoin(LTC) wallet? [yes/else or enter for no]: " var_q
if [[ "${var_q}" == "yes" ]]; then
   ./setup.cc.wallet.sh ./src/cfg.cc.litecoin.sh install || ./setup.cc.wallet.sh ./src/cfg.cc.litecoin.sh update
   (test $? != 0) && echo "build litecoin wallet failed" && exit 1
fi

read -p "$* Would you like to install or update Bitcoin(BTC) wallet? [yes/else or enter for no]: " var_q
if [[ "${var_q}" == "yes" ]]; then
   ./setup.cc.wallet.sh ./src/cfg.cc.bitcoin.sh install || ./setup.cc.wallet.sh ./src/cfg.cc.bitcoin.sh update
   (test $? != 0) && echo "build bitcoin wallet failed" && exit 1
fi

read -p "$* Would you like to install or update Verge(XVG) wallet? [yes/else or enter for no]: " var_q
if [[ "${var_q}" == "yes" ]]; then
   ./setup.cc.wallet.sh ./src/cfg.cc.verge.sh install || ./setup.cc.wallet.sh ./src/cfg.cc.verge.sh update
   (test $? != 0) && echo "build verge wallet failed" && exit 1
fi

read -p "$* Would you like to install or update Dogecoin(DOGE) wallet? [yes/else to no]: " var_q
if [[ "${var_q}" == "yes" ]]; then
   ./setup.cc.wallet.sh ./src/cfg.cc.dogecoin.sh install || ./setup.cc.wallet.sh ./src/cfg.cc.dogecoin.sh update
   (test $? != 0) && echo "build dogecoin wallet failed" && exit 1
fi

read -p "$* Would you like to install or update PIVX(PIVX) wallet? [yes/else or enter for no]: " var_q
if [[ "${var_q}" == "yes" ]]; then
   ./setup.cc.wallet.sh ./src/cfg.cc.pivx.sh download install || ./setup.cc.wallet.sh ./src/cfg.cc.pivx.sh download update
   (test $? != 0) && echo "download pivx wallet failed" && exit 1
fi

read -p "$* Would you like to install or update Dash(DASH) wallet? [yes/else or enter for no]: " var_q
if [[ "${var_q}" == "yes" ]]; then
   ./setup.cc.wallet.sh ./src/cfg.cc.dash.sh install || ./setup.cc.wallet.sh ./src/cfg.cc.dash.sh update
   (test $? != 0) && echo "build dash wallet failed" && exit 1
fi

read -p "$* Would you like to install or update Lbry Credits LevelDB(LBC) wallet? [yes/else or enter for no]: " var_q
if [[ "${var_q}" == "yes" ]]; then
   ./setup.cc.wallet.sh ./src/cfg.cc.lbrycrd.leveldb.sh install || ./setup.cc.wallet.sh ./src/cfg.cc.lbrycrd.leveldb.sh update
   (test $? != 0) && echo "build lbry leveldb wallet failed" && exit 1
fi

read -p "$* Would you like to install or update Lbry credits SQLITE(LBC) wallet? [yes/else or enter for no]: " var_q
if [[ "${var_q}" == "yes" ]]; then
   ./setup.cc.wallet.sh ./src/cfg.cc.lbrycrd.sqlite.sh install || ./setup.cc.wallet.sh ./src/cfg.cc.lbrycrd.sqlite.sh update
   (test $? != 0) && echo "build lbry sqlite wallet failed" && exit 1
fi

read -p "$* Would you like to install or update Pocketcoin Bastyon.com(PKOIN) wallet? [yes/else or enter for no]: " var_q
if [[ "${var_q}" == "yes" ]]; then
   ./setup.cc.wallet.sh ./src/cfg.cc.pocketcoin.sh install || ./setup.cc.wallet.sh ./src/cfg.cc.pocketcoin.sh update
   (test $? != 0) && echo "build pkoin wallet failed" && exit 1
fi

read -p "$* Would you like to install or update Particl(PART) wallet? [yes/else or enter for no]: " var_q
if [[ "${var_q}" == "yes" ]]; then
   ./setup.cc.wallet.sh ./src/cfg.cc.particl.sh install || ./setup.cc.wallet.sh ./src/cfg.cc.particl.sh update
   (test $? != 0) && echo "build particle wallet failed" && exit 1
fi

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
./setup.cc.wallet.profile.sh ./src/cfg.cc.verge.sh
(test $? != 0) && echo "make verge wallet dex profile failed" && exit 1
./setup.cc.wallet.profile.sh ./src/cfg.cc.dogecoin.sh
(test $? != 0) && echo "make dogecoin wallet dex profile failed" && exit 1
./setup.cc.wallet.profile.sh ./src/cfg.cc.pivx.sh
(test $? != 0) && echo "make pivx wallet dex profile failed" && exit 1
./setup.cc.wallet.profile.sh ./src/cfg.cc.dash.sh
(test $? != 0) && echo "make dash wallet dex profile failed" && exit 1
./setup.cc.wallet.profile.sh ./src/cfg.cc.lbrycrd.leveldb.sh
(test $? != 0) && echo "make lbry leveldb wallet dex profile failed" && exit 1
./setup.cc.wallet.profile.sh ./src/cfg.cc.lbrycrd.sqlite.sh
(test $? != 0) && echo "make lbry sqlite wallet dex profile failed" && exit 1
./setup.cc.wallet.profile.sh ./src/cfg.cc.pocketcoin.sh
(test $? != 0) && echo "make pocketcoin wallet dex profile failed" && exit 1
./setup.cc.wallet.profile.sh ./src/cfg.cc.particl.sh
(test $? != 0) && echo "make particl wallet dex profile failed" && exit 1

echo "DEXBOT trading strategies setup"
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.block.ltc.sh strategy1      blocknet01   litecoin01 \
|| ./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.block.ltc.sh strategy1      blocknet01   litecoin01 update_strategy
(test $? != 0) && echo "make BLOCK LTC trading startegy1 failed" && exit 1
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.bitcoin.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.btc.ltc.sh strategy1         bitcoin01    litecoin02 \
|| ./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.bitcoin.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.btc.ltc.sh strategy1         bitcoin01    litecoin02 update_strategy
(test $? != 0) && echo "make BTC LTC trading startegy1 failed" && exit 1
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.verge.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.xvg.ltc.sh strategy1           verge01      litecoin03 \
|| ./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.verge.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.xvg.ltc.sh strategy1           verge01      litecoin03 update_strategy
(test $? != 0) && echo "make XVG LTC trading startegy1 failed" && exit 1
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.dogecoin.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.doge.ltc.sh strategy1       dogecoin01   litecoin04 \
|| ./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.dogecoin.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.doge.ltc.sh strategy1       dogecoin01   litecoin04 update_strategy
(test $? != 0) && echo "make DOGE LTC trading startegy1 failed" && exit 1
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.pivx.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.pivx.ltc.sh strategy1           pivx01       litecoin05 \
|| ./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.pivx.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.pivx.ltc.sh strategy1           pivx01       litecoin05 update_strategy
(test $? != 0) && echo "make PIVX LTC trading startegy1 failed" && exit 1
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.dash.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.dash.ltc.sh strategy1           dash01       litecoin06 \
|| ./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.dash.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.dash.ltc.sh strategy1           dash01       litecoin06 update_strategy
(test $? != 0) && echo "make DASH LTC trading startegy1 failed" && exit 1
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.lbrycrd.leveldb.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.lbc.ltc.sh strategy1 lbrycrd01    litecoin07 \
|| ./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.lbrycrd.leveldb.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.lbc.ltc.sh strategy1 lbrycrd01    litecoin07 update_strategy
(test $? != 0) && echo "make LBC LTC trading startegy1 failed" && exit 1
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.pocketcoin.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.pkoin.ltc.sh strategy1    pocketcoin01 litecoin08 \
|| ./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.pocketcoin.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.pkoin.ltc.sh strategy1    pocketcoin01 litecoin08 update_strategy
(test $? != 0) && echo "make PKOIN LTC trading startegy1 failed" && exit 1
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.particl.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.part.ltc.sh strategy1    particl01 litecoin09 \
|| ./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.particl.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.part.ltc.sh strategy1    particl01 litecoin09 update_strategy
(test $? != 0) && echo "make PART LTC trading startegy1 failed" && exit 1

echo "download BlockDX from official repositories:"
./setup.cc.blockdx.sh download install || ./setup.cc.blockdx.sh download update
(test $? != 0) && echo "setup BlockDX failed" && exit 1

echo "create blockdx firejail sandbox profile start script "
./setup.cc.blockdx.profile.sh
(test $? != 0) && echo "setup BlockDX profile failed" && exit 1

echo "Start/stop/update scripts with GNU Screen terminal multiplexer setup"
./setup.screen.sh install || ./setup.screen.sh update
(test $? != 0) && echo "Start/stop/update scripts with GNU Screen terminal multiplexer setup failed" && exit 1

cd ~/dexsetup/

echo '
cd ~/dexsetup/dexsetup/
echo "DEXBOT trading strategies reconfiguration"
read -p "$* Enter BLOCK address: " block1
read -p "$* Enter LTC address 1: " ltc1
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.block.ltc.sh strategy1 $block1 $ltc1 update_strategy
(test $? != 0) && echo "make BLOCK LTC trading startegy1 failed" && exit 1

read -p "$* Enter BTC address: " btc1
read -p "$* Enter LTC address 2: " ltc2
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.bitcoin.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.btc.ltc.sh strategy1 $btc1 $ltc2 update_strategy
(test $? != 0) && echo "make BTC LTC trading startegy1 failed" && exit 1

read -p "$* Enter XVG address: " xvg1
read -p "$* Enter LTC address 3: " ltc3
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.verge.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.xvg.ltc.sh strategy1 $xvg1 $ltc3 update_strategy
(test $? != 0) && echo "make XVG LTC trading startegy1 failed" && exit 1

read -p "$* Enter DOGE address: " doge1
read -p "$* Enter LTC address 4: " ltc4
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.dogecoin.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.doge.ltc.sh strategy1 $doge1 $ltc4 update_strategy
(test $? != 0) && echo "make DOGE LTC trading startegy1 failed" && exit 1

read -p "$* Enter PIVX address: " pivx1
read -p "$* Enter LTC address 5: " ltc5
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.pivx.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.pivx.ltc.sh strategy1 $pivx1 $ltc5 update_strategy
(test $? != 0) && echo "make PIVX LTC trading startegy1 failed" && exit 1

read -p "$* Enter DASH address: " dash1
read -p "$* Enter LTC address 6: " ltc6
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.dash.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.dash.ltc.sh strategy1 $dash1 $ltc6 update_strategy
(test $? != 0) && echo "make DASH LTC trading startegy1 failed" && exit 

read -p "$* Enter LBC address: " lbc1
read -p "$* Enter LTC address 7: " ltc7
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.lbrycrd.leveldb.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.lbc.ltc.sh strategy1 $lbc1 $ltc7 update_strategy
(test $? != 0) && echo "make LBC LTC trading startegy1 failed" && exit 1

read -p "$* Enter PKOIN address: " pkoin1
read -p "$* Enter LTC address 8: " ltc8
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.pocketcoin.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.pkoin.ltc.sh strategy1 $pkoin1 $ltc8 update_strategy
(test $? != 0) && echo "make PKOIN LTC trading startegy1 failed" && exit 1

read -p "$* Enter PART address: " part1
read -p "$* Enter LTC address 9: " ltc9
./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.particl.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.part.ltc.sh strategy1 $part1 $ltc9 update_strategy
(test $? != 0) && echo "make PART LTC trading startegy1 failed" && exit 1

' > installer_reconfigure_dexbot.sh
chmod 755 installer_reconfigure_dexbot.sh

echo "Dexsetup setup has successfully finished"
echo "DEXBOT Strategies needs to be reconfigured with valid wallet addressses by using reconfiguration script later after you setup your wallet addresses 'cd ~/dexsetup && ./installer_reconfigure_dexbot.sh'"
