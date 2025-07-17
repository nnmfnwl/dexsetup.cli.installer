### About
  * **dexsetup.cli.installer** is simple interactive command line installer for [dexsetup](https://github.com/nnmfnwl/dexsetup?tab=readme-ov-file#step-by-step-setup-tutorial)

### Summary
  1. Install `mandatory packages` and `reconfigure user for ability to use tor`.
  2. Download or update `DEXSETUP` to latest version.
  3. Choose which `CLI` and `GUI` `dependency packages` to install.
  4. Choose which `wallets and wallets profiles` to install and configure.
  5. Setup `DEXBOT` and generate all `default trading strategies` from templates.
  6. setup `BlockDX` the Blocknet DEX graphical user interface app.
  7. Generate `screen start script` and let user know how to start screen script is and how to connect it, navigate it and detach from it from terminal.
  8. Generate `dexbot reconfigurationm script` used to set wallet addresses used by DEXBOT trading strategies.

### How setup dexsetup with cli installer
  * Here are 2 user friendly options to download and run instaler:
  * **1. Download and start dexsetup [`installer.sh`](https://github.com/nnmfnwl/dexsetup.cli.installer/raw/refs/heads/main/installer.sh) script manually but `not anonymously`**:
```
bash ./installer.sh
```

  * **2. Download and start dexsetup `installer.sh` script `anonymously`** but for total privacy install `tor`, `proxychains4` and `wget` first.
  * To install privacy packages on **`Debian`** or **`Ubuntu`** based distributions by using `apt` and `su` or `sudo`:
```
pkgs="proxychains4 tor torsocks wget";
groups | grep debian-tor > /dev/null && cfg_user_tor="echo 'Tor for ${USER} is already configured'" || cfg_user_tor="usermod -a -G debian-tor ${USER}";
sudo -v; (test $? != 0) && su_cmd="echo 'Please enter ROOT password'; su -c" || su_cmd="echo 'Please enter ${USER} sudo password'; sudo -sh -c";
eval "${su_cmd} \"apt update; apt full-upgrade; apt install ${pkgs}; ${cfg_user_tor}; exit\""
```
  * Download and run installer anonymously:
```
mkdir -p ~/dexsetup && cd ~/dexsetup && rm -f installer.sh && proxychains4 wget "https://github.com/nnmfnwl/dexsetup.cli.installer/raw/refs/heads/main/installer.sh" && bash installer.sh
```

### How to start and connect, navigate and detach from installed dexsetup environment
  * All generated files are stored at `~/dexsetup`
  * Blockchains are using default chain data directories like `./litecoin`, `./blocknet`, `./bitcoin` etc...
    
  * To **start** `main CLI start script` which opens management only by console interface:
```
cd ~/dexsetup/dexsetup/ && ./start.screen.instance_default.cli.sh
```
  * To **start** `main start GUI script` which opens management by console interface and graphical user interface wallets as well:
```
cd ~/dexsetup/dexsetup/ && ./start.screen.instance_default.gui.sh
```
  * To **connect** to dexsetup management by `GNU Screen terminal multiplexer` console interface
```
screen -x
```
  * To **list and navigate** screen tabs/windows use shortcut `CTRL + a ^ "` (hold `CTRL` and push `a`, release `CTRL` and then push `"`, which is probably activated as `shift+"`)
  * To **detach and keep running** applications inside screen the console multiplexer use keyboard shortcut `CTRL + a ^ d`
  * All screen terminal multiplexer tabs are nicely named with predefined commands, and user just use enter to confirm commands depending on what is needed

### Trading bot strategies reconfiguration
  * After successfull installation/reinstallation/update, there is generated `installer_reconfigure_dexbot.sh` script wich could be used to reconfigure generated DEXBOT trading strategies once user sets up wallets trading addresses.
```
cd ~/dexsetup/ && ./installer_reconfigure_dexbot.sh
```
  * Every generated strategy is readable well documented configuration based on [`DEXBOT template`](https://github.com/nnmfnwl/dexbot/blob/merge.2025.03.26/howto/examples/bot_v2_template.py) generated as mix with specific strategy trading pair configuration [`BLOCK/LTC`](https://github.com/nnmfnwl/dexsetup/blob/merge.2025.02.06/src/cfg.strategy.block.ltc.sh) , [`BTC/LTC`](https://github.com/nnmfnwl/dexsetup/blob/merge.2025.02.06/src/cfg.strategy.btc.ltc.sh) ...
  * By default all generated strategy could be found at
```
cd ~/dexsetup/dexbot/git.src/ && ls -la | grep strategy | grep .py
```
  * Final strategy tunning is easy but most effective way would be to write own `strategy trading pair configuration` for dexsetup which could be easy shared used again and again.

### Used components
  * List of all used components by dexsetup here [`dexsetup readme page`](https://github.com/nnmfnwl/dexsetup/tree/merge.2025.02.06?tab=readme-ov-file#list-used-components-by-dexsetup)
