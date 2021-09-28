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
	TEST_NFU_4IN_1OUT (2, 2, 0, 0, 0, 0, 0, 0, 0);
	TEST_NFU_4IN_1OUT (3, 2, 0, 1, 0, 0, 0, 0, 0);
	TEST_NFU_4IN_1OUT (4, 2, 0, 2, 0, 0, 0, 0, 0);
	TEST_NFU_4IN_1OUT (5, 2, 0, 3, 0, 0, 0, 0, 0);
	TEST_NFU_4IN_1OUT (6, 2, 0, 0, 44, 10, 14, 22, 22);
	TEST_NFU_4IN_1OUT (7, 2, 0, 1, 28, 10, 14, 22, 22);
	TEST_NFU_4IN_1OUT (8, 2, 0, 2, 44, 10, 14, 22, 22);
	TEST_NFU_4IN_1OUT (9, 2, 0, 3, 28, 10, 14, 22, 22);

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
