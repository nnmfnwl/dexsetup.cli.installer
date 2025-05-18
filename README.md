# dexsetup.cli.installer

**About**
  * For lazy people who not like to read [dexsetup](https://github.com/nnmfnwl/dexsetup?tab=readme-ov-file#step-by-step-setup-tutorial) setup documentation

**Summary**
  * Just one command do download and run dexsetup.cli.installer to:
1. Update OS packages and setup user.
2. Create dexsetup directory structures and download or if exists try to update to lastest version.
4. Choose interactively which dependency packages to install and setup proxychains config file for user.
5. Setup wallets and wallets profiles by asking one by one which wallet user want and if exists asking if to try to update.
7. Setup [DEXBOT](https://github.com/nnmfnwl/dexbot) and generate all default trading strategies from templates.
8. Generate screen start script and inform user where main start screen script is and how to enter it, navigate it and detach from it.
10. Inform user that in screen number NN NN NN are predefined commands which needs to be used to regenerate trading strategies with real addresses.
11. etc TODO

**Usage**
  * To download and run dexsetup installer script by one command
```
wget -q -O - "https://github.com/nnmfnwl/dexsetup.cli.installer/raw/refs/heads/main/installer.sh" | bash
```
  * Or to download `installer.sh` amanually and run dexsetup installer script after
```
bash ./installer.sh
```

**Result**
  * All generated files are stored at `~/dexsetup`
  * Blockchains are using default chain data directories like `./litecoin`, `./blocknet`, `./bitcoin` etc...
  * There is main start screen script for management by console interface
```
cd ~/dexsetup/dexsetup/ && ./start.screen.instance_default.cli.sh
```
  * There is main start screen script for running wallets with graphical interface mode and also with ability to manage by console interface
```
cd ~/dexsetup/dexsetup/ && ./start.screen.instance_default.gui.sh
```
  * To connect to screen console interface
```
screen -x
```
  * To list and navigate screen tabs/windows use keyboard shortcut `CTRL + a + "`
  * To detach and keep running applications inside screen the console multiplexer use keyboard shortcut `CTRL + a + d`
  * All screen terminal multiplexer tabs are nicely named with predefined commands, and user just use enter to confirm commands depending on what is needed
