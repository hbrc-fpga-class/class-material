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

```verilog {.line-numbers}
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

