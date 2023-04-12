package;

// GameJolt things
import flixel.addons.ui.FlxUIState;
import tentools.api.FlxGameJolt as GJApi;
// Login things
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIInputText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import lime.system.System;
// Toast things
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

using StringTools;

class GameJoltAPI // Connects to tentools.api.FlxGameJolt
{
	/**
	 * Inline variable to see if the user has logged in.
	 * True for logged in, false for not logged in. (Read Only!)
	 */
	public static var userLogin(default, null):Bool = false; // For User Login Achievement (Like IC)

	/**
	 * Inline variable to see if the user wants to submit scores.
	 */
	public static var leaderboardToggle:Bool;

	/**
	 * Grabs the username of the actual logged in user and returns it
	 * @param username Bool value
	 * @return String 
	 */
	public static function getUser():String
		return GJApi.username;

	/**
	 * Grabs the game token of the actual logged in user and returns it
	 * @param username Bool value
	 * @return String 
	 */
	public static function getToken():String
		return GJApi.usertoken;

	/**
	 * Sets the game API key from GJKeys.api
	 * Doesn't return anything
	 */
	public static function connect() {
		trace("Grabbing API keys...");

		GJApi.init(Std.int(GJKeys.id), Std.string(GJKeys.key), function(data:Bool) {
			#if debug
			var daDesc:String = "If you are a developer, check GJKeys.hx\nMake sure the id and key are formatted correctly!";
			Main.gjToastManager.createToast(GameJoltInfo.imagePath, 'Game${!data ? " not" : ""} authenticated!', !data ? daDesc : "Success!");
			#end
		});
	}

	/**
	 * Inline function to auth the user. Shouldn't be used outside of GameJoltAPI things.
	 * @param in1 username
	 * @param in2 token
	 * @param loginArg Used in only GameJoltLogin
	 */
	public static function authDaUser(in1:String, in2:String, ?loginArg:Bool = false) {
		if (!userLogin && in1 != "" && in2 != "") {
			GJApi.authUser(in1, in2, function(v:Bool) {
				trace("User: " + in1);
				trace("Token: " + in2);

				if (v) {
					Main.gjToastManager.createToast(GameJoltInfo.imagePath, 'SIGNED IN: ${in1.toUpperCase()}', "CONNECTED TO GAMEJOLT!");
					trace("User authenticated!");
					FlxG.save.data.gjUser = in1;
					FlxG.save.data.gjToken = in2;
					FlxG.save.flush();
					userLogin = true;
					startSession();
					if (loginArg) {
						GameJoltLogin.login = true;
						FlxG.switchState(new GameJoltLogin());
					}
				} else {
					if (loginArg) {
						GameJoltLogin.login = true;
						FlxG.switchState(new GameJoltLogin());
					}
					Main.gjToastManager.createToast(GameJoltInfo.imagePath, "Not signed in!\nSign in to save GameJolt Trophies and Leaderboard Scores!", "");
					trace("User login failure!");
					// FlxG.switchState(new GameJoltLogin());
				}
			});
		}
	}

	/**
	 * Inline function to deauth the user, shouldn't be used out of GameJoltLogin state!
	 * @return  Logs the user out and closes the game
	 */
	public static function deAuthDaUser() {
		closeSession();
		userLogin = false;
		trace('User: ${FlxG.save.data.gjUser} | Token: ${FlxG.save.data.gjToken}');
		FlxG.save.data.gjUser = "";
		FlxG.save.data.gjToken = "";
		FlxG.save.flush();
		trace("Logged out!");
		System.exit(0);
	}

	/**
	 * Awards a trophy to the user!
	 * @param id Trophy ID. Check your game's API settings for trophy IDs.
	 */
	public static function getTrophy(id:Int) {
		if (userLogin)
			GJApi.addTrophy(id, (data:Map<String, String>) -> trace(!data.exists("message") ? data : 'Could not add Trophy [$id] : ${data.get("message")}'));
	}

	/**
	 * Checks a trophy to see if it was collected
	 * @param id Trophy ID
	 * @return Bool (True for achieved, false for unachieved)
	 */
	public static function checkTrophy(id:Int):Bool {
		var value:Bool = false;
		var trophy:Null<Map<String, String>> = pullTrophy(id);

		if (trophy != null) {
			value = trophy.get("achieved") == "true";
			trace('Trophy state [$id]: ${value ? "achieved" : "unachieved"}');
		}

		return value;
	}

	public static function pullTrophy(id:Int):Null<Map<String, String>> {
		var returnable:Map<String, String> = [];

		GJApi.fetchTrophy(id, (data:Map<String, String>) -> returnable = data);
		if (returnable.exists("message")) {
			trace('Failed to pull trophy [$id] : ${returnable.get("message")}');
			return null;
		}
		return returnable;
	}

	/**
	 * Add a score to a table!
	 * @param score Score of the song. **Can only be an int value!**
	 * @param tableID ID of the table you want to add the score to!
	 * @param extraData (Optional) You could put accuracy or any other details here!
	 */
	public static function addScore(score:Int, tableID:Int, ?extraData:String) {
		var retFormat:String = 'Score: $score';
		if (GameJoltAPI.leaderboardToggle) {
			trace("Trying to add a score");
			var formData:Null<String> = extraData != null ? extraData.split(" ").join("%20") : null;

			if (formData != null)
				retFormat += '\nExtra Data: $formData';

			GJApi.addScore(score + "%20Points", score, tableID, false, null, formData, function(data:Map<String, String>) {
				trace("Score submitted with a result of: " + data.get("success"));
				Main.gjToastManager.createToast(GameJoltInfo.imagePath, "Score submitted!", retFormat, true);
			});
		} else {
			if (extraData != null)
				retFormat += '\nExtra Data: $extraData';

			retFormat += "\nScore was not submitted due to score submitting being disabled!";
			Main.gjToastManager.createToast(GameJoltInfo.imagePath, "Score not submitted!", retFormat, true);
		}
	}

	/**
	 * Return the highest score from a table!
	 * 
	 * Usable by pulling the data from the map by [function].get();
	 * 
	 * Values returned in the map: score, sort, user_id, user, extra_data, stored, guest, success
	 * 
	 * @param id The table you want to pull from
	 * @return Map<String,String> or null if not available
	 */
	public static function pullHighScore(id:Int):Null<Map<String, String>> {
		var returnable:Null<Map<String, String>>;
		GJApi.fetchScore(id, 1, function(data:Map<String, String>) {
			if (!data.exists('message')) {
				trace('Could not pull High Score from Table [$id] :' + data.get('message'));
				returnable = null;
			} else {
				trace(data);
				returnable = data;
			}
		});
		return returnable;
	}

	/**
	 * Inline function to start the session. Shouldn't be used out of GameJoltAPI
	 * Starts the session
	 */
	public static function startSession() {
		GJApi.openSession(function() {
			trace("Session started!");
			new FlxTimer().start(20, tmr -> pingSession(), 0);
		});
	}

	/**
	 * Tells GameJolt that you are still active!
	 * Called every 20 seconds by a loop in startSession().
	 */
	public static function pingSession()
		GJApi.pingSession(true, () -> trace("Ping!"));

	/**
	 * Closes the session, used for signing out
	 */
	public static function closeSession()
		GJApi.closeSession(() -> trace('Closed out the session'));
}

class GameJoltInfo {
	/**
	 * Variable to change which state to go to by hitting ESCAPE or the CONTINUE buttons.
	 */
	public static var changeState:FlxUIState = new MainMenuState();

	/**
	 * Inline variable to change the font for the GameJolt API elements. **Example: `Paths.font("vcr.ttf");`**
	 * @param font You can change the font by doing **Paths.font([Name of your font file])** or by listing your file path.
	 * If *null*, will default to the normal font.
	 */
	public static var font:String = null;

	/**
	 * Inline variable to change the font for the notifications made by Firubii.
	 * 
	 * Don't make it a NULL variable. Worst mistake of my life.
	 */
	public static var fontPath:String = "assets/fonts/vcr.ttf";

	/**
	 * Image to show for notifications. Leave NULL for no image, it's all good :)
	 * 
	 * Example: `Paths.getLibraryPath("images/stepmania-icon.png");`
	 */
	public static var imagePath:String = null;

	/* Other things that shouldn't be messed with are below this line! */
	/**
	 * GameJolt + FNF version.
	 */
	public static var version:String = "1.1";

	/**
	 * Random quotes I got from other people. Nothing more, nothing less. Just for funny.
	 */
}

class GameJoltLogin extends MusicBeatState {
	var loginTexts:FlxTypedGroup<FlxText>;
	var loginBoxes:FlxTypedGroup<FlxUIInputText>;
	var loginButtons:FlxTypedGroup<FlxButton>;
	var usernameText:FlxText;
	var tokenText:FlxText;
	var usernameBox:FlxUIInputText;
	var tokenBox:FlxUIInputText;
	var signInBox:FlxButton;
	var helpBox:FlxButton;
	var logOutBox:FlxButton;
	var cancelBox:FlxButton;
	// var profileIcon:FlxSprite;
	var username1:FlxText;
	var username2:FlxText;

	// var gamename:FlxText;
	// var trophy:FlxBar;
	// var trophyText:FlxText;
	// var missTrophyText:FlxText;
	public static var charBop:FlxSprite;

	// var icon:FlxSprite;
	var baseX:Int = -190;

	public static var login:Bool = false;

	// static var trophyCheck:Bool = false;
	override function create() {
		if (FlxG.save.data.lbToggle != null)
			GameJoltAPI.leaderboardToggle = FlxG.save.data.lbToggle;

		if (!login) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(2, 0, 0.85);
		}

		trace("GJ Api Initialized? : " + Std.string(GJApi.initialized));
		FlxG.mouse.visible = true;

		Conductor.changeBPM(102);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat', 'preload'));
		bg.setGraphicSize(FlxG.width);
		bg.antialiasing = true;
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set();
		bg.alpha = 0.25;
		add(bg);

		charBop = new FlxSprite(FlxG.width - 400, 250);
		charBop.frames = Paths.getSparrowAtlas('characters/BOYFRIEND', 'shared');
		charBop.animation.addByPrefix('idle', 'BF idle dance', 24, false);
		charBop.animation.addByPrefix('loggedin', 'BF HEY', 24, false);
		charBop.setGraphicSize(Std.int(charBop.width * 1.4));
		charBop.antialiasing = true;
		charBop.flipX = false;
		add(charBop);

		loginTexts = new FlxTypedGroup<FlxText>(2);
		add(loginTexts);

		usernameText = new FlxText(0, 125, 300, "Username:", 20);
		tokenText = new FlxText(0, 225, 300, "Token:", 20);

		loginTexts.add(usernameText);
		loginTexts.add(tokenText);
		loginTexts.forEach(function(item:FlxText) {
			item.screenCenter(X);
			item.x += baseX;
			item.font = GameJoltInfo.font;
		});

		loginBoxes = new FlxTypedGroup<FlxUIInputText>(2);
		add(loginBoxes);

		usernameBox = new FlxUIInputText(0, 175, 300, null, 32, FlxColor.BLACK, FlxColor.GRAY);
		tokenBox = new FlxUIInputText(0, 275, 300, null, 32, FlxColor.BLACK, FlxColor.GRAY);

		loginBoxes.add(usernameBox);
		loginBoxes.add(tokenBox);
		loginBoxes.forEach(function(item:FlxUIInputText) {
			item.screenCenter(X);
			item.x += baseX;
			item.font = GameJoltInfo.font;
		});

		if (GameJoltAPI.userLogin) {
			remove(loginTexts);
			remove(loginBoxes);
		}

		loginButtons = new FlxTypedGroup<FlxButton>(3);
		add(loginButtons);

		signInBox = new FlxButton(0, 475, "Sign In", function() {
			trace(usernameBox.text);
			trace(tokenBox.text);
			GameJoltAPI.authDaUser(usernameBox.text, tokenBox.text, true);
		});

		helpBox = new FlxButton(0, 550, "GameJolt Token", function() {
			if (!GameJoltAPI.userLogin)
				openLink('https://www.youtube.com/watch?v=T5-x7kAGGnE');
			else {
				GameJoltAPI.leaderboardToggle = !GameJoltAPI.leaderboardToggle;
				FlxG.save.data.lbToggle = GameJoltAPI.leaderboardToggle;
				Main.gjToastManager.createToast(GameJoltInfo.imagePath, "Score Submitting",
					"Score submitting is now " + (GameJoltAPI.leaderboardToggle ? "enabled" : "disabled"));
			}
		});

		helpBox.color = FlxColor.fromRGB(84, 155, 149);
		logOutBox = new FlxButton(0, 625, "Log Out & Close", () -> GameJoltAPI.deAuthDaUser());
		logOutBox.color = FlxColor.RED; // FlxColor.fromRGB(255, 134, 61);

		cancelBox = new FlxButton(0, 625, "Not Right Now", function() {
			FlxG.save.flush();
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7, false, null, true, () -> FlxG.switchState(GameJoltInfo.changeState));
		});

		if (!GameJoltAPI.userLogin)
			loginButtons.add(signInBox);
		else {
			cancelBox.y = 475;
			cancelBox.text = "Continue";
			loginButtons.add(logOutBox);
		}
		loginButtons.add(helpBox);
		loginButtons.add(cancelBox);

		loginButtons.forEach(function(item:FlxButton) {
			item.screenCenter(X);
			item.setGraphicSize(Std.int(item.width) * 3);
			item.x += baseX;
		});

		if (GameJoltAPI.userLogin) {
			username1 = new FlxText(0, 95, 0, "Signed in as:", 40);
			username1.alignment = CENTER;
			username1.screenCenter(X);
			username1.x += baseX;
			add(username1);

			username2 = new FlxText(0, 145, 0, "" + GameJoltAPI.getUser() + "", 40);
			username2.alignment = CENTER;
			username2.screenCenter(X);
			username2.x += baseX;
			add(username2);
		}

		if (GameJoltInfo.font != null) {
			username1.font = GameJoltInfo.font;
			username2.font = GameJoltInfo.font;
			loginBoxes.forEach(item -> item.font = GameJoltInfo.font);
			loginTexts.forEach(item -> item.font = GameJoltInfo.font);
		}
	}

	override function update(elapsed:Float) {
		if (FlxG.save.data.lbToggle == null) {
			FlxG.save.data.lbToggle = false;
			FlxG.save.flush();
		}

		if (GameJoltAPI.userLogin) {
			helpBox.text = "Leaderboards:\n" + (GameJoltAPI.leaderboardToggle ? "Enabled" : "Disabled");
			helpBox.color = (GameJoltAPI.leaderboardToggle ? FlxColor.GREEN : FlxColor.RED);
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

		if (FlxG.keys.justPressed.ESCAPE) {
			FlxG.save.flush();
			FlxG.mouse.visible = false;
			FlxG.switchState(GameJoltInfo.changeState);
		}

		super.update(elapsed);
	}

	override function beatHit() {
		super.beatHit();
		// charBop.animation.play((GameJoltAPI.userLogin ? "loggedin" : "idle"));
	}

	function openLink(url:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [url, "&"]);
		#else
		FlxG.openURL(url);
		#end
	}
}

/*The toast things, pulled from Hololive Funkin
 * Thank you Firubii for the code for this!
 * https://twitter.com/firubiii
 * https://github.com/firubii
 * ILYSM
 */
class GJToastManager extends Sprite {
	public static var ENTER_TIME:Float = 0.5;
	public static var DISPLAY_TIME:Float = 3.0;
	public static var LEAVE_TIME:Float = 0.5;
	public static var TOTAL_TIME:Float = ENTER_TIME + DISPLAY_TIME + LEAVE_TIME;

	var playTime:FlxTimer = new FlxTimer();

	public function new() {
		super();
		FlxG.signals.postStateSwitch.add(onStateSwitch);
		FlxG.signals.gameResized.add(onWindowResized);
	}

	/**
	 * Create a toast!
	 * 
	 * Usage: **Main.gjToastManager.createToast(iconPath, title, description);**
	 * @param iconPath Path for the image **Paths.getLibraryPath("image/example.png")** (Set to null if you won't add an image, it's all OK)
	 * @param title Title for the toast
	 * @param description Description for the toast
	 * @param sound Want to have an alert sound? Set this to **true**! Defaults to **false**.
	 */
	public function createToast(iconPath:Null<String>, title:String, description:String, sound:Bool = false, color:String = '#3848CC'):Void {
		if (sound)
			FlxG.sound.play(Paths.sound('confirmMenu'));

		var toast = new Toast(iconPath, title, description, color);
		addChild(toast);

		playTime.start(TOTAL_TIME);
		playToasts();
	}

	public function playToasts():Void {
		for (i in 0...numChildren) {
			var child = getChildAt(i);
			FlxTween.cancelTweensOf(child);
			FlxTween.tween(child, {y: (numChildren - 1 - i) * child.height}, ENTER_TIME, {
				ease: FlxEase.quadOut,
				onComplete: function(tween:FlxTween) {
					FlxTween.cancelTweensOf(child);
					FlxTween.tween(child, {y: (i + 1) * -child.height}, LEAVE_TIME, {
						ease: FlxEase.quadOut,
						startDelay: DISPLAY_TIME,
						onComplete: function(tween:FlxTween) {
							cast(child, Toast).removeChildren();
							removeChild(child);
						}
					});
				}
			});
		}
	}

	public function collapseToasts():Void {
		for (i in 0...numChildren) {
			var child = getChildAt(i);
			FlxTween.tween(child, {y: (i + 1) * -child.height}, LEAVE_TIME, {
				ease: FlxEase.quadOut,
				onComplete: function(tween:FlxTween) {
					cast(child, Toast).removeChildren();
					removeChild(child);
				}
			});
		}
	}

	public function onStateSwitch():Void {
		if (!playTime.active)
			return;

		var elapsedSec = playTime.elapsedTime / 1000;
		if (elapsedSec < ENTER_TIME) {
			for (i in 0...numChildren) {
				var child = getChildAt(i);
				FlxTween.cancelTweensOf(child);
				FlxTween.tween(child, {y: (numChildren - 1 - i) * child.height}, ENTER_TIME - elapsedSec, {
					ease: FlxEase.quadOut,
					onComplete: function(tween:FlxTween) {
						FlxTween.cancelTweensOf(child);
						FlxTween.tween(child, {y: (i + 1) * -child.height}, LEAVE_TIME, {
							ease: FlxEase.quadOut,
							startDelay: DISPLAY_TIME,
							onComplete: function(tween:FlxTween) {
								cast(child, Toast).removeChildren();
								removeChild(child);
							}
						});
					}
				});
			}
		} else if (elapsedSec < DISPLAY_TIME) {
			for (i in 0...numChildren) {
				var child = getChildAt(i);
				FlxTween.cancelTweensOf(child);
				FlxTween.tween(child, {y: (i + 1) * -child.height}, LEAVE_TIME, {
					ease: FlxEase.quadOut,
					startDelay: DISPLAY_TIME - (elapsedSec - ENTER_TIME),
					onComplete: function(tween:FlxTween) {
						cast(child, Toast).removeChildren();
						removeChild(child);
					}
				});
			}
		} else if (elapsedSec < LEAVE_TIME) {
			for (i in 0...numChildren) {
				var child = getChildAt(i);
				FlxTween.tween(child, {y: (i + 1) * -child.height}, LEAVE_TIME - (elapsedSec - ENTER_TIME - DISPLAY_TIME), {
					ease: FlxEase.quadOut,
					onComplete: function(tween:FlxTween) {
						cast(child, Toast).removeChildren();
						removeChild(child);
					}
				});
			}
		}
	}

	public function onWindowResized(x:Int, y:Int):Void {
		for (i in 0...numChildren) {
			var child = getChildAt(i);
			child.x = Lib.current.stage.stageWidth - child.width;
		}
	}
}

class Toast extends Sprite {
	var back:Bitmap;
	var icon:Bitmap;
	var title:TextField;
	var desc:TextField;

	public function new(iconPath:Null<String>, titleText:String, description:String, color:String = '#3848CC') {
		super();
		back = new Bitmap(new BitmapData(500, 125, true, 0xFF000000));
		back.alpha = 0.9;
		back.x = back.y = 0;

		if (iconPath != null) {
			var iconBmp = FlxG.bitmap.add(Paths.image(iconPath));
			iconBmp.persist = true;
			icon = new Bitmap(iconBmp.bitmap);
			icon.width = 100;
			icon.height = 100;
			icon.x = 10;
			icon.y = 10;
		}

		title = new TextField();
		title.text = titleText.toUpperCase();
		title.setTextFormat(new TextFormat(openfl.utils.Assets.getFont(GameJoltInfo.fontPath).fontName, 30, FlxColor.fromString(color), true));
		title.wordWrap = true;
		title.width = 360;
		title.x = iconPath != null ? 120 : 5;
		title.y = 5;

		desc = new TextField();
		desc.text = description.toUpperCase();
		desc.setTextFormat(new TextFormat(openfl.utils.Assets.getFont(GameJoltInfo.fontPath).fontName, 24, FlxColor.WHITE));
		desc.wordWrap = true;
		desc.width = 360;
		desc.height = 95;
		desc.x = iconPath != null ? 120 : 5;
		desc.y = 35;

		if (titleText.length >= 25 || titleText.contains("\n")) {
			desc.y += 25;
			desc.height -= 25;
		}

		addChild(back);

		if (iconPath != null)
			addChild(icon);

		addChild(title);
		addChild(desc);

		width = back.width;
		height = back.height;
		x = Lib.current.stage.stageWidth - width;
		y = -height;
	}
}
