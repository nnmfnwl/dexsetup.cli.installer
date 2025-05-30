## dexsetup.cli.installer

### About
  * [dexsetup](https://github.com/nnmfnwl/dexsetup?tab=readme-ov-file#step-by-step-setup-tutorial) installer with simple command line interface

### Summary
  1. Install `mandatory packages` and `reconfigure user for ability to use tor`.
  2. Download or update `dexsetup` to lastest version.
  3. Choose interactively which `optional dependency packages` to install.
  4. Choose interactively which `wallets and wallets profiles` to install and configure.
  5. Setup `DEXBOT` and generate all `default trading strategies` from templates.
  6. setup `BlockDX` the Blocknet DEX graphical user interface app
  7. Generate `screen start script` and inform user where main start screen script is and how to enter it, navigate it and detach from it.
  8. Generate `dexbot reconfigurationm script` used to set wallet addresses used by DEXBOT trading strategies.

### How setup dexsetup with cli installer
  * Here are 2 user friendly options to download and run instaler:

  1. Download [`installer.sh`](https://github.com/nnmfnwl/dexsetup.cli.installer/raw/refs/heads/main/installer.sh) manually and start setup by:
```
bash ./installer.sh
```
  2. Download and run dexsetup `installer.sh` script `anonymously` but install tor, proxychains4 and wget first
  * Install packages and reconfigure user with `su` (by detauld used in Debian)
```
su -c "apt update; apt full-upgrade; apt install wget proxychains4 tor; groups ${USER} | grep debian-tor || usermod -a -G debian-tor ${USER}; exit"
```
  * Install packages and reconfigure user with `sudo` (by default used in Ubuntu)
```
sudo sh -c "apt update; apt full-upgrade; apt install wget proxychains4 tor; groups ${USER} | grep debian-tor || usermod -a -G debian-tor ${USER}; exit"
```
  * Download and run installer anonymously
```
mkdir -p ~/dexsetup && cd ~/dexsetup && rm -f installer.sh && proxychains4 wget "https://github.com/nnmfnwl/dexsetup.cli.installer/raw/refs/heads/main/installer.sh" && bash installer.sh
```

### How to use installed dexsetup environment
  * All generated files are stored at `~/dexsetup`
  * Blockchains are using default chain data directories like `./litecoin`, `./blocknet`, `./bitcoin` etc...
  * There is main start script which opens management only by console interface:
```
cd ~/dexsetup/dexsetup/ && ./start.screen.instance_default.cli.sh
```
  * There is main start script which opens management by console interface and graphical user interface wallets as well:
```
cd ~/dexsetup/dexsetup/ && ./start.screen.instance_default.gui.sh
```
  * To connect to `GNU Screen terminal multiplexer` console interface
```
screen -x
```
  * To list and navigate screen tabs/windows use shortcut `CTRL + a ^ "` (hold `CTRL` and push `a`, release `CTRL` and then push `"`)
  * To detach and keep running applications inside screen the console multiplexer use keyboard shortcut `CTRL + a ^ d`
  * All screen terminal multiplexer tabs are nicely named with predefined commands, and user just use enter to confirm commands depending on what is needed

### Used components
  * List of all used components by dexsetup here [`dexsetup readme page`](https://github.com/nnmfnwl/dexsetup/tree/merge.2025.02.06?tab=readme-ov-file#list-used-components-by-dexsetup)
