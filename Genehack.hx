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
	public inline static var kJump : Int = 200;
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
		
		_phasesThroughWalls = true;
		
		
		_controller = controls;
		
		
		SetMove(WALK, GenehackConstants.kSpeed, 200);
		SetMove(SHIFTCLIMB, (GenehackConstants.kSpeed), 200);
	
		
		_actionOneActivate = WallJump;
		_actionOneInactive = JumpRestore;
		
		_actionTwoActivate = MoveShiftOn;
		_actionTwoInactive = MoveShiftOff;
		
		controls.SetActionStyle(1, KeyStyle.HOLD);
		controls.SetActionStyle(2, KeyStyle.HOLD);
		
		_jumpStrength = GenehackConstants.kJump;
	
		_hoverStrength = 195;
		
		makeGraphic(30,30, FlxColor.SALMON);
	}
	
	
	
	/**
	 * actionCheck(). See if the controller is registering
	 * input, and activate/deactivate the appropriate abilities.
	 */
	private function actionCheck() : Void
	{
		// Check if there is an action one...
		if (_actionOneActivate != null)
		{
			// If so, check for controller value and activate
			if (_controller.GetActionKeyValue(1))
			{
				_actionOneActivate();
			}
			/* If not, check if there's an inactive function
			for that ability. */
			else if (_actionOneInactive != null)
			{
				_actionOneInactive();
			}
		}
		
		
		// Check if there is an action two...
		if (_actionTwoActivate != null)
		{
			// If so, check for controller value and activate
			if (_controller.GetActionKeyValue(2))
			{
				_actionTwoActivate();
			}
			/* If not, check if there's an inactive function
			for that ability. */
			else if (_actionTwoInactive != null)
			{
				_actionTwoInactive();
			}
		}
	}
	
	
	
	/**
	 * moveCheck(). Check for movement data from the controller, and
	 * activate the appropriate movement style.
	 */
	private function moveCheck() : Void
	{
		var moveDirection : IntPoint = _controller.GetDirection();
		
		// If the character has any movement style...
		// ... this is purely just paranoia.
		if (_lrMovement != null)
		{
			if (!_moveStyleShifted)
			{
				_lrMovement(moveDirection.X);
			}
			// If shifted style, and a shifted move style exists,
			// do eeeet.
			else if (_lrMovementShifted != null)
			{
				_lrMovementShifted(moveDirection.X);
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