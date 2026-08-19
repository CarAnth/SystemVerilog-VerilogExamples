`timescale 1ns/1ps

module tb_sync_fifo;

    localparam int WIDTH = 8;
    localparam int DEPTH = 8;

    logic clk;
    logic rst_n;
    logic wr_en;
    logic rd_en;
    logic [WIDTH-1:0] data_in;

    logic [WIDTH-1:0] data_out;
    logic full;
    logic empty;

    logic [WIDTH-1:0] received_data;
    logic [WIDTH-1:0] previous_data;

    sync_fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .wr_en   (wr_en),
        .rd_en   (rd_en),
        .data_in (data_in),
        .data_out(data_out),
        .full    (full),
        .empty   (empty)
    );

    // Clock üretimi
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // FIFO'yu resetleme
    task automatic reset_fifo;
        begin
            @(negedge clk);

            rst_n   = 1'b0;
            wr_en   = 1'b0;
            rd_en   = 1'b0;
            data_in = '0;

            repeat (2) @(posedge clk);

            @(negedge clk);
            rst_n = 1'b1;

            @(negedge clk);
        end
    endtask

    // FIFO'ya bir veri yazma
    task automatic write_fifo(
        input logic [WIDTH-1:0] write_data
    );
        begin
            if (full) begin
                $error("FIFO doluyken normal write_fifo task'i cagirildi");
            end else begin
                @(negedge clk);
                data_in = write_data;
                wr_en   = 1'b1;

                // DUT bu posedge'de veriyi yazar
                @(posedge clk);
                @(negedge clk);

                wr_en = 1'b0;
            end
        end
    endtask

    // FIFO'dan bir veri okuma
    task automatic read_fifo(
        output logic [WIDTH-1:0] read_data
    );
        begin
            if (empty) begin
                $error("FIFO bosken normal read_fifo task'i cagirildi");
                read_data = 'x;
            end else begin
                @(negedge clk);
                rd_en = 1'b1;

                // DUT bu posedge'de data_out'u günceller
                @(posedge clk);
                @(negedge clk);

                read_data = data_out;
                rd_en     = 1'b0;
            end
        end
    endtask

    // Okunan veriyi beklenen veriyle karşılaştırma
    task automatic check_data(
        input logic [WIDTH-1:0] expected_data,
        input logic [WIDTH-1:0] actual_data
    );
        begin
            if (actual_data !== expected_data) begin
                $error(
                    "Data mismatch! Expected=%h, Actual=%h",
                    expected_data,
                    actual_data
                );
            end else begin
                $display(
                    "Data correct: Expected=%h, Actual=%h",
                    expected_data,
                    actual_data
                );
            end
        end
    endtask

    // Aynı clock'ta okuma ve yazma
    task automatic simultaneous_read_write(
        input  logic [WIDTH-1:0] write_data,
        output logic [WIDTH-1:0] read_data
    );
        begin
            if (empty || full) begin
                $error(
                    "Simultaneous test icin FIFO ne bos ne de dolu olmali"
                );
            end else begin
                @(negedge clk);

                data_in = write_data;
                wr_en   = 1'b1;
                rd_en   = 1'b1;

                @(posedge clk);
                @(negedge clk);

                read_data = data_out;

                wr_en = 1'b0;
                rd_en = 1'b0;
            end
        end
    endtask

    initial begin
        rst_n   = 1'b1;
        wr_en   = 1'b0;
        rd_en   = 1'b0;
        data_in = '0;

        // -------------------------------------------------
        // TEST 1: Reset sonrasında empty=1, full=0
        // -------------------------------------------------

        $display("\nTEST 1: Reset kontrolu");

        reset_fifo();

        if (empty !== 1'b1)
            $error("Reset sonrasinda empty=1 olmadi");

        if (full !== 1'b0)
            $error("Reset sonrasinda full=0 olmadi");

        // -------------------------------------------------
        // TEST 2: Tek veri yazma ve okuma
        // -------------------------------------------------

        $display("\nTEST 2: Tek veri yazma/okuma");

        write_fifo(8'hA5);
        read_fifo(received_data);
        check_data(8'hA5, received_data);

        if (empty !== 1'b1)
            $error("Tek veri okunduktan sonra FIFO bos olmadi");

        // -------------------------------------------------
        // TEST 3: FIFO sirasi
        // -------------------------------------------------

        $display("\nTEST 3: FIFO sirasi");

        reset_fifo();

        write_fifo(8'h11);
        write_fifo(8'h22);
        write_fifo(8'h33);

        read_fifo(received_data);
        check_data(8'h11, received_data);

        read_fifo(received_data);
        check_data(8'h22, received_data);

        read_fifo(received_data);
        check_data(8'h33, received_data);

        // -------------------------------------------------
        // TEST 4: FIFO'yu tamamen doldurma
        // -------------------------------------------------

        $display("\nTEST 4: Full kontrolu");

        reset_fifo();

        for (int i = 0; i < DEPTH; i++) begin
            write_fifo(i);
        end

        if (full !== 1'b1)
            $error("DEPTH kadar veri yazilmasina ragmen full=1 olmadi");
        else
            $display("Full testi basarili");

        // -------------------------------------------------
        // TEST 5: Doluyken fazladan yazma
        // -------------------------------------------------

        $display("\nTEST 5: Doluyken yazma engelleme");

        // write_fifo task'ını kullanmıyoruz çünkü full iken
        // yazmayı özellikle denemek istiyoruz.
        @(negedge clk);
        data_in = 8'hEE;
        wr_en   = 1'b1;

        @(posedge clk);
        @(negedge clk);

        wr_en = 1'b0;

        if (full !== 1'b1)
            $error("Gecersiz yazmadan sonra full bozuldu");

        // FIFO'yu boşalt. EE hiçbir zaman çıkmamalı.
        for (int i = 0; i < DEPTH; i++) begin
            read_fifo(received_data);
            check_data(i, received_data);
        end

        // -------------------------------------------------
        // TEST 6: Tamamen boşaltma
        // -------------------------------------------------

        $display("\nTEST 6: Empty kontrolu");

        if (empty !== 1'b1)
            $error("Tum veriler okundugu halde empty=1 olmadi");
        else
            $display("Empty testi basarili");

        // -------------------------------------------------
        // TEST 7: Boşken fazladan okuma
        // -------------------------------------------------

        $display("\nTEST 7: Bosken okuma engelleme");

        previous_data = data_out;

        @(negedge clk);
        rd_en = 1'b1;

        @(posedge clk);
        @(negedge clk);

        rd_en = 1'b0;

        if (empty !== 1'b1)
            $error("Gecersiz okumadan sonra empty bozuldu");

        if (data_out !== previous_data)
            $error("Bosken okuma data_out degerini degistirdi");
        else
            $display("Bosken okuma basariyla engellendi");

        // -------------------------------------------------
        // TEST 8: Aynı anda okuma ve yazma
        // -------------------------------------------------

        $display("\nTEST 8: Ayni anda okuma ve yazma");

        reset_fifo();

        write_fifo(8'hA1);
        write_fifo(8'hB2);

        // A1 okunurken C3 yazılacak
        simultaneous_read_write(8'hC3, received_data);
        check_data(8'hA1, received_data);

        // FIFO'da artık B2 ve C3 olmalı
        read_fifo(received_data);
        check_data(8'hB2, received_data);

        read_fifo(received_data);
        check_data(8'hC3, received_data);

        if (empty !== 1'b1)
            $error("Simultaneous test sonrasinda FIFO bos olmadi");

        $display("\nALL FIFO TESTS PASSED");
        $finish;
    end

    initial begin
        $dumpfile("tb_sync_fifo.vcd");
        $dumpvars(0, tb_sync_fifo);
    end

endmodule