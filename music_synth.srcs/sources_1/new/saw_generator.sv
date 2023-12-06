`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2023 01:17:40 PM
// Design Name: 
// Module Name: saw_generator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module saw_generator(input logic  Clk,                
                     input logic  [21:0] tune_in_dds, 
                     input logic  tune_valid_dds,     
                     output logic [15:0] saw_out,
                     output logic saw_valid  
                     );
    //fo = tune_word * f_clk / 2^16
    /* Xilinx PG141: basically tune_in_dds is 24 bits wide but only uses 22 bits; last 2 truncated
    When the DDS Compiler is configured to be a SIN/COS LUT only, the PHASE_IN field is
    mapped to s_axis_phase_tdata. The PHASE_IN field occupies a byte-oriented field in
    the least significant portion of the bus. So the width of s_axis_phase_tdata is the
    minimum multiple of 8 bits required to accommodate the PHASE_IN width. Because this is
    an input, any additional bits required to achieve this byte orientation are ignored by the
    core and are optimized away during synthesis or mapping.
    */                                                   
    saw_phase_gen saw_wave(.aclk(Clk), 
                           .s_axis_config_tvalid(tune_valid_dds), //s_axis_config_tvalid(tune_valid_dds)
                           .s_axis_config_tdata(tune_in_dds),  //s_axis_config_tdata(tune_in_dds)
                           .m_axis_phase_tvalid(saw_valid), 
                           .m_axis_phase_tdata(saw_out));
    
endmodule
