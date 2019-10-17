Verilog Tutorial Links:
* [Part 1](https://github.com/hbrc-fpga-class/class-material/blob/master/verilog_tutorial_part1.md)
* [Part 2](https://github.com/hbrc-fpga-class/class-material/blob/master/verilog_tutorial_part2.md)
* [Part 3](https://github.com/hbrc-fpga-class/class-material/blob/master/verilog_tutorial_part3.md)


# Verilog Tutorial Part 3 Overview

* Putting it all together
* HBA Architecture Review
* Design of a Speed Controller Peripheral
* Design of the Speed Controller Driver
* Implementation of Speed Controller Peripheral
* Adding to the main project
* Building a new project
* Implementation of the Speed Controller Driver
* Testing the peripheral and driver


# Putting it all together

At the beginning of the class we took a top down approach and 
learned about the HBA architecture and how the FPGA peripherals 
communicate with the hbadaemon running on the Raspberry Pi,
and how to write Python apps that talk to the hbadaemon.

Then we took a bottom up approach and learned the basics
of Verilog and how to synthesize designs for the FPGA.

In this class we will bring it all together by building
a peripheral that we will add to the HBA FPGA architecture.
We will then write a hbadaemon driver, and an app to
test our new peripheral.



# HBA Architecture Review

  * [HBA Daemon presentation (.md)](hbadaemon_talk.md)
  * [HBA FPGA Architecture presentation (.md)](hbafpga_talk.md) [(.pdf)](hbafpga_talk_slides.pdf)

# Design of Speed Controller Peripheral

![velocity controller](./images/Velocity_Controller.png)

* Driver sets **reg_desired_speed** and **reg_init_pwm** which is 
an estimate pwm to get the robot to move at the desired speed.
* Speed is measures in encoder ticks per .01 seconds.
* Use up/down counter to generate PWM value.  
* If we are going too slow and not accelerating bump up the PWM value.
* If we are going too fast and not deaccelerating bump down the PWM
  value.


# Get latest updates

First let make sure we have the latest version of the FPGA periperhals and drivers.
Login into your robot and type:

```
> cd ~/hbrc_fpga_class/peripherals
> git pull origin master
> cd ../eedd
> git pull origin hba
> make
> sudo make install
```

Then make sure the lastest version fpga bitstream is loaded on the tinyfpga.

```
> cd ~/hbrc_fpga_class/peripherals/projects/main_project/romi-pcb
```

* Connect a usb cable between the tinyfpga and the Pi
* Press the button on the tinyfpga to put it in bootloader mode

Now program the tinyfpga.

```
> tinyprog -p top.bin
```

Now we can restart the **hbadaemon** with the following commands:

```
> ps -aux | grep hbadaemon
ubuntu     551  0.0  0.1   2164  1076 ?        Ss   17:39   0:00 /usr/local/bin/hbadaemon
ubuntu    1230  0.0  0.0   3816   580 pts/1    S+   18:09   0:00 grep --color=auto hbadaemon
> kill 551
> hbadaemon
> hbalist
```

# Testing Encoders

We can test that the encoders gives us approx 1440 counts per revolution:

```
> hbaset serial_fpga intrr_rate 30      # set the max interrupt rate to 30hz
> hbaset hba_quad ctrl 7                # enable quad updates and interrupts
> hbaset hba_quad reset 1               # reset the encoder counters
> hbacat hba_quad enc                   # start output encoder values, ctrl-c to stop
```

Try turning a wheel one revolution to see how many counts you get.

Now lets test the speed reporting.  Open a 2nd terminal to the robot and type:

```
> hbaset hba_motor mode bb              # puts both motors in break mode
> hbaset hba_motor motor0 a             # set the left motor pwm to 10%
> hbaset hba_motor motor1 a             # set the right motor pwm to 10%
> hbaset hba_motor mode ff              # put both motors in forward mode
```

This will get both motors spinning slowly. Now in the 1st terminal lets check the
speed.

```
> hbaset hba_quad speed_period 20       # sets the speed measurement period to 20ms
> hbacat hba_quad speed                 # start output of speed values, ctrl-c to top
```

The speed values are in encoder ticks per speed_period.

In the 2nd terminal type:

```
> hbaset hba_motor mode bb              # puts both motors in break mode
```

# Implementation of Speed Controller Logic

The basic implementation files are in the directory

```
> cd ~/hbrc_fpga_class/peripherals/verilog_tutorial/8_Speed_Controller

```

First lets look at the comparator module:

```verilog
module comparator
(
    input wire clk,
    input wire reset,
    input wire en,
    input wire [7:0] in1,
    input wire [7:0] in2,

    output reg less_than,       // in1 < in2
    output reg equal,           // in1 = in2
    output reg greater_than     // in1 > in2
);


always @ (posedge clk)
begin
    if (reset) begin
        less_than <= 0;
        equal <= 0;
        greater_than <= 0;
    end else begin
        if (en) begin
            if (in1 == in2) begin
                equal <= 1;
            end else if (in1 < in2) begin
                less_than <= 1;
            end else begin
                greater_than <= 1;
            end
        end
    end
end

endmodule
```

Now look at the up_down_counter module:

```verilog
module up_down_counter
(
    input wire clk,
    input wire reset,
    input wire en,
    input wire load,

    input wire [7:0] init_value,
    input wire up,
    input wire down,

    output reg [7:0] out_value
);

always @ (posedge clk)
begin
    if (reset) begin
        out_value <= 0;
    end else begin
        if (load) begin
            out_value <= init_value;
        end else begin
            if (en) begin
                if (up==1 && out_value<100) begin
                    out_value <= out_value + 1;
                end else if (down==1 && out_value>0) begin
                    out_value <= out_value - 1;
                end
            end
        end
    end
end

endmodule
```

Now lets create the parent speed_controller module

```verilog
module speed_controller
(
    input wire clk,
    input wire reset,
    input wire en,

    input wire [7:0] actual_speed,
    input wire [7:0] desired_speed,

    input wire [7:0] init_pwm,

    output wire [7:0] pwm_value
);

/*
**********************
*  Signals
**********************
*/

wire speed_too_slow;
wire speed_too_fast;
wire slowing;
wire speeding_up;

reg [7:0] previous_speed;

wire up = speed_too_slow & ~speeding_up;
wire down = speed_too_fast & ~slowing;

reg [7:0] init_pwm_reg;
reg load;

/*
**********************
*  Instantiations
**********************
*/

// Compare actual speed to desired speed
comparator comp_inst1
(
    .clk(clk),
    .reset(reset),
    .en(en),
    .in1(actual_speed),  // [7:0]
    .in2(desired_speed),  // [7:0]

    .less_than(speed_too_slow),       // in1 < in2
    //.equal(),           // in1 = in2
    .greater_than(speed_too_fast)     // in1 > in2
);

// Check if we are accel or decel
comparator comp_inst2
(
    .clk(clk),
    .reset(reset),
    .en(en),
    .in1(actual_speed),  // [7:0]
    .in2(previous_speed),  // [7:0]

    .less_than(slowing),       // in1 < in2
    //.equal(),           // in1 = in2
    .greater_than(speeding_up)     // in1 > in2
);

up_down_counter up_down_counter_inst
(
    .clk(clk),
    .reset(reset),
    .en(en),
    .load(load),

    .init_value(init_pwm_reg),   // [7:0]
    .up(up),
    .down(down),

    .out_value(pwm_value) // [7:0]
);

/*
**********************
*  Main
**********************
*/

// Remember previous speed
always @ (posedge clk)
begin
    if (reset) begin
        previous_speed <= 0;
    end else begin
        if (en) begin
            previous_speed <= actual_speed;
        end
    end
end

// Generate load for init_pwm
always @ (posedge clk)
begin
    if (reset) begin
        init_pwm_reg <= 0;
        load <= 0;
    end else begin
        init_pwm_reg <= init_pwm;
        load <= 0;
        if (init_pwm_reg != init_pwm) begin
            // new init_pwm value, so load it
            load <= 1;
        end
    end
end


endmodule
```

# Implementation of Speed Controller Peripheral

Now lets create the speed controller peripheral

```
> cd ~/hbrc_fpga_class/peripherals      # cd to top level of peripherals repo
> cp -r hba_basicio hba_speed_ctrl      # use hba_basicio as template
> cd hba_speed_ctrl
> mv hba_basicio.v hba_speed_ctrl.v     # rename to hba_speed_ctrl
> cp ~/hbrc_fpga_class/peripherals/verilog_tutorial/8_Speed_Controller/*.v .
```

Update the file **compile.vf** so it looks like this

```
# iverilog -c compile.vf
hba_speed_ctrl.v
../hba_reg_bank/hba_reg_bank.v
speed_controller.v
comparator.v
up_down_counter.v
```


Update the file **README.md** to define the port and register interfaces.  It should look
like this:

```
# hba_speed_ctrl

## Description

This module is a HBA (HomeBrew Automation) bus peripheral.
It enables a simple speed controller.

## Port Interface

This module implements an HBA Slave interface.
It also has the following additional ports.

* __speed_ctrl_actual_lspeed[7:0]__ (input) : Encoder speed of left motor
* __speed_ctrl_actual_rspeed[7:0]__ (input) : Encoder speed of right motor
* __speed_ctrl_lpwm[7:0]__ (output) : The pwm value for left motor
* __speed_ctrl_rpwm[7:0]__ (output) : The pwm value for right motor

## Register Interface

There are three 8-bit registers.

* __reg0__ : (reg_desired_lspeed) - Left speed in encoder ticks per period.
* __reg1__ : (reg_desired_rspeed) - Right speed in encoder ticks per period.
* __reg2__ : (reg_init_lpwm) - Initial left pwm duty cycle.
* __reg3__ : (reg_init_rpwm) - Initial right eft pwm duty cycle.

```

Now lets update the **hba_speed_ctrl.v** file.

The main things we need to do are:
* Change the module name to hba_speed_ctrl
* Update port interface to have the additional signals specified in the README.md
* Update the regsiter bank instantiation to match registers in README.md
* Instantiate the speed_control.v module
* Add glue logic to tie things together








