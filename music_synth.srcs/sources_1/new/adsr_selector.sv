module adsr_selector(input logic Clk,
                     input logic Reset,
                     input logic S_but_inc_adsr,
                     input logic [3:0] S_SW_sel_adsr, //[3] a [2] d [1] s [0] r
                     output logic [3:0] a, d, s, r);
                     
    //logic [3:0] a_tmp, d_tmp, s_tmp, r_tmp;
    logic but_adsr_db;
//    logic a_sel, d_sel, s_sel, r_sel;
//    assign a_sel = S_SW_sel_adsr[3];
//    assign d_sel = S_SW_sel_adsr[2];
//    assign s_sel = S_SW_sel_adsr[1];
//    assign r_sel = S_SW_sel_adsr[0];
    
    always_ff @(posedge Clk) begin
        if(Reset) begin
            a <= 0;
            d <= 0;
            s <= 0;
            r <= 0;
        end else begin
            if(but_adsr_db) begin
                case(S_SW_sel_adsr)
                4'b0001: begin
                         if(r == 4'd15)
                            r <= 0;
                         else   
                            r <= r + 1;
                         end
                4'b0010: begin
                         if(s == 4'd15)
                            s <= 0;
                         else   
                            s <= s + 1;
                         end
                4'b0100: begin
                         if(d == 4'd15)
                            d <= 0;
                         else   
                            d <= d + 1;
                         end
                4'b1000: begin
                         if(a == 4'd15)
                            a <= 0;
                         else   
                            a <= a + 1;
                         end
                default: begin
                         a <= a;
                         d <= d;
                         s <= s;
                         r <= r;
                         end                                                                                    
                endcase                 
            end else begin
                a <= a;
                d <= d;
                s <= s;
                r <= r;
            end    
        end            
    end
    
    real_oneshot ro_adsr(.Clk(Clk), .Reset(Reset), .d(S_but_inc_adsr), .q(but_adsr_db));
                         
endmodule
