//https://www.chipverify.com/verilog/verilog-positive-edge-detector
module real_oneshot(input logic Clk,
                    input logic Reset,
                    input logic d,
                    output logic q);
                    
    //logic [16:0] cnt;
    logic edge_det;
    logic is_pressed;
    //logic q_pre_db;
    
    always_ff @(posedge Clk) begin
        if(Reset) begin
            edge_det <= 0;
        end else begin
            edge_det <= d;
            //q <= d & ~ edge_det;
        end
    end
    
    //remove
    //assign q_pre_db = d & ~ edge_det; //remove
    assign q = d & ~ edge_det;        //add
    
endmodule
