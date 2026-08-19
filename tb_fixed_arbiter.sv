module tb_fixed_arbiter;
logic [3:0] req;
logic [3:0] grant;

fixed_priority_arbiter uut(
    .req(req),
    .grant(grant)
);


task automatic check_arbiter(
    input logic [3:0] test_req,
    input logic [3:0] expected_grant
);
    begin
        req = test_req;
        #1;

        if (grant !== expected_grant) begin
            $error("ERROR:grant mismatch: expected: %b , actual:%b", expected_grant, grant);

        end else begin
            $display("PASSED");

        end
    end
    
endtask //automatic

initial begin
    check_arbiter(4'b0000, 4'b0000);
        check_arbiter(4'b0001, 4'b0001);
        check_arbiter(4'b0010, 4'b0010);
        check_arbiter(4'b0011, 4'b0001);
        check_arbiter(4'b0100, 4'b0100);
        check_arbiter(4'b0101, 4'b0001);
        check_arbiter(4'b0110, 4'b0010);
        check_arbiter(4'b0111, 4'b0001);
        check_arbiter(4'b1000, 4'b1000);
        check_arbiter(4'b1001, 4'b0001);
        check_arbiter(4'b1010, 4'b0010);
        check_arbiter(4'b1011, 4'b0001);
        check_arbiter(4'b1100, 4'b0100);
        check_arbiter(4'b1101, 4'b0001);
        check_arbiter(4'b1110, 4'b0010);
        check_arbiter(4'b1111, 4'b0001);
    

    $finish;

end
endmodule