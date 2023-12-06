//https://github.com/gundy/tiny-synth/tree/develop
//modified to fit our use.
module pdm_dac #(parameter DATA_BITS = 16)(
  input logic signed [DATA_BITS-1:0] din,
  input logic [1:0] waveform_sel,
  input logic clk,
  input logic Reset,
  output logic dout
);
    
    logic [DATA_BITS:0] accumulator;
    logic [DATA_BITS-1:0] unsigned_din;
    
    assign unsigned_din = din ^ (2**(DATA_BITS-1));
    
    always_ff @(posedge clk) begin
      if(Reset)
        accumulator <= 0;
      else  
        accumulator <= (accumulator[DATA_BITS-1 : 0] + unsigned_din);
    end
    
    always_comb begin
        if(waveform_sel == 2'b11 | waveform_sel == 2'b01) begin
            dout = unsigned_din;            
        end else begin
            dout = accumulator[DATA_BITS];
        end
    end
    
    //assign dout = accumulator[DATA_BITS];
    
endmodule