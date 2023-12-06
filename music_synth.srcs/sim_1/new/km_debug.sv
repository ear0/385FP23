module km_debug();
    timeunit 10ns;
    timeprecision 1ns;
    localparam int data_width = 4;
    logic Clk; //km i
    logic Reset; //km //sim var i
    logic [7:0] keycode0_gpio; //i
    logic [7:0] keycode1_gpio; //i
    logic [4:0] filter_sel; //o
    logic filter_sel_en; //o
    logic filter_bypass; //o
    logic gate_tvalid; //o
    logic [7:0] counter;
    assign counter = WHATTHEFUCK.counter;
    logic [21:0] frequency_word; //o
    int C4 = 4'd4;
    int Cs4 = 5'd22;
    int D4 = 3'd7;
    int Ds4 = 4'd9;
    int E4 = 4'd10;
    int F4 = 4'd11;
    int Fs4 = 4'd13;
    int G4 = 4'd14;
    int Gs4 = 4'd15;
    int A4 = 6'd51;
    int As4 = 6'd52;
    int HF = 5'd29;  
    int filt_minus = 10'd45;
    int filt_plus = 10'd46;
    int filt_bp = 'd47;  
    logic db_clk_u, db_clk_d; //WHATTHEFUCK.kdb_bypass
    logic  q1, q2, q3, q3n, dout;    
    logic S_but_filt_sel_up, S_but_filt_sel_dn;
    logic selu, seld;
    //logic filt_up_db, filt_dn_db;
    //assign filt_up_db = WHATTHEFUCK.filt_up_db;
    //assign filt_dn_db = WHATTHEFUCK.filt_dn_db;
    //assign db_clk_u = WHATTHEFUCK.kdb_filt_up.db_clk;
    //assign db_clk_d = WHATTHEFUCK.kdb_filt_dn.db_clk;
//    assign q1 = WHATTHEFUCK.kdb_bypass.q1;
//    assign q2 = WHATTHEFUCK.kdb_bypass.q2;
//    assign q3 = WHATTHEFUCK.kdb_bypass.q3;
//    assign q3n = WHATTHEFUCK.kdb_bypass.q3n;
//    assign dout = WHATTHEFUCK.kdb_bypass.dout;
//    sync fu(.Clk, .d(selu), .q(S_but_filt_sel_up));
//    sync fd(.Clk, .d(seld), .q(S_but_filt_sel_dn));  
    assign S_but_filt_sel_up = selu;
    assign S_but_filt_sel_dn = seld; 
    keymapper WHATTHEFUCK(.*);
   // keymapper WHATTHEFUCK(.Clk, .Reset, .S_but_filt_sel_up, S_but_filt_sel_dn,  );
    always begin: CLOCK_GENERATION
        #1 Clk = ~Clk;
    end
    
    initial begin: CLOCK_INITIALIZATION
        Clk = 0;
    end
    
    initial begin: TEST_VECTORS
    Reset = 1;
    selu = 0;
    seld = 0;
    #100
    Reset = 0;
    keycode0_gpio = C4;
    #2000
    keycode0_gpio = Cs4;
    #2000
    keycode0_gpio = 0;
    #2000
    keycode0_gpio = D4;
    #2000 
    keycode0_gpio = Ds4;
    #2000
    keycode0_gpio = E4;
    #2000
    keycode0_gpio = F4;
    #2000
    keycode0_gpio = Fs4;
    #2000
    keycode0_gpio = G4;
    #2000
    keycode0_gpio = Gs4;
    #2000
    keycode0_gpio = A4;
    #2000
    keycode0_gpio = As4;
    #2000
    keycode0_gpio = HF;
    #500000
    keycode0_gpio = 0;
    #1000000 selu = 1; //press up button
    #1000000 selu = 0; //release up button
    #1000000 selu = 1; //press up button
    #1000000 selu = 0; //release up button
    #1000000 selu = 1; //press up button
    #1000000 selu = 0; //release up button        
    #1000000 seld = 1; //press down button
    #1000000 seld = 0; //release down button
    //spam down button
    #1000000 seld = 1; //press down button
    #1000000 seld = 0; //release down button
    #1000000 seld = 1; //press down button
    #1000000 seld = 0; //release down button
    #1000000 seld = 1; //press down button
    #1000000 seld = 0; //release down button           
    
    end    
endmodule
