`timescale 1ns/1ps

module fifo_tb;
    localparam WIDTH = 8;
    localparam DEPTH = 8;

    // declare and initialize inputs
    logic w_clk = 0;
    logic r_clk = 0;
    logic w_rst = 0;
    logic r_rst = 0;
    logic w_en = 0;
    logic r_en = 0;
    logic [WIDTH-1:0] wdata = '0;

    // declare outputs driven by DUT
    logic [WIDTH-1:0] rdata;
    logic full;
    logic empty;

    // clock generation
    always #5 w_clk = ~w_clk; // write clock with period of 10
    always #12 r_clk = ~r_clk; // read clock with period of 24

    // instantiate the design under test
    async_fifo_top #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    )DUT(
        .w_clk(w_clk),
        .r_clk(r_clk),
        .w_rst(w_rst),
        .r_rst(r_rst),
        .w_en(w_en),
        .r_en(r_en),
        .wdata(wdata),
        .rdata(rdata),
        .full(full),
        .empty(empty)
    );
  
   // task to reset fifo
  task reset();
      $display("\n\nresetting FIFO...");
      w_rst = 1;
      r_rst = 1;
      #20; // hold reset for 50 time units
      r_rst = 0;
      w_rst = 0;
      #5; // settling time after reset
  endtask

  // task to write to FIFO
  task write_fifo(input logic [WIDTH-1:0] data);
      // if full, cannot write
      if(full) begin
          $display("CANNOT WRITE TO FIFO. FULL FIFO DETECTED");
      end

      // if not full, can write
      else begin
          @(posedge w_clk);
          #1;
          w_en = 1;
          wdata = data;
          @(posedge w_clk);
          #1;
          w_en = 0;
          $display("SUCCESSFULLY WROTE %h TO FIFO.",data);
          repeat(3) @(posedge w_clk); // wait for synchronizer to propagate signal
      end
  endtask

  // task to read to FIFO
  task read_fifo();
      // trying to read but fifo empty
      if(empty) begin
          $display("CANNOT READ VALUE. FIFO EMPTY");
      end
      // if trying to read but fifo not empty
      else begin
          @(posedge r_clk);
          #1;
          r_en = 1; 
          $display("SUCCESSFULLY READ %h FROM FIFO", rdata);
          // wait for data to appear on rdata after asserting r_en
          @(posedge r_clk);
          #1;
          r_en = 0;
          repeat(3) @(posedge r_clk); // wait for synchronizer to propagate
          
      end

  endtask

  initial begin
      $dumpfile("dump.vcd");
      $dumpvars(0, fifo_tb);
      // reset signals
      reset();
      // empty check
      $display("\nwrite and read one value to FIFO:");

      // write a value
      write_fifo(8'h3A);	
    
      // read value back
      read_fifo();
      
      // write 8 values to FIFO and verify full logic
      $display("\nwrite 8 values and verify full functionality of FIFO:");
      for(int i = 0; i < 8; i++) begin
        write_fifo($urandom_range(0, 255));
      end
      write_fifo(8'hFF);

      // read back the 8 values and verify empty logic
      $display("\nread back the 8 values and verify empty functionality of FIFO:");
      for(int i = 0; i < 8; i++) begin
        read_fifo();
      end
      read_fifo();

      $display("\nreset during operation test:");
      write_fifo(8'hAA);
      write_fifo(8'hBB);
      write_fifo(8'hCC);
      write_fifo(8'hDD);
      reset(); // reset mid-operation
      $display("after reset: empty=%b full=%b", empty, full); // should be empty=1 full=0
      $display("now try to read, should be empty:");
      read_fifo(); // should be rejected
      $finish;
  end


endmodule

