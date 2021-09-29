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
static inline unsigned int fft(long i1, long i2, long i3, long i4){
    asm("");
    int a = i1;
    int b = i2;
    int c = i3; 
    int d = i4;
    int e = a << 9;
    int f = b << 1;
    int g = c << 9;
    int h = d << 1;
    char i = f;
    int j = e | f;
    char k = h;
    int l = g | h;
    unsigned m = j >> 8;
    unsigned n = l >> 8;
    char o = m;
    char p = n;
    return ((unsigned)k << 24) | ((unsigned)o << 16) | ((unsigned)p << 8) | (i);
}

#pragma GCC push_options
#pragma GCC optimize ("O0")
#pragma GCC optimize ("inline-functions")
int main( int argc, char* argv[] ){
  time_t t;

  int tests = DATA_SIZE/4;
  printf("Starting FFT NFU#2 Test\n");
  for(int j = 0; j < tests; ++j){
    printf("Test #%d/%d:",j+1,tests);
    volatile long w1 = input_data[j*4], w2 = input_data[j*4+1], w3 = input_data[j*4+2], w4 = input_data[j*4+3];
    volatile char r1a,r1b,r1c,r1d,r2a,r2b,r2c,r2d;
    int r2;

      asm volatile (
      "set_load_nfu 2, 1, 2, 3 \n\t"
      "or %4, %4, %4 \n\t"
      "or %5, %5, %5 \n\t"
      "or %6, %6, %6 \n\t"
      "set_load_nfu 2, 4, 0, 0 \n\t"
      "or %7, %7, %7 \n\t"
      "exec_nfu 2, 0\n\t"
      "pop_nfu 2, %0, 0 \n\t"
      "pop_nfu 2, %1, 1 \n\t"
      "pop_nfu 2, %2, 2 \n\t"
      "pop_nfu 2, %3, 3 \n\t"
      : "=r"(r1a), "=r"(r1b),"=r"(r1c),"=r"(r1d)
      : "r"(w1),"r"(w2),"r"(w3),"r"(w4));
      
      r2 = fft(w1,w2,w3,w4);
      r2a = 0xFF&r2;
      r2b = (0xFF00&r2)>>8;
      r2c = (0xFF0000&r2)>>16;
      r2d = (0xFF000000&r2)>>24;
      
      if(r1a != r2a || r1b != r2b || r1c != r2c || r1d != r2d){
        printf("FAILED: NFU (r1=%d,r2=%d,r3=%d,r4=%d) Software=(r1=%d,r2=%d,r3=%d,r4=%d)\n",
            r1a,r1b,r1c,r1d,r2a,r2b,r2c,r2d);
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
