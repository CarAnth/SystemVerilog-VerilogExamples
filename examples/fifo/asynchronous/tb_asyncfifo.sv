module tb_async_fifo;
localparam int DATA_WIDTH;
localparam int ADDR_WIDTH;

logic wr_clk;
logic wr_rst_n;
logic wr_en;
logic [DATA_WIDTH-1:0] wr_data;
logic full;

logic rd_clk;
logic rd_rst_n;
logic rd_en;
logic [DATA_WIDTH-1:0] rd_data;
logic rd_valid;
logic empty;

async_fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) dut (
    .wr_clk     (wr_clk),
    .wr_rst_n   (wr_rst_n),
    .wr_en      (wr_en),
    .wr_data    (wr_data),
    .full       (full),
    .rd_clk     (rd_clk),
    .rd_rst_n   (rd_rst_n),
    .rd_en      (rd_en),
    .rd_data    (rd_data),
    .rd_valid   (rd_valid),
    .empty      (empty)
);

initial begin
    wr_clk = 1'b0;
    rd_clk = 1'b0;

    forever #5 wr_clk = ~wr_clk;
    forever #12 rd_clk = ~rd_clk;
end

    
endmodule