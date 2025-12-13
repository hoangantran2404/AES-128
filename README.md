# AES-128
Online sources I have reviewed: 
- Youtube           :  [https://www.youtube.com/watch?v=gP4PqVGudtg&t=44s](https://www.youtube.com/watch?v=gP4PqVGudtg&t=64s)
- Scientific article:  [https://ieeexplore.ieee.org/abstract/document/9367201](https://www.scielo.org.ar/pdf/laar/v37n1/v37n1a14.pdf)


  
1.Overview
- This project implements the AES algorithm entirely in Verilog on Vivado and C coding language on VS code.
- It is designed for FPGA synthesis, demonstrating digital design skills in pipelining, FSM control, message scheduling, and data path design.


1.1 Dataflow:
  - UART Receiver (8-bit)
  - Message Packer (8-bit → 512-bit)
  - AES-256 Core (32-bit internal)
  - Message Packer (128-bit → 8-bit)
  - UART TX (8-bit)


  
2.Features
- Fully compliant with AES-128 specification
- Modular structure (Cipher, Key_Expansion, and Control Units)
- Pipeline-friendly design for better throughput
- Parameterizable data width[32bit] and easy integration
- Testbench included for simulation and verification using waveform
- Synthesizable and activable on ZCU102 (FPGA board)


3.Structures
<img width="1746" height="626" alt="Screenshot from 2025-12-13 17-25-49" src="https://github.com/user-attachments/assets/3fdd0cf8-a224-472a-a975-7f1be9956de5" />

- README.md

  
📂 RTL
- AES128_top.v            # Top-level module
- AES128_core.v           # This module has FSMD (Finite State Machine and Datapath), which controls module Cipher and module Key_Expansion doing in parallel way.
- receiver                # UART receiver for converting the string input to binary (designed by my teacher)
- transmitter             # UART transmitter for converting the string output to binary (designed by my teacher)
- Key_Expansion.v         # This module generates 44 keys, which used in module Cipher in each 11 rounds.
- Cipher.v                # This module does 11 rounds from 4 words of plaintext and 4 words of key to generate 4 final words of AES key(32-bit/1 Word).
- MP_in.v                 # This module receives 128-bit of plaintext and 128-bit of key from UART RX and send to core sequentially.
- MP_out.v                # This module has the same structure to MP_in.v, however it receives final 128-bit key from core and use "handshake" technique to send to UART TX.
- RotWord.v               # Computational Units instantiated in Key_Epansion
- SubWord.v               # Computational Units instantiated in Key_Epansion 
- RoundConst.v            # Computational Units instantiated in Key_Epansion 
- AddRoundKey.v           # Computational Units instantiated in Cipher 
- SubBytes.v              # Computational Units instantiated in Cipher 
- ShiftRows.v             # Computational Units instantiated in Cipher 
- MixColumns.v            # Computational Units instantiated in Cipher


📂 UART
- receiver                # UART receiver for converting the string input to binary (designed by my teacher)
- transmitter             # UART transmitter for converting the string output to binary (designed by my teacher)


📂 Embedded Code
- AES128_core.c           # This is AES128_core implemented on software in C language. I use this file to generate output and then compare with result from ZCU102 FPGA board.

