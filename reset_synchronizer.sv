module reset_synchronizer (
    input logic clk,
    input logic async_rst_n,
    output logic sync_rst_n
);

logic sync_ff1;
logic sync_ff2;

always_ff @( posedge clk or negedge async_rst_n) begin
    if (!async_rst_n) begin
        sync_ff1 <= 1'b0;
        sync_ff2 <= 1'b0;
    end else begin
        sync_ff1 <= async_rst_n;
        sync_ff2 <= sync_ff1;
       
    end
end

assign  sync_rst_n = sync_ff2;

endmodule

