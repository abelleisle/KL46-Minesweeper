/**
 * @file menu.h
 * @author Andy Belle-Isle
 */
#ifndef MENU_H
#define MENU_H

#include "stdlib.h"

/**
 * @func Menu_Leaderboard
 * Places a list of leaderboards in the menu so the menu can print them.
 * @param n How many leaderboards are being sent to the menu
 * @param ... A variable list of all the leaderboards to pass in.
 *  MUST BE TYPE Leaderboard.
 */
void Menu_Leaderboard(size_t n, ...);

/**
 * @func Menu_Create
 * Creates a menu with the given options.
 * @param n How many options the menu will have
 * @param ... A list of strings that will be the options.
 *  MUST BE char* type
 */
void Menu_Create(size_t n, ...);

/**
 * @func Menu_Draw
 * Draw the menu. It will draw all options and place a '>' on the left side
 *  of the currently selected option.
 */
void Menu_Draw(void);

/**
 * @func Menu_Run
 * Runs the menu and allows the user to move the cursor around.
 * @return The number of the option selected
 */
int Menu_Run(void);

#endif // MENU_H
