module async_fifo #(
    parameter int DATA_WIDTH = 8;
    parameter int ADDR_WIDTH = 3;
    
) (
    input logic wr_clk,
    input logic wr_rst_n,
    input logic wr_en,
    input logic [DATA_WIDTH-1:0] wr_data,
    output logic full,

    input logic rd_clk,
    input logic rd_rst_n,
    input logic rd_en,
    input logic [DATA_WIDTH-1:0] rd_data,
    input logic rd_valid,
    output logic empty
);

localparam int DEPTH = 1 << ADDR_WIDTH;
logic [DATA_WIDTH - 1:0] mem [0:DEPTH - 1];
logic [ADDR_WIDTH:0] wr_bin;
logic [ADDR_WIDTH:0] wr_bin_next;
logic [ADDR_WIDTH:0] wr_gray;
logic [ADDR_WIDTH:0] wr_gray_next;

logic [ADDR_WIDTH:0] rd_bin;
logic [ADDR_WIDTH:0] rd_bin_next;
logic [ADDR_WIDTH:0] rd_gray;
logic [ADDR_WIDTH:0] rd_gray_next;

logic [ADDR_WIDTH:0] rd_gray_sync1;
logic [ADDR_WIDTH:0] rd_gray_sync2;

logic [ADDR_WIDTH:0] wr_gray_sync1;
logic [ADDR_WIDTH:0] wr_gray_sync2;

endmodule