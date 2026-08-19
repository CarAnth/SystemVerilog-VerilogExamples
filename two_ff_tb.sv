module tb_two_ff;
logic clk;
logic rst_n;
logic async_in;
logic sync_out;

two_ff uut(
    .clk(clk),
    .rst_n(rst_n),
    .async_in(async_in),
    .sync_out(sync_out)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin  
    $dumpfile("tb_two_ff.vcd");
    $dumpvars(0, tb_two_ff);

    rst_n = 1'b0;
    async_in = 1'b0;

    repeat(2) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;
    
    if(sync_out !== 1'b0) begin
        $error("Error: sync_out should be 0 after reset");
    end
    // Test 1: async_in = 1
    @(negedge clk);
    async_in = 1'b1;
    @(posedge clk);
    @(negedge clk);
    if(sync_out !== 1'b0) begin
        $error("Error: sync_out should be 0 after first clock cycle");
    end
    @(posedge clk);
    @(negedge clk);
    if(sync_out !== 1'b1) begin
        $error("Error: sync_out should be 1 after second clock cycle");
    end

    async_in = 1'b0;
    repeat (2) @(posedge clk);
    @(negedge clk);
    #1;
    async_in = 1'b1;
    #3;
    async_in = 1'b0;
    repeat (2) @(posedge clk);
    @(negedge clk);

    if(sync_out !== 1'b0) begin
        $error("Error: sync_out should be 0 after async_in change");
    end else begin
        $display("Test passed: sync_out is 0 after async_in change");
    end
    $finish;
    

    
end
    
endmodule