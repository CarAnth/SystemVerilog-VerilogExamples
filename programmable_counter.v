module programmable_counter #(
    parameter WIDTH = 8
)(
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 enable,
    input  wire                 load,
    input  wire [WIDTH-1:0]     load_value,
    input  wire [WIDTH-1:0]     limit_value,
    output reg  [WIDTH-1:0]     count,
    output reg                  limit_pulse
);



always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        count <= {WIDTH{1'b0}};
        limit_pulse <= 1'b0;
    end else begin
        limit_pulse <= 1'b0;
if(load) begin
    count <= load_value;
end
else if(enable) begin
    if(count == limit_value) begin
        count <= 1'b0;
        limit_pulse <= 1'b1;
    end else begin
        count <= count + 1'b1;
        limit_pulse <= 1'b0;
    end
end

end
end
endmodule