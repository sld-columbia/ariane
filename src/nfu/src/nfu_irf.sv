// TODO: Find the right disclaimer
// Copyright 2021 IBM Research Thomas J. Watson. 
//
// Author: David Trilla, IBM Research Thomas J. Watson Center
// Date: 02.05.2021
// Description: NOVIA Input Register File (ORF)

module nfu_irf #(
  // NFU configuration
  parameter nfu_pkg::nfu_features_t         Features =  nfu_pkg::RV64NFU,

  localparam int unsigned WIDTH      = Features.Width,
  localparam int unsigned ACCS       = Features.Accelerators,
  localparam int unsigned OPWIDTH    = Features.OpWidth,
  localparam int unsigned NOPERANDS  = 2**OPWIDTH
)( 
  input logic                                             clk_i,
  input logic                                             rst_ni,
  // Input signals
  input logic [WIDTH-1:0]                                 data_i,
  input logic [OPWIDTH-1:0]                               addr_i,
  input logic [ACCS-1:0]                                  acc_i,
  // Input handshake
  input logic                                             data_en_i,
  // Output signals
  output logic [NOPERANDS-1:0][WIDTH-1:0] data_o
  // Output handshake
);
  logic [ACCS-1:0][NOPERANDS-1:0][WIDTH-1:0]        regfile;

  
  assign data_o = regfile[acc_i];

  always_latch begin : set_load
    if(data_en_i) begin
      // Substracting 1 since we never get 0 addr (disabled input)
     regfile[acc_i][addr_i-1] = data_i;
    end
  end

endmodule
