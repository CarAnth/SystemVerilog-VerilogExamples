module roundrobin (
    input logic clk,
    input logic rst_n,
    input logic [3:0] req,
    output logic [3:0] grant
);
    logic [1:0] last_grant;
    logic [1:0] next_last_grant;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            last_grant <= 2'd3;

        end else begin
            last_grant <= next_last_grant;
            
        end
    end

    always_comb begin
        grant           = 4'b0000;
        next_last_grant = last_grant;
        case (last_grant)
            2'd0: begin
                if(req[1]) begin
                grant = 4'b0010;
                end else if (req[2]) begin
                grant = 4'b0100;
                end else if (req[3]) begin
                grant = 4'b1000;
                end else if (req[0]) begin
                    grant = 4'b0001;
                end
            end

            2'd1: begin
                if (req[2]) begin
                    grant = 4'b0100;
                end else if (req[3]) begin
                    grant = 4'b1000;
                end else if (req[0]) begin
                    grant = 4'b0001;
                end else if (req[1]) begin 
                    grant = 4'b0010;
                end
            end

            2'd2:begin
                if (req[3]) begin
                    grant = 4'b1000;
                end else if (req[0]) begin
                    grant = 4'b0001;
                end else if (req[1]) begin
                    grant = 4'b0010;
                end else if (req[2]) begin
                    grant = 4'b0100;
                end
            end


            2'd3:begin
                if (req[0]) begin
                    grant = 4'b0001;
                end else if (req[1]) begin
                    grant = 4'b0010;
                end else if (req[2]) begin
                    grant = 4'b0100;
                end else if (req[3]) begin
                    grant = 4'b1000;
                end
            end

            default: begin
                grant = 4'b0000;
                next_last_grant = 2'd3;
            end
        endcase

        case (grant)
            4'b0001: next_last_grant = 2'd0;
            4'b0010: next_last_grant = 2'd1;
            4'b0100: next_last_grant = 2'd2;
            4'b1000: next_last_grant = 2'd3;
            default: next_last_grant = last_grant;
        endcase

        
    end
endmodule