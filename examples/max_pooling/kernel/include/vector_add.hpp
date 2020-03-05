#ifndef __MATRIX_MULTIPLY_HPP
#define __MATRIX_MULTIPLY_HPP
#include <cstdint>


/*
 * This is the most basic single tile version of vector addition
 * that adds two vectors A and B and stores the result in C.
 *
 * The code assumes a sinlge 1x1 grid of a single 1x1 tile group
 * Do NOT use this version with larger tile groups 
 */
template <typename TA, typename TC>
int __attribute__ ((noinline)) kernel_tile_vector_add(TA *A, TC *C,
                      uint32_t WIDTH) {
        // A single tile performs the entire vector addition
	for (int iter_x = 0; iter_x + 4 < WIDTH; iter_x += 4) { 
                float max = A[iter_x];
                for(int iter_y = iter_x + 1; iter_y < iter_x + 4; iter_y++) {
                        C[iter_y] = 0;
                        if(A[iter_y] > max) {
                                max = A[iter_y];
                        }
                }
                C[iter_x] = max;
	}

        return 0;
}

#endif
