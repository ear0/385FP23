//https://fpgacoding.com/time-to-create-a-pulse-width-modulation-circuit/
//according to Jason the CA (GOAT) we should use 12 bits in here. division ratio of 2268 will not allow us
//to reconstruct analog audio properly! 11/28

module pwm
    #(parameter BITS = 16, parameter BITS_CUTOFF = 4)
    (
        input logic clk, //, clk_441,
        input logic rst,
        input logic [1:0] waveform_sel,
        input logic gate_tvalid,
        input logic SW_pwm_scale,
        input logic [BITS - 1 : 0] dty,
        output logic pwm
    );

    logic rPwm;
    logic [BITS - 1 : 0] rDuty;
    logic [BITS - 1 : 0] dty_temp;
    logic pwmNext;
    logic [BITS - 1 : 0] dutyNext;
    logic [BITS - 1 : 0] sample_last;
    logic load_pwm;
    assign load_pwm = sample_last != dty;
//    always_comb begin
//        if(SW_pwm_scale) begin
//            dty_temp = dty + 16'h8000;
//        end else begin
//            dty_temp = dty;
//        end
//    end
    
    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            sample_last <= 0;
        end else begin
            sample_last <= dty;
        end
    end
                 
    always_ff @(posedge clk, posedge rst)
    begin
//        if (rst | clk_441) begin
        if (rst | load_pwm) begin
            rPwm <= 0;
            rDuty <= 0;
        end else begin
            rPwm <= rDuty < (dty_temp[BITS - 1: BITS_CUTOFF]);
            rDuty <= rDuty + 1;
        end
    end
         
//    assign dutyNext = rDuty + 1;
//    assign pwmNext = rDuty < (dty_temp[BITS - 1: BITS_CUTOFF]);
    
    always_comb begin
        if(SW_pwm_scale) begin
            dty_temp = dty + 16'h8000;
        end else begin
            dty_temp = dty;
        end
            
        if(gate_tvalid & (waveform_sel != 2'b11))
            pwm = rPwm;
        else if(gate_tvalid & (waveform_sel == 2'b11))
            pwm = dty[BITS - 1: BITS_CUTOFF];
        else
            pwm = 0;
    end

endmodule