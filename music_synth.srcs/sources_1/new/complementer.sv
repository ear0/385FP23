module complementer #(parameter DATA_WIDTH = 16) 
                    (input logic [DATA_WIDTH - 1: 0] signed_mag_in,
                     output logic [DATA_WIDTH - 1: 0] twos_comp_out);
                     
    //localparam logic [DATA_WIDTH - 1:0] max_val = ((DATA_WIDTH << 1) - 1);
    
    //converts signed magnitude to two's complement
//    always_comb begin
//        if(signed_mag_in[DATA_WIDTH - 1]) begin
//            twos_comp_out = ~signed_mag_in + 1;
//        end else begin
//            twos_comp_out = signed_mag_in;
//        end
//    end

    always_comb begin
        twos_comp_out = signed_mag_in[DATA_WIDTH - 1] ? ~signed_mag_in : signed_mag_in;
        twos_comp_out = signed_mag_in[DATA_WIDTH - 1] ? twos_comp_out + 1 : twos_comp_out;   
    end
endmodule
