# Asynchronous FIFO

## Overview
Parameterized RTL Asynchronous FIFO implementation and verification using SystemVerilog, supporting two independent clock domains for write and read operations. Used gray-code along with 2 flip-flop synchronizer to prevent metastability when crossing clock domains.

## Description
An asynchronous FIFO, or First In First Out, allows data to be transferred between two different clock domains. In other words, unlike a standard FIFO operating on a single clock, async FIFOs handle read and write operations on completely different clocks, which requires more complicated handling in order to prevent data corruption due to clock domain crossing.

## Architecture
### Design Modules
| Module | Description |
|--------|-------------|
| `async_fifo_top.sv` | Top-level module connecting all submodules to assemble the FIFO|
| `fifo_mem.sv` | Dual-port memory array that writes data synchronously on `w_clk` when write enable is asserted, and combinationally outputs read data based on current read pointer |
| `wr_ptr_handler.sv` | Handles write pointer by incrementing pointer on valid writes, converts binary pointer to gray code to prepare for CDC to read, handles full detection logic |
| `rd_ptr_handler.sv` | Handles read pointer by incrementing pointer on valid reads, converts binary pointer to gray code to prepare for CDC to write domain, handles empty detection logic|
| `sync_2ff.sv` | 2 flip-flop synchronizer to handle clock domain crossing of gray-coded read and write pointers; gives metastable signals 2 clock cycles to resolve|
| `fifo_tb.sv` | Testbench verifying functional correctness |

### Full/Empty Detection
To distinguish between full and empty conditions, I added an extra MSB to both read and write pointers, making them one bit wider than needed to address the memory. For example, for a FIFO of depth 8, I only needed 3 bits to address the whole FIFO. However, I added an extra bit to detect if a FIFO was full and empty. 

**Empty** The FIFO is empty simply when the read and write pointers are the same value, as the pointers are the exact same if the same amount of words have been written to and read from the FIFO. In order to compare the read and write pointers, I had to first convert the original binary write pointer to gray code, then sent it through a two flip-flop synchronizer across to the read domain to prevent metastability. Finally, I simply compared the values of the gray-coded write and read pointers to determine the empty condition.

**Full** The FIFO is full when the write has lapped the read pointer by exactly DEPTH entries. Thus, in binary, we know that the write pointer has lapped the read pointer if the extra MSB we added is different between the read and write pointer but all lower bits are the same. However, because our FIFO is asynchronous, we must use gray code to compare pointers instead, since we used gray code along with a 2FF synchronizer when sending pointers across clock domains between read and write. In gray code, the full condition is triggered when the top two bits of the write pointer differ from the top two bits of the read pointer and the remaining bits are equal.

### Clock Domain Crossing
  As explained previously, the whole challenge of an asynchronous FIFO is due to clock domain crossing, as flip-flop setup and hold times cause data to be corrupted when transferring data between different clock domains. 

To safely pass a bit across clock domains, we use a 2 flip-flop synchronizer to pass the bit through two consecutive flip-flops clocked by the destination domain. Although the first flip-flop may sample a metastable value, by the time the signal reaches the second flip-flop, there is an extremely high probability that the second flip-flop outputs a stable 0 or 1. This outputted value may not be the value that was originally inputted, but at the very least we get a stable output and prevent metastability.

However, for our case, we need to pass a multi-bit pointer between two clock domains. For our multi-bit binary pointers, multiple bits can change simulatenously (e.g 011 -> 100), which means that when such a value passes through the 2FF synchronizer, each bit would resolve to a random stable bit independently which could result in a completely different pointer value than the one we expected. To solve this, we can convert our binary pointers to gray code pointers since gray code ensures that only one bit changes in each increment. 

As a result, when we pass gray-coded pointers through the 2FF synchronizer, only one bit potentially go through metastability and the outputted pointer will either be the newly incremented pointer (best case) or the original pointer value (worst case). Either case is acceptable, because they are both valid and expected pointer values. If the gray-coded pointer resolves to the original pointer position, the full/empty logic will only see a stale value for that one clock cyclebefore correcting itself in the next clock cycle when the poi  nter stabilizes. However, the important conclusion is that the one-bit one-cycle, error will never corrupt any data. In the worst case, it merely costs one wasted read or write opportunity.
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
