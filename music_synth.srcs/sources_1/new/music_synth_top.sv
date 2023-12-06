module music_synth_top  
                    #(parameter DATA_BITWIDTH = 16, parameter PHASE_ACC_WIDTH = 22)
                    (input logic Clk,
                    input logic Reset, //btn0
                    input logic [1:0] SW_lfo, //select LFO waveform (2'b00-2'b11), sw0-sw1
                    input logic [1:0] SW_osc, //select OSC waveform (2'b00-2'b11), sw2-sw3
                    input logic SW_filt_bp, but_filt_sel_up, but_filt_sel_dn, //btn1-btn2, sw4
                    input logic [3:0] SW_lfo_scale, // switches to generate LFO amplitude divisor (affects modulation) //SW15, SW14, SW13, SW12
                    input logic SW_pwm_scaler, //a6 sw11
                    input logic but_inc_adsr, //h2 btn3
                    //input logic en_adsr, //a5 sw10 lowkey not needed if AM is bypassed.
                    input logic [3:0] SW_sel_adsr, //choose whether to select a, d, s, r. SW10, SW9, SW8, SW7. A5 A4 B2 C2
                    input logic SW_AM_bypass, //sw6
                   // input logic [5:0] SW_volume_scaler,
                    //USB signals
                    input logic [0:0] gpio_usb_int_tri_i,
                    output logic gpio_usb_rst_tri_o,
                    input logic usb_spi_miso,
                    output logic usb_spi_mosi,
                    output logic usb_spi_sclk,
                    output logic usb_spi_ss,
                    //UART
                    input logic uart_rtl_0_rxd,
                    output logic uart_rtl_0_txd,
                    output logic audio_outL,
                    output logic audio_outR
                    //audio test
                    ,output logic audio_outLtest //servo0 so i can probe with scope
                    ,output logic audio_outRtest //servo1 so i can probe with scope
                    //hex signals for displaying which filter we are using
                    ,output logic [7:0] hex_seg //filt (left hex)
                    ,output logic [3:0] hex_grid //filt (left hex)
                    ,output logic [7:0] hex_seg_adsr
                    ,output logic [3:0] hex_grid_adsr              
                    );
    
    //volume switches gonna be sw5-sw10
    
    //RESET IS ASYNC RN AND DOES NOT ENTER A SYNCHRONIZER, ASBSOLUTELY LOOK INTO IF THIS WILL BRICK THE DESIGN!!!!!                 
    logic [1:0] lfo_waveform_sel, osc_waveform_sel;
    logic mux_bypass;
    //TEMP
    assign audio_outLtest = audio_outL;
    assign audio_outRtest = audio_outR;
    logic [5:0] filter_sel; //50 coef sets so 6 bits
    logic filter_sel_en;
    assign mux_bypass = 0; //for test
    logic [PHASE_ACC_WIDTH - 1:0] frequency_word_lfo, frequency_word_osc; //
    logic gate_tvalid;
   
    logic [DATA_BITWIDTH - 1:0] lfo_out, osc_out;   
   
    logic [1:0] SW_S_lfo;
    logic [1:0] SW_S_osc;
    logic [31:0] keycode0_gpio, keycode1_gpio;
  
    logic nrst;
    logic reset_ah;
    //logic pwm_o; 
    logic dty; //assign dty to lfo_out for test
    assign reset_ah = Reset;
    assign nrst = ~Reset;
    logic [3:0] SW_S_lfo_scale;
    //assign audio_outL = pwm_o;
    //assign audio_outR = pwm_o;
    logic [15:0] data_in;
    
    logic [15:0] data_out;
    logic SW_filt_bp_S, S_but_filt_sel_up, S_but_filt_sel_dn;
    logic [15:0] mod_word;
    logic [7:0] beta;
    logic SW_S_pwm_scale;
    
    logic clk_441;
    logic [15:0] AM_data_in, AM_data_out;
    logic [3:0] a, d, s, r;
    logic [7:0] amplitude;
    //logic AM_bypass;
    logic [3:0] S_SW_sel_adsr;
    logic S_but_inc_adsr;
    logic SW_S_AM_bypass;                        
    sync sw_sync_lfo [1:0] (.Clk(Clk), 
                           //.Reset(reset_ah), 
                           .d(SW_lfo), 
                           .q(SW_S_lfo));
                        
    sync sw_sync_osc [1:0](.Clk(Clk), 
                         //.Reset(reset_ah), 
                         .d(SW_osc), 
                         .q(SW_S_osc));
    
    sync sw_sync_pwm(.Clk(Clk), .d(SW_pwm_scaler), .q(SW_S_pwm_scale));
                         
    sync filt_bp_SW(.Clk, .d(SW_filt_bp), .q(SW_filt_bp_S)); //derived str8 from SW (gonna be SW4) E1
    
    sync filt_sel_u(.Clk, .d(but_filt_sel_up), .q(S_but_filt_sel_up)); //btn1 J1
    
    sync filt_sel_d(.Clk, .d(but_filt_sel_dn), .q(S_but_filt_sel_dn)); //btn2 G2
    
    sync sw_sync_lfo_scale[3:0] (.Clk(Clk),
                                 .d(SW_lfo_scale), 
                                 .q(SW_S_lfo_scale));
    
    sync sw_sync_adsr_sel[3:0](.Clk(Clk), .d(SW_sel_adsr), .q(S_SW_sel_adsr)); //[3] a [2] d [1] s [0] r
    
    sync but_adsr(.Clk(Clk), .d(but_inc_adsr), .q(S_but_inc_adsr));
    
    sync sw_AM_bp(.Clk(Clk), .d(SW_AM_bypass), .q(SW_S_AM_bypass));
    
    //add logic to display the requested coefficient set on the hex display
    HexDriver hex_filt(.clk(Clk), 
                       .reset(Reset), 
                       .in({4'b0, 4'b0,{1'b0, 1'b0, filter_sel[5:4]}, filter_sel[3:0]}), 
                       .hex_seg(hex_seg), 
                       .hex_grid(hex_grid));
    
    HexDriver hex_adsr(.clk(Clk), 
                       .reset(Reset),
                       .in({a,d,s,r}),
                       .hex_seg(hex_seg_adsr),
                       .hex_grid(hex_grid_adsr));
    
    final_synth_top mb_synth (.clk_100MHz(Clk),
                              .gpio_usb_int_tri_i(gpio_usb_int_tri_i),
                              .gpio_usb_keycode_0_tri_o(keycode0_gpio),
                              .gpio_usb_keycode_1_tri_o(keycode1_gpio),
                              .gpio_usb_rst_tri_o(gpio_usb_rst_tri_o),
                              .reset_rtl_0(nrst),
                              .uart_rtl_0_rxd(uart_rtl_0_rxd),
                              .uart_rtl_0_txd(uart_rtl_0_txd),
                              .usb_spi_miso(usb_spi_miso),
                              .usb_spi_mosi(usb_spi_mosi),
                              .usb_spi_sclk(usb_spi_sclk),
                              .usb_spi_ss(usb_spi_ss)
                              );
    //add volume control
    //assign vol_data_out = data_out / S_n_SW_volume_scaler;
    
    //pdm works well, avoids gate issue.
    pdm_dac pdm_dac_L(.clk(Clk), .Reset(Reset), .din(AM_data_out), .dout(audio_outL), .waveform_sel(SW_S_osc));
    
//    pwm #(.BITS(DATA_BITWIDTH)) pwm_driver_L(.clk(Clk), 
//                                             .rst(reset_ah),
//                                             .gate_tvalid(1), //hardcode to 1 for testing adsr
//                                             .waveform_sel(SW_S_osc),
//                                             .SW_pwm_scale(SW_S_pwm_scale), 
//                                             .dty(AM_data_out), //assigned filter output to duty cycle control
//                                             .pwm(audio_outL));
                                             
    pdm_dac pdm_dac_R(.clk(Clk), .Reset(Reset), .din(AM_data_out), .dout(audio_outR), .waveform_sel(SW_S_osc));
                                                 
//    pwm #(.BITS(DATA_BITWIDTH)) pwm_driver_R(.clk(Clk), 
//                                             .rst(reset_ah),
//                                             .gate_tvalid(1), //hardcode to 1 for testing adsr
//                                             .waveform_sel(SW_S_osc),
//                                             .SW_pwm_scale(SW_S_pwm_scale), 
//                                             .dty(AM_data_out), //assigned filter output to duty cycle control
//                                             .pwm(audio_outR));
                                                                                    
    assign frequency_word_lfo = frequency_word_osc; //if we want this to be a true lfo we should shift fw_osc some
     // assign beta mod index to 5; equivalent to Am*Kp = 5 . we can also parameterize the lfo_out shift
    //changed up sine gen in lfo to be independent of osc. made it so the output is unit circle only.
    //next we will realize an architecture in which lfo is the message signal input to osc.
    
    /*
    REALLY IMPORTANT: BOTH OSCILLATORS ARE NOW UNIT CIRCLE OUTPUTS!!!!!!!
    */
    low_freq_osc lfo(.Clk(Clk),
                     .Reset(reset_ah), 
                     .lfo_waveform_sel(SW_S_lfo), 
                     .mux_bypass(mux_bypass),
                     .gate_tvalid(gate_tvalid),
                     .frequency_word_lfo(frequency_word_lfo),   
                     .lfo_out(lfo_out)); //lfo_out for sine is now normalized to the unit circle so can be (-0.5, 0.5), 
                                         // while for osc it can be (-1, 1).
                     
    assign mod_word = beta * (lfo_out >> SW_S_lfo_scale); //scale LFO amplitude via right shift.   
                                 
    oscillator_core oscillator(.Clk(Clk),
                               .Reset(reset_ah),
                               .osc_waveform_sel(SW_S_osc),
                               .mux_bypass(mux_bypass), //hardcode to 1 for test
                               .gate_tvalid(gate_tvalid), //hardcode to 1 for test
                               .frequency_word_osc(mod_word + frequency_word_osc),
                               .osc_out(osc_out));
                               
    assign data_in = osc_out; //temp for testing filter using lfo as osc core       
                        
    lowpass_FIR lowpass_top (
      .Clk(Clk),
      .Reset(reset_ah),
      .filter_bypass(SW_filt_bp_S), //derived str8 from SW (gonna be SW2) F1
      .filter_sel_en(filter_sel_en),
      .filter_sel(filter_sel),
      .data_in(data_in),
      .data_out(data_out)
    );
    
    Clock_divider2 am_adsr_441(.clock_in(Clk), 
                               .clock_out(clk_441),
                               .en_441(1'b1),
                               .Reset,
                               .frequency_word(22'b0));
                               
//    assign a = 10;    //hardcode for adsr test
//    assign d = 5;     //hardcode for adsr test
//    assign s = 3;     //hardcode for adsr test
//    assign r = 1;     //hardcode for adsr test
    //assign AM_bypass = SW_S_lfo_scale[3];
    
    adsr_selector adsr_sel(.Clk,
                           .Reset,
                           .S_but_inc_adsr,
                           .S_SW_sel_adsr,
                           .a,
                           .d,
                           .s,
                           .r);
                                      
    ADSR_gen adsr(.Clk(clk_441), .Reset(Reset), .gate_tvalid(gate_tvalid), .a, .d, .s, .r, .amplitude);
                                   
    AM_mod #(.DATA_BITS(DATA_BITWIDTH)) am_mod
                              (.Clk(clk_441), 
                               .Reset(Reset), 
                               .AM_bypass(SW_S_AM_bypass),
                               .amplitude(amplitude), 
                               .AM_data_in(data_out), 
                               .AM_data_out(AM_data_out));
                                                               
    keymapper km(.Clk(Clk), 
                 .Reset(reset_ah), 
                 .keycode0_gpio,
                 .keycode1_gpio,
                 .filter_sel, //o
                 .filter_sel_en, //o
                 .S_but_filt_sel_up, .S_but_filt_sel_dn,
                 //.filter_bypass, //o
                 .mod_depth(beta), //o
                 .gate_tvalid(gate_tvalid), 
                 .frequency_word(frequency_word_osc));
                              
endmodule