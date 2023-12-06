module osc_hw_test_top(input logic Clk, 
                       input logic [15:0] SW,
                       input logic Reset, Trig,
                       output logic audio_outL,
                       output logic audio_outR,
                       output logic [15:0] test_audio);
                       
    logic Reset_SH, Trig_SH;
    logic [15:0] SW_SH;
    logic [15:0] saw_out;
    logic audio_out;
    logic sample_clk_out;
    sync sw_sync [15:0] (.Clk(Clk), .d(SW), .q(SW_SH));
    sync button_sync [1:0] (Clk, {Reset, Trig}, {Reset_SH, Trig_SH});
    
    assign audio_outL = audio_out;
    assign audio_outR = audio_out;
    
endmodule
