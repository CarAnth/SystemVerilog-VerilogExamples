module async_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int ADDR_WIDTH = 3
    
) (
    input logic wr_clk,
    input logic wr_rst_n,
    input logic wr_en,
    input logic [DATA_WIDTH-1:0] wr_data,
    output logic full,

    input logic rd_clk,
    input logic rd_rst_n,
    input logic rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic rd_valid,
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
logic wr_fire;
logic rd_fire;
logic full_next;
logic empty_next;

assign wr_fire = wr_en && !full; //indicates that we can really write
assign rd_fire = rd_en && !empty;

always_comb begin
    wr_bin_next = wr_bin;

    if (wr_fire) begin
        wr_bin_next = wr_bin + 1'b1;
    end

    //calculate the gray code equivalent for the new pointer 
    wr_gray_next =(wr_bin_next >> 1) ^ wr_bin_next;
    full_next =(wr_gray_next =={~rd_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1], rd_gray_sync2[ADDR_WIDTH-2:0]}); 
end

/*
Write domanin
*/
always_ff @( posedge wr_clk or negedge wr_rst_n ) begin
    if (!wr_rst_n) begin
        wr_bin <= '0;
        wr_gray <= '0;
        full <= '0;
    end else begin
        wr_bin <= wr_bin_next;
        wr_gray <= wr_gray_next;
        full <= full_next;
    end
end

always_ff @(posedge wr_clk) begin
    if (wr_fire) begin
        mem[wr_bin[ADDR_WIDTH-1:0]] <= wr_data;
    end
end 

//read pointers to the write domain 
always_ff @(posedge wr_clk or negedge wr_rst_n )begin
    if (!wr_rst_n) begin
        rd_gray_sync1 <= '0;
        rd_gray_sync2 <= '0;
    end else begin
        rd_gray_sync1 <= rd_gray;
        rd_gray_sync2 <= rd_gray_sync1;
    end
end

/*
Read Domain
*/
always_comb begin
    rd_bin_next = rd_bin;

    if (rd_fire) begin
        rd_bin_next = rd_bin + 1'b1;
    end  
    rd_gray_next = (rd_bin_next >> 1) ^ rd_bin_next; 
    empty_next = (rd_gray_next == wr_gray_sync2);   
end


always_ff @( posedge rd_clk or rd_rst_n ) begin
    if (!rd_rst_n) begin
        rd_bin  <= '0;
        rd_gray <= '0;
        empty   <=1'b1;

    end else begin
        rd_bin <= rd_bin_next;
        rd_gray <= rd_gray_next;
        empty <= empty_next;

    end
end

always_ff @(posedge rd_clk or negedge rd_rst_n ) begin
    if (!rd_rst_n) begin
        rd_data <= '0;
        rd_valid <= 1'b0;

    end else begin
      rd_valid <= 1'b0;  
      if (rd_fire) begin
            rd_data <= mem[rd_bin[ADDR_WIDTH-1:0]];
            rd_valid <= 1'b1;
        end
    end
end

always_ff @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        wr_gray_sync1 <= '0;
        wr_gray_sync2 <= '0;
    end else begin
        wr_gray_sync1 <= wr_gray;
        wr_gray_sync2 <= wr_gray_sync1 ;
    end
end



endmodule