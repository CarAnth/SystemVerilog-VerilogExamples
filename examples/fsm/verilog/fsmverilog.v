module sequence_detector (
    input wire clk,
    input wire rst_n,
    input wire valid,
    input wire bit_in,
    output reg match
);

localparam [1:0]   IDLE=2'b00,
                   S1=2'b01,
                   S10=2'b10,
                   S101=2'b11;

reg [1:0] current_state;
reg [1:0] next_state;
reg       detect;

always @(*) begin
    next_state = current_state;
    detect = 1'b0;
    if (valid) begin
    case (current_state)
        IDLE: begin
            if (bit_in) begin
                next_state = S1;
            end else begin
                next_state = IDLE;
            end
        end 
        S1:begin
                if (bit_in) begin
                        next_state = S1;
                end else begin
                        next_state = S10;
                end
            end

        S10:begin
                if (bit_in) begin
                    next_state = S101;
                end else begin
                    next_state = IDLE;
                end
            end
        S101:begin
                if(bit_in) begin
                    detect = 1'b1;
                    next_state = S1;
                end else begin
                    next_state = S10;
                end
            end
        default: begin
            next_state = IDLE;
            detect = 1'b0;
        end

    endcase
end

end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
            current_state <= IDLE;
            match <= 1'b0;
        end else begin
            current_state <= next_state;
            match <= detect;
        end
end


    
endmodule


