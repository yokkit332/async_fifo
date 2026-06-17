module fifo_mem #(
    parameter WIDTH = 8,// width of each element
    parameter DEPTH = 8 // max number of entries in FIFO
)(
    input logic w_clk,
    input logic w_en,
    input logic [$clog2(DEPTH):0] w_ptr, // log of depth, extra bit for full/empty calculation
    input logic [$clog2(DEPTH):0] r_ptr, // log of depth, extra bit for full/empty calculation
    input logic [WIDTH-1:0] wdata, // data to read into FIFO
    output logic [WIDTH-1:0] rdata // data to be read out of FIFO
);
    // memory array - DEPTH entries each WIDTh bits wide
    logic [WIDTH-1:0] mem [DEPTH-1:0];
    
    // write logic
    always_ff @(posedge w_clk) begin
        if(w_en) begin
            mem[w_ptr[$clog2(DEPTH)-1:0]] <= wdata; // exclude msb of w_ptr that was used for full/empty calc
        end
    end

    // combinational read logic, always output data at current r_ptr location
    assign rdata = mem[r_ptr[$clog2(DEPTH)-1:0]];

endmodule

