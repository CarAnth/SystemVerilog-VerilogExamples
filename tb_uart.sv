`timescale 1ns/1ps

module uart_tb;

    localparam int CLK_PER_BITS = 4;
    logic clk;
    logic rst_n;
    logic start;
    logic [7:0] data_in;

    logic tx;
    logic busy;
    logic done;
    uart_tx dut(
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .data_in(data_in),
        .tx(tx),
        .busy(busy),
        .done(done)
    );

    task check_tx(input logic [7:0] expected_data);
        @(negedge tx);

        #20;
        if (tx !== 1'b0) begin
            $error("Start bit error");
        end
        #20;
        for (int i = 0;i < 8 ;i++ ) begin
            #40;
            if (tx !== expected_data[i]) begin
                $error("Error in bit:%d , expected:%b, received:%b",i,expected_data[i],tx);

            end
        end
        #40;
        if (tx!==1'b1) begin
            $error(
                "Stop bit error"
            );
        end


    endtask 
    
    //clk
    initial begin
        clk=0;
        forever #5 clk=~clk;

    end

    //testing
    
    initial begin
        rst_n = 1'b0;
        start = 1'b0;
        data_in = 8'b0;

        repeat (2) @(posedge clk);

        rst_n = 1'b1;

        @(posedge clk);
        
        fork
            check_tx(8'b1001_1101);
        join_none

        data_in=8'b1001_1101;
        start=1'b1;

        @(posedge clk);
        start=1'b0;



        wait(done==1'b1);

        @(posedge clk);
        $display("UART Transmission done.");
        $finish;

    end
    initial begin
        $dumpfile("tb_uart.vcd");
        $dumpvars(0, uart_tb);
    end
endmodule