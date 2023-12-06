`timescale 1ns / 1ps
module sine2square(
                   input logic signed [15:0] sine_in,
                   output logic [15:0] sq_out
                   );
                   
    localparam int threshold = 0;
    assign sq_out = (sine_in > threshold) ? 16'd65535 : 16'h0;
endmodule
