// -------------------------------------------------------------
//
// Module: filter
// Generated by MATLAB(R) 9.14 and Filter Design HDL Coder 3.1.13.
// Generated on: 2023-11-14 01:22:01
// -------------------------------------------------------------

// -------------------------------------------------------------
// HDL Code Generation Options:
//
// OptimizeForHDL: on
// TargetDirectory: U:\
// CoefficientSource: ProcessorInterface
// TargetLanguage: Verilog
// TestBenchStimulus: step ramp chirp 

// Filter Specifications:
//
// Sample Rate     : N/A (normalized frequency)
// Response        : Lowpass
// Specification   : Fp,Fst,Ap,Ast
// Stopband Edge   : 0.13605
// Stopband Atten. : 40 dB
// Passband Ripple : 1 dB
// Passband Edge   : 0.045351
// -------------------------------------------------------------

// -------------------------------------------------------------
// HDL Implementation    : Fully parallel
// Folding Factor        : 1
// -------------------------------------------------------------
// Filter Settings:
//
// Discrete-Time IIR Filter (real)
// -------------------------------
// Filter Structure    : Direct-Form II, Second-Order Sections
// Number of Sections  : 3
// Stable              : Yes
// Linear Phase        : No
// Arithmetic          : fixed
// Numerator           : s16,13 -> [-4 4)
// Denominator         : s16,14 -> [-2 2)
// Scale Values        : s16,18 -> [-1.250000e-01 1.250000e-01)
// Input               : s16,0 -> [-32768 32768)
// Section Input       : s16,12 -> [-8 8)
// Section Output      : s16,10 -> [-32 32)
// Output              : s16,0 -> [-32768 32768)
// State               : s16,15 -> [-1 1)
// Numerator Prod      : s32,28 -> [-8 8)
// Denominator Prod    : s32,29 -> [-4 4)
// Numerator Accum     : s38,28 -> [-512 512)
// Denominator Accum   : s38,29 -> [-256 256)
// Round Mode          : convergent
// Overflow Mode       : wrap
// Cast Before Sum     : true
// -------------------------------------------------------------




`timescale 1 ns / 1 ns

module filter
               (
                clk,
                clk_enable,
                reset,
                filter_in,
                write_enable,
                write_done,
                write_address,
                coeffs_in,
                filter_out
                );

  input   clk; 
  input   clk_enable; 
  input   reset; 
  input   signed [15:0] filter_in; //sfix16
  input   write_enable; 
  input   write_done; 
  input   [4:0] write_address; //ufix5
  input   signed [15:0] coeffs_in; //sfix16
  output  signed [15:0] filter_out; //sfix16

////////////////////////////////////////////////////////////////
//Module Architecture: filter
////////////////////////////////////////////////////////////////
  // Local Functions
  // Type Definitions
  // Constants
  // Signals
  reg  signed [15:0] input_register; // sfix16
  reg  write_enable_reg; // boolean
  reg  write_done_reg; // boolean
  reg  [4:0] write_address_reg; // ufix5
  reg  signed [15:0] coeffs_in_reg; // sfix16
  // Section 1   Processor Interface Signals 
  wire signed [15:0] coeff_scale1_assigned; // sfix16_En18
  wire signed [15:0] coeff_scale1_temp; // sfix16_En18
  reg  signed [15:0] coeff_scale1_reg; // sfix16_En18
  reg  signed [15:0] coeff_scale1_shadow_reg; // sfix16_En18
  wire signed [15:0] scale1; // sfix16_En12
  wire signed [31:0] mul_temp; // sfix32_En18
  wire signed [15:0] coeff_b1_section1_assigned; // sfix16_En13
  wire signed [15:0] coeff_b1_section1_temp; // sfix16_En13
  reg  signed [15:0] coeff_b1_section1_reg; // sfix16_En13
  reg  signed [15:0] coeff_b1_section1_shadow_reg; // sfix16_En13
  wire signed [15:0] coeff_b2_section1_assigned; // sfix16_En13
  wire signed [15:0] coeff_b2_section1_temp; // sfix16_En13
  reg  signed [15:0] coeff_b2_section1_reg; // sfix16_En13
  reg  signed [15:0] coeff_b2_section1_shadow_reg; // sfix16_En13
  wire signed [15:0] coeff_b3_section1_assigned; // sfix16_En13
  wire signed [15:0] coeff_b3_section1_temp; // sfix16_En13
  reg  signed [15:0] coeff_b3_section1_reg; // sfix16_En13
  reg  signed [15:0] coeff_b3_section1_shadow_reg; // sfix16_En13
  wire signed [15:0] coeff_a2_section1_assigned; // sfix16_En14
  wire signed [15:0] coeff_a2_section1_temp; // sfix16_En14
  reg  signed [15:0] coeff_a2_section1_reg; // sfix16_En14
  reg  signed [15:0] coeff_a2_section1_shadow_reg; // sfix16_En14
  wire signed [15:0] coeff_a3_section1_assigned; // sfix16_En14
  wire signed [15:0] coeff_a3_section1_temp; // sfix16_En14
  reg  signed [15:0] coeff_a3_section1_reg; // sfix16_En14
  reg  signed [15:0] coeff_a3_section1_shadow_reg; // sfix16_En14
  // Section 1 Signals 
  wire signed [37:0] a1sum1; // sfix38_En29
  wire signed [37:0] a2sum1; // sfix38_En29
  wire signed [37:0] b1sum1; // sfix38_En28
  wire signed [37:0] b2sum1; // sfix38_En28
  wire signed [15:0] typeconvert1; // sfix16_En15
  reg  signed [15:0] delay_section1 [0:1] ; // sfix16_En15
  wire signed [37:0] inputconv1; // sfix38_En29
  wire signed [31:0] a2mul1; // sfix32_En29
  wire signed [31:0] a3mul1; // sfix32_En29
  wire signed [31:0] b1mul1; // sfix32_En28
  wire signed [31:0] b2mul1; // sfix32_En28
  wire signed [31:0] b3mul1; // sfix32_En28
  wire signed [37:0] sub_cast; // sfix38_En29
  wire signed [37:0] sub_cast_1; // sfix38_En29
  wire signed [38:0] sub_temp; // sfix39_En29
  wire signed [37:0] sub_cast_2; // sfix38_En29
  wire signed [37:0] sub_cast_3; // sfix38_En29
  wire signed [38:0] sub_temp_1; // sfix39_En29
  wire signed [37:0] b1multypeconvert1; // sfix38_En28
  wire signed [37:0] add_cast; // sfix38_En28
  wire signed [37:0] add_cast_1; // sfix38_En28
  wire signed [38:0] add_temp; // sfix39_En28
  wire signed [37:0] add_cast_2; // sfix38_En28
  wire signed [37:0] add_cast_3; // sfix38_En28
  wire signed [38:0] add_temp_1; // sfix39_En28
  wire signed [15:0] section_result1; // sfix16_En10
  // Section 2   Processor Interface Signals 
  wire signed [15:0] coeff_scale2_assigned; // sfix16_En18
  wire signed [15:0] coeff_scale2_temp; // sfix16_En18
  reg  signed [15:0] coeff_scale2_reg; // sfix16_En18
  reg  signed [15:0] coeff_scale2_shadow_reg; // sfix16_En18
  wire signed [15:0] scale2; // sfix16_En12
  wire signed [31:0] mul_temp_1; // sfix32_En28
  wire signed [15:0] coeff_b1_section2_assigned; // sfix16_En13
  wire signed [15:0] coeff_b1_section2_temp; // sfix16_En13
  reg  signed [15:0] coeff_b1_section2_reg; // sfix16_En13
  reg  signed [15:0] coeff_b1_section2_shadow_reg; // sfix16_En13
  wire signed [15:0] coeff_b2_section2_assigned; // sfix16_En13
  wire signed [15:0] coeff_b2_section2_temp; // sfix16_En13
  reg  signed [15:0] coeff_b2_section2_reg; // sfix16_En13
  reg  signed [15:0] coeff_b2_section2_shadow_reg; // sfix16_En13
  wire signed [15:0] coeff_b3_section2_assigned; // sfix16_En13
  wire signed [15:0] coeff_b3_section2_temp; // sfix16_En13
  reg  signed [15:0] coeff_b3_section2_reg; // sfix16_En13
  reg  signed [15:0] coeff_b3_section2_shadow_reg; // sfix16_En13
  wire signed [15:0] coeff_a2_section2_assigned; // sfix16_En14
  wire signed [15:0] coeff_a2_section2_temp; // sfix16_En14
  reg  signed [15:0] coeff_a2_section2_reg; // sfix16_En14
  reg  signed [15:0] coeff_a2_section2_shadow_reg; // sfix16_En14
  wire signed [15:0] coeff_a3_section2_assigned; // sfix16_En14
  wire signed [15:0] coeff_a3_section2_temp; // sfix16_En14
  reg  signed [15:0] coeff_a3_section2_reg; // sfix16_En14
  reg  signed [15:0] coeff_a3_section2_shadow_reg; // sfix16_En14
  // Section 2 Signals 
  wire signed [37:0] a1sum2; // sfix38_En29
  wire signed [37:0] a2sum2; // sfix38_En29
  wire signed [37:0] b1sum2; // sfix38_En28
  wire signed [37:0] b2sum2; // sfix38_En28
  wire signed [15:0] typeconvert2; // sfix16_En15
  reg  signed [15:0] delay_section2 [0:1] ; // sfix16_En15
  wire signed [37:0] inputconv2; // sfix38_En29
  wire signed [31:0] a2mul2; // sfix32_En29
  wire signed [31:0] a3mul2; // sfix32_En29
  wire signed [31:0] b1mul2; // sfix32_En28
  wire signed [31:0] b2mul2; // sfix32_En28
  wire signed [31:0] b3mul2; // sfix32_En28
  wire signed [37:0] sub_cast_4; // sfix38_En29
  wire signed [37:0] sub_cast_5; // sfix38_En29
  wire signed [38:0] sub_temp_2; // sfix39_En29
  wire signed [37:0] sub_cast_6; // sfix38_En29
  wire signed [37:0] sub_cast_7; // sfix38_En29
  wire signed [38:0] sub_temp_3; // sfix39_En29
  wire signed [37:0] b1multypeconvert2; // sfix38_En28
  wire signed [37:0] add_cast_4; // sfix38_En28
  wire signed [37:0] add_cast_5; // sfix38_En28
  wire signed [38:0] add_temp_2; // sfix39_En28
  wire signed [37:0] add_cast_6; // sfix38_En28
  wire signed [37:0] add_cast_7; // sfix38_En28
  wire signed [38:0] add_temp_3; // sfix39_En28
  wire signed [15:0] section_result2; // sfix16_En10
  // Section 3   Processor Interface Signals 
  wire signed [15:0] coeff_scale3_assigned; // sfix16_En18
  wire signed [15:0] coeff_scale3_temp; // sfix16_En18
  reg  signed [15:0] coeff_scale3_reg; // sfix16_En18
  reg  signed [15:0] coeff_scale3_shadow_reg; // sfix16_En18
  wire signed [15:0] scale3; // sfix16_En12
  wire signed [31:0] mul_temp_2; // sfix32_En28
  wire signed [15:0] coeff_b1_section3_assigned; // sfix16_En13
  wire signed [15:0] coeff_b1_section3_temp; // sfix16_En13
  reg  signed [15:0] coeff_b1_section3_reg; // sfix16_En13
  reg  signed [15:0] coeff_b1_section3_shadow_reg; // sfix16_En13
  wire signed [15:0] coeff_b2_section3_assigned; // sfix16_En13
  wire signed [15:0] coeff_b2_section3_temp; // sfix16_En13
  reg  signed [15:0] coeff_b2_section3_reg; // sfix16_En13
  reg  signed [15:0] coeff_b2_section3_shadow_reg; // sfix16_En13
  wire signed [15:0] coeff_a2_section3_assigned; // sfix16_En14
  wire signed [15:0] coeff_a2_section3_temp; // sfix16_En14
  reg  signed [15:0] coeff_a2_section3_reg; // sfix16_En14
  reg  signed [15:0] coeff_a2_section3_shadow_reg; // sfix16_En14
  //   -- Section 3 Signals 
  wire signed [37:0] a1sum3; // sfix38_En29
  wire signed [37:0] b1sum3; // sfix38_En28
  wire signed [15:0] a1sumtypeconvert3; // sfix16_En15
  reg  signed [15:0] delay_section3; // sfix16_En15
  wire signed [37:0] inputconv3; // sfix38_En29
  wire signed [31:0] a2mul3; // sfix32_En29
  wire signed [31:0] b1mul3; // sfix32_En28
  wire signed [31:0] b2mul3; // sfix32_En28
  wire signed [37:0] sub_cast_8; // sfix38_En29
  wire signed [37:0] sub_cast_9; // sfix38_En29
  wire signed [38:0] sub_temp_4; // sfix39_En29
  wire signed [37:0] b1multypeconvert3; // sfix38_En28
  wire signed [37:0] add_cast_8; // sfix38_En28
  wire signed [37:0] add_cast_9; // sfix38_En28
  wire signed [38:0] add_temp_4; // sfix39_En28
  wire signed [15:0] section_result3; // sfix16_En10
  // Last Section Value --   Processor Interface Signals 
  wire signed [15:0] coeff_scale4_assigned; // sfix16_En18
  wire signed [15:0] coeff_scale4_temp; // sfix16_En18
  reg  signed [15:0] coeff_scale4_reg; // sfix16_En18
  reg  signed [15:0] coeff_scale4_shadow_reg; // sfix16_En18
  wire signed [15:0] scale4; // sfix16
  wire signed [31:0] mul_temp_3; // sfix32_En28
  wire signed [15:0] output_typeconvert; // sfix16
  reg  signed [15:0] output_register; // sfix16

  // Block Statements
  always @ (posedge clk or posedge reset)
    begin: input_reg_process
      if (reset == 1'b1) begin
        input_register <= 0;
        write_enable_reg <= 1'b0;
        write_done_reg <= 1'b0;
        write_address_reg <= 0;
        coeffs_in_reg <= 0;
      end
      else begin
        if (clk_enable == 1'b1) begin
          input_register <= filter_in;
          write_enable_reg <= write_enable;
          write_done_reg <= write_done;
          write_address_reg <= write_address;
          coeffs_in_reg <= coeffs_in;
        end
      end
    end // input_reg_process

  //   -------- Section 1 Processor Interface logic------------------

  assign mul_temp = input_register * coeff_scale1_shadow_reg;
  assign scale1 = (mul_temp[21:0] + {mul_temp[6], {5{~mul_temp[6]}}})>>>6;

  assign coeff_scale1_assigned = (write_address_reg == 5'b00000) ? coeffs_in_reg :
                           coeff_scale1_reg;
  assign coeff_scale1_temp = (write_enable_reg == 1'b1) ? coeff_scale1_assigned :
                       coeff_scale1_reg;
  assign coeff_b1_section1_assigned = (write_address_reg == 5'b00001) ? coeffs_in_reg :
                                coeff_b1_section1_reg;
  assign coeff_b1_section1_temp = (write_enable_reg == 1'b1) ? coeff_b1_section1_assigned :
                            coeff_b1_section1_reg;
  assign coeff_b2_section1_assigned = (write_address_reg == 5'b00010) ? coeffs_in_reg :
                                coeff_b2_section1_reg;
  assign coeff_b2_section1_temp = (write_enable_reg == 1'b1) ? coeff_b2_section1_assigned :
                            coeff_b2_section1_reg;
  assign coeff_b3_section1_assigned = (write_address_reg == 5'b00011) ? coeffs_in_reg :
                                coeff_b3_section1_reg;
  assign coeff_b3_section1_temp = (write_enable_reg == 1'b1) ? coeff_b3_section1_assigned :
                            coeff_b3_section1_reg;
  assign coeff_a2_section1_assigned = (write_address_reg == 5'b00100) ? coeffs_in_reg :
                                coeff_a2_section1_reg;
  assign coeff_a2_section1_temp = (write_enable_reg == 1'b1) ? coeff_a2_section1_assigned :
                            coeff_a2_section1_reg;
  assign coeff_a3_section1_assigned = (write_address_reg == 5'b00101) ? coeffs_in_reg :
                                coeff_a3_section1_reg;
  assign coeff_a3_section1_temp = (write_enable_reg == 1'b1) ? coeff_a3_section1_assigned :
                            coeff_a3_section1_reg;
  always @ (posedge clk or posedge reset)
    begin: coeff_reg_process_section1
      if (reset == 1'b1) begin
        coeff_scale1_reg <= 0;
        coeff_b1_section1_reg <= 0;
        coeff_b2_section1_reg <= 0;
        coeff_b3_section1_reg <= 0;
        coeff_a2_section1_reg <= 0;
        coeff_a3_section1_reg <= 0;
      end
      else begin
        if (clk_enable == 1'b1) begin
          coeff_scale1_reg <= coeff_scale1_temp;
          coeff_b1_section1_reg <= coeff_b1_section1_temp;
          coeff_b2_section1_reg <= coeff_b2_section1_temp;
          coeff_b3_section1_reg <= coeff_b3_section1_temp;
          coeff_a2_section1_reg <= coeff_a2_section1_temp;
          coeff_a3_section1_reg <= coeff_a3_section1_temp;
        end
      end
    end // coeff_reg_process_section1

  always @ (posedge clk or posedge reset)
    begin: coeff_shadow_reg_process_section1
      if (reset == 1'b1) begin
        coeff_scale1_shadow_reg <= 0;
        coeff_b1_section1_shadow_reg <= 0;
        coeff_b2_section1_shadow_reg <= 0;
        coeff_b3_section1_shadow_reg <= 0;
        coeff_a2_section1_shadow_reg <= 0;
        coeff_a3_section1_shadow_reg <= 0;
      end
      else begin
        if (write_done_reg == 1'b1) begin
          coeff_scale1_shadow_reg <= coeff_scale1_reg;
          coeff_b1_section1_shadow_reg <= coeff_b1_section1_reg;
          coeff_b2_section1_shadow_reg <= coeff_b2_section1_reg;
          coeff_b3_section1_shadow_reg <= coeff_b3_section1_reg;
          coeff_a2_section1_shadow_reg <= coeff_a2_section1_reg;
          coeff_a3_section1_shadow_reg <= coeff_a3_section1_reg;
        end
      end
    end // coeff_shadow_reg_process_section1

  //   ------------------ Section 1 ------------------

  assign typeconvert1 = (a1sum1[29:0] + {a1sum1[14], {13{~a1sum1[14]}}})>>>14;

  always @ (posedge clk or posedge reset)
    begin: delay_process_section1
      if (reset == 1'b1) begin
        delay_section1[0] <= 16'b0000000000000000;
        delay_section1[1] <= 16'b0000000000000000;
      end
      else begin
        if (clk_enable == 1'b1) begin
          delay_section1[1] <= delay_section1[0];
          delay_section1[0] <= typeconvert1;
        end
      end
    end // delay_process_section1

  assign inputconv1 = $signed({scale1[15:0], 17'b00000000000000000});

  assign a2mul1 = delay_section1[0] * coeff_a2_section1_shadow_reg;

  assign a3mul1 = delay_section1[1] * coeff_a3_section1_shadow_reg;

  assign b1mul1 = typeconvert1 * coeff_b1_section1_shadow_reg;

  assign b2mul1 = delay_section1[0] * coeff_b2_section1_shadow_reg;

  assign b3mul1 = delay_section1[1] * coeff_b3_section1_shadow_reg;

  assign sub_cast = inputconv1;
  assign sub_cast_1 = $signed({{6{a2mul1[31]}}, a2mul1});
  assign sub_temp = sub_cast - sub_cast_1;
  assign a2sum1 = sub_temp[37:0];

  assign sub_cast_2 = a2sum1;
  assign sub_cast_3 = $signed({{6{a3mul1[31]}}, a3mul1});
  assign sub_temp_1 = sub_cast_2 - sub_cast_3;
  assign a1sum1 = sub_temp_1[37:0];

  assign b1multypeconvert1 = $signed({{6{b1mul1[31]}}, b1mul1});

  assign add_cast = b1multypeconvert1;
  assign add_cast_1 = $signed({{6{b2mul1[31]}}, b2mul1});
  assign add_temp = add_cast + add_cast_1;
  assign b2sum1 = add_temp[37:0];

  assign add_cast_2 = b2sum1;
  assign add_cast_3 = $signed({{6{b3mul1[31]}}, b3mul1});
  assign add_temp_1 = add_cast_2 + add_cast_3;
  assign b1sum1 = add_temp_1[37:0];

  assign section_result1 = (b1sum1[33:0] + {b1sum1[18], {17{~b1sum1[18]}}})>>>18;

  //   -------- Section 2 Processor Interface logic------------------

  assign mul_temp_1 = section_result1 * coeff_scale2_shadow_reg;
  assign scale2 = (mul_temp_1[31:0] + {mul_temp_1[16], {15{~mul_temp_1[16]}}})>>>16;

  assign coeff_scale2_assigned = (write_address_reg == 5'b01000) ? coeffs_in_reg :
                           coeff_scale2_reg;
  assign coeff_scale2_temp = (write_enable_reg == 1'b1) ? coeff_scale2_assigned :
                       coeff_scale2_reg;
  assign coeff_b1_section2_assigned = (write_address_reg == 5'b01001) ? coeffs_in_reg :
                                coeff_b1_section2_reg;
  assign coeff_b1_section2_temp = (write_enable_reg == 1'b1) ? coeff_b1_section2_assigned :
                            coeff_b1_section2_reg;
  assign coeff_b2_section2_assigned = (write_address_reg == 5'b01010) ? coeffs_in_reg :
                                coeff_b2_section2_reg;
  assign coeff_b2_section2_temp = (write_enable_reg == 1'b1) ? coeff_b2_section2_assigned :
                            coeff_b2_section2_reg;
  assign coeff_b3_section2_assigned = (write_address_reg == 5'b01011) ? coeffs_in_reg :
                                coeff_b3_section2_reg;
  assign coeff_b3_section2_temp = (write_enable_reg == 1'b1) ? coeff_b3_section2_assigned :
                            coeff_b3_section2_reg;
  assign coeff_a2_section2_assigned = (write_address_reg == 5'b01100) ? coeffs_in_reg :
                                coeff_a2_section2_reg;
  assign coeff_a2_section2_temp = (write_enable_reg == 1'b1) ? coeff_a2_section2_assigned :
                            coeff_a2_section2_reg;
  assign coeff_a3_section2_assigned = (write_address_reg == 5'b01101) ? coeffs_in_reg :
                                coeff_a3_section2_reg;
  assign coeff_a3_section2_temp = (write_enable_reg == 1'b1) ? coeff_a3_section2_assigned :
                            coeff_a3_section2_reg;
  always @ (posedge clk or posedge reset)
    begin: coeff_reg_process_section2
      if (reset == 1'b1) begin
        coeff_scale2_reg <= 0;
        coeff_b1_section2_reg <= 0;
        coeff_b2_section2_reg <= 0;
        coeff_b3_section2_reg <= 0;
        coeff_a2_section2_reg <= 0;
        coeff_a3_section2_reg <= 0;
      end
      else begin
        if (clk_enable == 1'b1) begin
          coeff_scale2_reg <= coeff_scale2_temp;
          coeff_b1_section2_reg <= coeff_b1_section2_temp;
          coeff_b2_section2_reg <= coeff_b2_section2_temp;
          coeff_b3_section2_reg <= coeff_b3_section2_temp;
          coeff_a2_section2_reg <= coeff_a2_section2_temp;
          coeff_a3_section2_reg <= coeff_a3_section2_temp;
        end
      end
    end // coeff_reg_process_section2

  always @ (posedge clk or posedge reset)
    begin: coeff_shadow_reg_process_section2
      if (reset == 1'b1) begin
        coeff_scale2_shadow_reg <= 0;
        coeff_b1_section2_shadow_reg <= 0;
        coeff_b2_section2_shadow_reg <= 0;
        coeff_b3_section2_shadow_reg <= 0;
        coeff_a2_section2_shadow_reg <= 0;
        coeff_a3_section2_shadow_reg <= 0;
      end
      else begin
        if (write_done_reg == 1'b1) begin
          coeff_scale2_shadow_reg <= coeff_scale2_reg;
          coeff_b1_section2_shadow_reg <= coeff_b1_section2_reg;
          coeff_b2_section2_shadow_reg <= coeff_b2_section2_reg;
          coeff_b3_section2_shadow_reg <= coeff_b3_section2_reg;
          coeff_a2_section2_shadow_reg <= coeff_a2_section2_reg;
          coeff_a3_section2_shadow_reg <= coeff_a3_section2_reg;
        end
      end
    end // coeff_shadow_reg_process_section2

  //   ------------------ Section 2 ------------------

  assign typeconvert2 = (a1sum2[29:0] + {a1sum2[14], {13{~a1sum2[14]}}})>>>14;

  always @ (posedge clk or posedge reset)
    begin: delay_process_section2
      if (reset == 1'b1) begin
        delay_section2[0] <= 16'b0000000000000000;
        delay_section2[1] <= 16'b0000000000000000;
      end
      else begin
        if (clk_enable == 1'b1) begin
          delay_section2[1] <= delay_section2[0];
          delay_section2[0] <= typeconvert2;
        end
      end
    end // delay_process_section2

  assign inputconv2 = $signed({scale2[15:0], 17'b00000000000000000});

  assign a2mul2 = delay_section2[0] * coeff_a2_section2_shadow_reg;

  assign a3mul2 = delay_section2[1] * coeff_a3_section2_shadow_reg;

  assign b1mul2 = typeconvert2 * coeff_b1_section2_shadow_reg;

  assign b2mul2 = delay_section2[0] * coeff_b2_section2_shadow_reg;

  assign b3mul2 = delay_section2[1] * coeff_b3_section2_shadow_reg;

  assign sub_cast_4 = inputconv2;
  assign sub_cast_5 = $signed({{6{a2mul2[31]}}, a2mul2});
  assign sub_temp_2 = sub_cast_4 - sub_cast_5;
  assign a2sum2 = sub_temp_2[37:0];

  assign sub_cast_6 = a2sum2;
  assign sub_cast_7 = $signed({{6{a3mul2[31]}}, a3mul2});
  assign sub_temp_3 = sub_cast_6 - sub_cast_7;
  assign a1sum2 = sub_temp_3[37:0];

  assign b1multypeconvert2 = $signed({{6{b1mul2[31]}}, b1mul2});

  assign add_cast_4 = b1multypeconvert2;
  assign add_cast_5 = $signed({{6{b2mul2[31]}}, b2mul2});
  assign add_temp_2 = add_cast_4 + add_cast_5;
  assign b2sum2 = add_temp_2[37:0];

  assign add_cast_6 = b2sum2;
  assign add_cast_7 = $signed({{6{b3mul2[31]}}, b3mul2});
  assign add_temp_3 = add_cast_6 + add_cast_7;
  assign b1sum2 = add_temp_3[37:0];

  assign section_result2 = (b1sum2[33:0] + {b1sum2[18], {17{~b1sum2[18]}}})>>>18;

  //   -------- Section 3 Processor Interface logic------------------

  assign mul_temp_2 = section_result2 * coeff_scale3_shadow_reg;
  assign scale3 = (mul_temp_2[31:0] + {mul_temp_2[16], {15{~mul_temp_2[16]}}})>>>16;

  assign coeff_scale3_assigned = (write_address_reg == 5'b10000) ? coeffs_in_reg :
                           coeff_scale3_reg;
  assign coeff_scale3_temp = (write_enable_reg == 1'b1) ? coeff_scale3_assigned :
                       coeff_scale3_reg;
  assign coeff_b1_section3_assigned = (write_address_reg == 5'b10001) ? coeffs_in_reg :
                                coeff_b1_section3_reg;
  assign coeff_b1_section3_temp = (write_enable_reg == 1'b1) ? coeff_b1_section3_assigned :
                            coeff_b1_section3_reg;
  assign coeff_b2_section3_assigned = (write_address_reg == 5'b10010) ? coeffs_in_reg :
                                coeff_b2_section3_reg;
  assign coeff_b2_section3_temp = (write_enable_reg == 1'b1) ? coeff_b2_section3_assigned :
                            coeff_b2_section3_reg;
  assign coeff_a2_section3_assigned = (write_address_reg == 5'b10100) ? coeffs_in_reg :
                                coeff_a2_section3_reg;
  assign coeff_a2_section3_temp = (write_enable_reg == 1'b1) ? coeff_a2_section3_assigned :
                            coeff_a2_section3_reg;
  always @ (posedge clk or posedge reset)
    begin: coeff_reg_process_section3
      if (reset == 1'b1) begin
        coeff_scale3_reg <= 0;
        coeff_b1_section3_reg <= 0;
        coeff_b2_section3_reg <= 0;
        coeff_a2_section3_reg <= 0;
      end
      else begin
        if (clk_enable == 1'b1) begin
          coeff_scale3_reg <= coeff_scale3_temp;
          coeff_b1_section3_reg <= coeff_b1_section3_temp;
          coeff_b2_section3_reg <= coeff_b2_section3_temp;
          coeff_a2_section3_reg <= coeff_a2_section3_temp;
        end
      end
    end // coeff_reg_process_section3

  always @ (posedge clk or posedge reset)
    begin: coeff_shadow_reg_process_section3
      if (reset == 1'b1) begin
        coeff_scale3_shadow_reg <= 0;
        coeff_b1_section3_shadow_reg <= 0;
        coeff_b2_section3_shadow_reg <= 0;
        coeff_a2_section3_shadow_reg <= 0;
      end
      else begin
        if (write_done_reg == 1'b1) begin
          coeff_scale3_shadow_reg <= coeff_scale3_reg;
          coeff_b1_section3_shadow_reg <= coeff_b1_section3_reg;
          coeff_b2_section3_shadow_reg <= coeff_b2_section3_reg;
          coeff_a2_section3_shadow_reg <= coeff_a2_section3_reg;
        end
      end
    end // coeff_shadow_reg_process_section3

  //   ------------------ Section 3 (First Order) ------------------

  assign a1sumtypeconvert3 = (a1sum3[29:0] + {a1sum3[14], {13{~a1sum3[14]}}})>>>14;

  always @ (posedge clk or posedge reset)
    begin: delay_process_section3
      if (reset == 1'b1) begin
        delay_section3 <= 0;
      end
      else begin
        if (clk_enable == 1'b1) begin
          delay_section3 <= a1sumtypeconvert3;
        end
      end
    end // delay_process_section3

  assign inputconv3 = $signed({scale3[15:0], 17'b00000000000000000});

  assign a2mul3 = delay_section3 * coeff_a2_section3_shadow_reg;

  assign b1mul3 = a1sumtypeconvert3 * coeff_b1_section3_shadow_reg;

  assign b2mul3 = delay_section3 * coeff_b2_section3_shadow_reg;

  assign sub_cast_8 = inputconv3;
  assign sub_cast_9 = $signed({{6{a2mul3[31]}}, a2mul3});
  assign sub_temp_4 = sub_cast_8 - sub_cast_9;
  assign a1sum3 = sub_temp_4[37:0];

  assign b1multypeconvert3 = $signed({{6{b1mul3[31]}}, b1mul3});

  assign add_cast_8 = b1multypeconvert3;
  assign add_cast_9 = $signed({{6{b2mul3[31]}}, b2mul3});
  assign add_temp_4 = add_cast_8 + add_cast_9;
  assign b1sum3 = add_temp_4[37:0];

  assign section_result3 = (b1sum3[33:0] + {b1sum3[18], {17{~b1sum3[18]}}})>>>18;

  //   -------- Last Section Value -- Processor Interface logic------------------

  assign mul_temp_3 = section_result3 * coeff_scale4_shadow_reg;
  assign scale4 = ({{12{mul_temp_3[31]}}, mul_temp_3[31:0]} + {mul_temp_3[28], {27{~mul_temp_3[28]}}})>>>28;

  assign coeff_scale4_assigned = (write_address_reg == 5'b00111) ? coeffs_in_reg :
                           coeff_scale4_reg;
  assign coeff_scale4_temp = (write_enable_reg == 1'b1) ? coeff_scale4_assigned :
                       coeff_scale4_reg;
  always @ (posedge clk or posedge reset)
    begin: coeff_reg_process_Last_ScaleValue
      if (reset == 1'b1) begin
        coeff_scale4_reg <= 0;
      end
      else begin
        if (clk_enable == 1'b1) begin
          coeff_scale4_reg <= coeff_scale4_temp;
        end
      end
    end // coeff_reg_process_Last_ScaleValue

  always @ (posedge clk or posedge reset)
    begin: coeff_shadow_reg_process_Last_ScaleValue
      if (reset == 1'b1) begin
        coeff_scale4_shadow_reg <= 0;
      end
      else begin
        if (write_done_reg == 1'b1) begin
          coeff_scale4_shadow_reg <= coeff_scale4_reg;
        end
      end
    end // coeff_shadow_reg_process_Last_ScaleValue

  assign output_typeconvert = scale4;

  always @ (posedge clk or posedge reset)
    begin: Output_Register_process
      if (reset == 1'b1) begin
        output_register <= 0;
      end
      else begin
        if (clk_enable == 1'b1) begin
          output_register <= output_typeconvert;
        end
      end
    end // Output_Register_process

  // Assignment Statements
  assign filter_out = output_register;
endmodule  // filter
