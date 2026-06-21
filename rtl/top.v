// -----------------------------------------------------------------------------
// Module: top
// Description: Top-level Integration of FPGA Smart Home Controller.
// -----------------------------------------------------------------------------
module top (
    input  wire clk_50m_i, reset_btn_i,
    input  wire sw_auto_i, sns_pir_i, sns_ldr_i, sns_temp_i, flt_oc_i,
    output wire out_pwm_light, out_pwm_fan, out_alarm,
    output wire [3:0] out_relays
);
    wire rst_n = ~reset_btn_i;
    wire t1k, t10;
    
    clk_en #(.TICK_HZ(1000)) u_t1k (.clk_i(clk_50m_i), .reset_n_i(rst_n), .tick_o(t1k));
    clk_en #(.TICK_HZ(10))   u_t10 (.clk_i(clk_50m_i), .reset_n_i(rst_n), .tick_o(t10));

    wire c_pir, c_ldr, c_temp, c_oc;
    debounce u_db1 (.clk_i(clk_50m_i), .reset_n_i(rst_n), .tick_i(t10), .raw_signal_i(sns_pir_i),  .filtered_level_o(c_pir));
    debounce u_db2 (.clk_i(clk_50m_i), .reset_n_i(rst_n), .tick_i(t10), .raw_signal_i(sns_ldr_i),  .filtered_level_o(c_ldr));
    debounce u_db3 (.clk_i(clk_50m_i), .reset_n_i(rst_n), .tick_i(t10), .raw_signal_i(sns_temp_i), .filtered_level_o(c_temp));
    debounce u_db4 (.clk_i(clk_50m_i), .reset_n_i(rst_n), .tick_i(t10), .raw_signal_i(flt_oc_i),   .filtered_level_o(c_oc));

    wire [7:0] d_l, d_f;
    ctrl_fsm u_core (
        .clk_i(clk_50m_i), .reset_n_i(rst_n), .mode_auto_i(sw_auto_i),
        .sensor_pir_i(c_pir), .sensor_ldr_i(c_ldr), .sensor_temp_i(c_temp), .fault_oc_i(c_oc),
        .drv_light_o(d_l), .drv_fan_o(d_f), .drv_sockets_o(out_relays), .alarm_o(out_alarm)
    );

    pwm8 u_p1 (.clk_i(clk_50m_i), .reset_n_i(rst_n), .tick_1k_i(t1k), .target_duty_i(d_l), .pwm_wave_o(out_pwm_light));
    pwm8 u_p2 (.clk_i(clk_50m_i), .reset_n_i(rst_n), .tick_1k_i(t1k), .target_duty_i(d_f), .pwm_wave_o(out_pwm_fan));

endmodule
