### Example of setup/add/update Blocknet(BLOCK) faucet takerbot
  * Many examples how to setup BLOCK/LTC and BLOCK/PIVX faucets.
  * 
#### Content
  1. Setup up from scratch, no update if existing components found [>>>](#1-a)
  2. Setup by add into existing dexsetup envoronment, no update if existing component found [>>>](#1-b)
  3. Update everything related to faucet [>>>](#1-c)

#### 1. Setup up from scratch, no update if existing components found
  * detect if tor is already configured
  * detect if to use sudo or su
  * install base packages
  * download dexsetup.installer anonymously by tor
  * run dexsetup.installer with pre-configured arguments
  * download dexsetup.framework
  * configure proxychains
  * download and build blocknet and litecoin wallet from source
  * download pivx wallet
```
# set base packages for anonymity from very beginning because we do not want even to gitbub to spy on us.
pkgs="proxychains4 tor torsocks wget";

# detect if tor is configured for user or not
groups | grep debian-tor > /dev/null && cfg_user_tor="echo 'Tor for ${USER} is already configured'" || cfg_user_tor="usermod -a -G debian-tor ${USER}";

# detect if to use sudo or su
sudo -v; (test $? != 0) && su_cmd="echo 'Please enter ROOT password'; su -c" || su_cmd="echo 'Please enter ${USER} sudo password'; sudo -sh -c";

# do necessary system update and install all needed packages
eval "${su_cmd} \"apt update; apt full-upgrade; apt install ${pkgs}; ${cfg_user_tor}; exit\""

# make base dexsetup directory, download dexsetup.installer by tor network and run installer with pre-configured arguments to use dexsetup.framework just to setup Blocknet dexbot faucet.
mkdir -p ~/dexsetup && cd ~/dexsetup && rm -f installer.sh && proxychains4 wget "https://github.com/nnmfnwl/dexsetup.cli.installer/raw/refs/heads/main/installer.sh" && bash installer.sh DEFAULT-N c-y  BLOCK-install-y LTC-install-y PIVX-install-y dex-profiles-y dexbot-strategies-y BLOCK-LTC-setup-y blockdx-install-y BLOCK-LTC-strategy-cfg "./src/cfg.strategy.block.ltc.faucet_takerbot.sh" BLOCK-LTC-strategy-name 'faucet1' BLOCK-LTC-strategy-addr1 'blocknet01' BLOCK-LTC-strategy-addr2 'litecoin01' PIVX-LTC-setup-y PIVX-LTC-strategy-cfg "./src/cfg.strategy.pivx.ltc.faucet_takerbot.sh" PIVX-LTC-strategy-name 'faucet1' PIVX-LTC-strategy-addr1 'pivx01' BLOCK-LTC-strategy-addr2 'litecoin02' 
```

#### Thanks for reading, feedback is welcome.
