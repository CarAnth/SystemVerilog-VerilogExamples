module uart_tx #(
    parameter int CLKS_PER_BITS =4
)(
    input logic clk,
    input logic rst_n,
    input logic start,
    input logic [7:0] data_in,
    
    output logic tx,
    output logic busy,
    output logic done
);

typedef enum logic [1:0] { 
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
        tx= 1'b1;
        busy = 1'b0;

        case (current_state)
            IDLE: begin
              tx = 1'b1;
              busy = 1'b0;

              if (start) begin
                next_state = START;
              end
                
            end
            START: begin
                tx=1'b0;
                busy=1'b1;
                if (baud_counter == CLKS_PER_BITS-1) begin
                    next_state = DATA;
                end
               
            end

            DATA: begin
                tx= data_reg[bit_index];
                busy =1'b1;
                if ((baud_counter == CLKS_PER_BITS-1)&&(bit_index == 3'd7)) begin
                    next_state = STOP;
        
                end
                
                
            end

            STOP: begin
                tx = 1'b1;
                busy = 1'b1;

                if (baud_counter == CLKS_PER_BITS-1) begin
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
            done          <= 1'b0;
        end else begin
            current_state <= next_state;
            done <= 1'b0;
        case (current_state)
            IDLE: begin
                baud_counter <=2'b0;
                bit_index <= 3'b0;
                if (start) begin
                    data_reg <= data_in;
                end
            end

            START: begin
                if (baud_counter == CLKS_PER_BITS-1) begin
                    baud_counter <= 2'b0;
                end else begin
                    baud_counter <= baud_counter + 1'b1;
                end
            end

            DATA: begin
                if (baud_counter == CLKS_PER_BITS-1) begin
                    baud_counter <= 2'b0;
                    if (bit_index == 3'd7)
                        bit_index <= 3'b0;
                    else
                        bit_index <= bit_index +1'b1;
                end else begin
                    baud_counter <= baud_counter + 1'b1;

                end

            end

            STOP: begin
                if (baud_counter == CLKS_PER_BITS-1) begin
                    baud_counter <= 2'b0;
                    done <= 1'b1;
                end else begin
                    baud_counter <= baud_counter + 1'b1;
                end
                
            end

            default: begin
               baud_counter <=2'b0;
               bit_index <= 3'b0; 
            end 
        endcase
    end
    end

    
endmodule