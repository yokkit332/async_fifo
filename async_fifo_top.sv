module async_fifo_top #(
    parameter WIDTH = 8, // width of each element
    parameter DEPTH = 8 // number of entries in FIFO
)(
    input logic w_clk,
    input logic r_clk,
    input logic w_rst,
    input logic r_rst,
    input logic w_en,
    input logic r_en,
    input logic [WIDTH-1:0] wdata,
    output logic [WIDTH-1:0] rdata,
    output logic full,
    output logic empty
);
    logic [$clog2(DEPTH):0] w_ptr;
    logic [$clog2(DEPTH):0] r_ptr;
    logic [$clog2(DEPTH):0] w_ptr_gray;
    logic [$clog2(DEPTH):0] r_ptr_gray;
    logic [$clog2(DEPTH):0] w_ptr_gray_synced;
    logic [$clog2(DEPTH):0] r_ptr_gray_synced;

    // instantiate the fifo memory
    fifo_mem #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) fifo_mem_instance (
        .w_clk(w_clk),
        .w_en(w_en),
        .w_ptr(w_ptr),
        .r_ptr(r_ptr),
        .wdata(wdata),
        .rdata(rdata)
    );

    // instantiate wr_ptr_handler
    wr_ptr_handler #(
        .WIDTH($clog2(DEPTH) + 1) // depth in binary, with extra bit for full/empty calculations
    ) wr_ptr_handler_inst (
        .w_clk(w_clk),
        .w_rst(w_rst),
        .w_en(w_en),
        .r_ptr_gray_sync(r_ptr_gray_synced),
        .w_ptr(w_ptr),
        .w_ptr_gray(w_ptr_gray),
        .full(full)
    );

    // instantiate rd_ptr_handler
    rd_ptr_handler #(
        .WIDTH($clog2(DEPTH) + 1) // depth in binary, with extra bit for full/empty calculations
    ) rd_ptr_handler_inst (
        .r_clk(r_clk),
        .r_rst(r_rst),
        .r_en(r_en),
        .w_ptr_gray_sync(w_ptr_gray_synced),
        .r_ptr(r_ptr),
        .r_ptr_gray(r_ptr_gray),
        .empty(empty)
    );

    // sync gray-code read ptr from read domain to write domain
    sync_2ff #(
        .WIDTH($clog2(DEPTH) + 1) // depth in binary, with extra bit for full/empty calculations
    ) read2write (
        .dst_clk(w_clk),
        .rst(w_rst),
        .data(r_ptr_gray),
        .data_synced(r_ptr_gray_synced)
    );

    
    // sync gray-code write ptr from write domain to read domain
    sync_2ff #(
        .WIDTH($clog2(DEPTH) + 1) // depth in binary, with extra bit for full/empty calculations
    ) write2read (
        .dst_clk(r_clk),
        .rst(r_rst),
        .data(w_ptr_gray),
        .data_synced(w_ptr_gray_synced)
    );


endmodule