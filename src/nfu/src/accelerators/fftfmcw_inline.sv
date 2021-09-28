// TODO: Find the right disclaimer
//
// Copyright 2021 IBM Research Thomas J. Watson. 
//
// Author: David Trilla, IBM Research Thomas J. Watson Center
// Date: 28.07.2021
// Description: 

module fftfmcw_inline #(
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
  //Inputs
  logic [WIDTH-1:0] a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u;
  //Accelerator
  assign a = data_i[0] + data_i[1];
  assign b = {32'b0,{32{1'b1}}} & data_i[2];
  assign c = data_i[2] + 1;
  assign d = data_i[0] + data_i[3];
  assign e = c == data_i[4];
  assign f = select_i[0] ? b : d;
  assign g = d + data_i[5];
  assign h = select_i[1] ? d : a;
  assign i = f << 1;
  assign j = g << 1;
  assign k = h < data_i[6];
  assign l = {32'b0,i[31:0]};
  assign m = i | 1'b1;
  assign n = {32'b0,j[31:0]};
  assign o = j | 1'b1;
  assign p = data_i[7] + l*32;
  assign q = {32'b0,m[31:0]};
  assign r = data_i[7] + n*32;
  assign s = {32'b0,o[31:0]};
  assign t = data_i[7] + q*32;
  assign u = data_i[7] + s*32;
  //Ouputs
  assign data_o[0] = p;
  assign data_o[1] = u;
  assign data_o[2] = t;
  assign data_o[3] = r;
  assign data_o[4] = b;
  assign data_o[5] = a;
  assign data_o[6] = d;
  assign data_o[7] = c;
  assign data_o[8] = e;
  assign data_o[9] = k;

endmodule
