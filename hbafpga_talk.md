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

TODO

* Simple demo using raw read/write

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
