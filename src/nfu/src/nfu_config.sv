// TODO: Find the right disclaimer
//
// Copyright 2021 IBM Research Thomas J. Watson. 
//
// Author: David Trilla, IBM Research Thomas J. Watson Center
// Date: 02.05.2021
// Description: NOVIA Configuration registers

module nfu_config #(
  parameter nfu_pkg::nfu_features_t         Features =  nfu_pkg::RV64NFU,

  localparam int unsigned WIDTH              = Features.Width,
  localparam int unsigned ACCS               = Features.Accelerators,
  localparam int unsigned CONFIG_SELECTS     = Features.ConfigSelects,
  localparam int unsigned CONFIGS            = Features.Configs

)( 
  input logic                       clk_i,
  input logic                       rst_ni,
  input logic [ACCS-1:0]            acc_i,
  input logic [CONFIGS-1:0]         config_i,
  // Input signals
  // Input handshake
  // Output signals
  output logic [CONFIG_SELECTS-1:0] select_o
  // Output handshake
);

  reg [ACCS-1:0][CONFIGS-1:0] configs [CONFIG_SELECTS-1:0];
  initial $readmemh("nfu.select.data", configs);

  assign select_o = configs[acc_i][config_i]; 


endmodule
