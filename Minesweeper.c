/**
 * @file Minesweeper.c
 * @author Andy Belle-Isle
 */
#include "MKL46Z4.h"
#include "Minesweeper.h"
#include "stdio.h"
#include "stdlib.h"

#include "board_utils.h"
#include "leader_utils.h"
#include "num_utils.h"
#include "game.h"
#include "menu.h"

#pragma import(__use_realtime_heap)

extern int Count;
extern int Seeder;
extern char RunStopWatch;

void notherfunc(void);

void init_kl46(void) {
    __asm("CPSID    I");
    Init_UART0_IRQ();
    InitLCD();
    Init_PIT_IRQ();
    __asm("CPSIE    I");
}

int main (void) {
    Count = 0;
    RunStopWatch = 0;
    
    init_kl46();

    Score es[10] = {{1234, "esy"}, 
                   {1235, "esy"},
                   {1236, "esy"},
                   {1237, "esy"},
                   {1238, "esy"},
                   {1239, "esy"},
                   {1240, "esy"},
                   {1241, "esy"},
                   {1242, "esy"},
                   {5635, "abc"}};
    
    Score ms[10] = {{1234, "med"}, 
                   {1235, "med"},
                   {1236, "med"},
                   {1237, "med"},
                   {1238, "med"},
                   {1239, "med"},
                   {1240, "med"},
                   {1241, "med"},
                   {1242, "med"},
                   {5635, "med"}};
    
    Score hs[10] = {{1234, "hrd"}, 
                   {1235, "hrd"},
                   {1236, "hrd"},
                   {1237, "hrd"},
                   {1238, "hrd"},
                   {1239, "hrd"},
                   {1240, "hrd"},
                   {1241, "hrd"},
                   {1242, "hrd"},
                   {5635, "hrd"}};

    Leaderboard easy = CreateLeader(es, 10);
    Leaderboard med = CreateLeader(ms, 10);
    Leaderboard hard = CreateLeader(hs, 10);            
    easy.window = CreateWindow(11, 12, 2, 1);
    med.window =  CreateWindow(11, 12, 2, 13);
    hard.window = CreateWindow(11, 12, 2, 25);

    Menu_Leaderboard(1, easy, med, hard);
    Menu_Create(4, "Easy", "Medium", "Hard", "Leaderboards");
                   
    while(1) {
        Screen_Clear();
        Menu_Draw();
        int difficulty = Menu_Run();

        PutStringSB("\033[?1049h",8);   // open scrollback terminal
        
        // wants to view leaderboards
        if (difficulty == 3) {
            Cursor_Move(easy.window.row-1, easy.window.column);
            PutStringSB("Easy", 4);
            PrintLeaderboard(easy);
            
            Cursor_Move(med.window.row-1, med.window.column);
            PutStringSB("Medium", 6);
            PrintLeaderboard(med);
            
            Cursor_Move(hard.window.row-1, hard.window.column);
            PutStringSB("Hard", 4);
            PrintLeaderboard(hard);
            
            GetChar();
        // wants to play a game
        } else {
            sprand(Seeder);
            switch(difficulty){
                case 0: Game_GenerateItems(difficulty, easy); break;
                case 1: Game_GenerateItems(difficulty, med); break;
                case 2: Game_GenerateItems(difficulty, hard); break;
                default:Game_GenerateItems(difficulty, easy);
            }

            
            if (Game_RunGame())
                switch (difficulty) { // if player wins the game add them to the scoreboard
                    case 0:
                        InsertPlayer((Score){Count, "USR"}, &easy);
                        break;
                    case 1:
                        InsertPlayer((Score){Count, "USR"}, &med);
                        break;
                    case 2:
                        InsertPlayer((Score){Count, "USR"}, &hard);
                        break;
                    default:;
                }
            
            Game_CleanUp();
        }

        PutStringSB("\033[?1049l",8);   // close scrollback terminal
    }

    return 0;
}
