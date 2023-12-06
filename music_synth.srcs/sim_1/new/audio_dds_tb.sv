module audio_dds_tb();
    timeunit 10ns;
    timeprecision 1ns;
    
    localparam int refclk_dds = 44100.0;
    localparam int num_bits_acc = 22;
    int desired_freq = 0;
    logic Clk, clk;
    logic clk_441;
    logic Reset;
    logic clk_out;
    assign clk = Clk;
    logic [21:0] frequency_word;
    logic [15:0] sine_out;
    logic [15:0] phase_out;
    logic m_axis_data_tvalid;
    logic m_axis_phase_tvalid;
    logic s_axis_config_tvalid;
    logic pwm;
    logic clock_in, clock_out;
    logic [21:0] intermediate_fo, DIVISOR;
    //assign intermediate_fo = cd2.intermediate_fo;
    assign DIVISOR = cd2.DIVISOR;
//    function logic freq_word(input int num_bits_acc, input int desired_freq);
//        begin
//            freq_word = int'((2**num_bits_acc)* desired_freq / refclk_dds);
//        end
//    endfunction
    
//    Clock_divider cd_test(.clk, .clk_out);
    /*
    aclk : IN STD_LOGIC;
    s_axis_config_tvalid : IN STD_LOGIC;
    s_axis_config_tdata : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_phase_tvalid : OUT STD_LOGIC;
    m_axis_phase_tdata :
    */
    audio_dds audio_dds_test(.aclk(clock_out), 
                            .s_axis_config_tvalid(s_axis_config_tvalid), 
                            .s_axis_config_tdata(frequency_word), 
                            .m_axis_data_tvalid(m_axis_data_tvalid), 
                            .m_axis_data_tdata(sine_out),
                            .m_axis_phase_tvalid(m_axis_phase_tvalid), 
                            .m_axis_phase_tdata(phase_out));
    
    pwm audiopwm(.clk(Clk), .rst(Reset), .dty(sine_out), .pwm(pwm));
    
    Clock_divider cd(.clock_in(Clk), .clock_out(clock_out));
    
    Clock_divider2 
                    #(.FREQ(44100.0)) 
                    cd2(.clock_in(Clk), 
                    .clock_out(clk_441),
                    .frequency_word('h73A)); 
                           
    always begin: CLK_GEN
        #1; 
        Clk = ~Clk;
       //#5000; 
        //clk_441 = ~clk_441;
    end
    
    initial begin: INIT_CLK
        Clk = 0;
        //clk_441 = 0;
    end
    
    initial begin: TEST_VECTORS
    //desired_freq = 0;
    Reset = 1;
    //s_axis_config_tvalid = 0;
    s_axis_config_tvalid = 1;
    frequency_word = 'd50_000;
    #2222400
    Reset = 0;
    s_axis_config_tvalid = 1;
    frequency_word = 'd100_000;
    #2222400
    desired_freq += 500;
    frequency_word = 'd1_000_000;
    #2222400
    desired_freq += 500;
    frequency_word = 'd1_500_000;
 
//    #2400
//    desired_freq += 500;
//    frequency_word = ((2**num_bits_acc)* 2500.0 / refclk_dds);
//    #2400
//    desired_freq += 500;
//    frequency_word = ((2**num_bits_acc)* 3000.0 / refclk_dds);
//    #2400
//    desired_freq += 500;
//    frequency_word = ((2**num_bits_acc)* 3500.0 / refclk_dds);
//    #2400
//    desired_freq += 500;
//    frequency_word = ((2**num_bits_acc)* 4000.0 / refclk_dds);
//    #2400
//    desired_freq += 500;
//    frequency_word = ((2**num_bits_acc)* 4500.0 / refclk_dds);
//    #2400
//    desired_freq += 500;
//    frequency_word = ((2**num_bits_acc)* 5000.0 / refclk_dds);
/*
    Reset = 1;
    s_axis_config_tvalid = 0;
    #2400
    Reset = 0;
    s_axis_config_tvalid = 1;
    frequency_word = ((2**num_bits_acc)* 500.0 / refclk_dds);
    #2400
    desired_freq += 500;
    frequency_word = ((2**num_bits_acc)* 1000.0 / refclk_dds);
    #2400
    desired_freq += 500;
    frequency_word = ((2**num_bits_acc)* 1500.0 / refclk_dds);
    #2400
    desired_freq += 500;
    frequency_word = ((2**num_bits_acc)* 2000.0 / refclk_dds);
    #2400
    desired_freq += 500;
    frequency_word = ((2**num_bits_acc)* 2500.0 / refclk_dds);
    #2400
    desired_freq += 500;
    frequency_word = ((2**num_bits_acc)* 3000.0 / refclk_dds);
    #2400
    desired_freq += 500;
    frequency_word = ((2**num_bits_acc)* 3500.0 / refclk_dds);
    #2400
    desired_freq += 500;
    frequency_word = ((2**num_bits_acc)* 4000.0 / refclk_dds);
    #2400
    desired_freq += 500;
    frequency_word = ((2**num_bits_acc)* 4500.0 / refclk_dds);
    #2400
    desired_freq += 500;
    frequency_word = ((2**num_bits_acc)* 5000.0 / refclk_dds);      
*/                                
    
    end
endmodule
