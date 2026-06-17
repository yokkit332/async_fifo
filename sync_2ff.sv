module sync_2ff #(
    parameter WIDTH = 4
)(
    input logic dst_clk,
    input logic rst,
    input logic [WIDTH-1:0] data,
    output logic [WIDTH-1:0] data_synced
);
    logic [WIDTH-1:0] ff1;
    always_ff @(posedge dst_clk, posedge rst) begin
        if(rst) begin
            ff1 <= '0;
            data_synced <= '0;
        end else begin
            ff1 <= data;
            data_synced <= ff1;
        end
    end

endmodule