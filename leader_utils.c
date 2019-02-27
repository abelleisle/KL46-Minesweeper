/**
 * @file leader_utils.c
 * @author Andy Belle-Isle
 */
#define LEAD_SIZE   10

#include "leader_utils.h"

Leaderboard CreateLeader(Score* entries, size_t entryAmt)
{
    Leaderboard l;

    // Make sure we only fill the array with either the max amount of entries,
    //  or however many we have
    for (int i = 0; i < entryAmt && i < LEAD_SIZE; i++) {
        l.entry[i] = entries[i];
    }

    return l;
}

Score PlayerToBeat(Score s, Leaderboard l)
{
    for (int i = 0; i < LEAD_SIZE; i++) {
        if (l.entry[i].time > s.time) {
            return l.entry[i];
        }
    }
}

int InsertPlayer(Score s, Leaderboard* l)
{
    if (s.time >= l->entry[LEAD_SIZE-1].time)
        return -1; // can't be added to list, unsuccessful
    for (int e = 0; e < LEAD_SIZE; e++) {
        /* If player's time is less than that of the position in the board */
        if (s.time < l->entry[e].time) {
            /* Shift all elements right from e+1 element by one. */
            for (int i = LEAD_SIZE - 1; i > e; i--) {
                l->entry[i] = l->entry[i-1];
            }
            l->entry[e] = s; // Add user to list
            return 0; // operation successful
        }
    }
    return -1; // unsuccessful
}

void PrintScore(Score s)
{
    char score[16];
    snprintf(score, 16, "%.3s  %d", s.tag, s.time);
    PutStringSB(score, 16);
}

void PrintLeaderboard(Leaderboard l)
{
    DrawBorder(l.window);
    Cursor_Save();
    for (int i = 0; i < LEAD_SIZE; i++) {
        PrintScore(l.entry[i]);
        Cursor_Load();
        Cursor_Down();
        Cursor_Save();
    }
}
