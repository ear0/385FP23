module modulator(input logic Clk,
                 input logic Clk_441,
                 input logic Reset,
                 input logic mod_en,
                 input logic [21:0] frequency_word_mod,
                 input logic signed [15:0] data_in,
                 output logic signed [15:0] data_out);
    
    //localparam int Ts =                   
    
    //multiplier_wrapper mixer(.Clk(Clk), .SCLR(Reset));
        
endmodule

module multiplier_wrapper(input logic Clk, 
                          input logic SCLR, 
                          input logic signed [15:0] A, 
                          input logic signed [15:0]B, 
                          output logic signed [31:0] Y);
                          
    mult_gen_0 u_multgen0(
                          .Clk, 
                          .SCLR, 
                          .A, 
                          .B, 
                          .Y
                          );                            
endmodule