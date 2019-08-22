# toolchain-utils
Tools for installing and configuring the iCE40 toolchain for the class

0. Install git:
`sudo apt-get install git`
1. Create directory for HBRC stuff and `cd` to it:
`mkdir hbrc-fpga-class && cd hbrc-fpga-class`
1. Clone this repo:
`git clone https://github.com/hbrc-fpga-class/toolchain-utils`
2. Enter the repo and make the installer executable
`cd toolchain-utils && chmod +x install.sh`
3. Run the script:
`./install.sh`
4. Log out and then log back in to refresh `$PATH`. Or just `source $HOME/.profile`


Note: The `nextpnr.sh` script needs some work. It's definitely not ready for primetime yet. 
