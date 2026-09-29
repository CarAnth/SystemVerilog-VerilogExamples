module pulse_sync (
    input logic src_clk,
    input logic dst_clk,
    input logic rst_n,
    input logic pulse_in,

    output logic pulse_out
);

logic src_toggle;
logic sync_ff1, sync_ff2, sync_ff2_d;


//source domain
always_ff @( posedge src_clk or negedge rst_n ) begin
    if (!rst_n) begin
        src_toggle <= 1'b0;
    end else if (pulse_in) begin
        src_toggle <= ~src_toggle;
    end
end
//sync domain
always_ff @( posedge dst_clk or negedge rst_n ) begin
    if (!rst_n) begin
        sync_ff1 <= 1'b0;
        sync_ff2 <= 1'b0;
        sync_ff2_d <= 1'b0;
    end else begin
        sync_ff1 <= src_toggle;
        sync_ff2 <= sync_ff1;
        sync_ff2_d <= sync_ff2;
    end
end

assign pulse_out = sync_ff2 ^ sync_ff2_d;



endmodule