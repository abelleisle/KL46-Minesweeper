/**
 * @file board_utils.c
 * @author Andy Belle-Isle
 */
#include "minesweeper.h"
#include "board_utils.h"
#include "stdlib.h"
#include "num_utils.h"

#define tst_bit(var, pos) ((var) & (1 << (pos)))

int spaceExists(int row, int col, Board b) {
    return (row >= 0 && row < b.height) && (col >= 0 && col < b.width);
}

int BombsNear(int row, int col, Board b) {
    int count = 0;
    for (int r = row - 1; r <= row + 1; r++) {
        for (int c = col - 1; c <= col + 1; c++) {
            if (spaceExists(r, c, b))
                if (tst_bit(b.board[r][c], 0)) count++;
        }
    }
    return count;
}

Board GenerateBoard(unsigned short width, 
                    unsigned short height, 
                    unsigned int bomb_num) {
                  
    Board board;
    board.width = width;
    board.height = height;
    board.bombs = bomb_num;
    board.flags = bomb_num;

    board.window.width = width+2;
    board.window.height = height+2;

    // TODO make sure the KL46 supports dynamic allocation
    // generate the the width array
    board.board = (char**)calloc(height, sizeof (char*));
    for (int h = 0; h < height; h++) {
        // generate the height for each column
        board.board[h] = (char*)calloc(width, sizeof (char));
    }

    for (int b = 0; b < bomb_num; b++) {
        /* get random location of bomb */
        int col = (rand()%width);
        int row = (rand()%height);

        /* If there is a bomb already, don't count this bomb */
        if (tst_bit(board.board[row][col],0)) {
            b--;
        /* If not, place a bomb, then tell all the cells surrounding the bomb
         *  to find out how many bombs are touching them. */
        } else {
            board.board[row][col] |= 1; // set bomb
            for (int r = row - 1; r <= row + 1; r++) {
                for (int c = col - 1; c <= col + 1; c++) {
                    if (spaceExists(r, c, board) && 
                            !tst_bit(board.board[r][c], 0)) {
                        board.board[r][c] |= 8; // tell that bomb is touching
                    }
                }
            }
        }
    }
    return board;
}

void DisplayCell(unsigned short row, unsigned short col, 
                 Board b, int single) {
    if (single) {
        Cursor_Save();
        Cursor_Move(b.window.row + 1 + row,
                    b.window.column + 1 + col);
    }
    char c = b.board[row][col];
    /* If the space has been opened */
    if (tst_bit(c, 2)) {
        /* If space has bomb */
        if (tst_bit(c, 0)) {
            PutStringSB("\033[5m\033[31m",9);  // flashing with red
            PutChar('*');
            PutStringSB("\033[0m",4);       // reset to default
        /* If space has flag */
        } else if (tst_bit(c,1)) {
            PutStringSB("\033[31m",5);  // color to red
            PutChar('f');
            PutStringSB("\033[0m",5);  // color to white
        /* If space is next to bomb */
        } else if (tst_bit(c,3)) {
            int bn = BombsNear(row, col, b);
            switch (bn) {
                case 1: PutStringSB("\033[94m",5); break; // bright blue
                case 2: PutStringSB("\033[32m",5); break; // green
                case 3: PutStringSB("\033[91m",5); break; // bright red
                case 4: PutStringSB("\033[34m",5); break; // dark blue
                case 5: PutStringSB("\033[31m",5); break; // dark red
                case 6: PutStringSB("\033[36m",5); break; // cyan
                case 7: PutStringSB("\033[33m",5); break; // yellow
                case 8: PutStringSB("\033[35m",5); break; // purple
                default:;
            }
            PutChar(bn+48);
            PutStringSB("\033[0m",5);  // color to white
        /* Empty opened space */
        } else {
            PutChar(' ');
        }
    /* If the space contains a flag */
    } else if (tst_bit(c, 1)){
        PutStringSB("\033[31m",5);      // color to red
        PutChar('f');
        PutStringSB("\033[0m",5);      // color to white
    /* Unopened space */
    } else {
        PutChar('#');
    }

    if (single) {
        Cursor_Load();
    }
}

void DisplayBoard(Board b) {
    DrawBorder(b.window);
    for (int h = 0; h < b.height; h++) {
        Cursor_Save();
        for (int w = 0; w < b.width; w++) {
            DisplayCell(h, w, b, 0);
        } // width
        Cursor_Load();
        Cursor_Down();
    } // height
}

void UncoverBoard(Board b) {
    for (int h = 0; h < b.height; h++)
        for (int w = 0; w < b.width; w++)
            b.board[h][w] |= 4;
}

void UncoverBombs(Board b) {
    for (int h = 0; h < b.height; h++)
        for (int w = 0; w < b.width; w++)
            if (tst_bit(b.board[h][w], 0)) {
                b.board[h][w] |= 4;
                DisplayCell(h, w, b, 1);
            }
}

int UpdateCell(int row, int col, enum update_t update, Board b) {
    if (!spaceExists(row, col, b)) return -1;
    switch (update) {
        case FLAG:
            /* Cell can't be open */
            if (!tst_bit(b.board[row][col], 2))
                b.board[row][col] |= 2;
            break;
        case UNFLAG:
            b.board[row][col] ^= 2;
            break;
        case OPEN:
            /* Make sure cell isn't open or a flag */
            if (!tst_bit(b.board[row][col], 2) && 
                !tst_bit(b.board[row][col], 1)) 
            {
                b.board[row][col] |= 4;
                if (tst_bit(b.board[row][col], 0))
                    return 1;
                if (b.board[row][col] == 4) {
                    UpdateCell(row+1, col,   REC_OPEN, b);
                    UpdateCell(row-1, col,   REC_OPEN, b);
                    UpdateCell(row,   col+1, REC_OPEN, b);
                    UpdateCell(row,   col-1, REC_OPEN, b);
                }
            }
            break;
        case REC_OPEN:
            /** Make sure cell isn't open, a bomb, or a flag*/
            if (!tst_bit(b.board[row][col], 2) &&
                !tst_bit(b.board[row][col], 0) &&
                !tst_bit(b.board[row][col], 1)) {

                b.board[row][col] |= 4;

                // only expand if cell isn't a count
                if (!tst_bit(b.board[row][col], 3)) {
                    UpdateCell(row+1, col,   REC_OPEN, b);
                    UpdateCell(row-1, col,   REC_OPEN, b);
                    UpdateCell(row,   col+1, REC_OPEN, b);
                    UpdateCell(row,   col-1, REC_OPEN, b);
                }
            }
            break;
        default:;
    }
    DisplayCell(row, col, b, 1);
    return 0;
}

int UncoverCell(int row, int col, Board b) {
    return UpdateCell(row, col, OPEN, b);
}

int FlagCell(int row, int col, Board* b) {
    if (spaceExists(row, col, *b)) {
        if (!tst_bit(b->board[row][col], 1)) {   // if not flagged
            if (b->flags > 0) {
                UpdateCell(row, col, FLAG, *b);
                b->flags--;
            }
            return 1;
        } else {                                // if flagged
            UpdateCell(row, col, UNFLAG, *b);
            b->flags++;
            return -1;
        }
    }
    return 0;
}

int WinCheck(Board b)
{
    int bamt = b.height * b.width;
    for (int h = 0; h < b.height; h++)
        for (int w = 0; w < b.width; w++)
            if (tst_bit(b.board[h][w], 2)) {
                bamt--;
            }
    return bamt == b.bombs;
}
