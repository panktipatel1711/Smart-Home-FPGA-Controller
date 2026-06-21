// -----------------------------------------------------------------------------
// Module: scenes
// Description: Memory block for environment preset configurations.
// -----------------------------------------------------------------------------
module scenes (
    input  wire [2:0] scene_index_i,
    output reg  [7:0] light_0_duty_o,
    output reg  [7:0] fan_0_duty_o,
    output reg  [3:0] socket_relays_o
);
    always @(*) begin
        case (scene_index_i)
            3'd0: begin light_0_duty_o = 8'd0;   fan_0_duty_o = 8'd0;   socket_relays_o = 4'b0000; end // ALL OFF
            3'd1: begin light_0_duty_o = 8'd45;  fan_0_duty_o = 8'd80;  socket_relays_o = 4'b0001; end // ECO
            3'd2: begin light_0_duty_o = 8'd255; fan_0_duty_o = 8'd240; socket_relays_o = 4'b1111; end // FULL
            default: begin light_0_duty_o = 0; fan_0_duty_o = 0; socket_relays_o = 0; end
        endcase
    end
endmodule
