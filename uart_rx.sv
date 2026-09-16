module uart_rx #(
    parameter int CLK_PER_BIT = 4
) (
    input logic clk,
    input logic rst_n,
    input logic rx,

    output logic [7:0] data_out,
    output logic data_valid
);

typedef enum logic[1:0] { 
    IDLE,
    START,
    DATA,
    STOP
} state_t;
    state_t current_state, next_state;


logic [7:0] data_reg;
logic [1:0] baud_counter;
logic [2:0] bit_index;

always_comb begin
    next_state = current_state;
    case (current_state)
        IDLE: begin
            if (rx==1'b0) begin
                next_state = START;
            end
        end

        START: begin
          if (baud_counter == (CLK_PER_BIT/2)-1) begin
            if (rx==1'b0) begin
                next_state = DATA;
            end else begin
                next_state = IDLE;
            end
          end
        end

        DATA:begin
            
            if ((baud_counter==CLK_PER_BIT-1)&&(bit_index ==3'd7)) begin
                next_state = STOP;
            end
            
        end

        STOP:begin
            if (baud_counter==CLK_PER_BIT-1) begin
                next_state = IDLE;
            end

        end
        default: next_state = IDLE;
    endcase
    
end

always_ff @( posedge clk or negedge rst_n ) begin
    if (!rst_n) begin
        current_state <= IDLE;
        data_reg      <= 8'b0;
        baud_counter  <= 2'b0;
        bit_index     <= 3'b0;
        data_valid    <= 1'b0;
        data_out      <= 8'b0;

    end else begin
        current_state <= next_state;
        case (current_state)
            IDLE: begin
                baud_counter <= 2'b0;
                data_valid <= 1'b0;
            end

            START:begin
                if (baud_counter==(CLK_PER_BIT/2)-1) begin
                    baud_counter <= 2'b0;
                end else begin
                    baud_counter <= baud_counter + 1'b1;
                end
            end

            DATA: begin
                if (baud_counter == CLK_PER_BIT-1) begin
                    baud_counter <= 2'b0;
                    data_reg[bit_index] <= rx;
                    if (bit_index == 3'd7)
                        bit_index <= 3'b0;
                    else
                        bit_index <= bit_index +1'b1;
                end else begin
                    baud_counter <= baud_counter + 1'b1;
                end
            end


            STOP: begin
            if (baud_counter == CLK_PER_BIT-1) begin
            baud_counter <= 2'b0;

            if (rx == 1'b1) begin
                data_out   <= data_reg;
                data_valid <= 1'b1;
            end
            end else begin
                baud_counter <= baud_counter + 1'b1;
            end
        end
            default:begin
                baud_counter <= 2'b0;
                bit_index    <= 3'b0;    
            end
            

        endcase
        
    end
end

    
endmodule