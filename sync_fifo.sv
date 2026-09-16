module sync_fifo #(
    parameter int unsigned WIDTH = 8,
    parameter int unsigned DEPTH = 8
) (
    input logic              clk,
    input logic              rst_n,
    input logic              wr_en,
    input logic              rd_en,
    input logic [WIDTH-1:0]  data_in,

    output logic [WIDTH-1:0] data_out,
    output logic             full,
    output logic             empty
);
    localparam int PTR_WIDTH   = $clog2(DEPTH);
    localparam int COUNT_WIDTH = $clog2(DEPTH + 1);
    logic [WIDTH-1:0] memory [0:DEPTH-1];
    logic [PTR_WIDTH-1:0] write_ptr;
    logic [PTR_WIDTH-1:0] read_ptr;
    logic [COUNT_WIDTH-1:0] count;


    assign full = (count==DEPTH);
    assign empty = (count==0);

    always_ff @(posedge clk or negedge rst_n ) begin

        if (!rst_n) begin
           write_ptr <='0;
           read_ptr  <='0;
           count     <='0;
           data_out  <= '0; 
        end else begin
            if (wr_en && !full) begin
                memory[write_ptr] <= data_in;
                write_ptr <= write_ptr + 1'b1;
            end
            if (rd_en && !empty) begin
                data_out <= memory[read_ptr];
                read_ptr <= read_ptr + 1'b1;
            end
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                2'b11: count <= count;
                2'b00: count <= count;
            endcase
            
        end


    end
endmodule