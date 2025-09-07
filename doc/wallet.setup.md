### How to setup/add/update/reinstall specific wallet only
  * example shows hot o setup Blocknet BLOCK
  * supported are BTC BCH LTC BLOCK DOGE XVG DASH LBC PART PKOIN 

#### Content
  1. Setup Wallet and environment as GUI+CLI from scratch, no update of existing components [>>>](#1)
  2. Setup wallet to existing environment, no update of existing components [>>>](#2)
  3. Automatically choose to setup or update wallet and envoronment [>>>](#3)
     
#### 1. Setup Wallet and environment as GUI+CLI from scratch, no update of existing components found
  * detect if tor is already configured
  * detect if to use sudo or su
  * install all related system packages
  * download dexsetup.installer anonymously by tor
  * run dexsetup.installer with pre-configured arguments
  * download dexsetup.framework
  * configure proxychains
  * download and build blocknet wallet from source
  * setup blocknet wallet profiles
```
# set which wallet
WALLET=BLOCK

# set base packages for anonymity from very beginning because we do not want even to gitbub to spy on us.
pkgs="proxychains4 tor torsocks wget";

# detect if tor is configured for user or not
groups | grep debian-tor > /dev/null && cfg_user_tor="echo 'Tor for ${USER} is already configured'" || cfg_user_tor="usermod -a -G debian-tor ${USER}";

# detect if to use sudo or su
sudo -v; (test $? != 0) && su_cmd="echo 'Please enter ROOT password'; su -c" || su_cmd="echo 'Please enter ${USER} sudo password'; sudo -sh -c";

# do necessary system update and install all needed packages
eval "${su_cmd} \"apt update; apt full-upgrade; apt install ${pkgs}; ${cfg_user_tor}; exit\""

# make base dexsetup directory, download dexsetup.installer by tor network and run installer with pre-configured arguments to use dexsetup.framework just to setup Blocknet wallet.
mkdir -p ~/dexsetup && cd ~/dexsetup && rm -f installer.sh && proxychains4 wget "https://github.com/nnmfnwl/dexsetup.cli.installer/raw/refs/heads/main/installer.sh" && bash installer.sh DEFAULT-N c-y upgrade-y pkg-privacy-y pkg-build-y pkg-tools-y pkg-gui-build-y pkg-gui-tools-y proceed-y ${WALLET}-install-y dao-profiles-y ${WALLET}-dao-profile-y dex-profiles-y ${WALLET}-dex-profile-y stake-profiles-y ${WALLET}-stake-profile-y
```

#### 2. Setup wallet to existing environment, no update of existing components

  * run dexsetup.installer with pre-configured arguments
  * download and build blocknet wallet from source
  * setup blocknet wallet profiles
```
# set which wallet
WALLET=BLOCK

# run installer
cd ~/dexsetup && bash installer.sh DEFAULT-N c-y ${WALLET}-install-y dao-profiles-y ${WALLET}-dao-profile-y dex-profiles-y ${WALLET}-dex-profile-y stake-profiles-y ${WALLET}-stake-profile-y
```

#### 3. Automatically choose to setup or update wallet and envoronment
  * force install or update related wallet components
```
# set which wallet
WALLET=BLOCK

# set base packages for anonymity from very beginning because we do not want even to gitbub to spy on us.
pkgs="proxychains4 tor torsocks wget";

# detect if tor is configured for user or not
groups | grep debian-tor > /dev/null && cfg_user_tor="echo 'Tor for ${USER} is already configured'" || cfg_user_tor="usermod -a -G debian-tor ${USER}";

# detect if to use sudo or su
sudo -v; (test $? != 0) && su_cmd="echo 'Please enter ROOT password'; su -c" || su_cmd="echo 'Please enter ${USER} sudo password'; sudo -sh -c";

# do necessary system update and install all needed packages
eval "${su_cmd} \"apt update; apt full-upgrade; apt install ${pkgs}; ${cfg_user_tor}; exit\""

# make base dexsetup directory, download dexsetup.installer by tor network and run installer with pre-configured arguments to use dexsetup.framework just to setup Blocknet wallet.
mkdir -p ~/dexsetup && cd ~/dexsetup && rm -f installer.sh && proxychains4 wget "https://github.com/nnmfnwl/dexsetup.cli.installer/raw/refs/heads/main/installer.sh" && bash installer.sh DEFAULT-N c-y upgrade-y pkg-privacy-y pkg-build-y pkg-tools-y pkg-gui-build-y pkg-gui-tools-y proceed-y dexsetup-update-y ${WALLET}-install-y ${WALLET}-update-y dao-profiles-y ${WALLET}-dao-profile-y dex-profiles-y ${WALLET}-dex-profile-y stake-profiles-y ${WALLET}-stake-profile-y
```

#### Thanks for reading, feedback is welcome.
