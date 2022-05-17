# GameJolt FNF Integration

## This project is designed to be used with **Friday Night Funkin**. This allows you to add trohies in your GameJolt gamepage and award them to the user along with adding scores to leaderboard tables!

### Included in the repo is the API to add trophies and the state (GameJoltLogin) to sign the user in.

### Have any issues? Report them to the repo via <a href="https://github.com/TentaRJ/GameJolt-FNF-Integration/issues">Github Issues</a>!

### -tenta

# PLANS:

### <a href="https://github.com/TentaRJ/GameJolt-FNF-Integration/projects/1">Github Project link</a>

# REQUIREMENTS:

I will be editing the API for this, meaning you have to download my custom haxelib library, <a href="https://github.com/TentaRJ/tentools">tentools</a>. 

You also need to download and rebuild <a href="https://github.com/haya3218/systools">Haya's version of systools</a>.

### Run these in the terminal:
```
haxelib git tentools https://github.com/TentaRJ/tentools.git
haxelib git systools https://github.com/haya3218/systools
haxelib run lime rebuild systools [windows, mac, linux]
```

If you are going to be releasing the source code of a mod with this integration, you need to place a few things into `Project.xml`.
### Place these into `Project.xml`:
```xml
<haxelib name="tentools" />
<haxelib name="systools" />
<ndll name="systools" haxelib="systools" />
```

###Important : Make sure Flixel is up to date. (4.11.0)
Without Flixel as 4.11.0 and up, Toasts Will Not Appear. The Achievement Still Gives Or Something, Just No Notification.

### Once that is all done, you can place `GameJolt.hx` into the `source/` folder of your project!

# SETUP (GAMEJOLT):

Make sure to add `import GameJolt;` at the top of `main.hx`!

To add your game's keys, you will need to make a file in the source folder named GJKeys.hx (filepath: ../source/GJKeys.hx).
<br>
In this file, you will need to add the GJKeys class with two public static variables, `id:Int` and `key:String`.

### `source/GJKeys.hx` example:
```hx
package;
class GJKeys
{
    public static var id:Int = 	0; // Put your game's ID here
    public static var key:String = ""; // Put your game's private API key here
}
```
### **DO NOT SHARE YOUR GAME'S API KEY! You can add `source/GJKeys.hx` to a `.gitignore` file to make sure no one grabs the key! If someone gets it, they can send false data!**

### You can find your game's API key and ID code within the game page's settngs under the game API tab.

# SETUP (TOASTS):

## **Thank you Firubii for the code for this! Please go check them out!**
**https://twitter.com/firubiii / https://github.com/firubii**

To setup toasts, you will need to do a few things.

Inside the Main class (Main.hx), you need to make a new variable called toastManager.

`Main.hx`
```haxe
public static var gjToastManager:GJToastManager;
```

Inside the setupGame function in the Main class, you will need to create the toastManager.
```haxe
gjToastManager = new GJToastManager();
addChild(gjToastManager);
```

TYSM Firubii for your help!

# USAGE:

## Make sure to put `import GameJolt.GameJoltAPI;` at the top of the file if you want to call a command!

```hx
import GameJolt.GameJoltAPI;
```

## These commands **must** be ran before starting the API. Place these in `TitleState.hx`:

```hx
GameJoltAPI.connect();
GameJoltAPI.authDaUser(FlxG.save.data.gjUser, FlxG.save.data.gjToken);
```

### Username and Token are grabbed from the default `FlxG.save` file. This file can be changed in `TitleState.hx`.

### Exiting the login menu will throw you back to Main Menu State. You can change this in the GameJoltLogin class inside GameJolt.hx.

### The session will automatically start on login and will be pinged every 30 seconds. If it isn't pinged within 120 seconds, the session automatically ends from GameJolt's side.

### You can open the login state by calling the GameJoltLogin state:
```hx
FlxG.switchState(new GameJoltLogin());
```

# CHANGABLE VARIABLES:

`GameJoltInfo.changeState:FlxUIState`
> The state you will call back to after hitting ESCAPE or CONTINUE

`GameJoltInfo.font:String`
> The font used in GameJoltLogin

`GameJoltInfo.fontPath:String`
> The font path used for the notifications

`GameJoltInfo.imagePath:String`
> The file path for the image in the notifications.

# COMMANDS AVAILABLE:

`GameJoltAPI.getStatus():Bool`
> Checking to see if the user has signed in. Returns a `bool` value. `true` if signed in, `false` if not signed in.

`GameJoltAPI.getuserInfo(username):String`
> Grabs the username and usertoken of the user and returns a `String`.<br>
> `username:Bool = true` -> `true` to grab username, `false` to grab usertoken.

`GameJoltAPI.getTrophy(trophyID);`
> `TrophyID:Int` -> ID of the trophy you want the player to earn.

`GameJoltAPI.checkTrophy(trophyID);`
> Returns a `bool` value of the achieved status. `True` for achieved, `false` for not achieved.<br>
> `TrophyID:Int` -> ID of the trophy you want to check.

`GameJoltAPI.pullTrophy(trophyID);`
> Returns a `Map<String,String>` of the trophy called for.<br>
> `TrophyID:Int` -> ID of the trophy you want to pull.

`GameJoltAPI.addScore(score:Int, tableID:Int, ?extraData:String);`
> Adds a score to a table on GameJolt.<br>
> `score:Int` -> The score to add. Will also count as the sorting value.<br>
> `tableID:Int` -> ID of the table.<br>
> `extraData:String` -> Exta data you want to add. Could be accuracy, who knows.

`GameJoltAPI.pullHighScore(tableID:Int)`
> Pulls the data from the highest score on the table. Will return a `Map<String,String>` value.<br>
> `tableID:Int` -> ID of the table.<br>
> Values returned -> `score, sort, user_id, user, extra_data, stored, guest, success`

# CREDITS:

- <a href = "https://github.com/brightfyregit">BrightFyre</a> - Testing and UI design
- <a href ="https://github.com/haya3218">Haya</a> - Systools fork
- <a href = "https://github.com/firubii">Firubii</a> - Toast system
