# Under Development

Verilog Tutorial Links:
* [Part 1](https://github.com/hbrc-fpga-class/class-material/blob/master/verilog_tutorial_part1.md)
* [Part 2](https://github.com/hbrc-fpga-class/class-material/blob/master/verilog_tutorial_part2.md)


# Verilog Tutorial Part 2 Overview

* 4 State Machine
    * Shifting Solution
    * State Machine Solution
* Paramertized modules
* Instantiating modules
* Testbenches 


# [4_State_Machine](https://github.com/hbrc-fpga-class/peripherals/tree/master/verilog_tutorial/4_State_Machine)

In this section we will learn how to model state machines in Verilog.  To get
started login to your robot using ssh and perform the following steps:

```
> cd ~/hbrc_fpga_class/peripherals
> source setup.bash
> cd verilog_tutorial/4_State_Machines
```

## Kit car style leds

The target design for this section is the
[Challenge activity](https://github.com/hbrc-fpga-class/class-material/blob/master/verilog_tutorial_part1.md#challenge)
at the end of the 
[verilog_tutorial_part1](https://github.com/hbrc-fpga-class/class-material/blob/master/verilog_tutorial_part1.md).

To repeat that desciption:

* A group of three leds bounce back and forth, so it looks like a
  Battlestar Galactica Cylon Scanner or the Kit car in Knight Rider.

## state_machine0.v

This solution does *not* use a state machine.  Instead it uses techniques
learned in Part1.  Here is the Verilog:

```verilog
/* Kit car style leds. */
/* No state machine version. */

// Force error when implicit net has no type.
`default_nettype none

module state_machine0
(
    input wire clk_16mhz,
    input wire button0,
    input wire button1,
    output reg [7:0] led
);

// reset when button0 is pushed
wire reset = ~button0;

// button1 is an enable
wire en = button1;

// internal registers
reg inc_led;
reg [23:0] fast_count;
reg count_dir;
reg [2:0] shift_count;


// Constants
localparam DELAY_COUNT  = 1_000_000;
localparam COUNT_UP     = 0;
localparam COUNT_DOWN   = 1;

// Generate a pulse to inc_leds every
// quarter of a second.
always @ (posedge clk_16mhz)
begin
    if (reset) begin
        inc_led <= 0;
        fast_count <= 0;
    end else begin
        if (en) begin
            inc_led <= 0;       // default
            fast_count <= fast_count + 1;
            if (fast_count == DELAY_COUNT) begin
                inc_led <= 1;
                fast_count <= 0;
            end
        end
    end
end

// Change led direction after 5 shifts
always @ (posedge clk_16mhz)
begin
    if (reset) begin
        count_dir <= COUNT_UP;
        shift_count <= 0;
    end else begin
        if (inc_led) begin
            shift_count <= shift_count + 1;
            if (shift_count == 4) begin
                count_dir <= ~count_dir;
                shift_count <= 0;
            end
        end
    end
end

// Increment the led count.
initial led <= 8'b000_0111;
always @ (posedge clk_16mhz)
begin
    if (reset) begin
        led <= 8'b000_0111;
    end else begin
        if (inc_led) begin
            if (count_dir == COUNT_UP) begin
                led <= led << 1;
            end else begin
                led <= led >> 1;
            end
        end
    end
end

endmodule
```

Items of note:
* **button1** is used as an **en** (enable) signal.

The notation:
```verilog
wire en = button1;
```

is equivalent to:
```verilog
wire en;
assign en = button1;
```

As Verilog evolved syntax shortcuts like the above developed.
Another one we use is putting the input/output ports and
type all in the module declaration like this:

```verilog
module state_machine0
(
    input wire clk_16mhz,
    input wire button0,
    input wire button1,
    output reg [7:0] led
);
```
An older style that you will see is the input/output ports
defined after the module declaration like this:

```verilog
module state_machine0 (clk_16mhz, button0, button1, led);

// declare ports
input clk_16mhz;
input button0;
input button1;
output [7:0] led;

// declare signal types
wire clk_16mhz;
wire button0;
wire button1;
reg [7:0] led;
```

* We add the **en** signal to gate incrementing **fast_count** which
controls our **inc_led** signal.  This always block is a common
pattern with a **reset** and **en**.

```verilog
// Generate a pulse to inc_leds every
// quarter of a second.
always @ (posedge clk_16mhz)
begin
    if (reset) begin
        inc_led <= 0;
        fast_count <= 0;
    end else begin
        if (en) begin
            inc_led <= 0;       // default
            fast_count <= fast_count + 1;
            if (fast_count == DELAY_COUNT) begin
                inc_led <= 1;
                fast_count <= 0;
            end
        end
    end
end
```

* Instead of a button press to change **count_dir**.  We use
**shift_count** to determine when to switch directions.

```verilog
// Change led direction after 5 shifts
always @ (posedge clk_16mhz)
begin
    if (reset) begin
        count_dir <= COUNT_UP;
        shift_count <= 0;
    end else begin
        if (inc_led) begin
            shift_count <= shift_count + 1;
            if (shift_count == 4) begin
                count_dir <= ~count_dir;
                shift_count <= 0;
            end
        end
    end
end
```

* We initialize the leds to 8'b000_0111.  So the right three leds will
be on at power up.  We use the shift operators to shift the leds left
and right based on the **count_dir**.

```verilog
// Increment the led count.
initial led <= 8'b000_0111;
always @ (posedge clk_16mhz)
begin
    if (reset) begin
        led <= 8'b000_0111;
    end else begin
        if (inc_led) begin
            if (count_dir == COUNT_UP) begin
                led <= led << 1;
            end else begin
                led <= led >> 1;
            end
        end
    end
end
```

Try commenting out the **initial** line and regenerate the bitstream.
No leds, why?  Now try hitting **button0**.  What happens?

## State Machines

A **finite-state machine (FSM)** or simply **state machine** is an abstract
machine that can be in exactly one of a finite number of states at
any given time.   The state machine can transition from one state to another
in response to some inputs.  In logic control applications there are two
styles of state machines  **Moore Machines** and **Mealy Machines**.  Both
of these types can be implemented in Verilog.

* Moore Machine

![Moore Machine](images/Moore_Machine.png)

* Mealy Machine

![Mealy Machine](images/Mealy_Machine.png)

Both types of state machines have these three parts:
* **Next State Logic**.  Also called the Transition Logic.  This combines the current
  state with the inputs and generates the next state.
* **State Logic**.  This is the memory (registers) that record the current state.
* **Output Logic**.  A state machine can have multiple outputs.  In a Moore Machine
this is soley based on the current state.  In a Mealy Machine the outputs are based
on the current state and the inputs.

**Which is better?** I think it is largly a matter of taste.  But for FPGAs
I think there is a good argument for using the Moore style in that the
outputs can be synchronous with the state transistions.  And synchronous is
good in FPGAs because it helps with timing.

## State Machine Coding Style

Since there are 3 parts to making a state machine, there are many styles
to coding a state machine.  But basically boils down to:
* **Three always blocks** : The next state logic and output logic are both modeled as
  combintorial always blocks. The state logic is a synchronous always block.
* **Two always blocks** : Two parts in one always block, and the other in another.
* **One always block** : All three parts in one always block.  This is my favorite.
This makes a Moore machine and the outputs are synchronous with the state
transistions.  It also, usually, requires the least typing.

**Note**: The important thing is you code the state-machine in a style that
the synthesis tool will recognize as a state-machine.  Then depending on the 
synthesis options, you can give it the freedom to recode it to optimize for area
or speed for example.

## state_machine1.v




