# GTKWave

[GTKWave](http://gtkwave.sourceforge.net/) is an open source waveform viewer.  We
will be using it to view waveforms generated from the [Icarus Verilog
Simulator](http://iverilog.icarus.com/) (a.k.a iverilog).

Both GTKWave and iverilog are already installed on the robot.  However GTKWave is a
GUI tool so there are a couple of different options to view the GUI on your computer.

## Option 1 Forward X over SSH

If you are connecting to the robot via ssh in a terminal window, you can use the
__-X__ option to enable X forwarding over SSH.  Example:

```
> ssh -X ubuntu@h01.local
```

### Windows 10

If you are using Windows 10 and Putty.  You need to install an X Server such as
Xming, and then "Enable X11 Forwarding" in the Putty SSH->X11 options.  Information
about this setup [here](https://askubuntu.com/questions/971171/how-to-use-putty-to-get-x11-connections-over-ssh-from-windows-to-ubuntu).

### xeyes

A good test to see if you got X11 Forwarding working is to login to the robot using
one of the methods above and try:

```
> xeyes
```

And see if a pair of eyes popup on your computer.

## Option 2 Install GTKWave on computer and use SSHFS

If you have SSHFS setup on your computer this method should work.  Instructions for
getting SSHFS setup [here](sshfs.md).

Using this method we navigate to the _vcd_ file that iverilog generates via SSHFS and open it
with GTKWave.

### Ubuntu

To install GTKWave on Ubuntu:

```
> sudo apt install gtkwave
```

### Other OS

See the [GTKWave website](http://gtkwave.sourceforge.net/) for downloads.

