module tb_multi_cdc;
logic src_clk;
logic dst_clk;
logic rst_n;
logic [7:0] src_data;
logic src_valid;
logic src_busy;
logic [7:0] dst_data;
logic dst_valid;

multi_cdc uut(
    .src_clk(src_clk),
    .dst_clk(dst_clk),
    .rst_n(rst_n),
    .src_data(src_data),
    .src_valid(src_valid),
    .src_busy(src_busy),
    .dst_data(dst_data),
    .dst_valid(dst_valid)
);


task automatic send_data(input logic [7:0] value);

    wait(src_busy === 1'b0);
    @(negedge src_clk);
    src_data = value;
    src_valid = 1'b1;
    @(negedge src_clk);
    src_valid = 1'b0;

endtask //automatic

task automatic send_while_busy(input logic [7:0] value);
    @(negedge src_clk);

    if(src_busy !== 1'b1)begin
        $fatal(1, "Fail: src_busy must be 1");
    end 
    else begin
            
    end


    
endtask //automatic

initial begin
    src_clk= 1'b0;
    forever #5 src_clk = ~src_clk;
end

initial begin
    dst_clk =1'b0;
    forever #7 dst_clk = ~dst_clk;
end

initial begin
    $dumpfile("tb_multi_cdc.vcd");
    $dumpvars(0, tb_multi_cdc);
    
    src_data='0;
    rst_n = 1'b0;
    src_valid =1'b0;


    repeat (2) @(posedge src_clk);
    @(negedge src_clk);
    rst_n = 1'b1;
    repeat (3) @(posedge src_clk);
    repeat (3) @(posedge dst_clk);

    send_data(8'hA5);

    wait(dst_valid === 1'b1);
    
    #5;
    if (dst_data !== 8'hA5) begin
        $fatal(1,"Fatal error: dst_data should be A5, real data: %h", dst_data);

        
    end else begin
        $display("Pass: expected A5, data: %h", dst_data);
    end
    
    
    repeat (2) @(posedge src_clk);
    
    
    
    $finish;  
    


end

endmodule
