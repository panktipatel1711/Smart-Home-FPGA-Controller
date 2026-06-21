`timescale 1ns/1ps
module home_tb;
    reg clk=0, rst=1, sw_auto=0, pir=0, ldr=0, temp=0, oc=0;
    wire lgt, fan, alm; wire [3:0] rly;

    top dut (clk, rst, sw_auto, pir, ldr, temp, oc, lgt, fan, alm, rly);
    always #10 clk = ~clk;

    initial begin
        $dumpfile("home.vcd"); $dumpvars(0, home_tb);
        #100 rst = 0;
        #200 sw_auto = 1; pir = 1; ldr = 1; // Auto Light ON
        #500 temp = 1; // Fan ON
        #500 oc = 1; // Emergency ALARM
        #1000 $finish;
    end
endmodule
