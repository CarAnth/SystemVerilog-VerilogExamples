module multi_cdc (
    input  logic         src_clk,
    input  logic         dst_clk,
    input  logic         rst_n,

    input  logic [7:0]   src_data,
    input  logic         src_valid,
    output logic         src_busy,

    output logic [7:0]   dst_data,
    output logic         dst_valid
);

    logic [7:0] data_hold;
    logic req_toggle;

    logic req_ff1;
    logic req_ff2;
    logic req_sync_d;

    logic ack_toggle;
    logic ack_ff1;
    logic ack_ff2;

    logic src_rst_n;
    logic dst_rst_n;

    reset_synchronizer src_reset_sync(
        .clk            (src_clk),
        .async_rst_n    (rst_n),
        .sync_rst_n     (src_rst_n)
    );

    
    reset_synchronizer dst_reset_sync(
        .clk            (dst_clk),
        .async_rst_n    (rst_n),
        .sync_rst_n     (dst_rst_n)
    );

    
    assign src_busy = req_toggle ^ ack_ff2;



    //source register
    always_ff @( posedge src_clk or negedge src_rst_n ) begin
        if (!src_rst_n) begin
            data_hold   <= 8'b00000000;
            req_toggle  <= 1'b0; 
        end else begin
            if (src_valid && !src_busy) begin
                data_hold <= src_data;
                req_toggle <= ~req_toggle;
            end
        end
    end

    always_ff @( posedge dst_clk or negedge dst_rst_n ) begin
        if (!dst_rst_n) begin
            req_ff1 <= '0;
            req_ff2 <= '0;
        end else begin
            req_ff1 <= req_toggle;
            req_ff2 <= req_ff1;
        end
    end

    always_ff @(posedge dst_clk or negedge dst_rst_n) begin 
       if (!dst_rst_n) begin
            req_sync_d  <= 1'b0;
            dst_valid   <= 1'b0;
            ack_toggle  <= 1'b0;
            dst_data    <= 1'b0;
       end else begin
        req_sync_d <= req_ff2;

        dst_valid <= 1'b0;

        if (req_ff2 != req_sync_d) begin

            dst_data <= data_hold;
            dst_valid <= req_sync_d ^ req_ff2;
            ack_toggle <= req_ff2;
        end   

        end

    end


    always_ff @( posedge src_clk or negedge src_rst_n ) begin
        if (!src_rst_n) begin
            ack_ff1 <=1'b0;
            ack_ff2 <=1'b0;
        end else begin
            ack_ff1 <=ack_toggle;
            ack_ff2 <=ack_ff1;
        end
    end
   
endmodule

