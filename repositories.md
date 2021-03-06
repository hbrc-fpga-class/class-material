# HBRC FPGA Class Repositories

The HBRC FGPA class materials are stored in 3 related repositories:

* [class-material](https://github.com/hbrc-fpga-class/class-material):
  The various class materials and documentation, including the shell
  scripts for building the tool chains.

* [hardware](https://github.com/hbrc-fpga-class/hardware):
  This is where all the hardware documentation is for the PCB that
  was designed and manufactured for the class.

* [peripherals](https://github.com/hbrc-fpga-class/peripherals):
  This is where all the Verilog and code documentation for the FPGA
  peripherals resides.

These repositories are installed on your robot in a directory named
`hbrc_fpga_class`.

You can install these repositories on your laptop by using `git`.

For Linux, the following will work:

     cd # somewhere
     mkdir hbrc-fpga-class
     cd hbrc-fpga-class
     git clone https://github.com/hbrc-fpga-class/class-material.git
     git clone https://github.com/hbrc-fpga-class/hardware.git
     git clone https://github.com/hbrc-fpga-class/peripherals.git

For MacOS/Windows, somebody else will have to provide instructions.

