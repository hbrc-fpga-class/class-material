# HBRC FPGA Class Syllabus

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
5. Buses and Numbers
    * Grouping wires together
    * Array like syntax
    * Numbers Format
        * num_bits'radix value
        * radix specifiers
    * Assigning number to a bus
        * decimal number
        * hex number
        * binary number
    * Port Buses
    * Wire Buses
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
            * if/else statements
            * case statements
                * often used for state machines
            * for/repeat/while loopAll:

## Class 4: To Be Decided
