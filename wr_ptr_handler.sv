module wr_ptr_handler #(
    parameter WIDTH = 4 // pointer width, $clog2(DEPTH) + 1
)(
    input logic w_clk,
    input logic w_rst,
    input logic w_en, // write enable from user to request write into FIFO
    input logic [WIDTH-1:0] r_ptr_gray_sync, // synchronized read_ptr used to calculate full
    output logic [WIDTH-1:0] w_ptr, // binary write ptr used to index memory
    output logic [WIDTH-1:0] w_ptr_gray, // gray code write pointer to send to read domain
    output logic full
);
  
    logic [WIDTH-1:0] w_ptr_next;

    always_ff @(posedge w_clk, posedge w_rst) begin
        if(w_rst) begin
            w_ptr <= '0;
        end
        else begin
            w_ptr <= w_ptr_next;
        end
    end

// output logic block for w_ptr
always_comb begin
    w_ptr_next = w_ptr;
    if(w_en && !full) begin
        w_ptr_next = w_ptr + 1;
    end
end
// convert binary read_ptr to gray code
always_comb begin
    w_ptr_gray = w_ptr ^ (w_ptr >> 1); // formula to convert binary to gray (right-shift then XOR)
end

// full detection logic - full if MSB of both signals are different but lower bits are the same
always_comb begin
  // parameterized values
  
  // full if top two bits are flipped and the rest LSB's are the same
  full = r_ptr_gray_sync == {~w_ptr_gray[WIDTH-1:WIDTH-2], w_ptr_gray[WIDTH-3:0]};
  
end




endmodule