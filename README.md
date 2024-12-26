# VerilogMatrixMultiplier
Verilog project for implementing matrix multiplication on spartan 6 nexys 3 FPGA.

Goals:
1. UART one-way communication working 10% (Done)
2. UART two-way communication working 10% (Done)
3. Serial matrix multiplication working on FPGA without UART 10% (Done)
4. Serial matrix multiplication working on FPGA with UART 10% (Done)
5. Fast/parallel/pipelined matrix of size 3x3 working on FPGA without UART, 10% (Done)
6. Fast/parallel/pipelined matrix of size 3x3 working on FPGA with UART, 10% (Done)
7. Fast/parallel/pipelined matrix of size 10x10 working on FPGA without UART, 10% (Done)
8. Fast/parallel/pipelined matrix of size 10x10 working on FPGA with UART, 10% (Done)
9. Make the newMem_to_TX file send 2 bytes of data instead of 1 byte, as number after multiplication of large matrix tend to clip.

TODO:
2. Currently the code runs via FSM without any pipelined structure, so we need to implement pipelining on it if possible as well.
