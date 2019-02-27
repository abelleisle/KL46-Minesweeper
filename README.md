# KL46-Minesweeper

This is a basic minesweeper game for the KL46 Microprocessor.
This was done as an alternate laboratory exercise for an Introduction to Embedded Systems class.

This version of the game was developed for the FRDM-KL46Z development board, 
and a large amount of the code was written in Assembly, so porting it to another board might be rather difficult as this
uses a fairy substantional amount of the special features of the board 
(7 segment display, GPIO Interrupts, Serial over USB, etc...)

## The Game
The game is very simple, and when it starts, it presents the user with a menu to select an option
```
> Easy
  Medium
  Hard
  Leaderboards
```
The user can use either the 'WASD' keys or 'HJKL' keys to move the cursor around.

Once the user starts a game they will see the following:
```
Flags: 10
Score to beat: 1234 ESY

+--------+
|        |
|        |
|        |
|        |
|        |
|        |
|        |
|        |
+--------+
```

The user can move their cursor around the board and use the 'F' key to flag a space, and the '\<Return\>' key to open up a space.

The amount of time that has passed since the user has started their game can be seen on the 7 segment display embedded on the
KL46 board.

## TODO
As this project is still interesting to me, I will hopefully find the time to add on some extra features.
I hope to add the following:
* Storing leaderboard on flash memory
* Allowing user to enter their own 3 letter tag for leaderboards.
* Adding external methods for displaying/controlling the game
  * SPI driven screen
  * GPIO Buttons
  * Various Sensors
