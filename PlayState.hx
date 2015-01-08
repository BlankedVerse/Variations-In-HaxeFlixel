package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

import Controller;
import AbilityBase;

import WorldWideKeys;

class ControlDefaults
{
	public inline static var kActionOne : String = "SPACE";
	public inline static var kActionTwo : String = "SHIFT";
	
	public inline static var kReincarnate : String = "ESCAPE";
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
	
	
	// Control variables
	var _actionOne = new Array<String>();
	var _actionTwo = new Array<String>();
	var _reincarnate = new Array<String>();
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		// Set control key lists to default (or saved user selections.)
		_actionOne.push(ControlDefaults.kActionOne);
		_actionTwo.push(ControlDefaults.kActionTwo);
		_reincarnate.push(ControlDefaults.kReincarnate);
		
		// Set controls buttons.
		gameController.SetButton(WorldWideKeys.ActionOne, _actionOne, KeyStyle.HOLD);
		gameController.SetButton(WorldWideKeys.ActionTwo, _actionTwo, KeyStyle.HOLD);
		gameController.SetButton(WorldWideKeys.Reincarnate, _reincarnate, KeyStyle.HOLD);
		
		// Load map, calling in the controller so it can be tied to the player character.
		_level = new TiledLevel (WorldWideKeys.TestingLevelPath, gameController);
		
		// Add tiles into play state
		add(_level.backgroundTiles);
		add(_level.foregroundTiles);
		
		// Load all objects from the map into the playstate
		_level.loadObjects(this);
		
		//super.create();
		
		// Set the camera to follow the player
		forEachOfType(PlayerCharacter, setFollow);
	}
	
	
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		_ghostPhase.destroy();
		_standardPhase.destroy();
		
		super.destroy();
	}

	
	
	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
	
		levelCollisions();
	}
	
	
	public function levelCollisions() : Void
	{
		// Clear the phase list.
		_standardPhase.clear();
		_ghostPhase.clear();
		
		// Separate all characters into ghostly and non-ghostly phases.
		forEachOfType(AbilityBase, setPhase);
		
		// Collide standard phase characters with all collision layers
		_level.collideWithLevel(_standardPhase, false);
		
		// Collide ghosts phase characters with only solid walls
		_level.collideWithLevel(_ghostPhase, true);		
	}
	
	
	
	public function setPhase(character : AbilityBase) : Void
	{
		if (character.PhasesThroughWalls)
		{
			_ghostPhase.add(character);
		}
		else
		{
			_standardPhase.add(character);
		}
	}
	
	
	public function setFollow(player : PlayerCharacter) : Void
	{
		FlxG.camera.follow(player);
	}
}