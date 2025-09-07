### Example of setup/add/update Blocknet(BLOCK) faucet takerbot
  * examples how to setup BLOCK/LTC and BLOCK/PIVX faucets.

#### Content
  1. Setup up from scratch as GUI+CLI+VNC, no update of existing components [>>>](https://github.com/nnmfnwl/dexsetup.cli.installer/edit/main/doc/blocknet.faucet.takerbot.md#1-setup-up-from-scratch-as-guiclivnc-no-update-of-existing-components)
  2. Setup into existing dexsetup environment, no update of existing component [>>>](https://github.com/nnmfnwl/dexsetup.cli.installer/edit/main/doc/blocknet.faucet.takerbot.md#2-setup-into-existing-dexsetup-environment-no-update-of-existing-component)
  3. Automatically choose to setup or update everything related to faucet [>>>](https://github.com/nnmfnwl/dexsetup.cli.installer/edit/main/doc/blocknet.faucet.takerbot.md#3-automatically-choose-to-setup-or-update-everything-related-to-faucet)

#### 1. Setup up from scratch as GUI+CLI+VNC, no update of existing components
  * detect if tor is already configured
  * detect if to use sudo or su
  * update and install operating system base packages
  * download dexsetup.installer anonymously by tor
  * run dexsetup.installer with pre-configured arguments
  * download dexsetup.framework
  * configure proxychains
  * download and build blocknet and litecoin wallet from source
  * download pivx wallet as prebuild binary package
  * configure BLOCK/LTC strategy called faucet1, the strategy with automatic taker bot enabled
  * configure PIVX/BLOCK strategy called faucet1, the strategy with automatic taker bot enabled
  
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
mkdir -p ~/dexsetup && cd ~/dexsetup && rm -f installer.sh && proxychains4 wget "https://github.com/nnmfnwl/dexsetup.cli.installer/raw/refs/heads/main/installer.sh" && bash installer.sh DEFAULT-N c-y upgrade-y pkg-privacy-y pkg-build-y pkg-tools-y pkg-gui-build-y pkg-gui-tools-y proceed-y vnc-autostart-y vnc-passwd "vncpasswordhere" BLOCK-install-y LTC-install-y PIVX-install-y dex-profiles-y BLOCK-dex-profile-y LTC-dex-profile-y PIVX-dex-profile-y dexbot-strategies-y BLOCK-LTC-setup-y BLOCK-LTC-strategy-cfg "./src/cfg.strategy.block.ltc.faucet_takerbot.sh" BLOCK-LTC-strategy-name 'faucet1' BLOCK-LTC-strategy-addr1 'blocknet01' BLOCK-LTC-strategy-addr2 'litecoin01' strategy-ticker-a PIVX strategy-ticker-b BLOCK strategy-cfg-a './src/cfg.cc.pivx.sh' strategy-cfg-b './src/cfg.cc.blocknet.sh' strategy-cfg "./src/cfg.strategy.pivx.block.faucet_takerbot.sh" strategy-name 'faucet1' strategy-address-a 'pivx01' strategy-address-b 'blocknet02' 
```

#### 2. Setup into existing dexsetup environment, no update of existing component
  * run dexsetup.installer with pre-configured arguments
  * download and build blocknet and litecoin wallet from source
  * download pivx wallet as prebuild binary package
  * configure BLOCK/LTC strategy called faucet1, the strategy with automatic taker bot activated
  * configure PIVX/BLOCK strategy called faucet1, the strategy with automatic taker bot activated
```
cd ~/dexsetup && bash installer.sh DEFAULT-N c-y BLOCK-install-y LTC-install-y PIVX-install-y dex-profiles-y BLOCK-dex-profile-y LTC-dex-profile-y PIVX-dex-profile-y dexbot-strategies-y BLOCK-LTC-setup-y BLOCK-LTC-strategy-cfg "./src/cfg.strategy.block.ltc.faucet_takerbot.sh" BLOCK-LTC-strategy-name 'faucet1' BLOCK-LTC-strategy-addr1 'blocknet01' BLOCK-LTC-strategy-addr2 'litecoin01' strategy-ticker-a PIVX strategy-ticker-b BLOCK strategy-cfg-a './src/cfg.cc.pivx.sh' strategy-cfg-b './src/cfg.cc.blocknet.sh' strategy-cfg "./src/cfg.strategy.pivx.block.faucet_takerbot.sh" strategy-name 'faucet1' strategy-address-a 'pivx01' strategy-address-b 'blocknet02' 
```

#### 3. Automatically choose to setup or update everything related to faucet
  * TODO
```
TODO
```

#### Thanks for reading, feedback is welcome.
