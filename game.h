/**
 * @file game.h
 * @author Andy Belle-Isle
 */
#ifndef GAME_H
#define GAME_H

#include "leader_utils.h"

void Game_GenerateItems (int, Leaderboard);
int  Game_RunGame       (void);
void Game_CleanUp       (void);

#endif //GAME_H
