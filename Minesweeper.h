/**
 * @file Minesweeper.h
 * @author Andy Belle-Isle
 */
#ifndef MINESWEEPER_H
#define MINESWEEPER_H

extern int Count; /**< How many seconds have passed in the game. */
extern int Seeder; /**< A time counter for seeding rand. */
extern char RunStopWatch; /**< A switch for running the stopwatch. */

char GetChar        (void);
void PutChar        (char);

void GetStringSB    (char*, int);
void PutStringSB    (char*, int);

void PutNumHex      (unsigned int);
void PutNumUB       (unsigned short int);

void Init_UART0_IRQ (void);
void Init_PIT_IRQ   (void);
void InitLCD        (void);
void LCD_PutHex     (unsigned int);

#endif //MINESWEEPER_H
