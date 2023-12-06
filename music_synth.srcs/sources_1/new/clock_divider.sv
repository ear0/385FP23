////https://www.fpga4student.com/2017/08/verilog-code-for-clock-divider-on-fpga.html
//module Clock_divider(clock_in,clock_out
//    );
//input clock_in; // input clock on FPGA
//output reg clock_out; // output clock after dividing the input clock by divisor
//reg[27:0] counter=28'd0;
//parameter DIVISOR = 28'd2272;
//always @(posedge clock_in)
//begin
// counter <= counter + 28'd1;
// if(counter>=(DIVISOR-1))
//  counter <= 28'd0;
// clock_out <= (counter<DIVISOR/2)?1'b1:1'b0;
//end
//endmodule

module Clock_divider2 #(parameter int NOM_DIVISOR = 2268, parameter int FIVEMEG_DIVISOR = 113 )
                    (input logic clock_in,
                     input logic en_441,
                     input logic Reset,
                     output logic clock_out,
                     input logic [21:0] frequency_word
                            );
    //WE WILL NOW CLOCK AT 5MHz TO RELAX TIMING REQUIREMENT IN THE CASE OF ARBITRARY DIVISOR.                        
    logic [27:0] counter; 
    int clk_in_freq = 100_000_000.0;          //divisor wont update properly if i dont use real???? 
    //real clk_ratio = clk_in_freq / (44100.0);  //divisor wont update properly if i dont use real????
    int div_ratio_use = 2268;     //hardcode to 2268 if u clock at 100MHz
    logic [31:0]  lol_2_to_the_22_haha = 4194304.0; //this has to be a real in every case - divisor is wrong if its an int
    logic [31:0] DIVISOR; //used to be clk_in_freq / freq
    
    //fclk for this is 2268x the sample clock for the DDS generators. so we could divide by 2268 to normalize
    
    always_comb begin
    //always_comb begin
        if(en_441) begin
            DIVISOR = 'd2268;
        end else begin
            DIVISOR = (div_ratio_use * (lol_2_to_the_22_haha)) / frequency_word;     
        end
    end
    
    always_ff @(posedge clock_in)
    begin
        if(Reset) begin
            counter <= 0;
        end else begin
            counter <= counter + 28'd1;
            if(counter>=(DIVISOR-1))
                counter <= 28'd0;
                clock_out <= (counter<DIVISOR/2)?1'b1:1'b0;
        end        
    end
    
endmodule

