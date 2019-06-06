# FPGA Robotics Class Outline

## Class 1 : Introduction and Tools Setup

1. Introduction
    * Overview of the Goals for the Class
        * Presenting a Pi/FPGA platform for Robotics
            * Raspberry Pi for high level programming
            * FPGA peripherals for real-time hardware control
            * Library of peripherals available
        * Learn how to build and program using existing peripherals
        * Learn how to build custom FPGA peripheral in Verilog
    * Today
        * Install required development tools
        * Test installation
        * Simple Blinky Verilog
        * Preview to the HomeBrew Automation Platform
2. Tool Installation
    * Virtual Machine Image?
    * Download HBA repos for github
    * Build Blink Verilog from source and download to board
3. HBA Preview
    * High-level diagram with both Pi and FPGA parts
    * FPGA architecture of a bus and peripherals on the bus.
    * FPGA Peripherals
    * Raspberry Pi to FPGA interface
    * Software Architecture Diagram
        * HBA Daemon
    * Demos of the HBA system in action

## Class 2 : HomeBrew Automation Platform

1. Bob presents
    * HBA architecture as it relates to an FPGA
    * Download, build, install HBA
    * Bash demo of HBA with a gamepad
    * Present and review a simple Python program to use gamepad
    * Quick review of plug-in API
    * Have participant load FPGA peripheral plug-ins
    * Bash demo of FPGA based robot peripherals

2. Brandon presents
    * Architecture of logic in the FPGA
    * Serial-to-FPGA inputs, outputs, and internal logic
    * HBA bus (as a module interface)
    * GPIO peripheral
        * Design and code review
        * Simple demo using raw read/write
        * Quick design and code review of HBA plug-in

## Class 3 : Verilog Tutorial

1. Introduction
    * Main Focus on Synthesis for FPGAs
    * Light coverage of Testbenches
    * Covering a subset of Verilog
    * Goals:
        * Hands-on
        * Practical not Theoretical
        * Read and Understand the HomeBrew Automation Peripheral's Verilog
        * Able to write simple HBA Verilog Peripherals
2. History
    * Verilog created in the Mid-80s
        * Created for simulation
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
    * VHDL independently developed around the same time
        * Created for documentation (DoD)
        * Ada like in syntax
        * not case-sensitive
        * Strongly typed
3. Modules, Ports, Values and Types
    * Module: The basic construct
    * The simplest module
    * Verilog Comments
    * Verilog Data Types
        * Nets
            * don't hold state
            * __wire__ : most common
        * Registers
            * holds state
            * __reg__ : for logic
            * __integer__ : for loop vars
    * Value Set
        * 0 : Logic 0 or false
        * 1 : Logic 1 or true
        * x : Unknown logic value (sim)
        * z : High impedance of tristate gate
    * Defining Ports
    * Defining Wires
    * Continuous Assignment
    * Semicolon and Whitespace
    * Program #1:
        * Button to LED module
        * Instantiate Button to LED module into top level model
        * Pins constraint file
        * Makefile
4. Operators
    * Binary Operators
    * Arithmetic Operators
    * Bit-wise Operators
    * Logical Operators
    * Unary Operators
    * Ternary Operator
    * Reduction Operators
    * Assignment Operators
        * =
            * blocking assignement
            * used for continuous assignments (rule of thumb for synthesizable)
        * <=
            * non-blocking assignment
            * used for procedural assignments (rule of thumb for synthesizable)
    * Challenge #1
        * Bring in two buttons as input
        * Output to one led
        * Pressing either button turns on the led
5. Busses and Numbers
    * Grouping wires together
    * Array like syntax
    * Numbers Format
        * num_bits'radix value
        * radix specifiers
    * Assigning number to a bus
        * decimal number
        * hex number
        * binary number
    * Port Busses
    * Wire Busses
    * Concatenations
    * Bit-Growth
    * Signed Numbers
    * Challenge #2
        * Write the hex value 0x55 to the 8 leds
    * Challenge #3
        * Have a button press change the value on leds to 0xAA.
        * When not pressed display 0x55.
        * Hint: Use Ternary Operator
6. Procedural Blocks
    *  Two types of Procedural Blocks
        * __initial__
            * Starts at time zero
            * Runs once
            * Can be used to initialize __reg__ types
            * Used in testbenches
        * __always__
            * Starts at time zero
            * When done, starts again, runs forever
        * Procedural Assignments
            * Only register types can be assigned
            * __reg__ type only can be assigned in procedural blocks
        * Procedural Statements
            * Mostly C like
            * if/else statemetns
            * case statements
                * often used for state machines
            * for/repeat/while loops
7. __always__ block for Combinatorial Logic
    * The sensitivity/event list
        * or, comma, and @*
        * Example of a mux
        * Challenge #4
            * Rewrite Challenge #3
            * Using __always__ block and if statement
8. __always__ block for Synchronous Logic
    * Add posedge clock to sensitivity list
    * A reg should only be set from one __always__ block!
    * Most of FPGA design should be synchronous logic
        * Helps with timing
    * Program #2:
        * Counter with MSBs on LEDs
        * Modify to have synchronous reset via button
    * Challenge #5:
        * Add another button
        * When pressed makes counter count down
        * When released counts up
9. State Machine
    * Use case statement to build state machine
    * Program #3:
        * Clock divider circuit
        * Statemachine with Cyclone like eye on LEDs
    * Program #4:
        * Button debounce circuit
        * Step through Cyclone eye animation with button
10. Test Benches
    * Write testbench for program #3.
    * Write testbench for program #4.

## Class 4 : Basic Robotic Circuits

1. Edge Detection Circuit
    * Program #5:
        * Turn on led when sees an edge
2. Sonar Distance Circuit
    * Program #6:
        * Display relative distance on leds
3. PWM Circuit
    * Program #6:
        * Drive motors
        * Button presses increase or decrease speed
        * 2nd Button changes direction
4. Quadrature Encoder Circuit
    * Program #7:
        * Display quarature counts on LEDs
5. Write a HBA peripheral

