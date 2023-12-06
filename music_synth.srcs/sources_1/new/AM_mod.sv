//https://github.com/gundy/tiny-synth/tree/develop
//modified to fit our use

module AM_mod #(parameter DATA_BITS = 16, parameter AMP_BITS = 8)
              (input logic Clk, //44.1 kHz clock
               input logic Reset,
               input logic AM_bypass,
               input logic [AMP_BITS - 1:0] amplitude,
               input logic signed [DATA_BITS - 1:0] AM_data_in,
               output logic signed [DATA_BITS - 1:0] AM_data_out);

    logic signed [AMP_BITS:0] amp_signed; //9 bits, padded with a 0
    logic signed [AMP_BITS + DATA_BITS - 1:0] scaled_din;
    logic signed [DATA_BITS - 1:0] AM_data_out_temp;
    assign amp_signed = {1'b0, amplitude[AMP_BITS - 1:0]};
        
    always_ff @(posedge Clk) begin
        if (Reset)
            scaled_din <= 0;
        else
            scaled_din <= (AM_data_in * amp_signed);
    end
    
    assign AM_data_out_temp = scaled_din[AMP_BITS + DATA_BITS - 1 -: DATA_BITS];
    
    always_comb begin
        unique case(AM_bypass)
            1'b0: AM_data_out = AM_data_out_temp;
            1'b1: AM_data_out = AM_data_in;
        endcase
    end
                    
endmodule
