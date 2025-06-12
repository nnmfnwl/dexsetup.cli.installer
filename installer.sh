#!/bin/bash

# do not allow run script as root check
echo "INFO >>> Checking to not run this script as root"
id | grep root && echo "ERROR >>> IT IS NOT ALLOWED TO RUN THIS SCRIPT AS ROOT !!!" && exit 1

# save global args
argcc=$#
argvv=("$@")

# interactivity function definition. find yes or no arguments or ask interactively
function tool_interactivity() { #toyes #tono #info
   for (( j=0; j<argcc; j++ )); do
      if [[ "${argvv[j]}" == "${1}" ]]; then
         echo ""
         echo ">>> ${3}"
         echo ">>> (been skip by arg '${1}'/'${2}') [y to yes]: y"
         #~ echo ">>> $3 [y to yes]: y (set by arg ${1})"
         var_q="y"
         return 0
      elif [[ "${argvv[j]}" == "${2}" ]]; then
         echo ""
         echo ">>> ${3}"
         echo ">>> (been skip by arg '${1}'/'${2}') [y to yes]: n"
         #~ echo ">>> $3 [y to yes]: n (set by arg ${2})"
         var_q="n"
         return 1
      fi
   done
   
   echo ""
   echo ">>> ${3}"
   read -p ">>> (could skip by arg '${1}'/'${2}') [y to yes]: " -n1 var_q ; echo ""
   if [[ "${var_q}" == "y" ]]; then
      return 0
   fi
   
   return 1
}

echo "INFO >>> Detecting Linux distribution operating system compatibility"
cat /etc/*release | grep -i -e debian -e ubuntu > /dev/null;
if [[ ${?} != 0 ]]; then
   cat /etc/*release
   tool_interactivity "compat-y" "compat-n" "Unsupported operating system has been detected. Would you like to continue installer?"
   if [[ "${var_q}" != "y" ]]; then
      echo "INFO >> DEXSETUP installer been canceled."
      exit 0
   fi
fi

echo "INFO >>> Detecting Linux distribution 'sudo'/'su' compatibility"
sudo -v; (test $? != 0) && su_cmd="echo 'Please enter ROOT password'; su -c" || su_cmd="echo 'Please enter ${USER} sudo password'; sudo -sh -c";

echo ""
echo "DEXSETUP INSTALLER - Blocknet's Decentralized Exchange Backend System Installer for Debian/Ubuntu based Linux distributions"
echo "We build decentralized system which has NO central point of failure or control"
echo "What it is and does:"
echo "It is advanced multipurpose tool to build genuine decentralized systems"
echo "It can prepare operating system to become node operator, tester, user or even developer and easy manage wallets and wallet profiles remotely by CLI and also GUI"
echo "it can setup or update DEXSETUP framework"
echo "It can build wallet from official source code or download wallets from official github repositories"
echo "It can configure or merge wallet .conf files configurations"
echo "It can create and manage wallet profiles and predefine wallet CLI commands per wallet profile"
echo "It can configure Blocknet service node with other by desetup installed wallets"
echo "It can setup DEXBOT automatic liquidity/trading bot"
echo "It can use predefined trading strategy templates to create DEXBOT trading strategies configured to be run directly within installed wallets"
echo "It can generate script used to easy manage all components by GNU Screen Terminal Multiplexer"
echo "It can configures VNC server and start automatically after restart"

tool_interactivity "c-y" "c-n" "Would you like to continue with this experimental dexsetup installer script?"
if [[ "${var_q}" != "y" ]]; then
   echo "INFO >> DEXSETUP installer been canceled."
   exit 0
fi

tool_interactivity "upgrade-y" "upgrade-n" "Would you like to set to update system before installation start?"
if [[ "${var_q}" == "y" ]]; then
   pkg_update="apt update; apt full-upgrade"
else
   pkg_update="echo 'no apt update/upgrade performed'"
fi

tool_interactivity "pkg-privacy-y" "pkg-privacy-n" "Would you like to set to install mandatory to have tor proxychains4 and torsocks privacy packages?"
if [[ "${var_q}" == "y" ]]; then
   pkg_privacy="tor proxychains4 torsocks"
   groups | grep debian-tor > /dev/null && cfg_user_tor="echo 'tor for ${USER} already configured'" || cfg_user_tor="usermod -a -G debian-tor ${USER}"
else
   pkg_privacy=""
   cfg_user_tor="echo 'no user tor configuration'"
fi

tool_interactivity "pkg-build-y" "pkg-build-n" "Would you like to set to install mandatory to have command line interface build packages?"
if [[ "${var_q}" == "y" ]]; then
   pkg_cli_build="curl wget git make cmake clang clang-tools clang-format libclang1 libboost-all-dev basez libprotobuf-dev protobuf-compiler libssl-dev openssl gcc g++ python3-pip python3-dateutil cargo pkg-config libseccomp-dev libcap-dev libsecp256k1-dev firejail firejail-profiles seccomp proxychains4 tor libsodium-dev libgmp-dev screen"
else
   pkg_cli_build=""
fi

tool_interactivity "pkg-tools-y" "pkg-tools-n" "Would you like to set to install recommended command line interface packages?"
if [[ "${var_q}" == "y" ]]; then
   pkg_cli_tools="clamav htop joe mc lm-sensors apt-file net-tools sshfs"
else
   pkg_cli_tools=""
fi

tool_interactivity "pkg-gui-build-y" "pkg-gui-build-n" "Would you like to set to install optional graphical user interface build packages?"
if [[ "${var_q}" == "y" ]]; then
   pkg_gui_build="qt5-qmake-bin qt5-qmake qttools5-dev-tools qttools5-dev qtbase5-dev-tools qtbase5-dev libqt5charts5-dev python3-gst-1.0 libqrencode-dev"
else
   pkg_gui_build=""
fi

tool_interactivity "pkg-gui-tools-y" "pkg-gui-tools-n" "Would you like to set to install optional graphical user interface packages and support for Tiger VNC server?"
if [[ "${var_q}" == "y" ]]; then
   pkg_gui_tools="gitg keepassx geany xsensors tigervnc-standalone-server"
   tool_interactivity "vnc-autostart-y" "vnc-autostart-n" "Would you like to set to setup tigervnc server to start automatically after startup?"
   if [[ "${var_q}" == "y" ]]; then
      #~ grep "^:1=${USER}$" /etc/tigervnc/vncserver.users >> /dev/null && cfg_user_vnc="echo 'TigerVNC for ${USER} is already configured'" || cfg_user_vnc="echo ':1=${USER}' >> /etc/tigervnc/vncserver.users; systemctl start tigervncserver@:1.service; systemctl enable tigervncserver@:1.service";
      port=1
      while : ; do
         grep "^:[0-9]=${USER}$" /etc/tigervnc/vncserver.users
         if [[ ${?} == 0 ]]; then
            echo "WARNING >>> TigerVNC for ${USER} is already configured. This step is skip."
            cfg_user_vnc="echo 'TigerVNC for ${USER} is already configured'"
            break
         else
            grep "^:${port}=" /etc/tigervnc/vncserver.users
            if [[ ${?} == 0 ]]; then
               echo "WARNING >>> TigerVNC is already configured at port ${port} for another user."
               read -p ">>> Please enter alternative port number 1 to 9: " -n1 portt ; echo ""
               echo "${portt}" | grep "[0-9]" && port=${portt} || echo "ERROR >>> Invalid port number ${portt} selected."
            else
               cfg_user_vnc="echo ':${port}=${USER}' >> /etc/tigervnc/vncserver.users; systemctl start tigervncserver@:${port}.service; systemctl enable tigervncserver@:${port}.service";
               break
            fi
         fi
      done
   fi
   tigervnc_yes="y"
else
   pkg_gui_tools=""
   cfg_user_vnc="echo 'no TigerVNC for ${USER} is going to be configured'"
   tigervnc_yes=""
fi

echo ""
eval_cmdd="${su_cmd} \"${pkg_update}; apt install apt ${pkg_privacy} ${pkg_cli_build} ${pkg_cli_tools} ${pkg_gui_build} ${pkg_gui_tools}; ${cfg_user_tor}; ${cfg_user_vnc}; exit\""
echo "${eval_cmdd}"
tool_interactivity "proceed-y" "proceed-n" "Proceed with above system setup/update?"
if [[ "${var_q}" == "y" ]]; then
   eval "$eval_cmdd"
else
   echo "INFO >> Operating system setup/update been skip."
fi

if [[ "${tigervnc_yes}" == "y" ]]; then
   tool_interactivity "vnc-setpassword-y" "vnc-setpassword-n" "Would you like to setup VNC user login password?"
   if [[ "${var_q}" == "y" ]]; then
      tigervncpasswd
      (test $? != 0) && echo "ERROR >>> setup vnc password failed" && exit 1
   fi
fi

echo "making and changing directory to (~/dexsetup)"
mkdir -p ./dexsetup && cd ./dexsetup
(test $? != 0) && echo "ERROR >>> Failed to make and change directory to (~/dexsetup)" && exit 1

echo "downloading latest dexsetup version by git anonymously over tor"
proxychains4 git clone https://github.com/nnmfnwl/dexsetup.git ./
if [[ ${?} != 0 ]]; then
   tool_interactivity "dexsetup-update-y" "dexsetup-update-n" "DEXSETUP seems already installed, would you like to try to update DEXSETUP and other components first?"
   if [[ "${var_q}" == "y" ]]; then
      echo "INFO >>> DEXSETUP re-installation/update in progress"
      git stash \
      && git checkout merge.2025.02.06 \
      && proxychains4 git pull \
      && chmod 755 setup* \
      && chmod 755 ./src/setup*.sh
      (test $? != 0) && echo "update dexsetup by git failed. try again later" && exit 1
   else
      echo "ERROR >>> DEXSETUP is already installed and update been skip"
   fi
else
   git checkout merge.2025.02.06 \
   && chmod 755 setup* \
   && chmod 755 ./src/setup*.sh
   (test $? != 0) && echo "ERROR >>> switch to experimental DEXSETUP version failed" && exit 1
fi

echo "INFO >>> Proxychains configuration file update"
./setup.cfg.proxychains.sh install
if [[ ${?} != 0 ]]; then
   tool_interactivity "proxychains-usr-reconfig-y" "proxychains-usr-reconfig-n" "Proxychains seems already configured, would you like to try to reconfigure first?"
   if [[ "${var_q}" == "y" ]]; then
   ./setup.cfg.proxychains.sh update
   (test $? != 0) && echo "ERROR >>> proxychains config file update failed" && exit 1
   fi
fi

echo "Building wallets from official repositories..."

# 
function tool_setup_wallet() {  #crypto_name  #crypto_ticker  #cfg_script_path  #download_build_action
   tool_interactivity "${2}-install-y" "${2}-install-n" "Would you like to install or update ${1}(${2}) wallet?"
   if [[ "${var_q}" == "y" ]]; then
      ./setup.cc.wallet.sh $3 install $4
      if [[ ${?} != 0 ]]; then
         tool_interactivity "${2}-update-y" "${2}-update-n" "${1} wallet installation failed or is already installed, would you like to try to update ${1} wallet?"
         if [[ "${var_q}" == "y" ]]; then
            ./setup.cc.wallet.sh $3 update $4
            if [[ ${?} != 0 ]]; then
               tool_interactivity "skip-failed-install-y" "skip-failed-install-n" "${1} wallet update failed, would you like to skip this wallet and continue?"
               if [[ "${var_q}" != "y" ]]; then
                  echo "ERROR >>> setup ${1}(${2}) wallet failed " && exit 1
               fi
            fi
         fi
      fi
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

tool_interactivity "dao-profiles-y" "dao-profiles-n" "Would you like to setup also standalone DAO profiles for blocknet?"
if [[ "${var_q}" == "y" ]]; then
   ./setup.cc.wallet.profile.sh ./src/cfg.cc.blocknet.dao.sh
   (test $? != 0) && echo "make blocknet wallet staking profile failed" && exit 1
fi

tool_interactivity "stake-profiles-y" "stake-profiles-n" "Would you like to setup also standalone staking profiles for blocknet, pocketcoin and pivx?"
if [[ "${var_q}" == "y" ]]; then
   ./setup.cc.wallet.profile.sh ./src/cfg.cc.blocknet.staking.sh
   (test $? != 0) && echo "make blocknet wallet staking profile failed" && exit 1
   ./setup.cc.wallet.profile.sh ./src/cfg.cc.pocketcoin.sh ~/.pocketcoin_staking wallet_pkoin_staking
   (test $? != 0) && echo "make pocketcoin (bastyon) wallet staking profile failed" && exit 1
   ./setup.cc.wallet.profile.sh ./src/cfg.cc.pivx.sh ~/.pivx_staking/ wallet_pivx_staking
   (test $? != 0) && echo "make pivx wallet staking profile failed" && exit 1
fi

tool_interactivity "dex-profiles-y" "dex-profiles-n" "Would you like to setup wallet profiles which to be used in DEX trading?"
if [[ "${var_q}" == "y" ]]; then
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
fi

#1 ticker1   #2 ticker2   #3 block script   #4 ticker 1 script   #5 ticker 2 script   #6 dexbot script  #7 dexbot strategy template  #8 strategy name #9 addr1   #10 addr2
function tool_setup_wallet_profile() {  
   tool_interactivity "${1}-${2}-setup-y" "${1}-${2}-setup-n" "Would you like to setup DEXBOT ${1}/${2} trading strategy ${8} with DEX trading wallet profiles?"
   if [[ "${var_q}" == "y" ]]; then
      ./setup.cc.dexbot.profile.sh ${3} ${4} ${5} ${6} ${7} ${8} ${9} ${10}
      if [[ ${?} != 0 ]]; then
         tool_interactivity "${1}-${2}-update-y" "${1}-${2}-update-n" "DEXBOT ${1}/${2} trading strategy ${8} failed or is already installed, would you like to try to update it?"
         if [[ "${var_q}" == "y" ]]; then
            ./setup.cc.dexbot.profile.sh ${3} ${4} ${5} ${6} ${7} ${8} ${9} ${10} update_strategy
            if [[ ${?} != 0 ]]; then
               tool_interactivity "${1}-${2}-skip-failed-y" "${1}-${2}-skip-failed-n" "DEXBOT ${1}/${2} trading strategy ${8} make failed, would you like to skip and continue?"
               if [[ "${var_q}" != "y" ]]; then
                  echo "ERROR >>> setup DEXBOT ${1}/(${2}) trading strategy {8} failed " && exit 1
               fi
            fi
         fi
      fi
   fi
}

tool_interactivity "dexbot-strategies-y" "dexbot-strategies-n" "Would you like to setup DEXBOT and trading strategies with DEX trading wallet profiles?"
if [[ "${var_q}" == "y" ]]; then
   tool_setup_wallet_profile "BLOCK" "LTC" ./src/cfg.cc.blocknet.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.block.ltc.sh strategy1 blocknet01 litecoin01
   
   tool_setup_wallet_profile "BTC" "LTC" ./src/cfg.cc.blocknet.sh ./src/cfg.cc.bitcoin.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.btc.ltc.sh strategy1 bitcoin01 litecoin02
   
   tool_setup_wallet_profile "XVG" "LTC" ./src/cfg.cc.blocknet.sh ./src/cfg.cc.verge.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.xvg.ltc.sh strategy1 verge01 litecoin03
   
   tool_setup_wallet_profile "DOGE" "LTC" ./src/cfg.cc.blocknet.sh ./src/cfg.cc.dogecoin.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.doge.ltc.sh strategy1 dogecoin01 litecoin04
   
   tool_setup_wallet_profile "PIVX" "LTC" ./src/cfg.cc.blocknet.sh ./src/cfg.cc.pivx.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.pivx.ltc.sh strategy1 pivx01 litecoin05
   
   tool_setup_wallet_profile "DASH" "LTC"  ./src/cfg.cc.blocknet.sh ./src/cfg.cc.dash.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.dash.ltc.sh strategy1 dash01 litecoin06
   
   tool_setup_wallet_profile "LBC" "LTC"  ./src/cfg.cc.blocknet.sh ./src/cfg.cc.lbrycrd.leveldb.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.lbc.ltc.sh strategy1 lbrycrd01 litecoin07
   
   tool_setup_wallet_profile "PKOIN" "LTC"  ./src/cfg.cc.blocknet.sh ./src/cfg.cc.pocketcoin.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.pkoin.ltc.sh strategy1 pocketcoin01 litecoin08
   
   tool_setup_wallet_profile "PART" "LTC" ./src/cfg.cc.blocknet.sh ./src/cfg.cc.particl.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.part.ltc.sh strategy1 particl01 litecoin09
fi

tool_interactivity "blockdx-install-y" "blockdx-install-n" "Would you like to install BlockDX(Blocknet DEX GUI app)?"
if [[ "${var_q}" == "y" ]]; then
   ./setup.cc.blockdx.sh download install
   if [[ ${?} != 0 ]]; then
      tool_interactivity "blockdx-update-y" "blockdx-update-n" "BlockdDX seems already installed, would you like to try to update it first?"
      if [[ "${var_q}" == "y" ]]; then
         ./setup.cc.blockdx.sh download update
         (test $? != 0) && echo "setup BlockDX failed" && exit 1
      fi
   fi
fi

tool_interactivity "blockdx-profile-y" "blockdx-profile-n" "Would you like to autoconfigure BlockDX default profile?"
if [[ "${var_q}" == "y" ]]; then
   ./setup.cc.blockdx.profile.sh
   (test $? != 0) && echo "setup BlockDX profile failed" && exit 1
fi

tool_interactivity "screen-y" "screen-n" "Would you like to setup Start/stop/update scripts with GNU Screen terminal multiplexer?"
if [[ "${var_q}" == "y" ]]; then
   ./setup.screen.sh install
   if [[ ${?} != 0 ]]; then
      tool_interactivity "screen-update-y" "screen-update-n" "GNU Screen Terminal Multiplexer script seems already configured, would you like to try to update it first?"
      if [[ "${var_q}" == "y" ]]; then
         ./setup.screen.sh update
         (test $? != 0) && echo "Start/stop/update scripts with GNU Screen terminal multiplexer setup failed" && exit 1
      fi
   fi
fi

cd ..

echo '
cd dexsetup || echo "dexsetup directory not found" && exit 1

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
echo "DEXBOT Strategies needs to be reconfigured with valid wallet addresses by using reconfiguration script later after you setup your wallet addresses 'cd `pwd` && ./installer_reconfigure_dexbot.sh'"
