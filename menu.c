/**
 * @file menu.c
 * @author Andy Belle-Isle
 */
#include "menu.h"

#include "stdarg.h"
#include "stdlib.h"
#include "leader_utils.h"
#include "draw.h"

static Leaderboard **leads;
static char **options;
static Window window;
static int entries;
static int option;

void Menu_Leaderboard(size_t n, ...)
{
    leads = (Leaderboard **)malloc(n*sizeof(Leaderboard*));
    va_list ld;
    va_start(ld, n);
    Leaderboard *l;
    for (int i = 0; i < n; i++) {
        l = va_arg(ld, Leaderboard*);
        leads[i] = l;
    }
}

void Menu_Create(size_t n, ...)
{
    options = (char **)malloc(n*sizeof(char*)); 
    entries = n;
    va_list op;
    va_start(op, n);
    char *o;
    for (int i = 0; i < n; i++) {
        o = va_arg(op, char*);
        options[i] = o;
    }

    window = CreateWindow(18,n+2, 1,1);
}

void Menu_Draw(void)
{
    DrawBorder(window);
    Cursor_Save();
    for (int i = 0; i < entries; i++) {
        PutStringSB(option == i ? "> " : "  ", 2);
        PutStringSB(options[i], 16);
        Cursor_Load();
        Cursor_Down();
        Cursor_Save();
    }
}

int Menu_Run(void)
{
    char doMenu = 1;
    while(doMenu) {
        char c = GetChar();
        switch(c) {
            case 'j': // down
            case 's':
                option++;
                option %= entries;
                break;
            case 'k': // up
            case 'w':
                option--;
                option %= entries;
                break;
            case '\r': //open
                doMenu = 0;
            default:;
        }
        Menu_Draw();
    }
    return option;
}
