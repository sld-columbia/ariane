// TODO: Find the right disclaimer
// Copyright 2021 IBM Research Thomas J. Watson. 
//
// Author: David Trilla, IBM Research Thomas J. Watson Center
// Date: 02.05.2021

package nfu_pkg;

  // NFU configuration
  typedef struct packed {
    int unsigned Width;
    int unsigned OpWidth;
    int unsigned Accelerators;
    int unsigned Configs;
    int unsigned ConfigSelects;
    int unsigned NrShiftRegEntries;
  } nfu_features_t;

  // Default test config
  localparam nfu_features_t RV64NFU = '{
    Width:                  64,
    OpWidth:                5,
    Accelerators:           4,
    Configs:                4,
    ConfigSelects:          64,
    NrShiftRegEntries:      3
  };

endpackage
