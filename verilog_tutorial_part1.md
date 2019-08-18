<!-- $theme: gaia -->
<!-- template: invert -->

---
# Status

This material is still in active development...

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

# [0_Hello_World](https://github.com/hbrc-fpga-class/peripherals/tree/master/verilog_tutorial/0_Hello_World)

Login to your robot using ssh and perform the following steps:

```
> cd ~/hbrc_fpga_class/peripherals
> source setup.bash
> cd verilog_tutorial/0_Hello_World
```

The bash script adds the program __prog_fpga.py__ to your path.
We use this program to download fpga bitstreams to the
TinyFPGA board of the Raspberry Pi SPI pins. More about this later.

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

__Exercise__ : Try adding a bogus line to hello0.v and re-run
the __iverilog hello0.v__ command.  What happens?

# hello1.v

```verilog
module hello1;
initial $display("Hello World1");
endmodule
```
The above code is in the file hello1.v.  It is the classic "hello world"
program.

Two new items are introduced:
1. __initial__ : This keyword means start here at time 0.  To have more than
one statement in an initial block, you need to add a "begin/end" block.  An
example of this later.
2. __$display__ : Is a _system task_ that acts a lot like _printf_ in C.  In
   Verilog words that start with a __$__ are special commands called system
   tasks. In general they are not synthesizable (often safely ignored by the
   synthesis tools).  But useful for debug and testbenches.

Try:

```
> iverilog hello1.v
> ./a.out
Hello World1
```

iverilog has a '-o' flag that renames the output executable (much like gcc).

```
> iverilog -o hello1 hello1.v
> ./hello1
Hello World1
```

There is also a Makefile in this directory so you can make the hello1
executable via

```
> make hello1
> ./hello1
Hello World1
```

Cleanup all the generated executables via

```
> make clean
```

# hello2.v

```verilog
module hello2;
initial 
begin
    $display("Hello World2");
    $display("Goodbye");
end
endmodule
```

This module is basically the same as hello1.v but it shows how to create an
__initial__ block with multiple statements, using __begin__ and __end__.

Verilog uses __begin__ and __end__ to delineate blocks.  This is in contrast
to C which uses curly braces __{__ and __}__

# hello3.v

```verilog
module hello3;
always
begin
    #1      // delay one simulation step (unitless by default)
    $display("Hello World3: ",$time);
    if ($time == 100) begin
        $finish;
    end
end
endmodule
```

This module introduces a couple of new concepts:
* __always__ : This keyword is similar to __initial__.  It says start here at
  time 0, and when you get to the end of the block, go back to the beginning of
  the block.  Basically it describes an infinite loop.
* __#1__ :  The __#__ followed by a number, indicates a delay in simulation
  steps.  By default the step size is unitless.  However you can assign units
  and percision using the __`timescale__ directive.  This is mostly used for
  testbench code.  
* __$time__ : Holds the integer part of the simulation time.
* __if__ : The __if__ statement is much like the C if statement.
* __$finish__ : Indicates that the simulation should finish/exit.


Try out this code via:
```
> make hello3
> ./hello3
```

---

# [1_Button_Led](https://github.com/hbrc-fpga-class/peripherals/tree/master/verilog_tutorial/1_Button_Led)

In this section we learn how to specify module inputs and outputs.
In these demos we connect the user buttons to leds on the robot.
We generate a bitstream and download it to the TinyFPGA board.

# button_led.v

```verilog
/* Buttons directly connected to leds. */

module button_led
(
    input wire button0,
    input wire button1,
    output wire [7:0] led
);

assign led[0] = ~button0;
assign led[1] = ~button1;

assign led[7:2] = 0;

endmodule
```

New concepts:
* Between the module name and the __;__ we insert parentheses in which we
  specify our input and output ports.
* We specify the output __led__ to be a bus of 8 wires, with the most significant
  bit being 7 and the least significant bit being 0.
* __assign__ : We assign value to our output bus __led__ using the assign
  statement.  __Note__ assignments are outside of intial or always blocks.

In this example the module button_led is going to be our top level module.  So
the __button0__, __button1__, and __led[7:0]__ ports need to be assigned to
package pins on the FPGA.  We can figure out the mapping between the ports
and package pins using these files:
* [Romi Adapter Board Pcb pdf](https://github.com/hbrc-fpga-class/hardware/blob/rev-A/tinyfpga-raspi-romi-board/outputs/tinyfpga-raspi-romi-board.pdf)
* [TinyFPGA pins top](https://cdn-shop.adafruit.com/1200x900/4038-01.jpg)
* [TinyFPGA pins bottom](https://cdn-shop.adafruit.com/1200x900/4038-00.jpg)

This is done in the file pins.pcf:

```
set_io button0    J4  # PIN_27
set_io button1    D8  # PIN_16

set_io led[0]       A9  # PIN_18
set_io led[1]       B8  # PIN_19
set_io led[2]       J3  # PIN_26
set_io led[3]       A8  # PIN_20
set_io led[4]       J9  # PIN_29
set_io led[5]       B7  # PIN_21
set_io led[6]       E8  # PIN_30
set_io led[7]       A7  # PIN_22
```

# Generating button_led bitstream

First let use __iverilog__ to verify we don't have any syntax errors:

## Syntax Check

```
> iverilog button_led.v
```

## Synthesis

Next we will use the [Yosys Open Synthesis Suite](http://www.clifford.at/yosys/).
This step will break the design into the target technology primitives.
In our case that is Lattice iCE40 FPGA primitives.
The output will be a [BLIF](http://www.cs.columbia.edu/~cs6861/sis/blif/index.html) file.

```
> yosys -p 'synth_ice40 -top button_led -blif button_led.blif' button_led.v
```

## Place and Route

We are using [arachne-pnr](https://github.com/YosysHQ/arachne-pnr) for place and route.
We should upgrade to [nextpnr](https://github.com/YosysHQ/nextpnr), 
but have not done that yet.

This step takes the design primitives generated by synthesis and maps them
to our target part.  Then it routes the primitives together.

The output is a [IceStorm](http://www.clifford.at/icestorm/) ASC file which
represents the FPGA configuration file. The IceStorm ASCII format has blocks of 0
and 1 for the config bits for each tile in the chip.

```
> arachne-pnr -s 7 -d 8k -P cm81 -o button_led.asc -p pins.pcf button_led.blif
```

## Check timing

The arachne-pnr tool is **not** timing driven.  These means you cannot give it
timing constraints up front and have it work on meeting those constraints.  

You can however run the IceStorm tool __icetime__ to give you a timing report.

We don't currently have a clock in our design, so the timing estimate
is not really needed yet.

In our main HBA project bitstream the clock is running at 50mhz.
So in general we want the timing estimate to be faster than 50mhz.

```
> icetime -d lp8k -mtr button_led.rpt button_led.asc
// Reading input .asc file..
// Reading 8k chipdb file..
// Creating timing netlist..
// Timing estimate: 6.02 ns (166.03 MHz)
```

## Generate Bitstream

If the timing looks good then we will generate the binary bitstream.
The tool __icepack__ converts from the ASCII bitstream to the 
binary bitstream.

```
> icepack button_led.asc button_led.bin
```

## Program the TinyFPGA

The Lattice iCE40 part that is on the TinyFPGA board can be programmed
via SPI.  The Raspberry Pi SPI pins on the GPIO header are routed to 
the SPI programming port on the TinyFPGA board.  

The FPGA can be programmed from the on board SPI flash, or from
the Raspberry Pi.  There is a GPIO pin on the Pi that selects between
the two.  

Unfortunately the TinyFPGA does not route the CRESET (configuration reset)
signal to an external pin.  So we have to manually press the CRESET button at
the appropriate time. 

There is a program __prog_fpga.py__ which is in the [utils](https://github.com/hbrc-fpga-class/peripherals/tree/master/utils) directory.

There is a script
[setup.bash](https://github.com/hbrc-fpga-class/peripherals/blob/master/setup.bash)
that you can source that will add __prog_fpga.py__ to your path.  Once it is in
your path you can program the bitstream with the following... It will prompt you
when to press the CRESET button.

```
> prog_fpga.py button_led.bin
```

Now you can press the two user buttons and turn on two leds!!

If you want the default bitstream back you can press the CRESET button
again and it will load it from the SPI flash!!

## The Makefile

In the *1_Button_Led* directory there is a Makefile.  So you can run all the step above via

```
> make
```

And program the bistream with

```
> make prog
```

## Exercise : A Verilog Gotcha!

By default Verilog does not require you define a wire before you use it.
This can be an issue if you have a typo in a wire name.

Update line 11 in button_led.v to the following:
```
assign ld = ~button1;
```

Now run our syntax check again:

```
> iverilog button_led.v
```

No errors!!

Now update button_led.v so it looks like this:

```verilog
/* Buttons directly connected to led. */

// Force error when implicit net has no type.
`default_nettype none

module button_led
(
    input wire button0,
    input wire button1,
    output wire [7:0] led
);

assign led[0] = ~button0;
// XXX assign led[1] = ~button1;
assign ld = ~button1;

assign led[7:2] = 0;

endmodule
```

Now run our syntax check again:

```
> iverilog button_led.v
button_led.v:15: error: Net ld is not defined in this context.
1 error(s) during elaboration.
```

That is better.

The __`default_nettype none__ directive says if a net has not been explicitly defined
give its nettype the value of __none__, which causes an error if it is used.

In general I think it is a good idea to add to the top of your verilog files.

```
// Force error when implicit net has no type.
`default_nettype none
```

The one place this can get you in trouble is if you are using modules from a 3rd
party that takes advantage of the default behavior.

---

# [2_Button_Led_Reg](https://github.com/hbrc-fpga-class/peripherals/tree/master/verilog_tutorial/2_Button_Led_Reg)

In this section we learn about the __reg__ keyword.

## button_led_reg1.v

```verilog
/* Buttons connected to leds via registers. */

// Force error when implicit net has no type.
`default_nettype none

module button_led_reg1
(
    input wire clk_16mhz,
    input wire button0,
    input wire button1,
    output reg [7:0] led
);


always @ (posedge clk_16mhz)
begin
    led[0] <= ~button0;
    led[1] <= ~button1;
    led[7:2] <= 0;
end

endmodule
```

This module behaves pretty much the same as the 1_Button_Led module.
Here are some difference to notice:
* We add another input port called __clk_16mhz__.  It has been added to
  _pins.pcf_ as well.
* Output port __led__ is specified as a __reg__ instead of a __wire__.  The
  __assign__ statement we used in the previous example, only works with
  __wire__.  If we set values in an __always__ (or __initial__) block we must
  use a __reg__ on the left hand side of the assignment.
* After the __always__ there is __@ (posedge clk_16mhz)__.  The __@__ operator
  is called the _change operator_.  And the signals in the parenthesis are
  called the sensitivity list. Remember the __always__ block is an infinite
  loop, but now it will only enter the next iteration of the loop on the
  positive edge of clk_16mhz.
* The assignment operator in the __always__ block is __<=__.  This is the __non
  blocking assignment operator__.  This means that the three assignment
  operations happens simultaneously on the rising edge of clk_16mhz.  The
  __led[1:0]__ signals will be implemented as D flip flops.  The __led[7:2]__
  signals probably will be optimized out since the value never changes.

You can build the bistream for this module and program the TinyFPGA in one shot
via:

```
> make button_led_reg1.v
```

---

# Operators

## Assignment Operators

* __=__
    * blocking assignement
    * used for continuous assignments (rule of thumb for synthesizable)
    * used with the __assign__ statement
* __<=__
    * non-blocking assignment
    * used for procedural assignments (rule of thumb for synthesizable)
    * used in __always__ blocks

In practice blocking vs non-blocking is more for the simulator than
for the synthesis tools.  Remember Verilog started as a simulation
tool.  In button_led_reg1.v if you replace the __<=__ with __=__ it will
synthesize the same.

## Arithmetic Operators

* __+__  : Addition
* __-__  : Subtraction
* __*__  : Multiplication
* __/__  : Division
* __%__  : Modulus
* __**__ : Power

## Bitwise Operators

* __|__   : OR
* __&__   : AND
* __^__   : XOR
* __<<__  : Shift left
* __>>__  : Shift right
* __<<<__ : Signed shift left
* __>>>__ : Signed shift right

## Logical Operators

* __||__   : Logical OR
* __&&__   : Logical AND

## Negation Operators

* __~__   : Bitwise negation
* __!__   : Logical negation

## Reduction Operators

* __|__   : Reduction OR
* __&__   : Reduction AND
* __^__   : Reduction XOR (parity)

## Ternary Operator

* __led[0] = (button1==1) ? 1 : 0;__


