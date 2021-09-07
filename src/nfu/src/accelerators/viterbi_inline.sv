// TODO: Find the right disclaimer
//
// Copyright 2021 IBM Research Thomas J. Watson. 
//
// Author: David Trilla, IBM Research Thomas J. Watson Center
// Date: 28.07.2021
// Description: 

module viterbi_inline #(
  parameter nfu_pkg::nfu_features_t         Features =  nfu_pkg::RV64NFU,

  localparam int unsigned WIDTH      = Features.Width,
  localparam int unsigned ACCS       = Features.Accelerators,
  localparam int unsigned CONFIG_SELECTS     = Features.ConfigSelects,
  localparam int unsigned NOPERANDS  = 2**Features.OpWidth
)( 
  // Input signals
  input logic [NOPERANDS-1:0][WIDTH-1:0] data_i,
  input logic [CONFIG_SELECTS-1:0]       select_i,
  // Input handshake
  // Output signals
  output logic [NOPERANDS-1:0][WIDTH-1:0] data_o
  // Output handshake
);
  assign data_o[0] = ((data_i[1] ^ 64'b1) & data_i[2]) | (data_i[0] & data_i[1]);

endmodule
