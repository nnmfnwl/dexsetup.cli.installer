#!/bin/bash

echo "INFO >>> Checking to not run this script as root"
id | grep root && echo "ERROR >> IT IS NOT ALLOWED TO RUN THIS SCRIPT AS ROOT !!!" && exit 1

echo "INFO >>> Detecting Linux distribution operating system compatibility"
cat /etc/*release | grep -i -e debian -e ubuntu > /dev/null;
if [[ ${?} != 0 ]]; then
   cat /etc/*release
   read -p ">>> Unsupported operating system has been detected. Would you like to continue installer? [y to yes]: " -n1 var_q ; echo ""
   if [[ "${var_q}" != "y" ]]; then
      echo "INFO >> DEXSETUP installer been canceled."
      exit 0
   fi
fi

echo "INFO >>> Detecting Linux distribution 'sudo'/'su' compatibility"
sudo -v; (test $? != 0) && su_cmd="echo 'Please enter ROOT password'; su -c" || su_cmd="echo 'Please enter ${USER} sudo password'; sudo -sh -c";

read -p ">>> Would you like to continue with this experimental dexsetup installer script? [y to yes]: " -n1 var_q ; echo ""
if [[ "${var_q}" != "y" ]]; then
   echo "INFO >> DEXSETUP installer been canceled."
   exit 0
fi

read -p ">>> Would you like to update system [y to yes]: " -n1 var_q ; echo ""
if [[ "${var_q}" == "y" ]]; then
   pkg_update="apt update; apt full-upgrade"
else
   pkg_update=""
fi

read -p ">>> Would you like to set to install mandatory to have tor proxychains4 and torsocks privacy packages? [y to yes]: " -n1 var_q ; echo ""
if [[ "${var_q}" == "y" ]]; then
   pkg_privacy="tor proxychains4 torsocks"
   groups | grep debian-tor > /dev/null && cfg_user_tor="echo 'tor for ${USER} already configured'" || cfg_user_tor="usermod -a -G debian-tor ${USER}"
else
   pkg_privacy=""
   cfg_user_tor="echo 'no user tor configuration'"
fi

read -p ">>> Would you like to set to install mandatory to have command line interface build packages? [y to yes]: " -n1 var_q ; echo ""
if [[ "${var_q}" == "y" ]]; then
   pkg_cli_build="curl wget git make cmake clang clang-tools clang-format libclang1 libboost-all-dev basez libprotobuf-dev protobuf-compiler libssl-dev openssl gcc g++ python3-pip python3-dateutil cargo pkg-config libseccomp-dev libcap-dev libsecp256k1-dev firejail firejail-profiles seccomp proxychains4 tor libsodium-dev libgmp-dev screen"
else
   pkg_cli_build=""
fi

read -p ">>> Would you like to set to install recommended command line interface packages? [y to yes]: " -n1 var_q ; echo ""
if [[ "${var_q}" == "y" ]]; then
   pkg_cli_tools="clamav htop joe mc lm-sensors apt-file net-tools sshfs"
else
   pkg_cli_tools=""
fi

read -p ">>> Would you like to set to install optional graphical user interface build packages? [y to yes]: " -n1 var_q ; echo ""
if [[ "${var_q}" == "y" ]]; then
   pkg_gui_build="qt5-qmake-bin qt5-qmake qttools5-dev-tools qttools5-dev qtbase5-dev-tools qtbase5-dev libqt5charts5-dev python3-gst-1.0 libqrencode-dev"
else
   pkg_gui_build=""
fi

read -p ">>> Would you like to set to install optional graphical user interface packages and support for Tiger VNC server? [y to yes]: " -n1 var_q ; echo ""
if [[ "${var_q}" == "y" ]]; then
   pkg_gui_tools="gitg keepassx geany xsensors tigervnc-standalone-server"
   read -p ">>> Would you like to set to setup tigervnc server to start automatically after startup? [y to yes]: " -n1 var_q ; echo ""
   if [[ "${var_q}" == "y" ]]; then
      grep "^:1=${USER}$" /etc/tigervnc/vncserver.users >> /dev/null && cfg_user_vnc="echo 'TigerVNC for ${USER} is already configured'" || cfg_user_vnc="echo ':1=${USER}' >> /etc/tigervnc/vncserver.users; systemctl start tigervncserver@:1.service; systemctl enable tigervncserver@:1.service";
   fi
   tigervnc_yes="y"
else
   pkg_gui_tools=""
   tigervnc_yes=""
fi

eval_cmdd="${su_cmd} \"${pkg_update}; apt install ${pkg_privacy} ${pkg_cli_build} ${pkg_cli_tools} ${pkg_gui_build} ${pkg_gui_tools}; ${cfg_user_tor}; ${cfg_user_vnc}; exit\""
echo "${eval_cmdd}"
read -p ">>> Procees with above system installation? [y to yes]: " -n1 var_q ; echo ""
if [[ "${var_q}" == "y" ]]; then
   eval "$eval_cmdd"
else
   echo "INFO >> DEXSETUP installer been canceled."
   exit 0
fi

if [[ "${tigervnc_yes}" == "y" ]]; then
   read -p ">>> Would you like to setup VNC user login password? [y to yes]: " -n1 var_q ; echo ""
   if [[ "${var_q}" == "y" ]]; then
      tigervncpasswd
      (test $? != 0) && echo "ERROR >>> setup vnc password failed" && exit 1
   fi
fi

echo "making and changing directory to (~/dexsetup)"
mkdir -p ~/dexsetup/dexsetup && cd ~/dexsetup/dexsetup
(test $? != 0) && echo "ERROR >>> Failed to make and change directory to (~/dexsetup)" && exit 1

echo "downloading latest dexsetup version by git anonymously over tor"
proxychains4 git clone https://github.com/nnmfnwl/dexsetup.git ./
if [[ ${?} != 0 ]]; then
   read -p ">>> DEXSETUP seems already installed, would you like to continue to try to update? [y to yes]: " -n1 var_q ; echo ""
   if [[ "${var_q}" == "y" ]]; then
      echo "INFO >>> DEXSETUP re-installation/update in progress"
      reinstall_yes="y"
      git stash \
      && proxychains4 git pull
      (test $? != 0) && echo "update dexsetup by git failed. try again later" && exit 1
   else
      echo "ERROR >>> DEXSETUP is already installed and installation canceled."
      exit 0
   fi
fi

git checkout merge.2025.02.06 \
&& chmod 755 setup* \
&& chmod 755 ./src/setup*.sh
(test $? != 0) && echo "ERROR >>> switch to experimental DEXSETUP version failed" && exit 1

echo "INFO >>> Proxychains configuration file update"
./setup.cfg.proxychains.sh install
if [[ ${reinstall_yes} == "y" ]]; then
   ./setup.cfg.proxychains.sh update
   (test $? != 0) && echo "ERROR >>> proxychains config file update failed" && exit 1
fi

echo "Building wallets from official repositories..."

# 
function tool_setup_wallet() {  #crypto_name  #crypto_ticker  #cfg_script_path  #download_build_action
   read -p ">>> Would you like to install or update ${1}(${2}) wallet? [y to yes]: " -n1 var_q ; echo ""
   if [[ "${var_q}" == "y" ]]; then
      ./setup.cc.wallet.sh $3 install $4
      if [[ ${?} != 0 ]]; then
         read -p ">>> ${1} wallet installation failed or is already installed, would you like to try to update ${1} wallet? [y to yes]: " -n1 var_q ; echo ""
         if [[ "${var_q}" == "y" ]]; then
            ./setup.cc.wallet.sh $3 update $4
         fi
      fi
      (test $? != 0) && echo "ERROR >>> setup ${1}(${2}) wallet failed " && exit 1
   fi
}

tool_setup_wallet "Blocknet" "BLOCK" "./src/cfg.cc.blocknet.sh" "build"
tool_setup_wallet "Litecoin" "LTC" "./src/cfg.cc.litecoin.sh" "build"
tool_setup_wallet "Bitcoin" "BTC" "./src/cfg.cc.bitcoin.sh" "build"
tool_setup_wallet "Dogecoin" "DOGE" "./src/cfg.cc.dogecoin.sh" "build"
tool_setup_wallet "Dash" "DASH" "./src/cfg.cc.dash.sh" "build"
tool_setup_wallet "PIVX" "PIVX" "./src/cfg.cc.pivx.sh" "download"
tool_setup_wallet "Verge" "XVG" "./src/cfg.cc.verge.sh" "build"
tool_setup_wallet "Lbry Credits LevelDB" "LBC" "./src/cfg.cc.lbrycrd.leveldb.sh" "build"
tool_setup_wallet "Lbry Credits SQLITE" "LBC" "./src/cfg.cc.lbrycrd.sqlite.sh" "build"
tool_setup_wallet "Pocketcoin(Bastyon.com)" "PKOIN" "./src/cfg.cc.pocketcoin.sh" "build"
tool_setup_wallet "Particl" "PART" "./src/cfg.cc.particl.sh" "build"

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
