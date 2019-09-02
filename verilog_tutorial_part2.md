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

You can try out this code from the **4_State_Machine** directory via:

```
> make state_machine0
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
transistions.  It also, usually, requires the least typing :-)

**Note**: The important thing is you code the state-machine in a style that
the synthesis tool will recognize as a state-machine.  Then depending on the
synthesis options, you can give it the freedom to recode it to optimize for area
or speed for example.

## state_machine1.v

```verilog
/* Light pattern leds */
/* State machine version. */

// Force error when implicit net has no type.
`default_nettype none

module state_machine1
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

// State machine register
reg [2:0] state;

// Constants
localparam DELAY_COUNT  = 1_500_000;
localparam COUNT_UP     = 0;
localparam COUNT_DOWN   = 1;

// State machine states
localparam STATE0  = 0;
localparam STATE1  = 1;
localparam STATE2  = 2;
localparam STATE3  = 3;
localparam STATE4  = 4;
localparam STATE5  = 5;
localparam STATE6  = 6;
localparam STATE7  = 7;

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


// state machine logic
always @ (posedge clk_16mhz)
begin
    if (reset) begin
        state <= STATE0;
        led <= 0;
    end else begin
        case (state)
            STATE0 : begin
                led <= 8'b1100_0011;
                if (inc_led) begin
                    state <= STATE1;
                end
            end
            STATE1 : begin
                led <= 8'b0110_0110;
                if (inc_led) begin
                    state <= STATE2;
                end
            end
            STATE2 : begin
                led <= 8'b0011_1100;
                if (inc_led) begin
                    state <= STATE3;
                end
            end
            STATE3 : begin
                led <= 8'b0001_1000;
                if (inc_led) begin
                    state <= STATE4;
                end
            end
            STATE4 : begin
                led <= 8'b0000_0000;
                if (inc_led) begin
                    state <= STATE5;
                end
            end
            STATE5 : begin
                led <= 8'b0001_1000;
                if (inc_led) begin
                    state <= STATE6;
                end
            end
            STATE6 : begin
                led <= 8'b0011_1100;
                if (inc_led) begin
                    state <= STATE7;
                end
            end
            STATE7 : begin
                led <= 8'b0110_0110;
                if (inc_led) begin
                    state <= STATE0;
                end
            end
            default : begin
                state <= STATE0;
                led <= 0;
            end
        endcase
    end
end

endmodule
```

In this example we implement a state-machine in a single always block.
To show the flexibility of a state-machine we have changed the light
pattern, from the previous example.

A couple items to notice:

 * **The state machine register**

 ```verilog
reg [2:0] state;
 ```

 We define **state** as a register with 3 bits.  This allows us to have up
 to 8 states.

 * **State Machine states constants**

 ```verilog
localparam STATE0  = 0;
localparam STATE1  = 1;
localparam STATE2  = 2;
localparam STATE3  = 3;
localparam STATE4  = 4;
localparam STATE5  = 5;
localparam STATE6  = 6;
localparam STATE7  = 7;
 ```

Usually the state constants will have more descriptive names.

Here we define the 8 states and the encoding for each of these states.
We are using **Sequential State Encoding**.  There are other encodings 
we could have choosen such as **Gray State Encoding** or 
**One-Hot State Encoding**.  I usually stick with **Sequential State Encoding**.

If you need to change the encoding style, there are usually options in the synthesis
tools that allows you to change the encoding style without
changing the Verilog code.

* **inc_led always block**.  We still have this block to slow down the transitions.

* **state machine always block**

```verilog
always @ (posedge clk_16mhz)
begin
    if (reset) begin
        state <= STATE0;
        led <= 0;
    end else begin
        case (state)
            STATE0 : begin
                led <= 8'b1100_0011;
                if (inc_led) begin
                    state <= STATE1;
                end
            end
            STATE1 : begin
                led <= 8'b0110_0110;
                if (inc_led) begin
                    state <= STATE2;
                end
            end
            STATE2 : begin
                led <= 8'b0011_1100;
                if (inc_led) begin
                    state <= STATE3;
                end
            end
            STATE3 : begin
                led <= 8'b0001_1000;
                if (inc_led) begin
                    state <= STATE4;
                end
            end
            STATE4 : begin
                led <= 8'b0000_0000;
                if (inc_led) begin
                    state <= STATE5;
                end
            end
            STATE5 : begin
                led <= 8'b0001_1000;
                if (inc_led) begin
                    state <= STATE6;
                end
            end
            STATE6 : begin
                led <= 8'b0011_1100;
                if (inc_led) begin
                    state <= STATE7;
                end
            end
            STATE7 : begin
                led <= 8'b0110_0110;
                if (inc_led) begin
                    state <= STATE0;
                end
            end
            default : begin
                state <= STATE0;
                led <= 0;
            end
        endcase
    end
end
```

We implement the state-machine using a **case** statement.  The general
syntax for the **case** statement is the following:

```verilog
case (expr)
    0 : statement0;
    1 : statement1;
    default : default_statement;
endcase
```

Multiple statements can be group with a case item by putting it in a **begin** **end**
block.  It is a good idea to always include a **default** item to catch
any states that was not specified.  After a case item is executed flow
continues after the **endcase**.

Things to notice about this state-machine block:
* **state and output registers** are initialized on reset and in the **default** item.

* **A Case item** implements the three logic blocks, output logic, transition logic,
  and state logic.

```verilog
STATE0 : begin
    led <= 8'b1100_0011;
    if (inc_led) begin
        state <= STATE1;
    end
end
```

You can try out this code from the **4_State_Machine** directory via:

```
> make state_machine1
```

# [5_PWM_Module](https://github.com/hbrc-fpga-class/peripherals/tree/master/verilog_tutorial/5_PWM_Module)

In this section we will move beyond blinking leds and drive a motor.
We will do this by generating a PWM module.

Our class robot is using the 
[Pololu Motor Driver and Power Distribution Board for Romi Chassis](https://www.pololu.com/product/3543/specs).

This board uses the [TI DRV8838](https://www.pololu.com/file/0J806/drv8838.pdf) for driving the motors.

The following is a table from the datasheet.

![DRV8838 Logic](images/drv8838_logic.png)

To control the speed of the robot we can _pwm_ the **EN** pin.

We can control the direction of the motor turns via the **PH** pin.

## Pulse-width modulation (PWM)

Pulse-width modulation (pwm) is a way of adjusting the average power delivered to the motor,
so we can control the speed of the motor.  The way this is done is by adjusting the 
**ON** to **OFF** time of a periodic signal.  The ratio of the **ON** time to the **OFF**
time is called **duty cycle**.  Here are some examples of different duty cycles.

![Duty Cycle](images/Duty_Cycle.png)

## pwm1.v

```verilog
// Force error when implicit net has no type.
`default_nettype none

module pwm1
(
    input wire clk_16mhz,
    input wire button0,
    input wire button1,
    output wire [7:0] led,

    // Motor pins
    output reg pwm,
    output wire dir,
    output wire float_n
);

// Parameters
localparam CLK_FREQUENCY = 16_000_000;
localparam PWM_FREQUENCY = 100_000;
localparam PERIOD_COUNT = (CLK_FREQUENCY/PWM_FREQUENCY);
localparam COUNT_BITS = $clog2(PERIOD_COUNT);
localparam DUTY_1_PERCENT = (PERIOD_COUNT/100);
localparam DUTY_CYCLE = 20;
localparam ON_COUNT = (DUTY_CYCLE*DUTY_1_PERCENT);

// Assignments
assign dir = ~button0;      // Button0 controls direction
assign float_n = button1;   // Button1 enables float
assign led = {6'h0,float_n,dir}; // Turn off leds

// Signals
reg [COUNT_BITS-1:0] pwm_count;

// Generate PWM
initial pwm<=0; // added for sim
always @ (posedge clk_16mhz)
begin
    pwm_count <= pwm_count + 1;
    pwm <= 1;
    if (pwm_count >= ON_COUNT) begin
        pwm <= 0;
    end
    if (pwm_count == PERIOD_COUNT) begin
        pwm_count <= 0;
    end
end

endmodule
```

In this example we generate a 100kHz PWM pulse with
a 20% duty cycle.  We have **button0** control the motor
direction and **button1** control the float_n pin.

We also added the following to the **pins.pcf** to
map our motor pins to the left motor

```
# Left Motor
set_io pwm          C1  # PIN_5
set_io dir          C2  # PIN_4
set_io float_n      B1  # PIN_3
```

We can try this code from the **5_PWM_Module** directory via

```
> make pwm1
```

Things to notice:

*  **Math in the Parameters**

```
localparam CLK_FREQUENCY = 16_000_000;
localparam PWM_FREQUENCY = 100_000;
localparam PERIOD_COUNT = (CLK_FREQUENCY/PWM_FREQUENCY);
localparam COUNT_BITS = $clog2(PERIOD_COUNT);
localparam DUTY_1_PERCENT = (PERIOD_COUNT/100);
localparam DUTY_CYCLE = 20;
localparam ON_COUNT = (DUTY_CYCLE*DUTY_1_PERCENT);
```
We let the Verilog Preprocessor do some math for us.  
We define the CLK_FREQUENCY and PWM_FREQUENCY and then compute
how many clock ticks it takes for a PWM period which
we call **PERIOD_COUNT**.   

NOTE: This division is integer division.  The fractional part is truncated.

The **$clog2()** system function returns the ceiling of the
logarithm to the base 2.  We use this to compute the number of
bits we need for our **pwm_count** register.

* **Use a parameter in register width**

```verilog
reg [COUNT_BITS-1:0] pwm_count;
```
This is fairly common in parameterized modules.  We have the __-1__ because
it goes down to 0.

* **Concatenation operator for setting led**

```verilog
assign led = {6'h0,float_n,dir}; // Turn off leds
```

Sets led[1]=float_n and led[0]=dir, and led[7:2]=0.

* **Generating the pwm**

```verilog
initial pwm<=0; // added for sim
always @ (posedge clk_16mhz)
begin
    pwm_count <= pwm_count + 1;
    pwm <= 1;
    if (pwm_count >= ON_COUNT) begin
        pwm <= 0;
    end
    if (pwm_count == PERIOD_COUNT) begin
        pwm_count <= 0;
    end
end
```

We intialize pwm to 0 for the simulator.  For the iCE40 it inits to 0 on
powerup.

By default we increment pwm_count and set pwm<=1.

If the pwm_count is >= ON_COUNT then pwm<=0.

If pwm_count == PERIOD_COUNT, then we reset pwm_count back to zero.
And the signal repeats.


