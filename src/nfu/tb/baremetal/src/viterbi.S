# See LICENSE for license details.

#*****************************************************************************
# novia.S
#-----------------------------------------------------------------------------
#
# Test novia instruction.
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64U
RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Arithmetic tests
  #-------------------------------------------------------------

	//TEST_NFU_2IN_1OUT ( 2,0, 0 0, 0, 0);
	//TEST_NFU_ADD_2OP ( 3, 2, 1, 1);
	//TEST_NFU_ADD_2OP ( 4, 255, 128, 127);

	// Testing Pop Count
	TEST_NFU_3IN_1OUT (2, 1, 0, 0, 0, 0, 0, 1, 2, 3);
	TEST_NFU_3IN_1OUT (3, 1, 0, 30, 10, 14, 22, 1, 2, 3);
	TEST_NFU_3IN_1OUT (4, 1, 0, 10, 22, 10, 14, 1, 2, 3);
	TEST_NFU_3IN_1OUT (5, 1, 0, 6, 14, 22, 10, 1, 2, 3);
	
	TEST_NFU_3IN_1OUT (6, 1, 0, 293, 367, 421, 9, 1, 2, 3);
	TEST_NFU_3IN_1OUT (7, 1, 0, 2047, 2047, 2047, 2047, 1, 2, 3);
	
	TEST_NFU_3IN_SPACING6_1OUT (8, 1, 0, 388, 10145, 35212, 4, 0, 1, 0, 2, 3);
	TEST_NFU_3IN_SPACING7_1OUT (9, 1, 0, 2048, 2048, 2048, 2048, 0, 1, 0, 2, 0, 3);

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
