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
  logic [WIDTH-1:0] a,b,c,d,e,f,g,h,i,j,k,l;
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

  assign i = e|f;
  assign j = g|h;

  assign k = i >> 8;
  assign l = j >> 8;

  assign data_o[0] = {16'b0,16'b1} & l;
  assign data_o[1] = {16'b0,16'b1} & h;
  assign data_o[2] = {16'b0,16'b1} & k;
  assign data_o[3] = {16'b0,16'b1} & f;


endmodule
