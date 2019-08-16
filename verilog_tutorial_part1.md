<!-- $theme: gaia -->
<!-- template: invert -->

---

# Today

* Goals
* Verilog History
* Modules and Ports
* Values and Types
* Program #1: Button to Led
* Program #2: Pi GPIO to Led
* Operators
* Exercise #1: Two buttons, either lights led
* Bus Notation
* Numbers
* Program #3: Displays 0x55 to the 8 leds
* Exercise #2: Button press display 0xAA
* Break.  
* Procedural Blocks
* Program #3: Counter on leds
* Exercise #3: Button press count down.
* Program #4: Capture button edge, count up and down
* State Machine
* Program #5: Cyclone like eye on LEDs
* Excercise #4: Speedup or Slowdown animation using buttons.

---

# This tutorials Goals

* Main Focus on Synthesis for FPGAs
* Light coverage of Testbenches
* Covering a subset of Verilog
* Hands-on
* Practical not Theoretical
* Read and Understand the HomeBrew Automation Peripheral's Verilog
* Able to write simple HBA Verilog Peripherals

---

# Verilog History

* Verilog created in the Mid-80s
* Created for simulation
    * "verification" and "logic"
    * High level and gate level simulation
* C like in syntax.
* case-sensitive
* Weakly typed
* Standards:
    * Verilog-95
    * Verilog 2001
        * Supported by most EDA tools
        * Target for this tutorial
    * Verilog 2005
    * SystemVerilog

---

# 0 Hello World

Login to your robot using ssh and perform the following steps:

```
> cd ~/hbrc_fpga_class/peripherals
> source setup.bash
> cd verilog_tutorial/0_Hello_World
```

The bash script adds the program __prog_fpga.py__ to your path.
We use this program to download fpga bitstreams to the
TinyFPGA board of the Raspberry Pi SPI pins. More about this later.

---

# hello0.v

```verilog
// Minimal module
module hello0;
endmodule
```

The above code is in the file hello0.v.  It is about as minimal a Verilog
program you can have.

The basic building block in Verilog is the __module__.  We define a module
using the keywords __module__ and __endmodule__.  You build circuits in
Verilog by connecting modules together.  Much like schematic symbols in
a schematic editor.

Notice the C style comment.  Verilog can look a bit C like but...

__Important__ : In Verilog (and other HDLs) you are not programming.  You
are describing circuits (structure and/or behavior).

We can _compile_ hello.v using the [iverilog](http://iverilog.icarus.com/) simulator,
which is pre-installed on the robot's Pi.

```
> iverilog hello0.v
```

If all went well it should have created a file called __a.out__ in the
current directory.  This is a real executable that can be run from the
command line. But it just starts and then quits.

```
> ./a.out
```

Running __iverilog__ in this way is a very quick way to do a
syntax check of your verilog module.

__Exercise__ : Try adding a bogus like to hello0.v and re-run
the __iverilog hello0.v__ command.  What happens?


