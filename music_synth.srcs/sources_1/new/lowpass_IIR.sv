module lowpass_IIR(
                  input logic Clk,
                  input logic [15:0] audio_in,
                  input logic [7:0] cutoff,
                  input logic [7:0] resonance,
                  input logic [7:0] gain,
                  output logic [15:0] audio_out
                );
  //behavioral moog filter experiment I found at https://github.com/bat52/aisynth/blob/main/moog_filter.v              
  // Internal signals
  logic [15:0] stage1, stage2, stage3, stage4;
  logic [15:0] delay1, delay2, delay3, delay4;
  logic [15:0] lowpass, bandpass, highpass;
  logic [15:0] feedback;

  // Constants
  parameter [15:0] ONE = 16'h7FFF;       // 1.0 in fixed-point format
  parameter [15:0] HALF = 16'h4000;      // 0.5 in fixed-point format

  // Calculate filter coefficients based on sampling frequency and input parameters
  logic [15:0] f, p, k;
  always_comb
  begin
    f = (cutoff << 9) / 44100;
    p = f * (1.8 - 0.8 * f);
    k = p + p - 1;
  end

  // Update filter stages
    always_comb
    begin
    stage1 = (audio_in - delay4) - ((delay1 * k) >> 15);
    stage1 = stage1 - ((delay1 * p) >> 15);
    stage2 = (delay1 + stage1) >> 1;
    stage3 = (stage1 + stage2) >> 1;
    stage4 = (stage2 + stage3) >> 1;

    lowpass = ((delay4 + stage4) >> 1) * gain;
    bandpass = ((stage1 - delay1) >> 1) * gain;
    highpass = (audio_in - lowpass - (bandpass * resonance) >> 15) * gain;

    feedback = highpass + (delay4 * resonance) >> 15;
    end
    always_ff @(posedge Clk) begin
        delay1 <= stage1;
        delay2 <= stage2;
        delay3 <= stage3;
        delay4 <= stage4;
    end

  // Output audio signal
  always_ff @(posedge Clk)
  begin
    audio_out <= (lowpass + highpass) >> 1;
  end

endmodule
