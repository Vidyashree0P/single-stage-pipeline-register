`timescale 1ns/1ps

module pipeline_reg #(
    parameter DATA_WIDTH = 8
)(
    input  logic                  clk,
    input  logic                  rst_n,

    input  logic [DATA_WIDTH-1:0] in_data,
    input  logic                  in_valid,
    output logic                  in_ready,

    output logic [DATA_WIDTH-1:0] out_data,
    output logic                  out_valid,
    input  logic                  out_ready
);

    logic [DATA_WIDTH-1:0] data_reg;
    logic valid_reg;

    // connect internal registers to output
    assign out_data  = data_reg;
    assign out_valid = valid_reg;

    // input can be accepted when the register is empty
    // or when the current output is being accepted
    assign in_ready = !valid_reg || out_ready;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_reg  <= '0;
            valid_reg <= 1'b0;
        end
        else begin
            // store new input data
            if (in_valid && in_ready) begin
                data_reg  <= in_data;
                valid_reg <= 1'b1;
            end

            // current data is taken and no new data is coming
            else if (out_valid && out_ready) begin
                valid_reg <= 1'b0;
            end
        end
    end

endmodule
