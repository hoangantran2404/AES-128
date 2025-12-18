# AES-128 Implementation on ZCU102

## 1. Overview
This project implements the **AES-128 (Advanced Encryption Standard)** algorithm entirely in Verilog using the Xilinx Vivado Design Suite. It is designed for FPGA synthesis, specifically targeting the **ZCU102** evaluation board.

Unlike hashing algorithms (like SHA-256) which verify integrity, AES-128 is a symmetric block cipher used for **confidentiality**. In the industry, this architecture is critical for:
* **SoC (System on Chip):** Acting as a dedicated hardware accelerator to offload encryption tasks from the main CPU, ensuring secure boot sequences and memory protection.
* **FPGA Applications:** Facilitating high-speed, low-latency network security protocols (such as IPsec or MACsec) where software encryption is too slow.
* **Smart ICs:** Providing power-efficient data protection in constrained environments like banking smart cards and secure IoT nodes.

### 1.1 Dataflow
The system processes data through the following pipeline:
1.  **UART Receiver:** Captures 8-bit serial input.
2.  **Message Packer (In):** Buffers and packs 8-bit inputs into a 128-bit Plaintext/Key block.
3.  **AES-128 Core:** Performs the 10-round encryption process (Key Expansion + Cipher).
4.  **Message Packer (Out):** Unpacks the resulting 128-bit Ciphertext into 8-bit segments.
5.  **UART Transmitter:** Serializes data for display.

## 2. Features
* **Fully Compliant:** Adheres strictly to FIPS 197 AES-128 specifications.
* **Modular Architecture:** Separated logic for Cipher, Key Expansion, and Control Units.
* **Optimized Design:** Pipeline-friendly data path for enhanced throughput.
* **Flexible Integration:** Parameterizable data width (default 32-bit internal).
* **Verified:** Validated via waveform simulation and C-model comparison.
* **Hardware Proven:** Synthesizable and active on the Xilinx ZCU102 FPGA.

## 3. Architecture
The following diagram illustrates the system hierarchy and data path:
<img width="1746" height="626" alt="AES Structure" src="https://github.com/user-attachments/assets/3fdd0cf8-a224-472a-a975-7f1be9956de5" />

## 4. Project Structure

### 📂 RTL Source Code

| Module Name | Type | Function / Description |
| :--- | :---: | :--- |
| `AES128_top.v` | **Top Level** | Main entry point; integrates UART, Message Packers, and Core. |
| `AES128_core.v` | **Core** | **FSMD Controller:** Orchestrates parallel execution of Cipher and Key Expansion. |
| `Key_Expansion.v` | **Compute** | Generates the 44 words required for the 11 key rounds. |
| `Cipher.v` | **Compute** | Performs the encryption rounds on 4 words of plaintext. |
| `MP_in.v` | **Datapath** | **Input Packer:** Collects UART data to form 128-bit blocks for the Core. |
| `MP_out.v` | **Datapath** | **Output Packer:** Handshakes with Core to serialize 128-bit output for UART. |
| `receiver.v` | **IO** | UART Receiver (RX). |
| `transmitter.v` | **IO** | UART Transmitter (TX). |

### 📂 Computational Units (Sub-modules)

| Module Name | Parent | Description |
| :--- | :--- | :--- |
| `SubBytes.v` | Cipher | Non-linear substitution step (S-Box). |
| `ShiftRows.v` | Cipher | Transposition step (Cyclic shift). |
| `MixColumns.v` | Cipher | Inter-column mixing operation. |
| `AddRoundKey.v` | Cipher | XORs the state with the round key. |
| `RotWord.v` | Key_Exp | Cyclic rotation of word bits. |
| `SubWord.v` | Key_Exp | S-Box substitution for key generation. |
| `RoundConst.v` | Key_Exp | Generates round constants (Rcon). |

### 📂 Embedded Code (Verification)

| File Name | Role | Function / Description |
| :--- | :---: | :--- |
| `AES128_core.c` | **Model** | **C Implementation:** Software version of the algorithm used to generate "Golden Vectors" to verify the FPGA hardware output. |

## 5. Getting Started

### Prerequisites
* Xilinx Vivado Design Suite
* ZCU102 FPGA Evaluation Board
* VS Code (for C simulation)

### Simulation & Hardware
1.  **Simulation:** Load the project in Vivado and run the behavioral simulation to view the waveform.
2.  **Implementation:** Run Synthesis and Implementation to generate the Bitstream.
3.  **Deployment:** Program the ZCU102 board.
4.  **Verification:** Use a Terminal (TeraTerm) to send plaintext strings and verify the encrypted output against the `AES128_core.c` software result.

## 6. References
* **Tutorial:** [AES Implementation Guide (YouTube)](https://www.youtube.com/watch?v=gP4PqVGudtg&t=64s)
* **Research:** [Scientific Article on AES/FPGA](https://www.scielo.org.ar/pdf/laar/v37n1/v37n1a14.pdf)

## 7. Acknowledgments
* UART Receiver/Transmitter modules provided by course instructor.
* GEMINI thinking 3 pro helps me how to decorate file README.md.
