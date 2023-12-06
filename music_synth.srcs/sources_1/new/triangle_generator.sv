module triangle_wave(input logic Clk,
                          input logic Reset,
                          input logic [21:0] frequency_word,
                          output logic [15:0] tri_out);
    localparam integer N = 22; //22-bit phase accumulator
    localparam integer M = (22 << 'd2);
    //localparam integer cycle = M / frequency_word; 
    logic [N-1 : 0] phase;
    always @(posedge Clk) begin
        if(Reset) begin
            phase <= 0;
            tri_out <= 0;
        end else 
        begin
            phase <= phase + frequency_word;
            if(phase < (1 << (N - 1))) 
                tri_out <= (phase << 1);
            else
                tri_out <= (((1 << N) - phase) << 1);
        end
     end
endmodule

module TriangleWaveGenerator (
  input logic Clk,
  input logic Reset,                // Clock input
  input logic [21:0] tuning_word, // 22-bit tuning word
  output logic [15:0] triangle          // Triangle wave output
);

  logic [15:0] phase; // 22-bit phase accumulator

  always_ff @(posedge Clk) begin
    if(Reset) begin
        phase <= 0;
        triangle <= 0;
    end
    else begin
    // Increment the phase accumulator based on the tuning word
    phase <= phase + tuning_word;

    // Generate the triangle wave
    if (phase[15]) // Check the MSB of the phase
      triangle <= ~phase[15:0] + 1; // Falling slope
    else
      triangle <= phase[15:0]; // Rising slope
     end
  end

endmodule

module test_TriangleWaveGenerator (
  input logic Clk,
  input logic Reset,                // Clock input
  input logic [21:0] tuning_word, // 22-bit tuning word
  output logic [15:0] triangle          // Triangle wave output
);
  localparam int phase_bits = 16;  
  logic [phase_bits - 1:0] phase; // 22-bit phase accumulator

  always_ff @(posedge Clk) begin
    if(Reset) begin
        phase <= 0;
        triangle <= 0;
    end
    else begin
    // Increment the phase accumulator based on the tuning word
    phase <= phase + tuning_word;

    // Generate the triangle wave
    if (phase[phase_bits - 1]) // Check the MSB of the phase
      triangle <= ~phase[phase_bits - 1:0] + 1; // Falling slope
    else
      triangle <= phase[phase_bits - 1:0]; // Rising slope
     end
  end

endmodule

module tri_plz (
  input logic clk,          // System clock at 44.1 kHz
  input logic rst,          // Reset input
  input logic [21:0] tuning_word, // 22-bit tuning word for frequency control
  output logic signed [15:0] triangle_wave // 16-bit output triangle wave
);
  // Internal variables
  logic [25:0] accumulator;
  logic [15:0] triangle_value;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        // Reset internal state
        accumulator <= 0;
        triangle_value <= 0;
    end else begin
        // Increment the accumulator with the tuning word
        accumulator <= accumulator + tuning_word;

        // Update the triangle wave value
        if (accumulator[25])
            triangle_value <= triangle_value - 1;
        else
            triangle_value <= triangle_value + 1;

        // Ensure triangle_value covers the full 16-bit range
        if (triangle_value == 16'd32767 && accumulator[25])
            triangle_value <= -16'd32768;
    end
end

  // Output the triangle wave
  assign triangle_wave = triangle_value;

endmodule
//https://github.com/gundy/tiny-synth/tree/develop
//modified to fit our use.
module tone_generator_triangle #(
  parameter ACCUMULATOR_BITS = 22,
  parameter OUTPUT_BITS = 16)
(
  input logic [ACCUMULATOR_BITS-1:0] accumulator,
  output logic [OUTPUT_BITS-1:0] dout,
  input logic en_ringmod,
  input logic ringmod_source);

  logic invert_wave;
  // invert the waveform (ie. start counting down instead of up)
  // if either ringmod is enabled and high,
  // or MSB of accumulator is set.
  assign invert_wave = (en_ringmod && ringmod_source)
                    || (!en_ringmod && accumulator[ACCUMULATOR_BITS-1]);

  assign dout = invert_wave ? ~accumulator[ACCUMULATOR_BITS-2 -: OUTPUT_BITS]
                            : accumulator[ACCUMULATOR_BITS-2 -: OUTPUT_BITS];

endmodule

