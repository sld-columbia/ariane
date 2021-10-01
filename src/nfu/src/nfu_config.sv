// TODO: Find the right disclaimer
//
// Copyright 2021 IBM Research Thomas J. Watson. 
//
// Author: David Trilla, IBM Research Thomas J. Watson Center
// Date: 02.05.2021
// Description: NOVIA Configuration registers

module nfu_config #(
  parameter nfu_pkg::nfu_features_t         Features =  nfu_pkg::RV64NFU,

  localparam int unsigned ACCS               = Features.Accelerators,
  localparam int unsigned CONFIG_SELECTS     = Features.ConfigSelects,
  localparam int unsigned CONFIGS            = Features.Configs

)( 
  input logic [ACCS-1:0]            acc_i,
  input logic [CONFIGS-1:0]         config_i,
  // Input signals
  // Input handshake
  // Output signals
  output logic [CONFIG_SELECTS-1:0] select_o
  // Output handshake
);

  always_comb begin
    case({acc_i,config_i}) 
      8'b00000000 : select_o = 64'h8000000000000000;
      8'b00000010 : select_o = 64'h4000000000000000;
      default : select_o = 64'h0000000000000000;
    endcase
  end



endmodule
