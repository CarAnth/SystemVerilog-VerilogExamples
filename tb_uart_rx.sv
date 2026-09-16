`timescale 1ns/1ps

module tb_uart_rx;
localparam int  CLK_PER_BIT = 4;
localparam logic [7:0] TEST_DATA = 8'b1010_1010;

logic clk;
logic rst_n;
logic rx;

logic [7:0] data_out;
logic data_valid;
uart_rx dut(
    .clk(clk),
    .rst_n(rst_n),
    .rx(rx),
    .data_out(data_out),
    .data_valid(data_valid)
);
//task
task  send_uart_byte(input logic [7:0] expected_data);
    rx=1'b1;
    @(negedge clk);
    rx=1'b0;
    #40;
    for (int i = 0; i<8; i++) begin
        rx = expected_data[i];
        #40;
    end
    rx=1'b1;
    #40;
endtask //

//clk
initial begin
    clk=0;
    forever #5 clk=~clk;
end

//testing

initial begin
    rx    = 1'b1;
    rst_n = 1'b0;

    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);

    fork
        send_uart_byte(TEST_DATA);

        begin
            @(posedge data_valid);

            if (data_out !== TEST_DATA) begin
                $error(
                    "ERROR: Data mismatch. Expected: %b, Actual: %b",
                    TEST_DATA, data_out
                );
            end
        end
    join

    @(negedge clk);

    if (data_valid !== 1'b0)
        $error("ERROR: data_valid remained high");
    else
        $display("All tests passed");

    $finish;
end

initial begin
    $dumpfile("tb_uart_rx.vcd");
    $dumpvars(0,tb_uart_rx);
end


endmodule