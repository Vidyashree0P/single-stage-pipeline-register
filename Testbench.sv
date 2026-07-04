`timescale 1ns/1ps

module tb_pipeline_reg;

    parameter DATA_WIDTH = 8;

    logic clk;
    logic rst_n;

    logic [DATA_WIDTH-1:0] in_data;
    logic                  in_valid;
    logic                  in_ready;

    logic [DATA_WIDTH-1:0] out_data;
    logic                  out_valid;
    logic                  out_ready;

    // instantiate the design
    pipeline_reg #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .in_data   (in_data),
        .in_valid  (in_valid),
        .in_ready  (in_ready),
        .out_data  (out_data),
        .out_valid (out_valid),
        .out_ready (out_ready)
    );

    // clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // task to send one data value
    task send_data(input logic [DATA_WIDTH-1:0] data);
        begin
            @(negedge clk);

            in_data  = data;
            in_valid = 1;

            // wait until the pipeline accepts the data
            while (!in_ready)
                @(posedge clk);

            @(posedge clk);

            @(negedge clk);
            in_valid = 0;
        end
    endtask

    initial begin

        // initial values
        rst_n     = 0;
        in_data   = 0;
        in_valid  = 0;
        out_ready = 0;

        // apply reset
        repeat (2) @(posedge clk);

        @(negedge clk);
        rst_n = 1;

        $display("Reset released");

        // Test 1: normal data transfer
        $display("\nTest 1: Normal transfer");

        out_ready = 0;
        send_data(8'd10);

        #1;

        if (out_valid && out_data == 8'd10)
            $display("PASS: Data 10 stored correctly");
        else
            $error("FAIL: Normal transfer");

        // allow output side to accept data
        @(negedge clk);
        out_ready = 1;

        @(posedge clk);
        #1;

        if (!out_valid)
            $display("PASS: Data consumed correctly");
        else
            $error("FAIL: Data was not consumed");


        // Test 2: backpressure
        $display("\nTest 2: Backpressure");

        @(negedge clk);
        out_ready = 0;

        send_data(8'd25);

        // keep output blocked for three clock cycles
        repeat (3) begin
            @(posedge clk);
            #1;

            if (out_valid && out_data == 8'd25)
                $display("PASS: Data 25 is held");
            else
                $error("FAIL: Data changed during backpressure");
        end

        // release backpressure
        @(negedge clk);
        out_ready = 1;

        @(posedge clk);
        #1;

        if (!out_valid)
            $display("PASS: Data consumed after backpressure");
        else
            $error("FAIL: Data was not consumed");


        // Test 3: consume old data and accept new data
        $display("\nTest 3: Consume and refill");

        @(negedge clk);
        out_ready = 0;

        send_data(8'd40);

        #1;

        if (out_valid && out_data == 8'd40)
            $display("PASS: Data 40 stored");
        else
            $error("FAIL: Data 40 was not stored");

        // consume 40 and send 50 in the same cycle
        @(negedge clk);

        out_ready = 1;
        in_valid  = 1;
        in_data   = 8'd50;

        @(posedge clk);
        #1;

        if (out_valid && out_data == 8'd50)
            $display("PASS: Data 50 replaced data 40");
        else
            $error("FAIL: Refill did not work");

        @(negedge clk);
        in_valid = 0;

        // consume the last value
        @(posedge clk);
        #1;

        if (!out_valid)
            $display("PASS: Pipeline is empty");
        else
            $error("FAIL: Pipeline is not empty");

        $display("\nAll tests completed");

        #10;
        $finish;
    end

endmodule
