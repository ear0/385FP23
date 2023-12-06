
module LUTsine(input logic  Clk,
               input logic  [21:0] tune_in_dds,
               input logic  tune_valid_dds,
               output logic [15:0] sine_cos_out,
               output logic sine_cos_lut_valid
               //,output logic [23:0] saw_out_opt
               );
    //logic [23:0] saw_out_int;
    //assign saw_out_opt = saw_out_int;           
    //fo = tune_word * f_clk / 2^16
    /* Xilinx PG141: basically tune_in_dds is 24 bits wide but only uses 22 bits; last 2 truncated
    When the DDS Compiler is configured to be a SIN/COS LUT only, the PHASE_IN field is
    mapped to s_axis_phase_tdata. The PHASE_IN field occupies a byte-oriented field in
    the least significant portion of the bus. So the width of s_axis_phase_tdata is the
    minimum multiple of 8 bits required to accommodate the PHASE_IN width. Because this is
    an input, any additional bits required to achieve this byte orientation are ignored by the
    core and are optimized away during synthesis or mapping.
    */
    lutsine_ddsblock sine_generator(.Clk(Clk), 
                                    .tune_valid_dds(tune_valid_dds), 
                                    .tune_in_dds(tune_in_dds), 
                                    .sine_cos_lut_valid(sine_cos_lut_valid), 
                                    .sine_cos_out(sine_cos_out)
                                    //,.phase_saw_out(saw_out_int)
                                    );
                                    
endmodule
