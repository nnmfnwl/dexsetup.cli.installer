#!/bin/bash

# do not allow run script as root check
echo "INFO >>> Checking to not run this script as root"
id | grep root && echo "ERROR >>> IT IS NOT ALLOWED TO RUN THIS SCRIPT AS ROOT !!!" && exit 1

# save global args
argcc=$#
argvv=("$@")

# define
#~ dexsetup_git_branch="merge.2025.02.06"
dexsetup_git_branch="dev.2025.10.23"

# interactivity function definition. find yes or no arguments or ask interactively
function tool_interactivity() { #toyes #tono #info
   for (( j=0; j<argcc; j++ )); do
      if [[ "${argvv[j]}" == "${1}" ]]; then
         echo ""
         echo ">>> ${3}"
         echo ">>> (been skip by arg '${1} / ${2}') [y to yes]: y"
         var_q="y"
         return 0
      elif [[ "${argvv[j]}" == "${2}" ]]; then
         echo ""
         echo ">>> ${3}"
         echo ">>> (been skip by arg '${1} / ${2}') [y to yes]: n"
         var_q="n"
         return 1
      fi
   done
   
   for (( j=0; j<argcc; j++ )); do
      if [[ "${argvv[j]}" == "DEFAULT-Y" ]]; then
         echo ""
         echo ">>> ${3}"
         echo ">>> (been skip by arg '${1} / ${2} / DEFAULT-Y') [y to yes]: y"
         var_q="y"
         return 0
      elif [[ "${argvv[j]}" == "DEFAULT-N" ]]; then
         echo ""
         echo ">>> ${3}"
         echo ">>> (been skip by arg '${1} / ${2} / DEFAULT-N') [y to yes]: n"
         var_q="n"
         return 1
      fi
   done
   
   echo ""
   echo ">>> ${3}"
   while : ; do
      read -p ">>> (could skip by arg '${1} / ${2} / DEFAULT-Y / DEFAULT-N') [n-no/y-yes]: " -n1 var_q ; echo ""
      if [[ "${var_q}" == "y" ]]; then
         return 0
      elif [[ "${var_q}" == "n" ]]; then
         return 1
      else
         echo "Please use <y> to 'Yes' or <n> to 'No'"
      fi
   done
   
   return 1
}

# find argument value
function tool_arg_value() { #1 arg.name #2 "if match" #3 "then set to" #4"secret"  #5 info  #arg is loaded to var_v
   var_v=""
   echo ""
   for (( j=0; j<argcc; j++ )); do
      if [[ "${argvv[j]}" == "${1}" ]]; then
         ((j++))
         var_v="${argvv[j]}"
         
         if [[ "${2}" == "${var_v}" ]]; then
            var_v="${3}"
            if [[ "secret" == "${4}" ]]; then
               echo ">>> argument '${1}' - ${5} value found but set to default '*******'"
            else
               echo ">>> argument '${1}' - ${5} value found but set to default '${var_v}'"
            fi
         else
            if [[ "secret" == "${4}" ]]; then
               echo ">>> argument '${1}' - ${5} value found '*******'"
            else
               echo ">>> argument '${1}' - ${5} value found '${var_v}'"
            fi
         fi
         
         return 0
      fi
   done
   
   if [[ "${2}" == "${var_v}" ]]; then
      var_v="${3}"
      if [[ "secret" == "${4}" ]]; then
         echo ">>> argument '${1}' - ${5} value not found and set to default '*******'"
      else
         echo ">>> argument '${1}' - ${5} value not found and set to default '${var_v}'"
      fi
   else
      if [[ "secret" == "${4}" ]]; then
         echo ">>> argument '${1}' - ${5} value not found and is empty '*******'"
      else
         echo ">>> argument '${1}' - ${5} value not found and is empty '${var_v}'"
      fi
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
sudo -v; (test $? != 0) && su_cmd="echo 'Please enter ROOT password'; su -c" || su_cmd="echo 'Please enter ${USER} sudo password'; sudo sh -c";

echo ""
echo "DEXSETUP INSTALLER - Blocknet's Decentralized Exchange Backend System Installer for Debian/Ubuntu based Linux distributions, namely dexsetup framework"
echo "We build decentralized system which has NO central point of failure or control"
echo "What it is and does:"
echo "It is advanced multipurpose tool to build genuine decentralized systems"
echo "It can prepare operating system to become node operator, tester, user or even developer and easy manage wallets and wallet profiles remotely by CLI and also GUI"
echo "It can setup or update DEXSETUP framework"
echo "It can build wallet from official source code or download wallets from official github repositories"
echo "It can configure or merge wallet .conf files configurations"
echo "It can create and manage wallet profiles and predefine wallet CLI commands per wallet profile"
echo "It can configure Blocknet service node with other by desetup installed wallets"
echo "It can setup DEXBOT automatic liquidity/trading bot"
echo "It can use predefined trading strategy templates to create DEXBOT trading strategies configured to be run directly within installed wallets"
echo "It can generate script used to easy manage all components by GNU Screen Terminal Multiplexer"
echo "It can configures VNC server and start automatically after restart"

tool_interactivity "c-y" "c-n" "Would you like to accept standardized MIT license agreement and continue with this experimental dexsetup installer script?"
if [[ "${var_q}" != "y" ]]; then
   echo "INFO >> DEXSETUP installer been canceled."
   exit 0
fi

tool_interactivity "upgrade-y" "upgrade-n" "Would you like to set to update system before installation start?"
if [[ "${var_q}" == "y" ]]; then
   pkg_update="apt -y update; apt -y full-upgrade"
else
   pkg_update="echo 'no apt update/upgrade performed'"
fi

tool_interactivity "pkg-privacy-y" "pkg-privacy-n" "Would you like to set to install mandatory to have tor proxychains4 and torsocks privacy packages?"
if [[ "${var_q}" == "y" ]]; then
   pkg_privacy="tor proxychains4 torsocks"
   groups | grep debian-tor > /dev/null && cfg_user_tor="echo 'tor for ${USER} already configured'" || cfg_user_tor="usermod -a -G debian-tor ${USER}"
else
   pkg_privacy=""
fi

tool_interactivity "pkg-build-y" "pkg-build-n" "Would you like to set to install mandatory to have command line interface build packages?"
if [[ "${var_q}" == "y" ]]; then
   pkg_cli_build="curl wget git make cmake clang clang-tools clang-format libclang1 libboost-all-dev basez libprotobuf-dev protobuf-compiler libssl-dev openssl gcc g++ python3-pip python3-dateutil cargo pkg-config libseccomp-dev libcap-dev libsecp256k1-dev firejail firejail-profiles seccomp proxychains4 tor libsodium-dev libgmp-dev screen libfmt-dev linux-cpupower libdb-dev libdb5.3++-dev"
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
   tigervnc_yes=""
fi

[[ "${cfg_user_tor}" == "" ]] && cfg_user_tor="echo 'no Tor service for ${USER} is going to be configured'"
[[ "${cfg_user_vnc}" == "" ]] && cfg_user_vnc="echo 'no TigerVNC for ${USER} is going to be configured'"

while : ; do
   # make system update and setup command
   eval_cmdd="${su_cmd} \"${pkg_update}; apt -y install apt ${pkg_privacy} ${pkg_cli_build} ${pkg_cli_tools} ${pkg_gui_build} ${pkg_gui_tools}; ${cfg_user_tor}; ${cfg_user_vnc}; exit\""
   # log message system update and setup command
   echo ""
   echo "${eval_cmdd}"
   # ask to process command
   tool_interactivity "proceed-y" "proceed-n" "Proceed with above system setup/update?"
   if [[ "${var_q}" == "y" ]]; then
      # process command
      eval "$eval_cmdd"
      if [[ "$?" == "0" ]]; then
         # break loop if system update and setup command success
         break
      else
         # warning if system update and setup command fails
         echo "WARNING >>> System setup password/update/install/tor/vnc failed. Please check above."
         # ask if to try to repeat system update and setup command
         tool_interactivity "proceed-repeat-y" "proceed-repeat-n" "Try to repeat system setup/update?"
         if [[ "${var_q}" == "y" ]]; then
            echo "INFO >> Trying to repeat system update & setup"
            # if above command already process vnc configuration, then do not try it again
            grep "^:[0-9]=${USER}$" /etc/tigervnc/vncserver.users && cfg_user_vnc="echo 'TigerVNC for ${USER} is already configured'"
            # if above command already process to add user to tor groups, then do not try ti again
            groups | grep debian-tor > /dev/null && cfg_user_tor="echo 'tor for ${USER} already configured'"
         else
            # if system update and setup commands fails and user refuse to repat, it exit installer process with error 1
            echo "ERROR >> System configuration step failed"
            exit 1
         fi
      fi
   else
      echo "WARNING >> Operating system setup/update been skip."
      break
   fi
done

if [[ "${tigervnc_yes}" == "y" ]]; then
   tool_interactivity "vnc-setpassword-y" "vnc-setpassword-n" "Would you like to setup VNC user login password?"
   if [[ "${var_q}" == "y" ]]; then
      tool_arg_value "vncpasswd" "" "" "secret" ""
      if [[ "$?" == "0" ]]; then
         echo -e "${var_v}\n${var_v}\nn" | tigervncpasswd
         var_v=""
      else
         echo "Please enter new VNC password for current user"
         tigervncpasswd
      fi
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
      && git checkout ${dexsetup_git_branch} \
      && proxychains4 git pull \
      && chmod 755 setup* \
      && chmod 755 ./src/setup*.sh
      (test $? != 0) && echo "update dexsetup by git failed. try again later" && exit 1
   else
      echo "ERROR >>> DEXSETUP is already installed and update been skip"
   fi
else
   git checkout ${dexsetup_git_branch} \
   && chmod 755 setup* \
   && chmod 755 ./src/setup*.sh
   (test $? != 0) && echo "ERROR >>> switch to experimental DEXSETUP version failed" && exit 1
fi

tool_interactivity "mate-conf-y" "mate-conf-n" "Would you like to add optimized mate desktop configuration?"
if [[ "${var_q}" == "y" ]]; then
   dconf load /org/mate/ < ./src/dconf.dump.org.mate.txt
   (test $? != 0) && echo "ERROR >>> Mate desktop add optimized configuration failed" && exit 1
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

# setup wallet
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
tool_setup_wallet "PIVX" "PIVX" "./src/cfg.cc.pivx.sh" "build"
tool_setup_wallet "Verge" "XVG" "./src/cfg.cc.verge.sh" "build"
tool_setup_wallet "Bitcoincash unlimited" "BCH" "./src/cfg.cc.bch.unlimited.sh" "build"
tool_setup_wallet "Bitcoincash node" "BCH" "./src/cfg.cc.bch.node.sh" "download"
#~ tool_setup_wallet "Lbry Credits LevelDB" "LBC" "./src/cfg.cc.lbrycrd.leveldb.sh" "build"
#~ tool_setup_wallet "Lbry Credits SQLITE" "LBC" "./src/cfg.cc.lbrycrd.sqlite.sh" "build"
tool_setup_wallet "Pocketcoin(Bastyon.com)" "PKOIN" "./src/cfg.cc.pocketcoin.sh" "build"
tool_setup_wallet "Particl" "PART" "./src/cfg.cc.particl.sh" "build"

echo "Wallets profiling setup"

# setup wallet profile
function tool_setup_wallet_profile() {  #crypto_name  #cfg_script_path
   tool_interactivity "${1}-profile-y" "${1}-profile-n" "Would you like to setup ${1}(${2}) wallet profile?"
   if [[ "${var_q}" == "y" ]]; then
      ./setup.cc.wallet.profile.sh ${2}
      if [[ ${?} != 0 ]]; then
         echo "make ${1}(${2}) wallet profile failed" && exit 1
      fi
   fi
}

tool_interactivity "dao-profiles-y" "dao-profiles-n" "Would you like to setup also standalone DAO profiles for blocknet?"
if [[ "${var_q}" == "y" ]]; then
   tool_setup_wallet_profile "BLOCK-dao" ./src/cfg.cc.blocknet.dao.sh
fi

tool_interactivity "stake-profiles-y" "stake-profiles-n" "Would you like to setup also standalone staking profiles for blocknet, pocketcoin and pivx?"
if [[ "${var_q}" == "y" ]]; then
   tool_setup_wallet_profile "BLOCK-stake" ./src/cfg.cc.blocknet.staking.sh
   tool_setup_wallet_profile "PKOIN-stake" ./src/cfg.cc.pocketcoin.staking.sh
   tool_setup_wallet_profile "PIVX-stake" ./src/cfg.cc.pivx.staking.sh
fi

tool_interactivity "dex-profiles-y" "dex-profiles-n" "Would you like to setup wallet profiles which to be used in DEX trading?"
if [[ "${var_q}" == "y" ]]; then
   tool_setup_wallet_profile "BLOCK-dex" ./src/cfg.cc.blocknet.sh
   tool_setup_wallet_profile "LTC-dex" ./src/cfg.cc.litecoin.sh
   tool_setup_wallet_profile "BTC-dex" ./src/cfg.cc.bitcoin.sh
   tool_setup_wallet_profile "XVG-dex" ./src/cfg.cc.verge.sh
   tool_setup_wallet_profile "DOGE-dex" ./src/cfg.cc.dogecoin.sh
   tool_setup_wallet_profile "PIVX-dex" ./src/cfg.cc.pivx.sh
   tool_setup_wallet_profile "DASH-dex" ./src/cfg.cc.dash.sh
   tool_setup_wallet_profile "BCH-unlimited-dex" ./src/cfg.cc.bch.unlimited.sh
   tool_setup_wallet_profile "BCH-node-dex" ./src/cfg.cc.bch.node.sh
   #~ tool_setup_wallet_profile "LBC-dex" ./src/cfg.cc.lbrycrd.leveldb.sh
   #~ tool_setup_wallet_profile "LBC-dex" ./src/cfg.cc.lbrycrd.sqlite.sh
   tool_setup_wallet_profile "PKOIN-dex" ./src/cfg.cc.pocketcoin.sh
   tool_setup_wallet_profile "PART-dex" ./src/cfg.cc.particl.sh
fi

#setup custom dexbot profile
tool_arg_value "strategy-name" "" "" "" "custom strategy name"
if [[ ${?} == 0 ]]; then
   strategy_name=${var_v}
   tool_arg_value "strategy-cfg" "" "" "" "custom strategy configuration file"
   if [[ ${?} == 0 ]]; then
      strategy_cfg=${var_v}
      tool_arg_value "strategy-cfg-a" "" "" "" "custom strategy configuration file A"
      if [[ ${?} == 0 ]]; then
         strategy_cfg_a=${var_v}
         tool_arg_value "strategy-cfg-b" "" "" "" "custom strategy configuration file B"
         if [[ ${?} == 0 ]]; then
            strategy_cfg_b=${var_v}
            tool_arg_value "strategy-addr-a" "" "" "" "custom strategy address A"
            if [[ ${?} == 0 ]]; then
               strategy_addr_a=${var_v}
               tool_arg_value "strategy-addr-b" "" "" "" "custom strategy address B"
               if [[ ${?} == 0 ]]; then
                  strategy_addr_b=${var_v}
                  ./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ${strategy_cfg_a} ${strategy_cfg_b} ./src/cfg.dexbot.alfa.sh ${strategy_cfg} ${strategy_name} ${strategy_addr_a} ${strategy_addr_b} 
                  if [[ ${?} != 0 ]]; then
                     tool_interactivity "$strategy-update-y" "strategy-update-n" "DEXBOT trading strategy ${strategy_name} failed or is already installed, would you like to try to update it?"
                     if [[ "${var_q}" == "y" ]]; then
                        ./setup.cc.dexbot.profile.sh ./src/cfg.cc.blocknet.sh ${strategy_cfg_a} ${strategy_cfg_b} ./src/cfg.dexbot.alfa.sh ${strategy_cfg} ${strategy_name} ${strategy_addr_a} ${strategy_addr_b} update_strategy update_source
                        if [[ ${?} != 0 ]]; then
                           tool_interactivity "$strategy-skip-failed-y" "strategy-skip-failed-n" "DEXBOT trading strategy ${strategy_name} make failed, would you like to skip and continue?"
                           if [[ "${var_q}" != "y" ]]; then
                              echo "ERROR >>> setup DEXBOT trading strategy {strategy_name} failed " && exit 1
                           fi
                        fi
                     fi
                  fi
               fi
            fi
         fi
      fi
   fi
fi

#1 ticker1   #2 ticker2   #3 block script   #4 ticker 1 script   #5 ticker 2 script   #6 dexbot script  #7 dexbot strategy template  #8 strategy name #9 addr_a   #10 addr_b
function tool_setup_dexbot_profile() {  
   tool_interactivity "${1}-${2}-setup-y" "${1}-${2}-setup-n" "Would you like to setup DEXBOT ${1}/${2} trading strategy ${8} with DEX trading wallet profiles?"
   if [[ "${var_q}" == "y" ]]; then
      
      tool_arg_value "${1}-${2}-strategy-cfg" "" "${7}" "" "strategy config"
      strategy_cfg=${var_v}
      tool_arg_value "${1}-${2}-strategy-name" "" "${8}" "" "strategy name"
      strategy_name=${var_v}
      tool_arg_value "${1}-${2}-strategy-addr-a" "" "${9}" "" "address1"
      strategy_addr_a=${var_v}
      tool_arg_value "${1}-${2}-strategy-addr-b" "" "${10}" "" "address2"
      strategy_addr_b=${var_v}
      
      ./setup.cc.dexbot.profile.sh ${3} ${4} ${5} ${6} ${strategy_cfg} ${strategy_name} ${strategy_addr_a} ${strategy_addr_b} 
      if [[ ${?} != 0 ]]; then
         tool_interactivity "${1}-${2}-update-y" "${1}-${2}-update-n" "DEXBOT ${1}/${2} trading strategy ${strategy_name} failed or is already installed, would you like to try to update it?"
         if [[ "${var_q}" == "y" ]]; then
            ./setup.cc.dexbot.profile.sh ${3} ${4} ${5} ${6} ${strategy_cfg} ${strategy_name} ${strategy_addr_a} ${strategy_addr_b} update_strategy update_source
            if [[ ${?} != 0 ]]; then
               tool_interactivity "${1}-${2}-skip-failed-y" "${1}-${2}-skip-failed-n" "DEXBOT ${1}/${2} trading strategy ${strategy_name} make failed, would you like to skip and continue?"
               if [[ "${var_q}" != "y" ]]; then
                  echo "ERROR >>> setup DEXBOT ${1}/(${2}) trading strategy {strategy_name} failed " && exit 1
               fi
            fi
         fi
      fi
   fi
}

tool_interactivity "dexbot-strategies-y" "dexbot-strategies-n" "Would you like to setup DEXBOT and trading strategies with DEX trading wallet profiles?"
if [[ "${var_q}" == "y" ]]; then
   strategies_enabled="1"
   
   #BLOCK
   tool_setup_dexbot_profile "BLOCK" "BCH" ./src/cfg.cc.blocknet.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.bch.unlimited.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.block.bch.sh strategy1 unique_block_addr unique_bch_addr
   
   tool_setup_dexbot_profile "BLOCK" "BTC" ./src/cfg.cc.blocknet.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.bitcoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.block.btc.sh strategy1 unique_block_addr unique_btc_addr
   
   tool_setup_dexbot_profile "BLOCK" "DASH" ./src/cfg.cc.blocknet.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.dash.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.block.dash.sh strategy1 unique_block_addr unique_dash_addr
   
   tool_setup_dexbot_profile "BLOCK" "DOGE" ./src/cfg.cc.blocknet.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.dogecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.block.doge.sh strategy1 unique_block_addr unique_doge_addr
   
   tool_setup_dexbot_profile "BLOCK" "LTC" ./src/cfg.cc.blocknet.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.block.ltc.sh strategy1 unique_block_addr unique_ltc_addr
   
   tool_setup_dexbot_profile "BLOCK" "PART" ./src/cfg.cc.blocknet.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.particl.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.block.part.sh strategy1 unique_block_addr unique_part_addr
   
   tool_setup_dexbot_profile "BLOCK" "PIVX" ./src/cfg.cc.blocknet.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.pivx.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.block.pivx.sh strategy1 unique_block_addr unique_pivx_addr
   
   tool_setup_dexbot_profile "BLOCK" "PKOIN" ./src/cfg.cc.blocknet.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.pocketcoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.block.pkoin.sh strategy1 unique_block_addr unique_pkoin_addr
   
   tool_setup_dexbot_profile "BLOCK" "XVG" ./src/cfg.cc.blocknet.sh ./src/cfg.cc.blocknet.sh ./src/cfg.cc.verge.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.block.xvg.sh strategy1 unique_block_addr unique_xvg_addr
   
   #BTC
   tool_setup_dexbot_profile "BTC" "LTC" ./src/cfg.cc.blocknet.sh ./src/cfg.cc.bitcoin.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.btc.ltc.sh strategy1 bitcoin01 litecoin02
   
   #XVG
   tool_setup_dexbot_profile "XVG" "LTC" ./src/cfg.cc.blocknet.sh ./src/cfg.cc.verge.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.xvg.ltc.sh strategy1 verge01 litecoin03
   
   #DOGE
   tool_setup_dexbot_profile "DOGE" "LTC" ./src/cfg.cc.blocknet.sh ./src/cfg.cc.dogecoin.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.doge.ltc.sh strategy1 dogecoin01 litecoin04
   
   #PIVX
   tool_setup_dexbot_profile "PIVX" "LTC" ./src/cfg.cc.blocknet.sh ./src/cfg.cc.pivx.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.pivx.ltc.sh strategy1 pivx01 litecoin05
   
   #DASH
   tool_setup_dexbot_profile "DASH" "LTC"  ./src/cfg.cc.blocknet.sh ./src/cfg.cc.dash.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.dash.ltc.sh strategy1 dash01 litecoin06
   
   #BCH
   tool_setup_dexbot_profile "BCH" "LTC"  ./src/cfg.cc.blocknet.sh ./src/cfg.cc.bch.unlimited.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.bch.ltc.sh strategy1 bitcoincash01 litecoin07
   
   #LBC
   #~ tool_setup_dexbot_profile "LBC" "LTC"  ./src/cfg.cc.blocknet.sh ./src/cfg.cc.lbrycrd.leveldb.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.lbc.ltc.sh strategy1 lbrycrd01 litecoin07
   
   #PKOIN
   tool_setup_dexbot_profile "PKOIN" "LTC"  ./src/cfg.cc.blocknet.sh ./src/cfg.cc.pocketcoin.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.pkoin.ltc.sh strategy1 pocketcoin01 litecoin08
   
   #PART
   tool_setup_dexbot_profile "PART" "LTC" ./src/cfg.cc.blocknet.sh ./src/cfg.cc.particl.sh ./src/cfg.cc.litecoin.sh ./src/cfg.dexbot.alfa.sh ./src/cfg.strategy.part.ltc.sh strategy1 particl01 litecoin09
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

tool_interactivity "session-y" "session-n" "Would you like to install SESSION ultimate privacy messenger app?"
if [[ "${var_q}" == "y" ]]; then
   ./setup.session.sh download install 
   if [[ ${?} != 0 ]]; then
      tool_interactivity "session-update-y" "session-update-n" "SESSION app seems already installed, would you like to try to update it to latest version first?"
      if [[ "${var_q}" == "y" ]]; then
         ./setup.session.sh update
         (test $? != 0) && echo "Setup SESSION app failed" && exit 1
      fi
   fi
fi

tool_interactivity "session-profile-y" "session-profile-n" "Would you like to auto-configure SESSION default profile?"
if [[ "${var_q}" == "y" ]]; then
   ./setup.session.profile.sh default
   (test $? != 0) && echo "setup SESSION profile failed" && exit 1
fi

tool_interactivity "tor-browser-y" "tor-browser-n" "Would you like to install tor-browser ultimate privacy web browser?"
if [[ "${var_q}" == "y" ]]; then
   ./setup.torbrowser.sh download install 
   if [[ ${?} != 0 ]]; then
      tool_interactivity "tor-browser-update-y" "tor-browser-update-n" "tor-browser seems already installed, would you like to try to update it to latest version first?"
      if [[ "${var_q}" == "y" ]]; then
         ./setup.torbrowser.sh update
         (test $? != 0) && echo "Setup tor-browser app failed" && exit 1
      fi
   fi
fi

tool_interactivity "tor-browser-profile-y" "tor-browser-profile-n" "Would you like to auto-configure tor-browser default profile?"
if [[ "${var_q}" == "y" ]]; then
   ./setup.torbrowser.profile.sh default
   (test $? != 0) && echo "setup tor-browser profile failed" && exit 1
fi

echo "All selected components been installed and configured and setup has successfully finished."
echo "Please continue by tutorial: https://github.com/nnmfnwl/dexsetup.cli.installer?tab=readme-ov-file#how-setup-dexsetup-with-cli-installer"
