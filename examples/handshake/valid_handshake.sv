module valid_handshake (
    input logic clk,
    input logic rst_n,
    input logic in_valid,
    input logic [7:0] in_data,
    input logic out_ready,

    output logic in_ready,
    output logic out_valid,
    output logic [7:0] out_data

);
logic [7:0] data_reg;
logic full_reg;
logic push;
logic pop;


always_comb begin
    out_data = data_reg;
    out_valid = full_reg;
    in_ready = !full_reg || out_ready;
end
assign push = in_valid && in_ready;
assign pop = out_valid && out_ready;

always_ff @(posedge clk or negedge rst_n ) begin
    if (!rst_n) begin
        data_reg <= 8'b00000000;
        full_reg <= 1'b0;
    end else if (push == 1'b1 && pop == 1'b0) begin
        data_reg <= in_data;
        full_reg <= 1'b1;
    end else if (push == 1'b0 && pop == 1'b1) begin
        full_reg <= 1'b0;
    end else if (push == 1'b1 && pop == 1'b1) begin
        data_reg <= in_data;
        full_reg <= 1'b1;
    end
        
end
    
endmodule