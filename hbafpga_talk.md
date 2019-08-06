<!-- $theme: gaia -->
<!-- template: invert -->

---

# Today

* FPGA HBA Architecture
* Serial Pi to FPGA Interface
* HBA Peripheral Interface
* HBA BasicIO Peripheral
  * Review peripheral's Verilog
  * Simple Demo Using raw read/write
  * Demo using driver: set, get, cat
  * Review peripheral's HBA plugin

---

# FPGA HBA Architecture
![center](./images/HBA_FPGA_Architecture.png)
* Serial (UART) interface between Pi and FPGA
* HBA Bus connects Peripherals
* Each Peripheral is assigned a slot
* Peripheral can be Master, Slave or Both
* Slave Peripherals
  * Contain bank of registers
  * Registers can be Read, Write or Both.
  * Used to setup peripherals and to read data
* Master Peripherals
  * Can read/write to Slave Peripheral registers
  * HBA Bus supports multiple master

---

# Serial Interface

The Raspberry Pi uses the serial interface to read and write to the
HBA Peripheral registers.  So the Raspberry Pi is a Master on the HBA Bus.

* Serial Interface (from perspective of rasp-pi)
  * __rpi_txd__  : Transmit data to the FPGA.
  * __rpi_rxd__  : Receive data from the FPGA
  * __rpi_intr__ : Interrupt from FPGA. Indicates FPGA has data to be read.

![center](./images/HBA_Address.png)

* Addressing Peripherals is 12 bits and is split into two parts.
  * The upper 4 bits select the desired peripheral slot.  There are 16 possible slots.
  * The lower 8 bits select the desired peripheral register.  There are 256 possible registers.

---

# Write Protocol

![center](./images/Write_Protocol.png)
* Command Byte:
  * 7   - Write(0) operation
  * 6:4 - Number of Registers to write minus 1.  So (1-8) possible.
  * 3:0 - Peripheral Slot Address
* Starting Peripheral Register Address. Auto increments if multiple data.
* Data0 .. DataN : The data to write.
* ACK/NACK : From FPGA.  ACK indicates successful write of data.

---

# Read Protocol

![center](./images/Read_Protocol.png)
* Command Byte:
  * 7   - Read(1) operation
  * 6:4 - Number of Registers to read minus 1.  So (1-8) possible.
  * 3:0 - Peripheral Slot Address
* Starting Peripheral Register Address. Auto increments if multiple data.
* Echo Cmd : The Pi sends a dummy byte.  The FPGA echos the cmd byte.
* Echo RegAddr : The Pi sends a dummy byte.  The FPGA echos the RegAddr byte.
* Data0 .. DataN : The Pi sends dummy byte for each reg read.  The FPGA sends reg value.

---

# Simple demo using raw read/write

---

# HBA Bus Interface

TODO

---

# hba_basicio Peripheral Verilog Code

TODO

---

# hba_basicio HBA Pluggin in C

TODO

---
