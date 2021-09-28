// TODO: Find the right disclaimer
//
// Copyright 2021 IBM Research Thomas J. Watson. 
//
// Author: David Trilla, IBM Research Thomas J. Watson Center
// Date: 28.07.2021
// Description: NOVIA accelerators wrapper NFU

module nfu_acc_wrap #(
  parameter int unsigned CONFIG         = 0,
  // NFU configuration
  parameter nfu_pkg::nfu_features_t    Features =  nfu_pkg::RV64NFU,

  localparam int unsigned WIDTH        = Features.Width,
  localparam int unsigned NOPERANDS    = 2**Features.OpWidth,
  localparam int unsigned CONFIG_SELECTS     = Features.ConfigSelects
)( 
  // Input signals
  input logic [NOPERANDS-1:0][WIDTH-1:0] data_i,
  input logic [CONFIG_SELECTS-1:0]       select_i,
  // Input handshake
  // Output signals
  output logic [NOPERANDS-1:0][WIDTH-1:0] data_o
  // Output handshake
);
  

  generate
    if (CONFIG == 1) begin : acc_0_gen
      fftfmcw_inline fftfmcw_inline0 (
        .data_i,
        .select_i,
        .data_o
      );
    end else if(CONFIG == 2) begin : acc_1_gen
      viterbi_inline viterbi_inline1 (
        .data_i,
        .select_i,
        .data_o
      );
    end else if(CONFIG == 3) begin : acc_0_gen
      fft_inline fft_inline2 (
        .data_i,
        .select_i,
        .data_o
      );
    end else if(CONFIG == 4) begin : acc_2_gen
      popcount_inline popcount_inline3 (
        .data_i,
        .select_i,
        .data_o
      );
    end
  endgenerate


endmodule
