package ;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;

import flixel.util.FlxColor;

import AbilityBase;
import Controller;
import UIFrame;

import WorldWideKeys;



class PlayerConstants
{
	public inline static var kSpeed : Int = 150;
	public inline static var kMaxSpeed : Int = 200;
	
	public inline static var kRunSpeed : Int = 300;
	public inline static var kRunMax : Int = 400;
	
	public inline static var kJump : Int = 200;
	public inline static var kHoverUp : Int = 250;
}




/**
 * ...
 * @author ...
 */
class PlayerCharacter extends AbilityBase
{
	var _controller : Controller = null;
	var _reincarnateButton : ActionButton = null;
	
	//var _skillScreen : abilitySelectMenu = new abilitySelectMenu();
	var _inSkillMenu : Bool = false;
	
	public function new(X:Float=0, Y:Float=0, controls:Controller) 
	{
		super(X, Y);
		
		PhasesThroughWalls = false;
		
		_controller = controls;
		
		_reincarnateButton = _controller.SetButton(WorldWideKeys.Reincarnate, null, TOGGLE);
		
		SetMove(new MoveProfile(WALK, PlayerConstants.kSpeed, PlayerConstants.kMaxSpeed));
		
<<<<<<< HEAD
		AbilitySet(WALLJUMP, HOVER, null);
=======
		AbilitySet(WALLJUMP, CLIMB, null);
>>>>>>> origin/master
		
		makeGraphic(30,30, FlxColor.SALMON);
	}
	
	
	
	/**
	 * Add an ability to the character's list. This doesn't, presently, check to make
	 * sure that abilities aren't tied to the same trigger, so watch out!
	 * @param	newSkill		The AbilityDirectory name of the new skill to add
	 * @param	triggerCheck	When the ability should be triggered. Use Permanent
	 * 							to make it always triggered.
	 */
	override function addAbility(newSkill : AbilityDirectory, 
								triggerCheck : Void -> Bool,
								?baseStrength : Int = 0,
								?maxStrength : Int = 0) : Void
	{
		
		// If a specific baseStrength or maxStrength are entered...
		if ((baseStrength != 0) || (maxStrength != 0))
		{
			// Use them.
			super.addAbility(newSkill, triggerCheck, baseStrength, maxStrength);
		}
		// Otherwise, use defaults from the constants list.
		else
		{
			switch (newSkill)
			{
				case RUN:
					super.addAbility(RUN, triggerCheck, 
							PlayerConstants.kRunSpeed, PlayerConstants.kRunMax);
				case CLIMB:
					super.addAbility(CLIMB, triggerCheck, 
							PlayerConstants.kSpeed, PlayerConstants.kMaxSpeed);
					
				case JUMP:
					super.addAbility(JUMP, triggerCheck, PlayerConstants.kJump);
				case WALLJUMP:
					super.addAbility(WALLJUMP, triggerCheck, PlayerConstants.kJump);
					
				case HOVER:
					super.addAbility(HOVER, triggerCheck, PlayerConstants.kHoverUp);
					
				// For abilities that don't require strengths, just call the super.
				default:
					super.addAbility(newSkill, triggerCheck);
			}
		}
	}
	
	
	
	override public function moveCheck() : Void
	{
		MoveDirection = _controller.GetDirection();
		super.moveCheck();
	}
	
	
	
	public function AbilitySet (primeAbility : AbilityDirectory,
								secondAbility : AbilityDirectory,
								passives : Array<AbilityDirectory>) : Void
	{
		var _actionOneButton = _controller.SetButton(WorldWideKeys.ActionOne, null, KeyStyle.HOLD);
		var _actionTwoButton = _controller.SetButton(WorldWideKeys.ActionTwo, null, KeyStyle.HOLD);
		
		ClearAbilities();
		
		addAbility(primeAbility, _actionOneButton.GetKeyInput);
		addAbility(secondAbility, _actionTwoButton.GetKeyInput);
		
		if (passives != null)
		{
			for (ability in passives)
			{
				addAbility(ability, Permanent);
			}
		}
	}
	
	
	
	/**
	 * Update the character.
	 */
	override public function update() : Void
	{
		_inSkillMenu = _reincarnateButton.GetKeyInput();
		
		// If in ability-swapping mode, only update that and not the player character.
		if (_inSkillMenu)
		{
			//_skillScreen.update();
			// If skillScreen finishes
			//if (_skillScreen.Finished)
			//{
				//SetMove(_skillScreen.Movement);
				//AbilitySet(_skillScreen.AbilityOne, _skillScreen.AbilityTwo, _skillScreen.Passives);
				//_inSkillMenu = false;
			//}
		}
		// Otherwise, perform a standard update.
		else
		{
			
			super.update();
			//_inSkillMenu = _reincarnateButton.GetKeyInput();
		}
	}
	
	
	
	/**
	 * Destroy this character.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}
}