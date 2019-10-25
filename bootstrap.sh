#!/usr/bin/env bash

apt-get update
apt-get upgrade -y

apt-get install -y build-essential clang bison flex \
	libreadline-dev gawk tcl-dev libffi-dev git mercurial graphviz \
	xdot pkg-config python python3 libftdi-dev git iverilog gtkwave \
	scons libftdi1-dev libconfuse-dev python3-libusb1 python3-ftdi1 \
	python3-serial python3-pip



if [ -d /vagrant/icestorm ]; then
  rm -rf /vagrant/icestorm
fi

if [ -d /vagrant/arachne-pnr ]; then
  rm -rf /vagrant/arachne-pnr
fi

if [ -d /vagrant/yosys ]; then
  rm -rf /vagrant/yosys
fi

git clone https://github.com/cliffordwolf/icestorm.git /vagrant/icestorm
cd icestorm
make -j$(nproc)
make install

git clone https://github.com/cseed/arachne-pnr.git /vagrant/arachne-pnr
cd arachne-pnr
make -j$(nproc)
make install

git clone https://github.com/cliffordwolf/yosys.git /vagrant/yosys
cd yosys
make -j$(nproc)
make install

pip3 install tinyprog
