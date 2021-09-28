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
	TEST_NFU_1IN_1OUT (4, 3, 0, 0, 0, 1, 0 ,0);
	TEST_NFU_1IN_1OUT (5, 3, 0, 5, 55, 1, 0, 0);
	TEST_NFU_1IN_1OUT (6, 3, 0, 11, 42431, 0, 1 ,0);
	TEST_NFU_1IN_1OUT (7, 3, 0, 8, 255, 1, 0 ,0);
	TEST_NFU_1IN_1OUT (8, 3, 0, 9, 55000, 0, 1, 0);
	TEST_NFU_1IN_1OUT (9, 3, 0, 64, 0xFFFFFFFFFFFFFFFF, 1, 0, 0);

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
