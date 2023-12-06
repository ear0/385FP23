module reg_any #(parameter DATA_BITWIDTH = 16)
                (input logic Clk,
                 input logic Reset,
                 input logic signed [DATA_BITWIDTH - 1:0] d, //signed?
                 output logic signed [DATA_BITWIDTH - 1: 0] q //signed?
                );
    always_ff @(posedge Clk) begin
        if(Reset) 
            q <= 0;
        else
            q <= d;
    end
    
endmodule
