module cdc_handshake (
    input  logic src_clk,
    input  logic dst_clk,
    input  logic rst_n,
    input  logic src_pulse,
    
    output logic src_busy,
    output logic dst_pulse
);

logic req_toggle;

logic req_sync_ff1;
logic req_sync_ff2;
logic req_sync_d;

logic ack_toggle;
logic ack_sync_ff1;
logic ack_sync_ff2;


always_comb begin 
    src_busy = (req_toggle != ack_sync_ff2);    
end

//source req
always_ff @( posedge src_clk or negedge rst_n ) begin
    if (!rst_n) begin
        req_toggle <= 1'b0;
    end else begin
        if (src_pulse && !src_busy) begin
            req_toggle <= ~req_toggle;

        end
    end
end


always_ff @( posedge dst_clk or negedge rst_n ) begin
    if (!rst_n) begin
        req_sync_ff1 <= 1'b0;
        req_sync_ff2 <= 1'b0;
    end else begin
        req_sync_ff1 <= req_toggle;
        req_sync_ff2 <= req_sync_ff1;
    end
end

//transformation ack signal     
    
always_ff @( posedge src_clk or negedge rst_n ) begin
    if (!rst_n) begin
        ack_sync_ff1 <= 1'b0;
        ack_sync_ff2 <= 1'b0;
    end else begin
        ack_sync_ff1 <= ack_toggle;
        ack_sync_ff2 <= ack_sync_ff1;
    end
end

always_ff @( posedge dst_clk or negedge rst_n ) begin
    if (!rst_n) begin
        req_sync_d <= 1'b0;
        dst_pulse <= 1'b0;
        ack_toggle <= 1'b0;
    end else begin
        req_sync_d <= req_sync_ff2;
        dst_pulse <= req_sync_d ^ req_sync_ff2;

        if (req_sync_d ^ req_sync_ff2) begin
            ack_toggle <= req_sync_ff2;
        end
    end
end


endmodule