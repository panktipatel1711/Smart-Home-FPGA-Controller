// -----------------------------------------------------------------------------
// Module: pwm8
// Description: 8-bit Pulse Width Modulation for Dimming and Fan Speed Control.
// -----------------------------------------------------------------------------
module pwm8 (
    input  wire       clk_i,
    input  wire       reset_n_i,
    input  wire       tick_1k_i,
    input  wire [7:0] target_duty_i,
    output reg        pwm_wave_o
);
    reg [7:0] counter;
    always @(posedge clk_i or negedge reset_n_i) begin
        if (!reset_n_i) begin counter <= 0; pwm_wave_o <= 0; end
        else if (tick_1k_i) begin
            counter <= counter + 1;
            pwm_wave_o <= (counter < target_duty_i);
        end
    end
endmodule
