// -----------------------------------------------------------------------------
// Module: clk_en
// Description: Synchronous clock enable generator for multi-rate timing.
// -----------------------------------------------------------------------------
module clk_en #(
    parameter integer CLK_HZ  = 50_000_000,
    parameter integer TICK_HZ = 1000
)(
    input  wire clk_i,
    input  wire reset_n_i,
    output reg  tick_o
);
    localparam integer DIVIDER_MAX = CLK_HZ / TICK_HZ;
    reg [$clog2(DIVIDER_MAX)-1:0] internal_counter;

    always @(posedge clk_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            internal_counter <= 0;
            tick_o           <= 1'b0;
        end else begin
            tick_o <= 1'b0;
            if (internal_counter == (DIVIDER_MAX - 1)) begin
                internal_counter <= 0;
                tick_o           <= 1'b1;
            end else begin
                internal_counter <= internal_counter + 1'b1;
            end
        end
    end
endmodule
