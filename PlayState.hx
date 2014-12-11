package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

import Controller;
import AbilityBase;


class ControlDefaults
{
	public inline static var kSpaceBar : String = "SPACE";
	public inline static var kShift : String = "SHIFT";
}



/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	public var gameController : Controller = new Controller();
	
	var _level : TiledLevel;
	
	var _standardPhase : FlxGroup = new FlxGroup();
	var _ghostPhase : FlxGroup = new FlxGroup();
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		// Set controls.
		gameController.SetButton("space bar action", ["SPACE"], KeyStyle.PRESS);
		gameController.SetButton("shift action", ["SHIFT"], KeyStyle.HOLD);
		
		// Load map, calling in the controller so it can be tied to the player character.
		_level = new TiledLevel ("assets/data/VariationDebugMap.tmx", gameController);
		
		// Add tiles into play state
		add(_level.backgroundTiles);
		add(_level.foregroundTiles);
		
		// Load all objects from the map into the playstate
		_level.loadObjects(this);
		
		//super.create();
		
		// Set the camera to follow the player
		forEachOfType(Genehack, setFollow);
		
		// Separate all characters into ghostly and non-ghostly phases.
		forEachOfType(AbilityBase, setPhase);
	}
	
	
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	
	
	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
		
		_level.collideWithLevel(_standardPhase, false);
		_level.collideWithLevel(_ghostPhase, true);
	}
	
	
	public function setPhase(character : AbilityBase) : Void
	{
		if (character._phasesThroughWalls)
		{
			_ghostPhase.add(character);
		}
		else
		{
			_standardPhase.add(character);
		}
	}
	
	
	public function setFollow(player : Genehack) : Void
	{
		FlxG.camera.follow(player);
	}
}