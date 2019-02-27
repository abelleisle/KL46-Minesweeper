/**
 * @file game.c
 * @author Andy Belle-Isle
 */
#include "stdlib.h"
#include "stdio.h"

#include "minesweeper.h"
#include "game.h"
#include "board_utils.h"
#include "leader_utils.h"

static Board b;
static char *curMove;
static Leaderboard leaderboard;

void Game_GenerateItems(int difficulty, Leaderboard l)
{
    leaderboard = l;
    switch (difficulty+1) {
        case 1:
            b = GenerateBoard(8, 8, 10);
            break;
        case 2:
            b = GenerateBoard(16, 16, 40);
            break;
        case 3:
            b = GenerateBoard(30, 16, 99);
            break;
        default:;
    }

    SetPosition(4, 1, &b.window);
    curMove = (char*)malloc(16);
}

int Draw_Header(void)
{
    Cursor_Move(1,1);
    PutStringSB("Flags: ", 7);
    Cursor_Move(2,1);
    PutStringSB("Score to beat: ", 15);
}

int Draw_HeaderData(void)
{
    char buf[16];
    Cursor_Move(1,8);
    snprintf(buf, 16, "%d ", b.flags);
    PutStringSB(buf, 16);
    Cursor_Move(2,16);
    PrintScore(PlayerToBeat((Score){Count, "USR"}, leaderboard));
}

int Game_RunGame(void)
{
    char c = 0;
    int run = 1;
    int loss = 0;
    int win = 0;

    int cur_row = 0;
    int cur_col = 0;

    //UncoverBoard(b);

    Draw_Header();
    DisplayBoard(b);            // draw the board
    Cursor_Move(b.window.row+1, b.window.column+1);

    RunStopWatch = 1; // starts the stop watch

    while(run && !loss && !win) {
        Cursor_Save();
        Draw_HeaderData();
        Cursor_Load();
        c = GetChar();
        switch(c) {
            case 3:   // ^C
                loss = 1;
                break;
            case 'j': // down
            case 's':
                if (cur_row < b.height-1) {
                    cur_row++;
                    Cursor_Down();
                }
                break;
            case 'k': // up
            case 'w':
                if (cur_row > 0) {
                    cur_row--;
                    Cursor_Up();
                }
                break;
            case 'l': // right
            case 'd':
                if (cur_col < b.width-1) {
                    cur_col++;
                    Cursor_Right();
                }
                break;
            case 'h': // left
            case 'a':
                if (cur_col > 0) {
                    cur_col--;
                    Cursor_Left();
                }
                break;
            case 'f': // flag
                FlagCell(cur_row, cur_col, &b);
                break;
            case '\r': //open
                /* player uncovers a bomb, so they lose */
                if (UncoverCell(cur_row, cur_col, b)) {
                    UncoverBombs(b);
                    loss = 1;
                } else {
                    if (WinCheck(b))
                        win = 1;
                }
                break;
            default:;
        }
    }

    RunStopWatch = 0; // stops the stop watch

    if (loss) {
        Window lost = CreateWindow(11, 3, 1, 1);
        DrawBorder(lost);
        PutStringSB("You lost!",9);
    } else if (win) {
        Window won = CreateWindow(10, 3, 1, 1);
        DrawBorder(won);
        PutStringSB("You won!", 8);
    }

    GetChar();
    
    return win;
}

void Game_CleanUp(void)
{
    free(curMove);
}
