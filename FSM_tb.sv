module fsm_tb;
    logic clk;
    logic rst_n;
    logic valid;
    logic bit_in;
    logic match;

    sequence_detector_1011 dut(
        .clk(clk),
        .rst_n(rst_n),
        .valid(valid),
        .bit_in(bit_in),
        .match(match)
    );

    task send_bit(
        
        input logic input_bit,
        input logic expected_match
    );begin
        @(negedge clk);
        bit_in = input_bit;
        valid = 1'b1;

        @(posedge clk);
        #1;

        if (match !== expected_match) begin
            $error(
                "ERROR: bit=%b , match= %b, expected=%b",
                input_bit, match, expected_match
            );

        end
    end
        
    endtask
    
    
    initial begin
        clk=0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("tb_fsm.vcd");
        $dumpvars(0, fsm_tb);

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