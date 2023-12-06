module lowpass_FIR #(parameter num_coeffs = 51, parameter coeff_sets = 20, 
                     parameter DATA_WIDTH = 16 , parameter CONFIG_WIDTH = 8,
                     parameter fullprecisionwidth = 49) //lets make this 10-20
                  (input logic Clk,
                   input logic Reset,
                   input logic filter_bypass,
                   input logic filter_sel_en,
                   input logic [5:0] filter_sel, //50 coef sets of 51 coefs so we need 6 bits for this now.
                   //input logic [15:0] coeff_in,
                   input logic [DATA_WIDTH - 1:0] data_in,
                   output logic [DATA_WIDTH -1:0] data_out);
                   //used to be 2*DATA_WIDTH - 1: 0
//Field A = Filter Select; size log2roundup(NUM_FILTS) (10 sets of 11 coeffs each so 4 bit select)
//when selecting coefficients use tvalid so the wrong thing is not loaded
    logic reset_ah, resetn;
    assign reset_ah = Reset;
    assign resetn = ~Reset;
    localparam int filt_sel_size = $clog2(coeff_sets);
    logic s_axis_data_tvalid;
    logic s_axis_data_tready;
    logic [DATA_WIDTH-1:0] s_axis_data_tdata;
    logic s_axis_config_tvalid;
    logic s_axis_config_tready;
    logic [7:0] s_axis_config_tdata;
    logic m_axis_data_tvalid;
    //logic m_axis_data_tready;
    logic [fullprecisionwidth - 1:0] m_axis_data_tdata;
    //used to be 2*DATA_WIDTH - 1: 0
    logic filter_select_en_int;
    logic fir_441;
    assign s_axis_data_tdata = data_in;
    //assign data_out = m_axis_data_tdata;
    
    //logic [1:0] delay_counter;
    always_ff @ (posedge Clk) begin //could do an always @(filter_sel and remove the filter_sel_en 
                                    //or an always @posedge clk and @posedge delay 
        if(reset_ah) begin
            s_axis_data_tvalid <= 1'b0; //this async reset may cause issues
            s_axis_config_tvalid <= 1'b0; //this async reset may cause issues
            s_axis_config_tdata <= 1'b0; //this async reset may cause issues
            //delay_counter <= 0;
        end
        else begin
            s_axis_data_tvalid <=1'b1; //check this, we might be able to tie this high forever
            //wait 1 clock as per FIR timing diagram
            if(filter_sel_en == 1'b1) begin //check logic for filter_sel && filter_sel < 5'd19
                s_axis_config_tvalid <= 1'b0; //always @posedge clk and @posedge delay 
                s_axis_config_tdata <= {8'b0, filter_sel};        
            end 
            else begin
                s_axis_config_tvalid <= 1'b1; 
            end
        end
    end
    
   //generate 441
//    logic [27:0] cnt_441;
//    logic [31:0] divisor;
//    assign divisor = 'd2268;
//    always_ff @(posedge Clk) begin
//        if (Reset) begin
//            cnt_441 <= 0;
//            fir_441 <= 0;
//        end else begin
//            cnt_441 <= cnt_441 + 1;
//            if(cnt_441 >= (divisor - 1)) begin
//                cnt_441 <= 0;
//                fir_441 <= (cnt_441<divisor/2)?1'b1:1'b0;
//            end
//        end
//    end
    
//    always_ff @(posedge fir_441) begin
//        if(Reset) begin
//            s_axis_config_tvalid <= 1'b0;    
//        end else begin
//            if(filter_sel_en == 1'b1) begin
//                s_axis_config_tvalid <= 1'b1; 
//            end
//            else
//                s_axis_config_tvalid <= 1'b0; 
//        end
//    end
    
    always_comb begin: filter_bypass_controller
        if(filter_bypass) begin
            data_out = data_in;
        end else begin
            data_out = m_axis_data_tdata[48:33];
        end
    end
    
    fir_10sets filt1(.aclk(Clk),
                    .aresetn(resetn),
                    .s_axis_data_tvalid(s_axis_data_tvalid), //i
                    .s_axis_data_tready(s_axis_data_tready), //o
                    .s_axis_data_tdata(s_axis_data_tdata), //i
                    .s_axis_config_tvalid(s_axis_config_tvalid), //i
                    .s_axis_config_tready(s_axis_config_tready), //o
                    .s_axis_config_tdata(s_axis_config_tdata), //i
                    .m_axis_data_tvalid(m_axis_data_tvalid), //o
                    .m_axis_data_tdata(m_axis_data_tdata) //o
                    );
endmodule
