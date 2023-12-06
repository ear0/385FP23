module complementer_tb();
    
    timeunit 1ns;
    timeprecision 1ns;
    
    logic Clk;
    logic Clk_441;
    logic Reset; 
    
    //lutsine
    logic sine_cos_lut_valid;
    logic [15:0] sine_cos_out;
    logic [21:0] tune_in_dds;
    logic tune_valid_dds;
    
    //lfo_mod_sine
    logic [15:0] m_axis_data_tdata;
    logic m_axis_data_tvalid;
    logic [21:0] s_axis_config_tdata;
    logic s_axis_config_tvalid;
    
    //complementer
    logic [15:0] signed_mag_in;
    logic [15:0] twos_comp_out;
    assign signed_mag_in = sine_cos_out;
    
    
    //general
    logic [21:0] frequency_word;
    assign tune_in_dds = frequency_word;
    assign s_axis_config_tdata = frequency_word;
    logic gate_tvalid;
    assign tune_valid_dds = gate_tvalid;
    assign s_axis_config_tvalid = gate_tvalid;
    
    //pwms
    logic pwm_twoscomp;
    logic pwm_lfo;
    logic pwm_lutsine;
    logic pwm_old_out_lfo;
    logic sw_pwm_scale;
    
    //gate/outputs
    logic [15:0] lutsine_out, lfo_mod_out;
    
    //sine2square
    logic [15:0] square_out;
    logic pwm_square;
    
    //triangle
    logic [15:0] tri_out, tri_mux_out;
    logic pwm_tri;
    
    always begin: CLOCK_GENERATION
        #5 Clk = ~Clk;
    end
    
    initial begin: CLOCK_INITIALIZATION
        Clk = 0;
    end

    Clock_divider2 cd_complement(.clock_in(Clk),
                                 .en_441(1'b1),
                                 .Reset(Reset),
                                 .clock_out(Clk_441),
                                 .frequency_word());
    //signed mag output -> NOW TWOS COMP (allegedly) //OSC
    lutsine_ddsblock comp_lutsine_ddsblock(.Clk(Clk_441),
                                           .sine_cos_lut_valid(sine_cos_lut_valid), //o valid
                                           .sine_cos_out(sine_cos_out), //o //data
                                           .tune_in_dds(tune_in_dds), //i //config_data
                                           .tune_valid_dds(tune_valid_dds)); //i //config_valid
    //twos comp output
    lfo_mod_sine comp_lfo_mod_sine(.Clk(Clk_441),
                                   .m_axis_data_tdata(m_axis_data_tdata), //o
                                   .m_axis_data_tvalid(m_axis_data_tvalid), //o
                                   .s_axis_config_tdata(s_axis_config_tdata), //i
                                   .s_axis_config_tvalid(s_axis_config_tvalid)); //i     
    
    complementer comp(.signed_mag_in(signed_mag_in), .twos_comp_out(twos_comp_out));                                                              
    
    pwm comp_out_test(.clk(Clk), .rst(Reset), .dty(twos_comp_out), .pwm(pwm_twoscomp), .gate_tvalid, .SW_pwm_scale(1), .waveform_sel(2'b00));
    
    pwm lutsine_out_test(.clk(Clk), .rst(Reset), .dty(lutsine_out), .pwm(pwm_lutsine), .gate_tvalid, .SW_pwm_scale(1), .waveform_sel(2'b00));
    
    pwm lfo_out_test(.clk(Clk), .rst(Reset), .dty(lfo_mod_out), .pwm(pwm_lfo), .gate_tvalid, .SW_pwm_scale(1), .waveform_sel(2'b00));
    
    TriangleWaveGenerator tg_test(.Clk(Clk_441), .Reset(Reset), .tuning_word(frequency_word), .triangle(tri_out));
    
    pwm tri_out_test(.clk(Clk), .rst(Reset), .dty(tri_out), .pwm(pwm_tri), .gate_tvalid, .SW_pwm_scale(SW_pwm_scale), .waveform_sel(2'b00));
    
    //sine2square sqout(.Clk(Clk_441), .sine_in(sine_cos_out), .sq_out(square_out));
    
    //pwm sq_out_test(.clk(Clk), .rst(Reset), .dty(square_out), .pwm(pwm_square), .gate_tvalid);
    
    //pwm_old pwm_old_lfo(.clk(Clk), .rst(Reset), .dty(lfo_mod_out), .pwm(pwm_old_out_lfo));
    
    test_outmux tmu(.*);
    
    initial begin: TEST_VECTORS
        Reset = 1;
        gate_tvalid = 0;
        sw_pwm_scale = 1;
        #10
        Reset = 0;
        frequency_word = 22'hFFFF; //1048575*44100/(2^22) = 11.024 kHz
        #10
        gate_tvalid = 1;
//        #1000
//        gate_tvalid = 1;
//        #100000
//        gate_tvalid = 1;
    end

endmodule

module test_outmux(input logic [15:0] m_axis_data_tdata, sine_cos_out, //tri_out, 
                   input logic gate_tvalid, 
                   output logic [15:0] lfo_mod_out, lutsine_out //, tri_mux_out
                   );
                   
    always_comb begin
        unique case(gate_tvalid)
            1'b0: begin 
                  lfo_mod_out = 0;
                  lutsine_out = 0;
                  //tri_mux_out = 0;
                  end
            1'b1: begin
                  lfo_mod_out = m_axis_data_tdata;
                  lutsine_out = sine_cos_out;
                  //tri_mux_out = tri_out;
                  end
        endcase
    end
                        
endmodule
