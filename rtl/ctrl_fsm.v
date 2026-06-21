// -----------------------------------------------------------------------------
// Module: ctrl_fsm
// Description: Core Finite State Machine (FSM) for Mode Management & Safety.
// -----------------------------------------------------------------------------
module ctrl_fsm (
    input  wire       clk_i, reset_n_i,
    input  wire       mode_auto_i, mode_saving_i,
    input  wire       sensor_pir_i, sensor_ldr_i, sensor_temp_i,
    input  wire       fault_oc_i, alarm_door_i,
    input  wire [7:0] man_light_i, man_fan_i,
    input  wire [3:0] man_sockets_i,
    input  wire [7:0] scn_light_i, scn_fan_i,
    input  wire [3:0] scn_sockets_i,
    output reg  [7:0] drv_light_o, drv_fan_o,
    output reg  [3:0] drv_sockets_o,
    output reg        alarm_o,
    output reg  [1:0] state_o
);
    localparam S_MANUAL = 2'b00, S_AUTO = 2'b01, S_ALARM = 2'b10, S_SAVING = 2'b11;
    reg [1:0] state, next_state;

    always @(posedge clk_i or negedge reset_n_i)
        if (!reset_n_i) state <= S_MANUAL; else state <= next_state;

    always @(*) begin
        next_state = state;
        if (fault_oc_i || alarm_door_i) next_state = S_ALARM;
        else begin
            case(state)
                S_MANUAL: if (mode_auto_i) next_state = S_AUTO;
                S_AUTO:   if (!mode_auto_i) next_state = S_MANUAL;
                S_ALARM:  next_state = S_ALARM; // Terminal until reset
                default:  next_state = S_MANUAL;
            endcase
        end
    end

    always @(*) begin
        drv_light_o = 0; drv_fan_o = 0; drv_sockets_o = 0; alarm_o = 0; state_o = state;
        case(state)
            S_MANUAL: begin drv_light_o = man_light_i; drv_fan_o = man_fan_i; drv_sockets_o = man_sockets_i; end
            S_AUTO:   begin 
                drv_light_o = (sensor_pir_i && sensor_ldr_i) ? 8'd150 : 8'd0;
                drv_fan_o   = (sensor_temp_i) ? 8'd220 : 8'd0;
                drv_sockets_o = scn_sockets_i;
            end
            S_ALARM:  begin alarm_o = 1; end
        endcase
    end
endmodule
