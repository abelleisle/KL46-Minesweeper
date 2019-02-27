/**
 * @file draw.h
 * @author Andy Belle-Isle
 */
#ifndef DRAW_H
#define DRAW_H

/**
 * @struct Window
 * Stores all data for the window
 */
typedef struct __attribute__((packed)) {
    unsigned short width;  /*<< How wide the window is */
    unsigned short height; /**< How tall the window is */
                           /** Note: All dimensions include the border */

    unsigned short column; /**< What column the top left of the window is */
    unsigned short row;    /**< What row the top left of the window is */
} Window;

/**
 * @func CreateWinedow
 * Creates a window and places it at the desired location with the desired size
 * @param width How wide the window is
 * @param height How tall the window is
 * @param row What row to place the top left of the window in
 * @param column What column to place the top left of the window in
 */
Window CreateWindow     (unsigned short width,   unsigned short height,
                         unsigned short row,     unsigned short column);

/**
 * @func SetPosition
 * Sets the position of the window
 * @param row What row to move the window to
 * @param column What column to move the window to
 * @param w A pointer to the window to modify
 */
void SetPosition        (unsigned short row, unsigned short column, Window* w);

/**
 * @func DrawBorder
 * Draws the border around the specified window and places the cursor in the
 *  top left of the content section.
 * @param w The window to draw
 */
void DrawBorder         (Window w);

inline void Cursor_Down (void); /** Moves the cursor down one row. */
inline void Cursor_Up   (void); /** Moves the cursor up one row. */
inline void Cursor_Left (void); /** Moves the cursor left one column. */
inline void Cursor_Right(void); /** Moves the cursor right one column. */
 
inline void Cursor_Save (void); /** Saves the cursor position on the screen. */
inline void Cursor_Load (void); /** Restores the saved cursor position. */

inline void Screen_Clear(void); /** Clears the terminal screen. */

/**
 * @func Cursor_Move
 * Moves the cursor to the specified location on the screen.
 * @param row What row to move the cursor to
 * @param column What column to move the cursor to
 */
void Cursor_Move        (unsigned short row, unsigned short column);

#endif //DRAW_H
