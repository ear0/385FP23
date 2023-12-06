//https://github.com/gundy/tiny-synth/tree/develop
//modified to fit our use
module ADSR_gen #(
    parameter SAMPLE_CLK_FREQ  = 44100,
    parameter ACCUMULATOR_BITS = 26
) (
    input logic Clk,
    input logic Reset,
    input logic gate_tvalid,
    input logic [3:0] a,
    d,
    s,
    r,
    output logic [7:0] amplitude
);
  localparam ACCUMULATOR_SIZE = 2 ** ACCUMULATOR_BITS;
  localparam ACCUMULATOR_MAX = ACCUMULATOR_SIZE - 1;

  logic [ACCUMULATOR_BITS:0] accumulator;
  logic [16:0] accumulator_inc;  /* value to add to accumulator */
  `define CALCULATE_PHASE_INCREMENT(n) $rtoi(ACCUMULATOR_SIZE / (n * SAMPLE_CLK_FREQ))  
  function [16:0] attack_table;
    input [3:0] param;
    begin
      case (param)
        4'b0000: attack_table = `CALCULATE_PHASE_INCREMENT(0.002);  // 33554
        4'b0001: attack_table = `CALCULATE_PHASE_INCREMENT(0.008);
        4'b0010: attack_table = `CALCULATE_PHASE_INCREMENT(0.016);
        4'b0011: attack_table = `CALCULATE_PHASE_INCREMENT(0.024);
        4'b0100: attack_table = `CALCULATE_PHASE_INCREMENT(0.038);
        4'b0101: attack_table = `CALCULATE_PHASE_INCREMENT(0.056);
        4'b0110: attack_table = `CALCULATE_PHASE_INCREMENT(0.068);
        4'b0111: attack_table = `CALCULATE_PHASE_INCREMENT(0.080);
        4'b1000: attack_table = `CALCULATE_PHASE_INCREMENT(0.100);
        4'b1001: attack_table = `CALCULATE_PHASE_INCREMENT(0.250);
        4'b1010: attack_table = `CALCULATE_PHASE_INCREMENT(0.500);
        4'b1011: attack_table = `CALCULATE_PHASE_INCREMENT(0.800);
        4'b1100: attack_table = `CALCULATE_PHASE_INCREMENT(1.000);
        4'b1101: attack_table = `CALCULATE_PHASE_INCREMENT(3.000);
        4'b1110: attack_table = `CALCULATE_PHASE_INCREMENT(5.000);
        4'b1111: attack_table = `CALCULATE_PHASE_INCREMENT(8.000);
        default: attack_table = 65535;
      endcase
    end
  endfunction

  function [16:0] decay_release_table;
    input [3:0] param;
    begin
      case (param)
        4'b0000: decay_release_table = `CALCULATE_PHASE_INCREMENT(0.006);
        4'b0001: decay_release_table = `CALCULATE_PHASE_INCREMENT(0.024);
        4'b0010: decay_release_table = `CALCULATE_PHASE_INCREMENT(0.048);
        4'b0011: decay_release_table = `CALCULATE_PHASE_INCREMENT(0.072);
        4'b0100: decay_release_table = `CALCULATE_PHASE_INCREMENT(0.114);
        4'b0101: decay_release_table = `CALCULATE_PHASE_INCREMENT(0.168);
        4'b0110: decay_release_table = `CALCULATE_PHASE_INCREMENT(0.204);
        4'b0111: decay_release_table = `CALCULATE_PHASE_INCREMENT(0.240);
        4'b1000: decay_release_table = `CALCULATE_PHASE_INCREMENT(0.300);
        4'b1001: decay_release_table = `CALCULATE_PHASE_INCREMENT(0.750);
        4'b1010: decay_release_table = `CALCULATE_PHASE_INCREMENT(1.500);
        4'b1011: decay_release_table = `CALCULATE_PHASE_INCREMENT(2.400);
        4'b1100: decay_release_table = `CALCULATE_PHASE_INCREMENT(3.000);
        4'b1101: decay_release_table = `CALCULATE_PHASE_INCREMENT(9.000);
        4'b1110: decay_release_table = `CALCULATE_PHASE_INCREMENT(15.00);
        4'b1111: decay_release_table = `CALCULATE_PHASE_INCREMENT(24.00);
        default: decay_release_table = 65535;
      endcase
    end
  endfunction

  localparam OFF = 3'd0;
  localparam ATTACK = 3'd1;
  localparam DECAY = 3'd2;
  localparam SUSTAIN = 3'd3;
  localparam RELEASE = 3'd4;

  logic [ 2:0] state;

  // initial begin
  //   state = OFF;
  //   amplitude = 0;
  //   accumulator = 0;
  // end


  // value to add to accumulator during attack phase
  // calculated from lookup table below based on attack parameter
  logic [16:0] attack_inc;
  always @(a) begin
    attack_inc <= attack_table(a);  // convert 4-bit value into phase increment amount
  end

  // value to add to accumulator during decay phase
  // calculated from lookup table below based on decay parameter
  logic [16:0] decay_inc;
  always @(d) begin
    decay_inc <= decay_release_table(d);  // convert 4-bit value into phase increment amount
  end

  logic [7:0] sustain_volume;  // 4-bit volume expanded into an 8-bit value
  logic [7:0] sustain_gap;  // gap between sustain-volume and full-scale (255)
  // used to calculate decay phase scale factor

  assign sustain_volume = {s, 4'b0000};
  assign sustain_gap = 255 - sustain_volume;

  // value to add to accumulator during release phase
  logic [16:0] release_inc;
  always @(r) begin
    release_inc <= decay_release_table(r);  // convert 4-bit value into phase increment amount
  end

  logic [16:0] dectmp;  /* scratch-logicister for intermediate result of decay scaling */
  logic [16:0] reltmp;  /* scratch-logicister for intermediate-result of release-scaling */


  logic [7:0] exp_out;  // exponential decay mapping of accumulator output; used for decay and release cycles
  eight_bit_exponential_decay_lookup exp_lookup (
      .din (accumulator[ACCUMULATOR_BITS-1-:8]),
      .dout(exp_out)
  );

  /* calculate the next state of the envelope generator based on
the state that we've just moved past, and the gate_tvalid signal */
  function [2:0] next_state;
    input [2:0] s;
    input g;
    begin
      case ({
        s, g
      })
        {
          ATTACK, 1'b0
        } :
        next_state = RELEASE;  /* attack, gate_tvalid off => skip decay, sustain; go to release */
        {ATTACK, 1'b1} : next_state = DECAY;  /* attack, gate_tvalid still on => decay */
        {
          DECAY, 1'b0
        } :
        next_state = RELEASE;  /* decay, gate_tvalid off => skip sustain; go to release */
        {DECAY, 1'b1} : next_state = SUSTAIN;  /* decay, gate_tvalid still on => sustain */
        {SUSTAIN, 1'b0} : next_state = RELEASE;  /* sustain, gate_tvalid off => go to release */
        {SUSTAIN, 1'b1} : next_state = SUSTAIN;  /* sustain, gate_tvalid on => stay in sustain */
        {RELEASE, 1'b0} : next_state = OFF;  /* release, gate_tvalid off => end state */
        {RELEASE, 1'b1} : next_state = ATTACK;  /* release, gate_tvalid on => attack */
        {OFF, 1'b0} : next_state = OFF;  /* end_state, gate_tvalid off => stay in end state */
        {OFF, 1'b1} : next_state = ATTACK;  /* end_state, gate_tvalid on => attack */
        default: next_state = OFF;  /* default is end (off) state */
      endcase
    end
  endfunction

  logic overflow;
  assign overflow = accumulator[ACCUMULATOR_BITS];

  logic prev_gate_tvalid;

  always_ff @(posedge Clk) begin
    if (Reset) begin
      state <= OFF;
      amplitude <= 0;
      accumulator <= 0;
    end else begin
      /* check for gate_tvalid low->high transitions (straight to attack phase)*/
      prev_gate_tvalid <= gate_tvalid;
      if (gate_tvalid && !prev_gate_tvalid) begin
        accumulator <= 0;
        state <= ATTACK;
      end

      /* otherwise, flow through ADSR state machine */
      if (overflow) begin
        accumulator <= 0;
        dectmp <= 8'd255;
        state <= next_state(state, gate_tvalid);
      end else begin
        case (state)
          ATTACK: begin
            accumulator <= accumulator + attack_inc;
            amplitude   <= accumulator[ACCUMULATOR_BITS-1-:8];
          end
          DECAY: begin
            accumulator <= accumulator + decay_inc;
            dectmp <= ((exp_out * sustain_gap) >> 8) + sustain_volume;
            amplitude <= dectmp;
          end
          SUSTAIN: begin
            amplitude <= sustain_volume;
            state <= next_state(state, gate_tvalid);
          end
          RELEASE: begin
            accumulator <= accumulator + release_inc;
            reltmp <= ((exp_out * sustain_volume) >> 8);
            amplitude <= reltmp;
            if (gate_tvalid) begin
              amplitude <= 0;
              accumulator <= 0;
              state <= next_state(state, gate_tvalid);
            end
          end
          default: begin
            amplitude <= 0;
            accumulator <= 0;
            state <= next_state(state, gate_tvalid);
          end
        endcase
      end
    end
  end
endmodule

module eight_bit_exponential_decay_lookup (
    input  logic [7:0] din,
    output logic [7:0] dout
);

  dist_mem_gen_0 exp_lookup_rom (
      .a  (din),
      .spo(dout)
  );

endmodule
