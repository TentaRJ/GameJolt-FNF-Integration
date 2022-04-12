package;

import GameJolt; //this is important

class Main extends Sprite
{
	public static var gjToastManager:GJToastManager; //this is needed for the child

	//obviously your original code wont't look like this but u need u add these where they currently are.
	
	private function setupGame():Void
	{
		gjToastManager = new GJToastManager();
		addChild(gjToastManager); //adding the toddler
	}
}
