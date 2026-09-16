`timescale 1ns/1ps

module tb_cdc;
logic src_clk;
logic dst_clk;
logic rst_n;
logic src_pulse;
logic src_busy;
logic dst_pulse;

cdc_handshake uut(
    .src_clk(src_clk),
    .dst_clk(dst_clk),
    .rst_n(rst_n),
    .src_pulse(src_pulse),
    .src_busy(src_busy),
    .dst_pulse(dst_pulse)
    
);

initial begin
    src_clk= 1'b0;
    forever #5 src_clk = ~src_clk;
end


initial begin
    dst_clk =1'b0;
    forever #10 dst_clk = ~dst_clk;
end

initial begin
    $dumpfile("tb_cdc.vcd");
    $dumpvars(0,tb_cdc);

    rst_n = 1'b0;
    src_pulse = 1'b0;

    repeat(2) @(posedge src_clk);
    @(negedge src_clk);
    rst_n = 1'b1;
    src_pulse = 1'b1;

    @(posedge src_clk);
    @(negedge src_clk);
    
    src_pulse = 1'b0;

    repeat(2) @(posedge dst_clk);
    @(negedge dst_clk);
    @(posedge dst_clk);
    #1;

    if (dst_pulse !== 1'b0) begin
        $error("dst_pulse should be low");
    end else begin
        $display("dst_pulse correct");
    end

    $finish;
end






endmodule