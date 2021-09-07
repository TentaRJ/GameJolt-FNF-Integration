# GameJolt FNF Integration

## This project is designed to be used with **Friday Night Funkin Mods**. This allows you to add trohies in your GameJolt gamepage and award them to the user.

### Included in the repo is the API to add trophies and the state (GameJoltLogin) to sign the user in.

### Programmed using Kade Engine 1.6.1. Support for other engines are limited, as I have not tested othe engines with this integration.

### Have any issues? Report them to the repo via <a href="https://github.com/TentaRJ/GameJolt-FNF-Integration/issues">Github Issues</a>!

### Thanks for reading this! Hope this all helps!

### -tenta

#### **Repo last updated SEPT.7.2021 Version 1.0.2 Public Beta**

# REQUIREMENTS:

I will be editing the API for this, meaning you have to download my custom haxelib library, <a href="https://github.com/TentaRJ/tentools">tentools</a>. 

You also need to download and rebuild <a href="https://github.com/TentaRJ/tentools">Haya's version of systools</a>.

## Run these in the terminal:
```
haxelib git tentools https://github.com/TentaRJ/tentools.git
haxelib git systools https://github.com/haya3218/systools
haxelib run lime rebuild systools [windows, mac, linux]
```

If you are going to be releasing the source code of a mod with this integration, you need to place a few things into `Project.xml`.
## Place these into `Project.xml`:
```xml
    	<haxelib name="tentools" />
	<haxelib name="systools" />
	<ndll name="systools" haxelib="systools" />
```

## Once that is all done, you can place `GameJolt.hx` into the `source/` folder of your project!

# SETUP:
To add your game's keys, you will need to make a file in the source folder named GJKeys.hx (filepath: ../source/GJKeys.hx).
<br>
In this file, you will need to add the GJKeys class with two public static variables, `id:Int` and `key:String`.
## `source/GJKeys.hx` example:
```hx
package;
class GJKeys
{
    public static var id:Int = 	0; // Put your game's ID here
    public static var key:String = ""; // Put your game's private API key here
}
```
## **DO NOT SHARE YOUR GAME'S API KEY! You can add `source/GJKeys.hx` to a `.gitignore` file to make sure no one grabs the key! If someone gets it, they can send false data!**

### You can find your game's API key and ID code within the game page's settngs under the game API tab.

# USAGE:

## These commands **must** be ran before starting the API. Place these in `TitleState.hx`:

```hx
GameJoltAPI.connect();
GameJoltAPI.authDaUser(FlxG.save.data.gjUser, FlxG.save.data.gjToken);
```

### Username and Token are grabbed from the default `FlxG.save` file. This file can be changed in `TitleState.hx`.

### Exiting the login menu will throw you back to Main Menu State. You can change this in the GameJoltLogin class inside GameJolt.hx.

### The session will automatically start on login and will be pinged every 30 seconds. If it isn't pinged within 120 seconds, the session automatically ends from GameJolt's side.

## You can open the login state by calling the GameJoltLogin state:
```hx
FlxG.switchState(new GameJoltLogin());
```

# Commands available:

`GameJoltAPI.checkStatus():Bool`
> Checking to see if the user has signed in. Returns a `bool` value. `true` if signed in, `false` if not signed in.

`GameJoltAPI.getuserInfo(username):String`
> Grabs the username and usertoken of the user and returns a `String`. <br>`username:Bool = true` -> `true` to grab username, `false` to grab usertoken.

`GameJoltAPI.getTrophy(trophyID);`
> `TrophyID:Int` -> ID of the trophy you want the player to earn.

# Credits

- BrightFyre - Testing the API with Entity Origins
- Haya - Systools fork
