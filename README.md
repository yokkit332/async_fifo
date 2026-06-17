# Asynchronous FIFO

## Overview
Parameterized RTL Asynchronous FIFO implementation and verification using SystemVerilog, supporting two independent clock domains for write and read operations. Used gray-code along with 2 flip-flop synchronizer to prevent metastability when crossing clock domains.

## Architecture
### Design Modules
| Module | Description |
|--------|-------------|
| `async_fifo_top.sv` | Top-level module connecting all submodules to assemble the FIFO|
| `fifo_mem.sv` | Dual-port memory array that writes data synchronously on `w_clk` when write enable is asserted, and combinationally outputs read data based on current read pointer |
| `wr_ptr_handler.sv` | Handles write pointer by incrementing pointer on valid writes, converts binary pointer to gray code to prepare for CDC to read, handles full detection logic |
| `rd_ptr_handler.sv` | Handles read pointer incrementing pointer on valid reads, converts binary pointer to gray code to prepare for CDC to write domain, handles empty detection logic|
| `sync_2ff.sv` | 2-flip-flop synchronizer to handle clock domain crossing of gray-coded read and write pointers; gives metastable signals 2 clock cycles to resolve|
| `fifo_tb.sv` | Testbench verifying functional correctness |


### Clock Domain Crossing
[Explain gray code pointers and 2FF synchronizer]

### Full/Empty Detection
[Explain the MSB trick and gray code full condition]

## Verification
### Test Cases
[List your test cases and what each verified]

## File Structure
| File | Description |
|------|-------------|
| async_fifo_top.sv | |
| fifo_mem.sv | |
| wr_ptr_handler.sv | |
| rd_ptr_handler.sv | |
| sync_2ff.sv | |
| fifo_tb.sv | |

## How to Run
[Icarus Verilog commands to simulate]
