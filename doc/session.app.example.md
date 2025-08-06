#### Example of setting up Session-Privacy-Messenger app in very secure, isolated way, running behind tor and ability to run multiple session accounts at once.

#### Installation
  * detect if tor is already configured, detect if to use sudo or su and install base packages.
  * download dexsetup.installer anonymously by tor and run it with pre-configured arguments to install/update session and setup profile name default.
```
# set base packages for anonymity from very beginning because we do not want even to gitbub to spy on us.
pkgs="proxychains4 tor torsocks wget";

# detect if tor is configured for user or not
groups | grep debian-tor > /dev/null && cfg_user_tor="echo 'Tor for ${USER} is already configured'" || cfg_user_tor="usermod -a -G debian-tor ${USER}";

# detect if to use sudo or su
sudo -v; (test $? != 0) && su_cmd="echo 'Please enter ROOT password'; su -c" || su_cmd="echo 'Please enter ${USER} sudo password'; sudo -sh -c";

# do necessary system update and install all needed packages
eval "${su_cmd} \"apt update; apt full-upgrade; apt install ${pkgs}; ${cfg_user_tor}; exit\""

# make base dexsetup directory, download dexsetup.installer by tor network and run installer with pre-configured arguments to use dexsetup.framework just to download/update session and make profile named default.
mkdir -p ~/dexsetup && cd ~/dexsetup && rm -f installer.sh && proxychains4 wget "https://github.com/nnmfnwl/dexsetup.cli.installer/raw/refs/heads/main/installer.sh" && bash installer.sh DEFAULT-N c-y dexsetup-update-y session-y session-profile-y session-update-y
```

#### Setting up multiple profiles
  * with dexsetup you can setup any number of profiles just in second!
  * example how to setup profile named `johnsmith`
```
cd ~/dexsetup && ./setup.session.profile.sh johnsmith
```

#### Directory struture
  * everything downloaded and configured by above example is standard system packages installation/configuration or pure user-space thing.
  * the main directory of everything is `~/dexsetup`
  * session profile files could be found `~/dexsetup/session/latest/data/profile/<profilename>`
```
cd ~/dexsetup && tree -d -L 4 session
```
```
session
└── latest
    └── data
        ├── download
        │   ├── bin
        │   ├── git.src
        │   └── pkg
        └── profile
            ├── default
            └── johnsmith

```

#### Restore Session profile from old account
  * If you been using Session app before the old profile files could be found at `~/.config/Session/`
  * You can very easy restore your session profile to be used secudrely by dexsetup as:
```
cp -r ~/.config/Session/* ~/dexsetup/session/latest/data/profile/Default/
```

#### How to start Session by generated dexsetup profiles
  * Start scripts could be found at `~/dexsetup/session/latest`
```
ls -la ~/dexsetup/session/latest
```
  * you can create symlink to your startscript and put it on Desktop
```
```
