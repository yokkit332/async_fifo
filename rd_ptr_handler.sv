module rd_ptr_handler #(
    parameter WIDTH = 4 // pointer width, $clog2(DEPTH) + 1
)(
    input logic r_clk,
    input logic r_rst,
    input logic r_en, // read enable from user to request read from FIFO
  input logic [WIDTH-1 : 0] w_ptr_gray_sync,
    output logic [WIDTH-1 : 0] r_ptr,
  output logic [WIDTH-1 : 0] r_ptr_gray,
    output logic empty
);
    logic [WIDTH-1 : 0] r_ptr_next;
    always_ff @(posedge r_clk, posedge r_rst) begin
        if(r_rst) begin
            r_ptr <= '0;
        end
        else begin
            r_ptr <= r_ptr_next;
        end
    end

    // r_ptr output logic block
    always_comb begin
        r_ptr_next = r_ptr;
        if(!empty && r_en) begin
            r_ptr_next = r_ptr + 1;
        end
    end

    // binary to gray conversion
    always_comb begin
        r_ptr_gray = r_ptr ^ (r_ptr >> 1);
    end

    // empty detection logic
    always_comb begin
        empty = (w_ptr_gray_sync == r_ptr_gray);
    end

endmodule