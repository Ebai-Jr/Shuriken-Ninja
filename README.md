# SHURIKEN NINJA
#### Video Demo: https://youtu.be/Cizzn1ORtiw
#### Description:
A game was created with the Lua programming language and the LOVE2D framework.
The game consist of a Ninja and Shurikens where the shurikens attack the ninja until they touch him hence ending the game. 
It starts with one shuriken at a slow speed and the number of shurikens as well as their speed increase over time.
The ninja has the ability to drop bombs and the bombs freeze any shuriken they come in contact with for 5 seconds.
The colour of the shuriken changes when it touches a bomb indicating that it has been frozen.
The speed of the ninja also increase as the number of enemies increase.
A dropped bomb will disappear after 5 seconds if no shuriken touches it.
The main screen of the game has 3 buttons, "Play game" to start the game, "Help" to see the game objectives and how to play and "Exit game" to quit the game.
When a player looses while playing the game, they are also shown a menu with 3 buttons: "Replay" to restart the game, "Menu" to go back to the main menu and "Quit" to exit the game. 

### How to Play
#### Movement keys
"W" - Up
"S" - Down
"A" - Left
"D" - Right
#### Bombs
Space Bar - Drop Bomb
#### Pause
Esc Key - Pause

### Folders
The main folders in the project are the "icon"-folder which contains the image of the game icon, the "images"-folder, which contains the images used in the project and the "sounds"-folder which contains the game sounds used for different actions like the background music, dropping bombs, freezing enemies, bomb disappearing and player loosing.

### The Different Files and Their Contents

#### The Main.lua file
This is the file which contains all the main functions and logics such as the LOVE2D load, update and draw functions which are the main functions when working with LOVE2D.
Other things specified here are the player speed, the levels which enemies respawn, logic to create a bomb at the players location, logic to change the state of the game, for example from running state to the paused state when the Esc key is pressed.
Also implemented a shockwave effect when the bomb disappears and timer logic for creating bombs so that the player can not just randomly drop bombs but can only have one bomb on the screen at a time.

#### The conf.lua file
This is the file where basic configurations are to be done. 
For my project, I used it just to specify that the game run on my second monitor when connected and the icon of the game was also specified here.

#### The Enemy.lua file
This is what was used to creat the shurikens and their logic
Added a rotation property to the shurikens and set their speed to just medium level(not too fast and not too slow).
The shurikens were also coded to come out of the screen from random directions.

#### The Button.lua file
This file contains the configurations for the buttons such as their color and onClick actions.

#### The SFX.lua file
This is the sound file.
It contains all the sounds used in the game and the playing actions.

#### Design Choices
The main idea which can to mind when creating the game was to make a survival game.
I decided to stick to something not too complex as it was my first game using lua and LOVE2D. Reason why I did not go for a design involving too many sprites and a more immersive environment.
After having the survival game in mind, the next decision to make was to select the visuals for the game. The ideas which came to mind were: making a tag game were the player evades incoming hands or a zombie type of game but I finally ended up settling with the concept of the ninja idea.
Adding a suitable background was among the final decisions for the designs. The ideas for the background were a dojo, a temple or a jungle. The theme I went after was an environment where you find ninjas but I finally ended up settling with idea of the dojo and was able to find a background to suit the concepts of the game.
I contemplated adding more obstacles on the screen but ended up deciding not to add for the moment keeping the core objective of the game as visible as possible.
Modifications can be made to the game with my progression in game development or an advanced version of the game can be made.