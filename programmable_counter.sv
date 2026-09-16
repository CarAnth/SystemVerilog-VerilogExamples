


module programmable_counter #(
    parameter int unsigned WIDTH = 8
)(
    input  logic                 clk,
    input  logic                 rst_n,
    input  logic                 enable,
    input  logic                 load,
    input  logic [WIDTH-1:0]     load_value,
    input  logic [WIDTH-1:0]     limit_value,
    output logic [WIDTH-1:0]     count,
    output logic                  limit_pulse
);


always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        count <= '0;
        limit_pulse <= 1'b0;
    end else begin
        limit_pulse <= 1'b0;
        if(load) begin
            count <= load_value;
        end else if(enable) begin
            if(count == limit_value) begin
                count <= '0;
                limit_pulse <= 1'b1;
            end else begin
                count <= count + 1'b1;
            end
        end
end
end
endmodule