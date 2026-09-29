

module tb_counter;
    parameter WIDTH = 8;
    reg clk;
    reg rst_n;
    reg enable;
    reg load;
    reg [WIDTH-1:0] load_value;
    reg [WIDTH-1:0] limit_value;
    wire [WIDTH-1:0] count;
    wire limit_pulse;
    
    integer error_count;


    programmable_counter #(.WIDTH(WIDTH)) uut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .load(load),
        .load_value(load_value),
        .limit_value(limit_value),
        .count(count),
        .limit_pulse(limit_pulse)
    );


    task check_outputs;
        input [WIDTH-1:0] expected_count;
        input expected_limit_pulse;
        begin
            if (count !== expected_count) begin
                $display("Error: Expected count = %d, Got = %d at time %t", expected_count, count, $time);
                error_count = error_count + 1;
            end
            if (limit_pulse !== expected_limit_pulse) begin
                $display("Error: Expected limit_pulse = %b, Got = %b at time %t", expected_limit_pulse, limit_pulse, $time);
                error_count = error_count + 1;
            end
        end
    endtask

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars(0, tb_counter);
        
        error_count = 0;
        rst_n = 0;
        enable = 0;
        load = 0;
        load_value = 8'd2;
        limit_value = 8'd4;
        
        #1;
        check_outputs(0, 0); // Check initial state after reset
        
        @(negedge clk);
        rst_n = 1;

        load = 1;
        @(posedge clk);
        @(negedge clk);
        check_outputs(2, 0); // Check after loading value

        load = 0;
        enable = 1;

        @(posedge clk);
        @(negedge clk);
        check_outputs(3, 0); // Check after first increment
        
        @(posedge clk);
        @(negedge clk);
        check_outputs(4, 0); // Check after first increment

        @(posedge clk);
        @(negedge clk);
        check_outputs(0, 1); // Check after reaching limit

        @(posedge clk);
        @(negedge clk);
        check_outputs(1, 0); // Check after reaching limit

        enable = 0;
        
        @(posedge clk);
        @(negedge clk);
        check_outputs(1, 0);

        // Load ve enable aynı anda 1: load öncelikli
        load_value = 3;
        load       = 1;
        enable     = 1;

        @(posedge clk);
        @(negedge clk);
        check_outputs(3, 0);

        // Load bırakılınca 3'ten saymaya devam etmeli
        load = 0;

        @(posedge clk);
        @(negedge clk);
        check_outputs(4, 0);

        if (error_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TEST FAILED: %0d errors detected", error_count);

        $finish;
    end
endmodule