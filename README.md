# FPGA-Ping-Pong-game

A Simple Ping Pong game written in VHDL for Spartan 3E FPGA board. <br>

![GitHub](https://img.shields.io/github/license/ashvnv/FPGA-Ping-Pong-game)

| | |
| ------------- | ------------- |
| Category  | FPGA  |
| Target Device  | Spartan 3E  |
| Language | VHDL |
| Tool | Xilinx 14.5 |

Clone this repository and open the **display1.ipf** file *(/display1/display1.ipf)* on Xilinx. <br>
There is no test bench in the project. The program was dumped directly on the board.

### Note
You can get the **VHDL file** and **Constraint file** directly under **raw/** folder. These files can be opened as text files.

---

## How to play?
A cube will keep traversing across the screen. The goal here is to hit it back by the pad in the bottom of the screen. Simply rotate the Rotary switch on the Spartan 3E board for moving the pad horizontally. If the cube is hit back successfully, the colour of the cube does not change otherwise the color will change.

## How it works?
Using a Spartan 3E board's internal VGA adapter, I have written a VHDL program which makes the Spartan board work as a VGA driver. Basic VGA timing signals are generated using the board's internal 50Mhz clock. Refer http://tinyvga.com/vga-timing/640x480@60Hz for getting the timing values. While the VGA pixels are being drawn on the screen, specific pixels are manipulated to make a cube like shape on the screen. The cube is moved across the screen according to the scaled down clock signal in the program. A pad is made at the bottom of the screen using the same way cube is made. This pad can be moved horizontally by simply rotating the Rotary switch on the Spartan 3E board. The cube and pad can be moved across the screen by changing the cube and pad's pixel location according to the scaled down clock in the program.

## Will it work on other FPGA boards?
- In Spartan 3E, the internal clock is of 50 Mhz. VGA timing signals required a 25 Mhz clock. So the 50 Mhz was scaled down to 25 Mhz in the program. If using other FPGA boards, this clock frequency may be different and accordingly the program has to be modified.
- Ofcourse the constraint file will be different for each board. *pins.ucf* file has to be modified for each board according to the datasheet.

The VHDL program should work on different boards once these issues are tackled.
