// TODO: Find the right disclaimer
//
// Copyright 2021 IBM Research Thomas J. Watson. 
//
// Author: David Trilla, IBM Research Thomas J. Watson Center
// Date: 28.07.2021
// Description: 

module fft_inline #(
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
  logic [WIDTH-1:0] a,b,c,d,e,f,g,h,j,l,m,n;
  logic [7:0] i,k,o,p;
  //Inputs
  assign a = data_i[0];
  assign b = data_i[1];
  assign c = data_i[2];
  assign d = data_i[3];

  //Accelerator
  assign e = a << 9;
  assign f = b << 1;
  assign g = c << 9;
  assign h = d << 1;

  assign i = f[7:0];
  assign j = e|f;
  assign k = h[7:0];
  assign l = g|h;

  assign m = j >> 8;
  assign n = l >> 8;

  assign o = m[7:0];
  assign p = n[7:0];

  assign data_o[0] = i;
  assign data_o[1] = p;
  assign data_o[2] = o;
  assign data_o[3] = k;


endmodule
