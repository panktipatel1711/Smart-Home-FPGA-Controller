// -----------------------------------------------------------------------------
// Module: debounce
// Description: Double-stage synchronization and noise filtering for physical inputs.
// -----------------------------------------------------------------------------
module debounce #(
    parameter integer DEBOUNCE_LIMIT = 5
)(
    input  wire clk_i,
    input  wire reset_n_i,
    input  wire tick_i,
    input  wire raw_signal_i,
    output reg  filtered_level_o,
    output reg  edge_pulse_o
);
    reg sync_0, sync_1;
    always @(posedge clk_i) begin
        sync_0 <= raw_signal_i;
        sync_1 <= sync_0;
    end

    reg [$clog2(DEBOUNCE_LIMIT+1)-1:0] counter;
    reg stable_state;

    always @(posedge clk_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            counter <= 0; stable_state <= 0; filtered_level_o <= 0; edge_pulse_o <= 0;
        end else begin
            edge_pulse_o <= 0;
            if (tick_i) begin
                if (sync_1 != stable_state) begin
                    counter <= counter + 1;
                    if (counter == DEBOUNCE_LIMIT) begin
                        stable_state <= sync_1;
                        counter <= 0;
                    end
                end else counter <= 0;

                if (stable_state && !filtered_level_o) begin
                    filtered_level_o <= 1; edge_pulse_o <= 1;
                end else if (!stable_state) filtered_level_o <= 0;
            end
        end
    end
endmodule
