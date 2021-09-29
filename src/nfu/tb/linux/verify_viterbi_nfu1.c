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
static inline long viterbi(long a, long b, long c){
    asm("");
    return  ((a ^ -1) & c )| (a & b);
}

#pragma GCC push_options
#pragma GCC optimize ("O0")
#pragma GCC optimize ("inline-functions")
int main( int argc, char* argv[] ){
  time_t t;

  int tests = DATA_SIZE/3;
  printf("Starting Viterbi NFU#1 Test\n");
  for(int j = 0; j < tests; ++j){
    printf("Test #%d/%d:",j+1,tests);
    volatile long w1 = input_data[j*3], w2 = input_data[j*3+1], w3 = input_data[j*3+2];
    volatile long r1,r2;

      asm volatile (
      "set_load_nfu 1, 1, 2, 3 \n\t"
      "or %1, %1, %1 \n\t"
      "or %2, %2, %2 \n\t"
      "or %3, %3, %3 \n\t"
      "exec_nfu 1, 0\n\t"
      "pop_nfu 1, %0, 0 \n\t"
      : "=r"(r1)
      : "r"(w1),"r"(w2),"r"(w3));
      
      r2 = viterbi(w1,w2,w3);
      
      if(r1 != r2){
        printf("FAILED: Inputs:%d, %d, %d Outputs: NFU=%d Software=%d\n", w1, w2, w3, r1,r2);
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
