module tb_fsmver;
reg clk;
reg rst_n;
reg valid;
reg bit_in;
reg match;


sequence_detector uut(
    .clk(clk),
    .rst_n(rst_n),
    .valid(valid),
    .bit_in(bit_in),
    .match(match)
);
task send_bit;
input input_bit;
input expected_bit;
    begin
        @(negedge clk);
        bit_in = input_bit;
        valid = 1'b1;
        @(posedge clk);
        #1;
    
        if (match != expected_bit) begin
            $error("ERROR: bit=%b, match=%b, expected:%b",
            input_bit,match,expected_bit);
        end

    end
endtask

initial begin
    clk =0;
    forever #5 clk = ~clk;
end

initial begin
    $dumpfile("tb_fsmv.vcd");
    $dumpvars(0,tb_fsmver);

    rst_n = 1'b0;
    valid = 1'b0;
    bit_in = 1'b0;
    repeat(2) @(posedge clk);
        @(negedge clk);

        rst_n = 1'b1;

        send_bit(1'b1, 1'b0);
        send_bit(1'b0, 1'b0);
        send_bit(1'b1, 1'b0);
        send_bit(1'b1, 1'b1);

        send_bit(1'b0, 1'b0);
        send_bit(1'b1, 1'b0);
        send_bit(1'b1, 1'b1);
        @(negedge clk);
        valid = 1'b0;
        bit_in =1'b0;

        $display("TEST COMPLETED");
        $finish;
end

endmodule