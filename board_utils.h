/**
 * @file board_utils.h
 * @author Andy Belle-Isle
 */
#ifndef BOARD_UTILS_H
#define BOARD_UTILS_H

#include "draw.h"

/**
 * @struct Board
 * Where are the board data is stored.
 */
typedef struct __attribute__((packed)){
    unsigned short width;   /**< How many columns the board has.*/
    unsigned short height;  /**< How many rows the board has.*/
    unsigned int bombs;     /**< How many bombs are in the board.*/
    unsigned int flags;     /**< How many flags the player has left.*/

    Window window;          /**< Location and dimensions of the window.*/

    char **board;           /**< Stores type of item in each location.
                             *   Data is stored in bits.
                             *   Bit 0: Bomb exists
                             *   Bit 1: Flag exists
                             *   Bit 2: Opened space
                             *   Bit 3: Contains a number
                             */
} Board;

/**
 * @enum update_t
 * How a certain cell will be updated.
 * @see UpdateCell
 */
enum update_t {FLAG, UNFLAG, OPEN, REC_OPEN};

/**
 * @func SpaceExists(int, int, Board)
 * Tells whether or not the given space exists on the given board.
 * @param row The row to test
 * @param col The column to test
 * @param b The board to test if the cell exists.
 * @return int 0: The space doesn't exist
 *             1: The space does exist.
 */
int spaceExists(int row, int col, Board b);

/**
 * @func BombsBear(int, int, Board)
 * Tells how many bombs are touching the given cell.
 * @param row The row to check
 * @param col The column to check
 * @param b The board to check the bombs on.
 * @return int How many bombs are touching the given cell.
 */
int BombsNear(int row, int col, Board b);

/**
 * @func GenerateBoard(unsigned short, unsigned short, int)
 * Generates a board given the size and the amount of bombs to place on it.
 * @param width How many columns the board is.
 * @param height How many rows the board is.
 * @param bomb_num How many bombs to place throughout the board.
 * @return Board The board that was generated.
 */
Board GenerateBoard(unsigned short width, 
                    unsigned short height, 
                    unsigned int bomb_num);

/**
 * @func DisplayBoard(Board)
 * Print the given board.
 * @param b The board to print
 */
void DisplayBoard(Board b);

/**
 * @func UncoverBoard(Board)
 * Uncover all the spaces on the board
 * @param b The board to uncover
 */
void UncoverBoard(Board b);

/**
 * @func UncoverBombs(Board)
 * Uncover only the bombs on the board.
 * @param b The board to uncover all the bombs on.
 */
void UncoverBombs(Board b);

/**
 * @func UpdateCell(int, int, enum update_t, Board)
 * Update the given cell on the given board in the specified way.
 * @param row What row to update
 * @param col What col to update
 * @param update How to update this cell.
 *               FLAG: Add a flag to this cell.
 *               OPEN: Open up the cell.
 *               REC_OPEN: Recursively open this cell to find the closest bomb.
 * @param b The board to update the cell(s) on.
 * @return What types of cells were updated.
 *              -1: Nothing happened
 *               0: Normal space or numbered space opened
 *               1: Bomb
 */
int UpdateCell(int row, int col, enum update_t update, Board b);

/**
 * @func UncoverCell(int, int, Board)
 * Given a covered cell, uncover it
 * @param row The row to uncover
 * @param col The column to uncover
 * @param b The board to uncover the cell on
 */
int UncoverCell(int row, int col, Board b);

/**
 * @func FlagCell(int, int, Board)
 * Given a blank cell, flag it
 * Given a flagged cell, unflag it
 * @param row The row to flag/unflag
 * @param col The column to flag/unflag
 * @param b The board to flag the cell on
 */
int FlagCell(int row, int col, Board* b);

/**
 * @func CheckWin(Board b)
 * Check if the given board is a winning board.
 * Winning means all cells except for bombs are uncovered.
 * @param b The board to check for the winning condition on.
 * @return 1 (true), 0 (false)
 */
int CheckWin(Board b);

#endif //BOARD_UTILS_H
