
module dsp_fpmult #(parameter num_coeffs = 20) (input logic Clk,
                                                input logic Reset,
                                                input logic coeff_load,
                                                input logic [4:0] coeff_sel,
                                                input logic [31:0] coeff_in,
                                                input logic [15:0] data_in,
                                                output logic [31:0] data_out [20]
                                                );
//    logic [31:0] coeffs [num_coeffs];
    
//    always_ff @(posedge Clk) begin
//        if(Reset) begin
//            for(int i = 0; i < num_coeffs; i++) begin
//                coeffs[i] <= 0;
//                data_out <= 0;
//            end
//        end
//    end
//    //multiplier .CLK .A .B . P, B is decimal coefficient
//    genvar i;
//    generate;
//        for(i = 0; i < num_coeffs; i++) begin
//            mult_gen_fir multiplier(.Clk(Clk), .A(data_in), .B(coeffs[i]));
//        end
//    endgenerate;             
endmodule
