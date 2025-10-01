### Example of automatization of full dexsetup environment installation 
  * The specific combination of installer arguments used as command installs or updates or forces every component of decentralized exchange system to be set to default expected stage.

#### Summary
  * download installer itself anonymously and run as full automatic installer
  * every installation and runtime component protected by kernel isolation
  * every installation and runtime component protected by tor network isolation
  * detect if tor is already configured
  * detect if to use sudo or su
  * update and install operating system base packages
  * configure vnc server and auto-start user GUI VNC session
  * download dexsetup.installer anonymously by tor
  * run dexsetup.installer with pre-configured arguments
  * download dexsetup.framework
  * configure proxychains
  * download and build all wallets from source
  * generate all predefined wallet profiles
  * BlockDX
  * DEXBOT
  * All trading startegies
  * generate screen script
  * install tor browser and configure tor profile named default
  * install session privacy messenger and configure session profile named default

#### Notice
  * 1. You will be asked for root or sudo password to update system and configure VNC session for user.
  * 2. you will be asked for new user VNC password, but it could be specified as `vncpasswd "password"` argument as well.

#### Command

```
# set base packages for anonymity from very beginning because we do not want even to gitbub to spy on us.
pkgs="proxychains4 tor torsocks wget";

# detect if tor is configured for user or not
groups | grep debian-tor > /dev/null && cfg_user_tor="echo 'Tor for ${USER} is already configured'" || cfg_user_tor="usermod -a -G debian-tor ${USER}";

# detect if to use sudo or su
sudo -v; (test $? != 0) && su_cmd="echo 'Please enter ROOT password'; su -c" || su_cmd="echo 'Please enter ${USER} sudo password'; sudo -sh -c";

# do necessary system update and install all needed packages
eval "${su_cmd} \"apt -y update; apt -y full-upgrade; apt -y install ${pkgs}; ${cfg_user_tor}; exit\""

# the specific combination of installer arguments used as command installs or updates or forces every component of decentralized exchange system to be set to default expected stage
mkdir -p ~/dexsetup && cd ~/dexsetup && rm -f installer.sh && proxychains4 wget "https://github.com/nnmfnwl/dexsetup.cli.installer/raw/refs/heads/main/installer.sh" && bash installer.sh c-y upgrade-y pkg-privacy-y pkg-build-y pkg-tools-y pkg-gui-build-y pkg-gui-tools-y vnc-autostart-y proceed-y proceed-repeat-y vnc-setpassword-y dexsetup-update-y mate-conf-y proxychains-usr-reconfig-y skip-failed-install-y BLOCK-install-y BLOCK-update-y LTC-install-y LTC-update-y BTC-install-y BTC-update-y DOGE-install-y DOGE-update-y DASH-install-y DASH-update-y PIVX-install-y PIVX-update-y XVG-install-y XVG-update-y LBC-install-n LBC-update-n PKOIN-install-y PKOIN-update-y PART-install-y PART-update-y dao-profiles-y BLOCK-dao-profile-y stake-profiles-y BLOCK-stake-profile-y PKOIN-stake-profile-y PIVX-stake-profile-y dex-profiles-y BLOCK-dex-profile-y LTC-dex-profile-y BTC-dex-profile-y XVG-dex-profile-y DOGE-dex-profile-y PIVX-dex-profile-y DASH-dex-profile-y LBC-dex-profile-y LBC-dex-profile-y PKOIN-dex-profile-y PART-dex-profile-y strategy-update-y strategy-skip-failed-y BLOCK-LTC-setup-y BLOCK-LTC-update-y BLOCK-LTC-skip-failed-y BTC-LTC-setup-y BTC-LTC-update-y BTC-LTC-skip-failed-y XVG-LTC-setup-y XVG-LTC-update-y XVG-LTC-skip-failed-y DOGE-LTC-setup-y DOGE-LTC-update-y DOGE-LTC-skip-failed-y PIVX-LTC-setup-y PIVX-LTC-update-y PIVX-LTC-skip-failed-y DASH-LTC-setup-y DASH-LTC-update-y DASH-LTC-skip-failed-y LBC-LTC-setup-n LBC-LTC-update-n LBC-LTC-skip-failed-n PKOIN-LTC-setup-y PKOIN-LTC-update-y PKOIN-LTC-skip-failed-y PART-LTC-setup-y PART-LTC-update-y PART-LTC-skip-failed-y blockdx-install-y blockdx-update-y blockdx-profile-y screen-y screen-update-y session-y session-update-y session-profile-y tor-browser-y tor-browser-update-y tor-browser-profile-y
```

#### Thanks for reading, feedback is welcome.
  * [Contact me](https://github.com/nnmfnwl/dexsetup.cli.installer#8-contact-me)
