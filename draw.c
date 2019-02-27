/**
 * @file draw.c
 * @author Andy Belle-Isle
 */
#include "draw.h"
#include "minesweeper.h"
#include "stdio.h"

Window CreateWindow(unsigned short width,  unsigned short height,
                    unsigned short row,    unsigned short column)
{
    return (Window){width,height,column,row};
}

void SetPosition(unsigned short row, unsigned short column, Window* w)
{
    w->row = row;
    w->column = column;
}

void DrawBorder(Window w)
{
    char topLeft[16];
    char left[16];
    snprintf(topLeft, 16, "\033[%d;%dH", w.row, w.column);
    PutStringSB(topLeft, 16);

    Cursor_Save(); // save top left cursor location

    PutChar('+'); // print top left +
    for (int i = 0; i < w.width-2; i++)
        PutChar('-'); // print top border
    PutStringSB("+\n\r", 3); // print top right +

    for (int x = 0; x < w.height-2; x++) {
        Cursor_Load(); // load cursor
        Cursor_Down(); // move it down
        Cursor_Save(); // save new location
        PutChar('|'); // left border
        for (int i = 0; i < w.width-2; i++)
            Cursor_Right();
        PutStringSB("|\n\r", 3);
    }

    Cursor_Load(); // load cursor
    Cursor_Down();
    PutChar('+'); // bottom left +
    for (int i = 0; i < w.width-2; i++)
        PutChar('-'); // bottom border
    PutStringSB("+\n\r", 3); // print top right +

    PutStringSB(topLeft, 16);
    PutStringSB("\033[B", 3);
    PutStringSB("\033[C", 3);
}

void Cursor_Down(void)
{
    PutStringSB("\033[B", 3);
}

void Cursor_Up(void)
{
    PutStringSB("\033[A", 3);
}

void Cursor_Left(void)
{
    PutStringSB("\033[D", 3);
}

void Cursor_Right(void)
{
    PutStringSB("\033[C", 3);
}

void Cursor_Save(void)
{
    PutStringSB("\033[s", 3);
}

void Cursor_Load(void)
{
    PutStringSB("\033[u", 3);
}

void Cursor_Move(unsigned short row, unsigned short column)
{
    char location[16];
    snprintf(location, 16, "\033[%d;%dH", row, column);
    PutStringSB(location, 16);
}

void Screen_Clear(void)
{
    PutStringSB("\033[2J", 4);
}
