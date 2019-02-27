/**
 * @file num_utils.c
 * @author Andy Belle-Isle
 */
#include "num_utils.h"

static int seed;

void sprand(int s)
{
    seed = s;
}

int prand()
{
    return rand()+seed;
}

unsigned int ToBCD(unsigned int s)
{
    unsigned int bcd = 0;
    char shift = 0;
    /* Go through each digit until the number is empty. */
    while (s > 0) {
        bcd |= (s % 10) << (shift++ << 2); // Add the bcd digit and shift it
        s /= 10; // remove the digit already converted
    }
    
    return bcd;
}
