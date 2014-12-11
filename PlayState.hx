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


/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	public var gameController : Controller = new Controller(["SPACE"], ["SHIFT"]);
	
	var _level : TiledLevel;
	
	var _standardPhase : FlxGroup = new FlxGroup();
	var _ghostPhase : FlxGroup = new FlxGroup();
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		_level = new TiledLevel ("assets/data/VariationDebugMap.tmx", gameController);
		
		add(_level.backgroundTiles);
		add(_level.foregroundTiles);
		
		_level.loadObjects(this);
		
		//super.create();
		forEachOfType(Genehack, setFollow);
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