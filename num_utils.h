/**
 * @file num_utils.h
 * @author Andy Belle-Isle
 */
#ifndef NUM_UTILS_H
#define NUM_UTILS_H

/**
 * @func sprand(int)
 * Places a seed in the prand() function to make more randomness.
 * @param seed The seed to set.
 */
void sprand(int seed);

/**
 * @func prand()
 * Pseudo-random number generator.
 * @return int The random number generated.
 */
int prand(void);

/**
 * @func ToBCD(unsigned short)
 * Given a half-word, convert it from binary to BCD
 * @param s The number to convert to s.
 * @return unsigned short The BCD value.
 */
unsigned int ToBCD(unsigned int s);

#endif //NUM_UTILS_H
