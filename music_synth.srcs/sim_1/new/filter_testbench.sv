module filter_testbench();
    timeunit 1ns;
    timeprecision 1ns;
    
    logic [21:0] tune_in_dds;//sim var
    logic tune_valid_dds; //sim var
    logic [15:0] sine_cos_out;
    logic sine_cos_lut_valid;
    logic Clk; //fir
    logic Reset; //fir //sim var
    localparam int DATA_WIDTH = 16;    
    logic filter_bypass;                        
    logic filter_sel_en; //sim var       //fir        
    logic [4:0] filter_sel; //sim var    //fir     
    //logic [15:0] coeff_in;            
    logic [DATA_WIDTH - 1:0] data_in; //from DDS  //fir
    logic [48:0] data_out; //2*DATA_WIDTH - 1: 0
    logic [DATA_WIDTH - 1:0] data_out_x; //fir
    assign data_out_x = data_out[15:0]; //test
    logic pwm_out;
    logic pwm;
    logic convert;
    
     //internal FIR signals
    logic [15:0] s_axis_config_tdata;
    assign s_axis_config_tdata = lpf_test.s_axis_config_tdata;
    logic s_axis_config_tvalid;
    logic s_axis_config_tready;
    logic s_axis_data_tready;
    assign s_axis_config_tready = lpf_test.s_axis_config_tready;
    assign s_axis_data_tready = lpf_test.s_axis_data_tready;
    assign s_axis_config_tvalid = lpf_test.s_axis_config_tvalid;
    logic s_axis_data_tvalid;
    assign s_axis_data_tvalid = lpf_test.s_axis_data_tvalid;
    assign data_in = sine_cos_out;
    logic clken, wren, write_done;
    logic [4:0] waddr;
    logic signed [15:0] coeffs_in, filter_out;
    logic [16:0] upper_f_out;
    assign upper_f_out = lpf_test.m_axis_data_tdata[49:32];
    
    LUTsine u_LUTsine (
      .Clk(Clk),
      .tune_in_dds(tune_in_dds),
      .tune_valid_dds(tune_valid_dds),
      .sine_cos_out(sine_cos_out),
      .sine_cos_lut_valid(sine_cos_lut_valid)
    );
    
    lowpass_FIR lpf_test(.Clk, 
                        .Reset, 
                        .filter_bypass, 
                        .filter_sel_en, 
                        .filter_sel, 
                        .data_in, 
                        .data_out(data_out));
                        
//    filter_unopt lpf_test(.clk(Clk),
//                              .clk_enable(clken),
//                              .reset(Reset),
//                              .filter_in(sine_cos_out),
//                              .write_enable(wren),
//                              .write_done(write_done),
//                              .write_address(waddr),
//                              .coeffs_in(coeffs_in),
//                              .filter_out(filter_out));
                              
    logic [15:0] audio_out;
    //use sine data in
    pwm pwn(.clk(Clk), .rst(Reset), .dty(data_in), .pwm(pwm));
    //pwm_gen2 powa(.clk(Clk), .reset(Reset), .sig_in(data_in), .convert(convert), .pwm_out(pwm_out));
    
    always begin: CLOCK_GENERATION
        #5 Clk = ~Clk;
    end
    
    initial begin: CLOCK_INITIALIZATION
        Clk = 0;
    end
    
    initial begin: TEST_VECTORS
    Reset = 1;
    filter_bypass = 0;
    tune_in_dds = 'h1FFF; 
    filter_sel_en = 1'b0;
    filter_sel = 4'b0;
    tune_valid_dds = 1;
    #10000
    Reset = 0;
    #10000
    filter_sel_en = 1'b1;
    filter_sel = 4'b0001;
    #100000
    filter_sel_en = 1'b1;
    filter_sel = filter_sel + 1;
    #100000
    filter_sel_en = 1'b1;
    filter_sel = filter_sel + 1;
    #100000
    filter_sel_en = 1'b1;
    filter_sel = filter_sel + 1;
    #100000
    filter_sel_en = 1'b1;
    filter_sel = filter_sel + 1;
    #10000
    filter_sel_en = 1'b1;
    filter_sel = filter_sel + 1;
    #10000
    filter_sel_en = 1'b1;
    filter_sel = filter_sel + 1;
    #10000
    filter_sel_en = 1'b1;
    filter_sel = filter_sel + 1;
    #10000
    filter_sel_en = 1'b1;
    filter_sel = filter_sel + 1;
    #10000
    filter_sel_en = 1'b1;
    filter_sel = filter_sel + 1;                                         
//    #1000
//    filter_sel_en = 1'b1;
//    filter_sel = 4'b0001;
//    #100
//    filter_sel_en = 0;
//    #1000
//    filter_sel_en = 1'b1;
//    filter_sel = filter_sel + 1;
//    #1000
//    filter_sel_en = 1'b1;
//    filter_sel = filter_sel + 1;
//    tune_in_dds = 'h3FF; //
//    #10000
//    filter_sel_en = 1'b1;
//    filter_sel = filter_sel + 1;
//    #10000
//    filter_sel_en = 1'b1;
//    filter_sel = filter_sel + 1;
//    #10000
//    filter_sel_en = 1'b1;
//    filter_sel = filter_sel + 1;
//    tune_in_dds = 'h06FF; //
//    #10000
//    filter_sel_en = 1'b1;
//    filter_sel = filter_sel + 1;
//    #10000
//    filter_sel_en = 1'b1;
//    filter_sel = filter_sel + 1;
//    #10000
//    filter_sel_en = 1'b1;
//    filter_sel = filter_sel + 1;
//    #10000
//    filter_sel_en = 1'b1;
//    filter_sel = filter_sel + 1;
//    #1000
//    filter_sel_en = 1'b1;
//    filter_sel = filter_sel + 1;
//    #10000
//    filter_sel_en = 1'b1;
//    filter_sel = filter_sel + 1;
//    #10000
//    filter_sel_en = 1'b1;
//    filter_sel = filter_sel + 1;
//    #10000
//    filter_sel_en = 1'b1;
//    filter_sel = filter_sel + 1;
//    #10000
//    filter_sel_en = 1'b1;
//    filter_sel = filter_sel + 1;
//    #10000
//    filter_sel_en = 1'b1;
//    filter_sel = filter_sel + 1;
//    #10000
//    filter_sel_en = 1'b1;
//    filter_sel = filter_sel + 1;
//    #10000
//    filter_sel_en = 1'b1;
//    filter_sel = filter_sel + 1;
//    #10000
//    filter_sel_en = 1'b1;
//    filter_sel = filter_sel + 1;
//    $stop;         
    end
endmodule
