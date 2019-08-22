#!/usr/bin/env bash

sudo apt-get install build-essential clang bison flex \
    libreadline-dev gawk tcl-dev libffi-dev git mercurial graphviz \
    xdot pkg-config python python3 libftdi-dev git iverilog gtkwave \
    scons libftdi1-dev libconfuse-dev python3-libusb1 python3-ftdi1 \
    python3-serial python3-pip

mkdir icestorm-build
cd icestorm-build

git clone https://github.com/cliffordwolf/icestorm.git icestorm
cd icestorm
make -j$(nproc)
sudo make install
cd ..

git clone https://github.com/cseed/arachne-pnr.git arachne-pnr
cd arachne-pnr
make -j$(nproc)
sudo make install
cd ..

git clone https://github.com/cliffordwolf/yosys.git yosys
cd yosys
make -j$(nproc)
sudo make install
cd ..

pip3 install tinyprog
