// TODO: Find the right disclaimer
//
// Copyright 2021 IBM Research Thomas J. Watson. 
//
// Author: David Trilla, IBM Research Thomas J. Watson Center
// Date: 28.07.2021
// Description: 

module popcount_inline #(
  parameter nfu_pkg::nfu_features_t         Features =  nfu_pkg::RV64NFU,

  localparam int unsigned WIDTH      = Features.Width,
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
  logic [WIDTH-1:0] a,b,c,d,e,f;

  assign a = data_i[0] - ((data_i[0] >> 1) & 64'h5555_5555_5555_5555);
  assign b = (a & 64'h3333_3333_3333_3333) +  ((a >> 2) & 64'h3333_3333_3333_3333);
  assign c = (b + (b >> 4)) & 64'h0F0F_0F0F_0F0F_0F0F;
  assign d = c + (c >> 8);
  assign e = d + (d >> 16);
  assign f = e + (e >> 32);
  assign data_o[0] = f & 64'h0000_0000_0000_007F;




endmodule
