package;

import GameJolt.GameJoltAPI; //important
import GameJolt; //important 

class TitleState extends MusicBeatState
{
	override public function create():Void //this is where you wanna start gamejolt
	{
		//gamejolt start shit
		GameJoltAPI.connect();
                GameJoltAPI.authDaUser(FlxG.save.data.gjUser, FlxG.save.data.gjToken);
		
		//AGAIN obviously ur code won't look like this but this shit needs to be here.
	}	
}
