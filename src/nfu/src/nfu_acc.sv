// TODO: Find the right disclaimer
//
// Copyright 2021 IBM Research Thomas J. Watson. 
//
// Author: David Trilla, IBM Research Thomas J. Watson Center
// Date: 02.05.2021
// Description: NOVIA accelerators wrapper NFU

module nfu_acc #(
  // NFU configuration
  parameter nfu_pkg::nfu_features_t         Features =  nfu_pkg::RV64NFU,

  localparam int unsigned WIDTH      = Features.Width,
  localparam int unsigned ACCS       = Features.Accelerators,
  localparam int unsigned NOPERANDS  = 2**Features.OpWidth,
  localparam int unsigned CONFIG_SELECTS     = Features.ConfigSelects
)( 
  input logic                          clk_i,
  input logic                          rst_ni,
  // Input signals
  input logic [NOPERANDS-1:0][WIDTH-1:0] data_i,
  input logic [ACCS-1:0]               acc_i,
  input logic [CONFIG_SELECTS-1:0]        select_i,
  // Input handshake
  // Output signals
  output logic [NOPERANDS-1:0][WIDTH-1:0] data_o
  // Output handshake
);

  logic [ACCS-1:0][NOPERANDS-1:0][WIDTH-1:0] result;
  // Accelerators
  nfu_acc_wrap #(
    .CONFIG(1)
  ) acc_0 (
    .data_i,
    .select_i,
    .data_o(result[0])
  );
  
  nfu_acc_wrap #(
    .CONFIG(2)
  ) acc_1 (
    .data_i,
    .select_i,
    .data_o(result[1])
  );
  
  nfu_acc_wrap #(
    .CONFIG(3)
  ) acc_2 (
    .data_i,
    .select_i,
    .data_o(result[2])
  );
  
  
  // Output Select
  assign data_o = result[acc_i];

endmodule
