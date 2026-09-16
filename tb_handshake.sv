`timescale 1ns/1ps

module tb_handshake;
    logic clk;
    logic rst_n;
    logic in_valid;
    logic [7:0] in_data;
    logic out_ready;

    logic in_ready;
    logic out_valid;
    logic [7:0] out_data;

    valid_handshake uut(
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .in_data(in_data),
        .out_ready(out_ready),
        .in_ready(in_ready),
        .out_valid(out_valid),
        .out_data(out_data)

    );
    //TASKS


    //CLK
    initial begin
        clk=0;
        forever #5 clk=~clk;
    end

    //INITIAL PHASE
    initial begin
        $dumpfile("tb_handshake.vcd");
        $dumpvars(0, tb_handshake);
        
        rst_n = 1'b0;
        in_valid = 1'b0;
        in_data = 8'b00000000;
        out_ready = 1'b0;
        repeat(2) @(posedge clk);
        rst_n = 1'b1;
        @(negedge clk);
        if(out_valid !== 1'b0) begin
            $error("Error: out_valid should be 0 after reset");
        end
        if(in_ready !== 1'b1) begin
            $error("Error: in_ready should be 1 after reset");
        end


        @(negedge clk);
        in_valid =1;
        in_data= 8'd25;

        @(posedge clk);
        @(negedge clk);
        in_valid = 1'b0;

        if(out_valid !== 1'b1) begin
            $error("Error: out_valid should be 1 after push");
        end

        if(out_data !== 8'd25) begin
            $error("Error: out_data should be 25 after push");
        end

         if (in_ready !== 1'b0)
            $error("Error: in_ready should be 0 while buffer is full and out_ready is 0");

        @(negedge clk);
        out_ready = 1'b1;

        @(posedge clk);
        @(negedge clk);
        out_ready = 1'b0;

        if (out_valid !==1'b0) begin
            $error("Error: out_valid should be 0 after pop");
        end

        if (in_ready !== 1'b1) begin
            $error("Error: in_ready should be 1 after pop");
        end
        
        @(negedge clk);
        
        in_valid = 1'b1;
        in_data = 8'd50;
        
        $finish;

    end
endmodule