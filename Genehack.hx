package ;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;

import flixel.util.FlxColor;

import AbilityBase;
import Controller;



class GenehackConstants
{
	public inline static var kSpeed : Int = 150;
	public inline static var kMaxSpeed : Int = 200;
	
	public inline static var kRunSpeed : Int = 300;
	public inline static var kRunMax : Int = 400;
	
	public inline static var kJump : Int = 200;
	public inline static var kHoverUp : Int = 280;
}




/**
 * ...
 * @author ...
 */
class Genehack extends AbilityBase
{
	var _controller : Controller = null;
	

	public function new(X:Float=0, Y:Float=0, controls:Controller) 
	{
		super(X, Y);
		
		PhasesThroughWalls = false;
		
		
		_controller = controls;
		
		
		//SetMove(WALK, GenehackConstants.kSpeed, GenehackConstants.kMaxSpeed);
		SetMove(CLIMB, GenehackConstants.kSpeed, GenehackConstants.kMaxSpeed);
		
		var _actionOneButton = _controller.SetButton("space bar action", null, KeyStyle.HOLD);
		var _actionTwoButton = _controller.SetButton("shift action", null, KeyStyle.HOLD);
		
		AddAbility(HOVER, _actionOneButton.GetKeyInput);
		AddAbility(DASH, _actionTwoButton.GetKeyInput);
		
		makeGraphic(30,30, FlxColor.SALMON);
	}
	
	
	
	/**
	 * Add an ability to the character's list. This doesn't, presently, check to make
	 * sure that abilities aren't tied to the same trigger, so watch out!
	 * @param	newSkill		The AbilityDirectory name of the new skill to add
	 * @param	triggerCheck	When the ability should be triggered. Use Permanent
	 * 							to make it always triggered.
	 */
	override public function AddAbility(newSkill : AbilityDirectory, 
								triggerCheck : Void -> Bool,
								?baseStrength : Int = 0,
								?maxStrength : Int = 0) : Void
	{
		// If a specific baseStrength or maxStrength are entered...
		if ((baseStrength != 0) || (maxStrength != 0))
		{
			// Use them.
			super.AddAbility(newSkill, triggerCheck, baseStrength, maxStrength);
		}
		// Otherwise, use defaults from the constants list.
		else
		{
			switch (newSkill)
			{
				case RUN:
					super.AddAbility(RUN, triggerCheck, 
							GenehackConstants.kRunSpeed, GenehackConstants.kRunMax);
				case CLIMB:
					super.AddAbility(CLIMB, triggerCheck, 
							GenehackConstants.kSpeed, GenehackConstants.kMaxSpeed);
					
				case JUMP:
					super.AddAbility(JUMP, triggerCheck, GenehackConstants.kJump);
				case WALLJUMP:
					super.AddAbility(WALLJUMP, triggerCheck, GenehackConstants.kJump);
					
				case HOVER:
					super.AddAbility(HOVER, triggerCheck, GenehackConstants.kHoverUp);
					
				// For abilities that don't require strengths, just call the super.
				default:
					super.AddAbility(newSkill, triggerCheck);
			}
		}
	}
	
	
	
	override public function moveCheck() : Void
	{
		MoveDirection = _controller.GetDirection();
		super.moveCheck();
	}
	
	
	
	/**
	 * Update the character.
	 */
	override public function update() : Void
	{
		super.update();
	}
	
	
	
	/**
	 * Destroy this character.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}
}