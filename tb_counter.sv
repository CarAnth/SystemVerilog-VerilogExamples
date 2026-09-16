module tb_counter;

    parameter int unsigned WIDTH = 8;

    logic                 clk;
    logic                 rst_n;
    logic                 enable;
    logic                 load;
    logic [WIDTH-1:0]     load_value;
    logic [WIDTH-1:0]     limit_value;
    logic [WIDTH-1:0]     count;
    logic                 limit_pulse;

    integer error_count;

    programmable_counter #(.WIDTH(WIDTH)) dut (
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
        if(count !== expected_count) begin
            $display("Error: Expected count = %0d, but got %0d", expected_count, count);
            error_count++;
        end

        if(limit_pulse !== expected_limit_pulse) begin
            $display("Error: Expected limit_pulse = %0b, but got %0b", expected_limit_pulse, limit_pulse);
            error_count++;
        end
    end
    endtask

    initial begin
        // clock generation
        clk = 0;
        forever #5 clk = ~clk; // 10 time units clock period
    end

    initial begin
        $dumpfile("tb_counter.vcd");
        $dumpvars(0, tb_counter);

        error_count = 0;
        rst_n = 0;
        enable = 0;
        load = 0;
        load_value = 8'd2;
        limit_value = 8'd4;

        #1;
        check_outputs(0, 0);

        @(negedge clk);
        rst_n = 1;

        load = 1;
        @(posedge clk);
        @(negedge clk);
        check_outputs(2, 0);

        load = 0;
        enable = 1;

        @(posedge clk);
        @(negedge clk);
        check_outputs(3, 0);

        @(posedge clk);
        @(negedge clk);
        check_outputs(4, 0);

        @(posedge clk);
        @(negedge clk);
        check_outputs(0, 1);

        @(posedge clk);
        @(negedge clk);
        check_outputs(1, 0);

        enable = 0;

        @(posedge clk);
        @(negedge clk);
        check_outputs(1, 0);

        load = 1;
        load_value = 8'd3;
        enable = 1;

        @(posedge clk);
        @(negedge clk);
        check_outputs(3, 0);

        load = 0;
        @(posedge clk);
        @(negedge clk);
        check_outputs(4, 0);

        if(error_count == 0) begin
            $display("All tests passed!");
        end else begin
            $display("Total errors: %0d", error_count);
        end
        $finish;

    end


endmodule
