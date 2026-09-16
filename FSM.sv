module sequence_detector_1011 (
    input  logic clk,
    input  logic rst_n,
    input  logic valid,
    input  logic bit_in,
    output logic match
);

typedef enum logic [1:0] {
    IDLE,
    S1,
    S10,
    S101
} state_t;
    state_t current_state, next_state;
    logic detect;

    always_comb begin
        next_state =current_state;
        detect = 1'b0;

        if(valid) begin
            case (current_state)
                IDLE : begin
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
                    detect =1'b0;
                end

            endcase
            
        end
    end

    always_ff @( posedge clk or negedge rst_n ) begin
        if (!rst_n) begin
            current_state <= IDLE;
            match <= 1'b0;
        end else begin
            current_state <= next_state;
            match <= detect;
        end
    end
        
endmodule