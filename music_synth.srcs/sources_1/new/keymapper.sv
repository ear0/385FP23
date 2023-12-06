module keymapper #(parameter PHASE_ACC_WIDTH = 22)
                (input logic [7:0] keycode0_gpio,
                 input logic S_but_filt_sel_up, S_but_filt_sel_dn, //added these to get around keyboard bs
                 input logic [7:0] keycode1_gpio,
                 input logic Clk,
                 input logic Reset,
                 output logic [5:0] filter_sel,
                 output logic filter_sel_en,
                 output logic [7:0] mod_depth, // corresponds to beta on top level. chosen via number keys. 0 would be no modulation
                 //output logic filter_bypass,
                 output logic gate_tvalid, 
                 output logic [PHASE_ACC_WIDTH - 1:0] frequency_word //generate dds tuning word from key press
                                                    //generate increment/decrement filter cutoff frequency
                                                    //generate increment/decrement FM mod intensity
                                                    );
    // 2^N * fo / fclk =  M[phase_acc_width - 1:0]
    localparam int fout = 0;
    localparam int fclk = 44_100.0;
    localparam int max_acc = (2**PHASE_ACC_WIDTH);                                                 
    logic [7:0] key1, key0;
    assign key1 = keycode1_gpio;
    assign key0 = keycode0_gpio;
    localparam int C4 = 4'd4;
    localparam int Cs4 = 5'd22;
    localparam int D4 = 3'd7;
    localparam int Ds4 = 4'd9;
    localparam int E4 = 4'd10;
    localparam int F4 = 4'd11;
    localparam int Fs4 = 4'd13;
    localparam int G4 = 4'd14;
    localparam int Gs4 = 4'd15;
    localparam int A4 = 6'd51;
    localparam int As4 = 6'd52;
    localparam int HF = 5'd29;  
    localparam int filt_minus = 10'd45;
    localparam int filt_plus = 10'd46;
    localparam int filt_bp = 'd47;
    localparam int space = 'd44;
    localparam int one   = 'd30;
    localparam int two   = 'd31;
    localparam int three = 'd32;
    localparam int four  = 'd33;
    localparam int five  = 'd34;
    localparam int six   = 'd35;
    localparam int seven = 'd36;
    localparam int eight = 'd37;
    localparam int nine  = 'd38;
    localparam int zero = 'd39;
   // logic fbp_internal;
    //logic fbp_out;
    //logic [3:0] filter_sel_internal;
    logic filt_up_db, filt_dn_db;
    //assign filter_sel = filter_sel_internal;
    //assign filter_bypass = fbp_internal;
    logic [23:0] counter; 
    //other keys being pressed still produce sound output. check the keycode here
    //added 10 ms delay upon keypress; probably unnecessary tbh
      always_ff @(posedge Clk or posedge Reset) begin: gate_for_music
        if (Reset) begin
          counter <= 0;
          gate_tvalid <= 0;
        end else begin
          counter <= counter + 1;
          if (keycode0_gpio == C4 || keycode0_gpio == Cs4 || keycode0_gpio == D4 || keycode0_gpio == Ds4
            || keycode0_gpio == E4 || keycode0_gpio == F4 || keycode0_gpio == Fs4 || keycode0_gpio == G4
            || keycode0_gpio == Gs4 || keycode0_gpio == A4 || keycode0_gpio == As4 || keycode0_gpio == HF
            //|| keycode0_gpio == filt_minus || keycode0_gpio == filt_plus || keycode0_gpio == filt_bp 
            || keycode0_gpio == space) begin  //exclude mod depth selection from this, that shoudlnt play music
            if (counter == 24'd10) begin //delay to ensure assertion of gate_tvalid occurs AFTER frequency word commits
              gate_tvalid <= 1;
            end
          end else begin
            counter <= 0;
            gate_tvalid <= 0;
          end
        end
      end
 //TEMPORARY!!!! REMOVE THESE 
//    assign filt_up_db = S_but_filt_sel_up;
//    assign filt_dn_db = S_but_filt_sel_dn;
//logic gate_tvalid_internal; // Internal signal for gate control
    //logic [3:0] prev_filter_sel;
    //logic rst_counter;
    //logic [1:0] sel_cnt;
    always_ff @(posedge Clk) begin
        if (Reset) begin
            frequency_word <= 0;
            //filter_sel <= 6'b1001; //set this to 9 so we dont get stuck in filter_sel = 0. ill fix later
            //filter_sel_en <= 0;
            mod_depth <= 0; //reset to 0 for pure tone.
            //sel_cnt <= 0;
            //rst_counter <= 1'b1;
        end else begin
        
            if(key0 == 4'd4)begin //a middle c4 // 261.626
                frequency_word <= $ceil(max_acc * 261.626 / fclk); //try int' for conversion to whole number       
            end                                                          
            else if(key0 == 5'd22) begin //s c#4   // 277.183           
                frequency_word <= $ceil(max_acc * 277.183 / fclk);       
            end                                                          
            else if(key0 == 3'd7) begin //d  d4 // 293.665              
                frequency_word <= $ceil(max_acc * 293.665 / fclk);       
            end                                                          
            else if(key0 == 4'd9) begin //f  d#4      // 311.127        
                frequency_word <= $floor(max_acc *  311.127 / fclk); //this rounds to the same thing as 'd10; hardcode it to floor for now     
            end                                                          
            else if(key0 == 4'd10) begin //g e4   // 329.628                       
                frequency_word <= $ceil(max_acc * 329.628 / fclk);        
            end
            else if(key0 == 4'd11)  begin //h f4  // 349.228
                frequency_word <= $ceil(max_acc * 349.228 / fclk);
            end
            else if(key0 == 4'd13)  begin //j f#4  // 369.994
                frequency_word <= $ceil(max_acc * 369.994 / fclk);
            end
            else if(key0 == 4'd14)  begin //k g4  // 391.995
                frequency_word <= $ceil(max_acc * 391.995 / fclk);
            end
            else if(key0 == 4'd15)  begin //l g#4 // 415.305 //this rounds to the same thing as 'd51...hardcode to floor
                frequency_word <= $floor(max_acc * 415.305 / fclk);
            end
            else if(key0 == 6'd51)  begin //; a4
                frequency_word <= $ceil(max_acc * 440 / fclk); // 440
            end
            else if(key0 == 6'd52)  begin //' a#4 // 466.164
                frequency_word <= $ceil(max_acc * 466.164 / fclk);
            end
            else if (key0 == 5'd29) begin //"HF" test (10 kHz)
                frequency_word <= int'(max_acc * (10000.0) / fclk);
            end
            else if (key0 == space) begin 
                frequency_word <= 'hffff;
            end            
            else if (key0 == zero) begin
                mod_depth <= 0; 
            end
            else if (key0 == one) begin
                mod_depth <= 20; //easter egg 
            end
            else if (key0 == two) begin
                mod_depth <= 40; //easter egg 
            end
            else if (key0 == three) begin
                mod_depth <= 60; //easter egg 
            end
            else if (key0 == four) begin
                mod_depth <= 80; //easter egg 
            end
            else if (key0 == five) begin
                mod_depth <= 100; //easter egg 
            end
            else if (key0 == six) begin
                mod_depth <= 120; //easter egg 
            end
            else if (key0 == seven) begin
                mod_depth <= 140; //easter egg 
            end     
            else if (key0 == eight) begin
                mod_depth <= 160; //easter egg 
            end     
            else if (key0 == nine) begin
                mod_depth <= 180; //easter egg 
            end                                                                                                                 
            //'d4 'd22 'd7 'd9 'd10 'd11 'd13 'd14 'd15 'd51 'd52       
            //filter control
            //these need to be debounced somehow. filter_sel and filter_bypass update like 5000 times
//no longer necessary as I am doing this with the bord switches
//            else if (SW_filt_bp) begin // [/{ //SW_filt_bp
//                frequency_word <= 0;
//                fbp_internal <= fbp_internal;
//            end
            else begin
                frequency_word <= 0; //keep unwanted keys from playing sounds
            end                                         
        end
    end
    //Debounce db_u(.clock(Clk), .in(S_but_filt_sel_up), .out(filt_up_db), .Reset);
    real_oneshot ro_u(.Clk, .Reset, .d(S_but_filt_sel_up), .q(filt_up_db));
    real_oneshot ro_d(.Clk, .Reset, .d(S_but_filt_sel_dn), .q(filt_dn_db));
    
    always_ff @(posedge Clk) begin
        if (Reset) begin
            filter_sel <= 6'b1001;
            filter_sel_en <= 0;    
        end
        else begin
            if (filt_dn_db) begin // -/_ //but_filt_sel_dn
                filter_sel_en <= 1'b1;
                //frequency_word <= 0;
                //sel_cnt <= sel_cnt + 1;
                if(filter_sel > 6'b000000) begin
                    filter_sel <= filter_sel - 1;
                end else if (filter_sel == 6'b000000) begin
                    filter_sel <= filter_sel;
                end
            end
            else if (filt_up_db) begin // +/= //but_filt_sel_up
                filter_sel_en <= 1'b1;
                //frequency_word <= 0;
                if(filter_sel < 6'd49) begin
                    filter_sel <= filter_sel + 1;
                end else if (filter_sel == 6'd49) begin //if saturated filter select just keep current value until we decrement
                    filter_sel <= filter_sel;
                end
            end
            else if (filt_dn_db == 0 & filt_up_db == 0) begin
                filter_sel_en <= 1'b0;
            end        
        end
    end
endmodule