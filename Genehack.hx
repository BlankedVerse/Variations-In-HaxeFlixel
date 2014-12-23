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
	
	var _actionOneButton : ActionButton = null;
	var _actionTwoButton : ActionButton = null;
	

	public function new(X:Float=0, Y:Float=0, controls:Controller) 
	{
		super(X, Y);
		
		PhasesThroughWalls = false;
		
		
		_controller = controls;
		
		
		//SetMove(WALK, GenehackConstants.kSpeed, GenehackConstants.kMaxSpeed);
		SetMove(CLIMB, GenehackConstants.kSpeed, GenehackConstants.kMaxSpeed);
		
		var _actionOneButton = _controller.SetButton("space bar action", null, KeyStyle.HOLD);
		var _actionTwoButton = _controller.SetButton("shift action", null, KeyStyle.HOLD);
		
		AddAbility(WALLJUMP, _actionOneButton.GetKeyInput);
		AddAbility(HOVER, _actionTwoButton.GetKeyInput);
		
		makeGraphic(30,30, FlxColor.SALMON);
	}
	
	
	
	/**
	 * Add an ability to the character's list. This doesn't, presently, check to make
	 * sure that abilities aren't tied to the same trigger, so watch out!
	 * @param	newSkill		The AbilityDirectory name of the new skill to add
	 * @param	triggerCheck	When the ability should be triggered. Use Permanent
	 * 							to make it always triggered.
	 */
	public function AddAbility(newSkill : AbilityDirectory, 
								triggerCheck : Void -> Bool) : Void
	{
		switch (newSkill)
		{
			case SHIFTMOVE:
				SetMove(RUN, GenehackConstants.kRunSpeed, GenehackConstants.kRunMax);
				actionList.push(new ActionSet(MoveShiftOn, MoveShiftOff, triggerCheck));
			case SHIFTCLIMB:
				SetMove(SHIFTCLIMB, GenehackConstants.kSpeed, GenehackConstants.kMaxSpeed);
				actionList.push(new ActionSet(MoveShiftOn, MoveShiftOff, triggerCheck));
			case JUMP:
				_jumpStrength = GenehackConstants.kJump;
				actionList.push(new ActionSet(Jump, JumpRestore, triggerCheck));
			case WALLJUMP:
				_jumpStrength = GenehackConstants.kJump;
				actionList.push(new ActionSet(WallJump, JumpRestore, triggerCheck));
				
				// Extra trait: Give walljumpers automatic Cling.
				actionList.push(new ActionSet(null, Cling, null));
			case HOVER:
				_hoverStrength = GenehackConstants.kHoverUp;
				actionList.push(new ActionSet(HoverOn, HoverOff, triggerCheck));
			case DASH:
				actionList.push(new ActionSet(DashCharge, DashRelease, triggerCheck));
			case SHIFTPHASE:
				actionList.push(new ActionSet(PhaseShifted, PhaseUnshifted, triggerCheck));
		}
	}
	
	
	
	/**
	 * actionCheck(). See if the controller is registering
	 * input, and activate/deactivate the appropriate abilities.
	 */
	private function actionCheck() : Void
	{
		// Check if there is an action one...
		for (action in actionList)
		{
			// If so, check for controller value and activate
			if ((action.Activate != null) && (action.TriggerCheck()))
			{
				action.Activate();
			}
			/* If not, check if there's an inactive function
			for that ability. */
			else if (action.Inactive != null)
			{
				action.Inactive();
			}
		}
	}
	
	
	
	/**
	 * moveCheck(). Check for movement data from the controller, and
	 * activate the appropriate movement style.
	 */
	private function moveCheck() : Void
	{
		MoveDirection = _controller.GetDirection();
		
		// If the character has any movement style...
		// ... this is purely just paranoia.
		if (_lrMovement != null)
		{
			if (!_moveStyleShifted)
			{
				_lrMovement(MoveDirection.X);
			}
			// If shifted style, and a shifted move style exists,
			// do eeeet.
			else if (_lrMovementShifted != null)
			{
				_lrMovementShifted(MoveDirection.X);
			}
		}
	}
	
	
	
	
	
	/**
	 * Update the character.
	 */
	override public function update() : Void
	{
		moveCheck();
		actionCheck();
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