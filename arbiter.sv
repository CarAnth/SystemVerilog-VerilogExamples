module fixed_priority_arbiter (
    input logic [3:0] req,
    output logic [3:0] grant
);

always_comb begin
    grant = 4'b0000;

    if (req[0]) begin
        grant = 4'b0001;
    end else if(req[1]) begin
        grant = 4'b0010;
    end else if (req[2]) begin
        grant = 4'b0100;
    end else if (req[3]) begin
        grant = 4'b1000;
    end

end
endmodule