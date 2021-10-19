// See LICENSE for license details.

//**************************************************************************
#include "util.h"
#include <string.h>
#include <limits.h>
#include <time.h>
#include <stdlib.h>

//--------------------------------------------------------------------------
// Input/Reference Data

#define type unsigned int
#include "stdio.h"
#include "dataset1.h"


//--------------------------------------------------------------------------
// Main
static inline long popcount(long w){
    asm("");
    w -= (w >> 1) & 0x5555555555555555ULL;
    w = (w & 0x3333333333333333ULL) + ((w >> 2) & 0x3333333333333333ULL);
    w = (w + (w >> 4)) & 0x0f0f0f0f0f0f0f0fULL;
    return ((w * 0x0101010101010101ULL) >> 56);
}

#pragma GCC push_options
#pragma GCC optimize ("O0")
#pragma GCC optimize ("inline-functions")
int main( int argc, char* argv[] ){
  time_t t;

  int tests = 10;
  printf("Starting Popcount #NFU3 Test\n");
  for(int j = 0; j < tests; ++j){
    printf("Test #%d/%d:",j+1,tests);
    volatile long w = input_data[j];
    volatile long r1,r2;

      asm volatile (
      "set_load_nfu 3, 1, 0, 0 \n\t"
      "or %1, %1, %1 \n\t"
      "exec_nfu 3, 0\n\t"
      "pop_nfu 3, %0, 0 \n\t"
      : "=r"(r1)
      : "r"(w));
      
      r2 = popcount(w);
      
      if(r1 != r2){
        printf("FAILED: NFU=%d Software=%d\n",r1,r2);
        printf("Exiting\n");
        return 1;
      }else{
        printf(" PASSED\n");
      }
  }
  printf("ALL TESTS PASSED\n");
#pragma GCC pop_options

  return 0;
}
