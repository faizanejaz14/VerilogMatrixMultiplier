# VerilogMatrixMultiplier
Verilog project for implementing matrix multiplication on spartan 6 nexys 3 FPGA.

## Repo Structure
The files used in the project are stored in Modules. All the .v files, testbenches and other relenvant modules are in there. Legacy folder contains experimented modules, which were later discarded due to bugs.

Videos contain our whole progress and Images contain outputs from our FGPA Matrix Multiplier.

## Goals
1. UART one-way communication working 10% (Done)
2. UART two-way communication working 10% (Done)
3. Serial matrix multiplication working on FPGA without UART 10% (Done)
4. Serial matrix multiplication working on FPGA with UART 10% (Done)
5. Serial and Parallel matrix of size 3x3 working on FPGA without and with UART, 10% (Done)
6. Make the newMem_to_TX file send 2 bytes of data instead of 1 byte, as number after multiplication of large matrix tend to clip.

## Improvements
The following improvements can be made in the design:
1. Extended Parallel Pipelining to 10x10 Multiplier. We were unable to implement this because the method we were using (Multiple Read/Write ports to memory) does not work in our case. See 3x3 Inconsistent Image, where the unused ports tend to overwrite the first memory location.
    
    a. Either rewrite the memories so A, B and C have their own dedicated memories. In the current program, Matrix A memory = 1:10, Matrix B = 1:1 and Matrix C = 1:10 (write:read ports).
    
    b. Extra slots in memory can be configured where the extra data can be written. This allows the unused write ports to write garbage in unused locations, but would increase the overall BRAM consumption.

    c. The FPGA (Spartan 6 Nexys 3) had a limit, and during 10x10 we had reached that limit. We did not test that with our updated implemetation but this should be considered as well.
