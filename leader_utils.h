/**
 * @file leader_utils.h
 * @author Andy Belle-Isle
 */
#ifndef LEADER_UTILS_H
#define LEADER_UTILS_H

#define LEAD_SIZE   10

#include "stdlib.h"
#include "stdio.h"
#include "minesweeper.h"
#include "draw.h"

/**
 * @struct Score
 * A single score entry.
 */
typedef struct __attribute__((packed)){
    unsigned short time; /*<< How much time in seconds this user took */
    char tag[3];         /*<< The user name. 3 letters, like an arcade game. */
} Score;

/**
 * @struct Leaderboard
 * The leaderboard structure.
 */
typedef struct {
    Window window;
    Score entry[LEAD_SIZE]; /*<< The list of all entries */
} Leaderboard;

/**
 * @func CreateLeader(struct Score)
 * Creates a new LeaderBoard from a list of scores
 * @param entries The list of scores to create a leaderboard from.
 * @return struct Leaderboard The leaderboard that was created.
 */
Leaderboard CreateLeader(Score* entries, size_t entryAmt);

/**
 * @func PlayerToBeat(struct Score, struct Leaderboard)
 * Tells the player the next best player that they can possibly beat.
 * @param s The current player.
 * @param l The leaderboard to find the next best player.
 * @return struct Score The player that the player is able to beat.
 */
Score PlayerToBeat(Score s, Leaderboard l);

/**
 * @func InsertPlayer(struct Score, struct Leaderboard)
 * Takes the given player and inserts them into the leaderboard given in the
 *  correct position;
 * @param s The player being placed in the leaderboard
 * @param l The leaderboard the player is being placed into
 * @return int 0: Operation was successful
 *            -1: Operation was unsuccessful
 */
int InsertPlayer(Score s, Leaderboard* l);

/**
 * @func PrintScore(Score)
 * Prints the given score
 * @param s The score to print
 */
void PrintScore(Score s);

/**
 * @func PrintLeaderBoard(struct Leaderboard)
 * Print the leaderboard out. Each entry is printed like so: "TAG  xxxx"
 * @param l The Leaderboard that will be printed
 */
void PrintLeaderboard(Leaderboard l);

#endif //LEADER_UTILS_H
