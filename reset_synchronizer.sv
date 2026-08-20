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

module tb_reset_sync;
logic clk;
logic async_rst_n;
logic sync_rst_n;

reset_synchronizer uut(
    .clk(clk),
    .async_rst_n(async_rst_n),
    .sync_rst_n(sync_rst_n)
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

initial begin
    $dumpfile("reset_sync.vcd");
    $dumpvars(0,tb_reset_sync);
    
    async_rst_n = 1'b1;
    @(posedge clk);
    async_rst_n = 1'b0;

    if (sync_rst_n !== 1'b0) begin
        $error("sync_rst_n should be 0");

    end else begin
        $display("sync_rst_is true");
    end
    #2;

    async_rst_n = 1'b1;

    repeat(2) @(posedge clk);
    @(negedge clk);

    if (sync_rst_n !== 1'b1) begin
        $error("sync_rst_n should be 1");

    end else begin
        $display("sync_rst_is true");
    end

    @(negedge clk);
    #2;
    async_rst_n = 1'b0;

    #1;
    if (sync_rst_n !== 1'b0) begin
        $error("sync_rst_n should be 0");
    end else begin
        $display("sync_rst_n is true");
    end
    $display("ALL test passed");
    $finish;
    


end

    
endmodule