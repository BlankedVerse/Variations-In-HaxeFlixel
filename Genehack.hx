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
	public inline static var kHoverUp : Int = 270;
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
		
		
		//SetMove(WALK, GenehackConstants.kSpeed, 200);
		SetMove(CLIMB, (GenehackConstants.kSpeed), 200);
		
		var _actionOneButton = _controller.SetButton("space bar action", null, KeyStyle.HOLD);
		var _actionTwoButton = _controller.SetButton("shift action", null, KeyStyle.HOLD);
	
		
		actionList.push(new ActionSet(WallJump, JumpRestore, _actionOneButton.GetKeyInput));
		actionList.push(new ActionSet(HoverOn, HoverOff, _actionTwoButton.GetKeyInput));
		//actionList.push(new ActionSet(DashCharge, DashRelease, _actionTwoButton.GetKeyInput));
		
		_jumpStrength = GenehackConstants.kJump;
	
		_hoverStrength = GenehackConstants.kHoverUp;
		
		makeGraphic(30,30, FlxColor.SALMON);
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