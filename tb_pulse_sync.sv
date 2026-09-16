`timescale 1ns/1ps

module tb_pulse;

    logic src_clk;
    logic dst_clk;
    logic rst_n;
    logic pulse_in;
    logic pulse_out;

    integer pulse_count;

    pulse_sync uut (
        .src_clk   (src_clk),
        .dst_clk   (dst_clk),
        .rst_n     (rst_n),
        .pulse_in  (pulse_in),
        .pulse_out (pulse_out)
    );

    // src_clk period: 10 ns
    initial begin
        src_clk = 1'b0;
        forever #5 src_clk = ~src_clk;
    end

    // dst_clk period: 50 ns
    initial begin
        dst_clk = 1'b0;
        forever #25 dst_clk = ~dst_clk;
    end

    always @(posedge dst_clk or negedge rst_n) begin
        if (!rst_n)
            pulse_count <= 0;
        else if (pulse_out)
            pulse_count <= pulse_count + 1;
    end

    initial begin
        $dumpfile("tb_pulse.vcd");
        $dumpvars(0, tb_pulse);

        rst_n    = 1'b0;
        pulse_in = 1'b0;

        repeat (2) @(posedge src_clk);
        @(negedge src_clk);
        rst_n = 1'b1;

        /*
         * Bir dst_clk posedge'inden hemen sonra başlıyoruz.
         * Böylece iki toggle değişimi bir sonraki dst_clk
         * posedge'inden önce gerçekleşecek.
         */
        @(posedge dst_clk);

        // Birinci pulse
        @(negedge src_clk);
        pulse_in = 1'b1;

        @(negedge src_clk);
        pulse_in = 1'b0;

        // İkinci pulse: hedefi beklemeden gönderiliyor
        @(negedge src_clk);
        pulse_in = 1'b1;

        @(negedge src_clk);
        pulse_in = 1'b0;

        repeat (5) @(posedge dst_clk);
        @(negedge dst_clk);

        $display(
            "Sent 2 fast pulses, received %0d pulses",
            pulse_count
        );

        if (pulse_count < 2)
            $display(
                "Expected result: destination missed pulse(s)"
            );
        else
            $display(
                "Both pulses were captured in this simulation"
            );

        $finish;
    end

endmodule