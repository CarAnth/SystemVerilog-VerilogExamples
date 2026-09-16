module tb_roundrobin;

logic clk;
logic rst_n;
logic [3:0] req;
logic [3:0] grant;

roundrobin uut(
    .clk(clk),
    .rst_n(rst_n),
    .req(req),
    .grant(grant)
);

task automatic req_check(
    input logic expected_req
);
    
endtask //automatic

initial begin
    clk=0;
    forever #5 clk=~clk;
end
task automatic check_arbiter(
    input logic [3:0] test_req,
    input logic [3:0] expected_grant 
);
    begin
        @(negedge clk);
        req = test_req;
        #1;

        if (!grant==expected_grant) begin
            $error("TEST FAILED. req:%b, expected:%b ,grant%b",
            req,expected_grant, grant);
        end else begin
            $display("TEST PASSED. req:%b, expected:%b ,grant%b",
            req,expected_grant, grant);
    
    end

        if (!$onehot0(grant)) begin
            $error("Birden fazla grant aktif.");
        end

        if ((grant & req) !== grant ) begin
            $error("Istek yapmayan requester grant aldi");
        end

        @(posedge clk);
        #1;


    end


    
endtask //automatic

task automatic apply_reset;
    begin
        rst_n=1'b0;
        req=4'b0000;

        repeat(2) @(posedge clk);

        @(negedge clk);

        rst_n = 1'b1;

    
    end
    
endtask //automatic
initial begin
    rst_n=1'b0;
    req=4'b0000;
    //Reset check
    apply_reset();
    check_arbiter(4'b0000, 4'b0000);
    //Single requests

    check_arbiter(4'b0001,4'b0001);
    check_arbiter(4'b0010,4'b0010);
    check_arbiter(4'b0100,4'b0100);
    check_arbiter(4'b1000,4'b1000);
    //All requests are active
    apply_reset();
    
    check_arbiter(4'b1111,4'b0001);
    check_arbiter(4'b1111,4'b0010);
    check_arbiter(4'b1111,4'b0100);
    check_arbiter(4'b1111,4'b1000);
    check_arbiter(4'b1111,4'b0001);
    //req0 and req2
    apply_reset();

    check_arbiter(4'b0101, 4'b0001);
    check_arbiter(4'b0101, 4'b0100);
    check_arbiter(4'b0101, 4'b0001);
    check_arbiter(4'b0101, 4'b0100);
    
    apply_reset();


    check_arbiter(4'b1111, 4'b0001);

  
    check_arbiter(4'b0000, 4'b0000);
    check_arbiter(4'b0000, 4'b0000);

  
    check_arbiter(4'b1111, 4'b0010);

    $display("ALL ROUND-ROBIN ARBITER TESTS PASSED");
    $finish;


end
    

endmodule