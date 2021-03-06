package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;

import Controller.IntPoint;


enum MoveStyleDirectory
{
	// Movement abilities
	WALK;
	CLIMB;
	RUN;
}



enum AbilityDirectory
{
	NONE;
	RUN;
	CLIMB;
	JUMP;
	WALLJUMP;
	HOVER;
	DASH;
	PHASE;
}



class CharacterConstants
{
	public inline static var kGravity : Int = 600;
	
	public inline static var kBaseDragX : Int = 300;
	public inline static var kBaseDragY : Int = 1200;
	public inline static var kBaseFallSpeed : Int = 800;
	
	public inline static var kJumpGhosting : Int = 6;
	public inline static var kJumpHold : Int = 14;
	
	public inline static var kHoverDuration : Int = 30;
	
	public inline static var kSkidMultiplier : Float = 0.9;
	public inline static var kClimbGrip : Int = 2;
	
	public inline static var kDashLength : Int = 15;
	public inline static var kDashSpeed : Int = 500;
}


class MoveProfile
{
	public var moveType : MoveStyleDirectory = WALK;
	public var accel : Int = 0;
	public var max : Int = 0;
	
	public function new(movementType : MoveStyleDirectory, acceleration : Int, maxSpeed : Int)
	{
		moveType = movementType;
		accel = acceleration;
		max = maxSpeed;
	}
}


class ActionSet
{
	public var Activate : Void -> Void = null;
	public var Inactive : Void -> Void = null;
	public var TriggerCheck : Void -> Bool = null;
	
	public function new(activationFunction : Void -> Void, inactiveFunction : Void -> Void,
							?actionTrigger : Void -> Bool = null)
	{
		Activate = activationFunction;
		Inactive = inactiveFunction;
		TriggerCheck = actionTrigger;
	}
}



/**
 * An collection of functions for different movements and actions.
 * Creatures created from this base have access to these abilities
 * as delegates for their actions.
 * @author ...
 */
class AbilityBase extends FlxSprite
{
	public var PhasesThroughWalls : Bool = false;
	
	public var MoveDirection : IntPoint = new IntPoint(0, 0);
	
	var _gravity : Int = CharacterConstants.kGravity;
	
	
	// Movement variables and delegates
	var _currentSpeed : MoveProfile = new MoveProfile(WALK, 0, 0);
	
	var _baseSpeed : MoveProfile;
	var _shiftedSpeed : MoveProfile;
	
	var _maxFall : Int = CharacterConstants.kBaseFallSpeed;
	
	var _jumpStrength : Int = 0;
	var _jumpHold : Int = 0;
	var _jumpGhost : Int = CharacterConstants.kJumpGhosting;
	var _jumpReleased : Bool = true;
	
	var _hoverStrength : Int = 0;
	var _hoverUpDuration : Int = 0;
	
	var _climbSpeed : Int = 0;
	
	var _dashLength : Int = -1;
	var _dashSpeed : Int = CharacterConstants.kDashSpeed;
	var _dashReady : Bool = true;
	var _dashDirection : IntPoint = new IntPoint(0, 0);
	
	var _moveStyleShifted : Bool = false;
	
	// The left and right movement delegate for a character.
	var _lrMovement : Int -> Void = null;
	// Secondary l/r movement delegate.
	var _lrMovementShifted : Int -> Void = null;
	
	
	// Action delegates
	var _actionList : Array<ActionSet> = new Array();
	

	public function new(X:Float=0, Y:Float=0) 
	{		
		super(X, Y);
		
		acceleration.y = _gravity;
		
		drag.x = CharacterConstants.kBaseDragX;
		drag.y = CharacterConstants.kBaseDragY;
	}
	
	
	
	/**
	 * Set basic movement info. walk, run, etc. Basic movement
	 * should always be put to walk, only use run for a secondary faster movement
	 * style. Climb substitutes for walk, shiftclimb is secondary movement
	 * version of climb.
	 */
	function SetMove(movementProfile : MoveProfile) : Void
	{		
		switch(movementProfile.moveType)
		{
			// Set walk as base movement, with speed and max
			case WALK:
				_lrMovement = Walk;
				
				_baseSpeed = movementProfile;
				
				_currentSpeed = _baseSpeed;
				maxVelocity.set(_currentSpeed.max, _maxFall);
				
			// Set climbing speed and max
			case CLIMB:
				_lrMovement = WalkClimb;
				
				_baseSpeed = movementProfile;
				
				_currentSpeed = _baseSpeed;
				maxVelocity.set(_currentSpeed.max, _maxFall);
				
				_climbSpeed = Std.int(_baseSpeed.accel / 2);
				
			case RUN:
				SetShiftedMove(movementProfile);
		}
	}
	
	

	/**
	 * Set shifted movement info. walk, run, etc. Basic movement
	 * should always be put to walk, only use run for a secondary faster movement
	 * style. Climb substitutes for walk, shiftclimb is secondary movement
	 * version of climb.
	 * @param	moveType	The move style, from the MoveStyle enum
	 * @param	accel		Acceleration of this move declaration
	 * @param	maxSpeed	Maximum speed for this move declaration
	 */
	function SetShiftedMove(movementProfile : MoveProfile) : Void
	{
	FlxG.log.add("ShiftMove set.");
		
		switch(movementProfile.moveType)
		{
			case WALK:
				// Nothing happens!
			
			// Set run as the shifted movestyle, with speed and max
			case RUN:
				_lrMovementShifted = Run;
				
				_shiftedSpeed = movementProfile;
				
			// Set climb speed and max as a shifted move type
			case CLIMB:
				_lrMovementShifted = WalkClimb;
			
				_shiftedSpeed = movementProfile;
				
				_climbSpeed = Std.int(movementProfile.accel / 2);
		}
	}
	
	
	
	/**
	 * Add an ability to the character's list. This doesn't, presently, check to make
	 * sure that abilities aren't tied to the same trigger, so watch out!
	 * @param	newSkill		The AbilityDirectory name of the new skill to add
	 * @param	triggerCheck	When the ability should be triggered. Use Permanent
	 * 							to make it always triggered.
	 * @param	baseStrength	Jump/hover strength, acceleration for movestyles, etc.
	 * @param	maxStrength		Move speed cap, etc.
	 */
	function addAbility(newSkill : AbilityDirectory, 
								triggerCheck : Void -> Bool,
								?baseStrength : Int = 0,
								?maxStrength : Int = 0) : Void
	{
		switch (newSkill)
		{
			case RUN:
				SetShiftedMove(new MoveProfile(RUN, baseStrength, maxStrength));
				_actionList.push(new ActionSet(MoveShiftOn, MoveShiftOff, triggerCheck));
			case CLIMB:
				SetShiftedMove(new MoveProfile(CLIMB, baseStrength, maxStrength));
				_actionList.push(new ActionSet(MoveShiftOn, MoveShiftOff, triggerCheck));
				
			case JUMP:
				_jumpStrength = baseStrength;
				_actionList.push(new ActionSet(Jump, JumpRestore, triggerCheck));
			case WALLJUMP:
				_jumpStrength = baseStrength;
				_actionList.push(new ActionSet(WallJump, JumpRestore, triggerCheck));
				
				// Extra trait: Give walljumpers automatic Cling.
				_actionList.push(new ActionSet(null, Cling, null));
			case HOVER:
				_hoverStrength = baseStrength;
				_actionList.push(new ActionSet(HoverOn, HoverOff, triggerCheck));
			case DASH:
				_actionList.push(new ActionSet(DashCharge, DashRelease, triggerCheck));
			case PHASE:
				_actionList.push(new ActionSet(PhaseShifted, PhaseUnshifted, triggerCheck));
			case NONE:
				//Nothing!
		}
	}
	
	
	
	/**
	 * ClearAbilities(). Clears the action list. Call to make sure that all abilities are
	 * cleared from the character's list.
	 */
	public function ClearAbilities() : Void
	{
		_actionList = new Array<ActionSet> ();
	}
	
	
	
	// L/R Movement types
	
	/**
	 * Walk in a given direction.
	 * @param	direction	A positive or negative integer (1 or -1).
	 */
	function Walk(direction : Int)
	{
		acceleration.y = _gravity;
		
		acceleration.x = (_currentSpeed.accel * Sign(direction));

		skid(Sign(direction));
	}
	
	
	
	/**
	 * Run in a given direction. 
	 * @param	direction	A positive or negative integer (1 or -1).
	 */
	function Run(direction : Int)
	{
		acceleration.y = _gravity;
		
		acceleration.x = (_currentSpeed.accel * Sign(direction));
		
		skid(Sign(direction));
	}
	
	
	
	/**
	 * Try to climb up a wall in a direction. If there's no wall to climb,
	 * walk instead.
	 * @param	direction	The direction to walk/attempt to climb.
	 */
	function WalkClimb (direction : Int)
	{
		if (isTouching(FlxObject.WALL))
		{
			// Cling to the wall...
			Cling();
			
			maxVelocity.y = _climbSpeed;
			
			// Touching wall in the direction you're moving, climb up it.
			if ((isTouching(FlxObject.RIGHT)) && (Sign(direction) > 0))
			{
				acceleration.y = -(_climbSpeed);
			}
			else if ((isTouching(FlxObject.LEFT)) && (Sign(direction) < 0))
			{
				acceleration.y = -(_climbSpeed);
			}
			
			// Moving away from wall
			else if ((isTouching(FlxObject.LEFT)) && (Sign(direction) > 0))
			{
				Walk(direction);
			}
			else if ((isTouching(FlxObject.RIGHT)) && (Sign(direction) < 0))
			{
				Walk(direction);
			}
			
			// If not moving at all
			else
			{
				acceleration.y = _gravity/CharacterConstants.kClimbGrip;
			}
		}
		// If you were touching a wall last frame but aren't now, reset gravity, start walking.
		else if (((wasTouching & FlxObject.WALL) != 0) 
			&& !isTouching(FlxObject.WALL))
		{
			maxVelocity.y = _maxFall;
			acceleration.y = _gravity;
			Walk(direction);
		}
		// If you weren't touching walls at all, just walk.
		else
		{
			Walk(direction);
		}
	}
	
	
	
	
	
	// Actions
	/**
	 * Activate a movement shift.
	 */
	function MoveShiftOn() : Void
	{
		if ((isTouching(FlxObject.FLOOR)) && (_currentSpeed != _shiftedSpeed))
		{
			_currentSpeed = _shiftedSpeed;
			maxVelocity.set(_currentSpeed.max, _maxFall);
		}
		
		// Shifting move modes should always set falling velocity to what's expected.
		if (maxVelocity.y != _maxFall)
		{
			maxVelocity.y = _maxFall;
		}
		
		_moveStyleShifted = true;
	}
	
	
	
	/**
	 * Turn off a movement shift.
	 */
	function MoveShiftOff() : Void
	{
		if ((isTouching(FlxObject.FLOOR)) && (_currentSpeed != _baseSpeed))
		{
			_currentSpeed = _baseSpeed;
			maxVelocity.set(_currentSpeed.max, _maxFall);
		}
		
		// Shifting move modes should always set falling velocity to what's expected.
		if (maxVelocity.y != _maxFall)
		{
			maxVelocity.y = _maxFall;
		}
		
		_moveStyleShifted = false;
	}
	
	
	
	/**
	 * Jump. Hold-type action. If the character is still within the jumpDelay margin
	 * of touching ground, they jump!
	 */
	function Jump() : Void
	{
		// If the character is already jumping, allow them
		// to gain more height as long as they hold the button.
		if ((_jumpHold > 0) && (acceleration.y != 0))
		{
			// Limit velocity.y so that it is at least _jumpStrength upwards.
			if (velocity.y > -_jumpStrength)
			{
				velocity.y = -_jumpStrength;
			}
			
			_jumpReleased = false;
			_jumpHold--;
		}
		
		
		if (_jumpReleased) 
		{
			// If the jumpGhosting forgiveness counter hasn't
			// hit 0 yet, then the character can start a jump.
			if (_jumpGhost > 0)
			{
				velocity.y -= _jumpStrength;
				_jumpGhost = -1;
				_jumpHold = CharacterConstants.kJumpHold;
			}
		}
	}
	
	
	
	/**
	 * Wall jump. Press-type action. If the character is still within the jumpDelay margin
	 * of touching ground, or if they're hugging a wall they jump!
	 */
	function WallJump() : Void
	{		
		if (_jumpReleased) 
		{
			// If the character is touching a wall but not the floor...
			if (
				(isTouching(FlxObject.WALL)) 
				&& (!isTouching(FlxObject.FLOOR))
				&& (_jumpHold == 0)
				)
			{
				// Do a jump...
				velocity.y -= _jumpStrength;
				_jumpGhost = -1;
				_jumpHold = CharacterConstants.kJumpHold;
				
				// .. and add a horizontal element in the opposite direction.
				if (isTouching(FlxObject.RIGHT))
				{
					velocity.x -= _jumpStrength;
				}
				else if (isTouching(FlxObject.LEFT))
				{
					velocity.x += _jumpStrength;
				}
				
			}
		}
		Jump();
	}
	
	
	
	/**
	 * Jump recover.
	 */
	function JumpRestore() : Void
	{
		// If touching the floor, reset jumpDelay counter.
		if (isTouching(FlxObject.FLOOR))
		{
			_jumpGhost = CharacterConstants.kJumpGhosting;
			_jumpHold = 0;
		}
		
		_jumpReleased = true;
		
		if (_jumpHold > 0)
		{
			_jumpHold--;
		}
	}
	
	
	
	/**
	 * Hover. Called whenever hover action is toggled on.
	 */
	function HoverOn() : Void
	{
		// Special controls for touching the ceiling. If you're hovering and
		// hit the roof, stop all vertical movement and set hover below
		// lower limit.
		if ((isTouching(FlxObject.CEILING)) && (!isTouching(FlxObject.FLOOR)))
		{
			acceleration.y = 0;
			velocity.y = 0;
			_hoverUpDuration = -1;
		}
		
		// If capable of jumping...
		if (_jumpGhost > 0)
		{
			// Drop to half gravity, give a slight upwards momentum, and set
			// hover duration.
			acceleration.y = CharacterConstants.kGravity / 2;
			velocity.y = -(_hoverStrength);
			_hoverUpDuration = CharacterConstants.kHoverDuration;
			
			
			_jumpGhost = -1;
		}
		// Otherwise, tick down hover counter to 0
		else if (_hoverUpDuration > 0)
		{
			_jumpHold = 0;
			_hoverUpDuration--;
		}
		// Or, if it is zero...
		else if (_hoverUpDuration == 0)
		{
			// Taper velocity off, set vertical acceleration to nil, and tick down
			velocity.y = velocity.y/1.5;
			acceleration.y = 0;
			_hoverUpDuration--;
		}
		else
		{
			acceleration.y = 0;
		}
	}
	
	
	
	/**
	 * Unhover. Called whenever hover action is toggled off.
	 */
	function HoverOff() : Void
	{
		// If touching the floor, reset jumpDelay counter.
		if (isTouching(FlxObject.FLOOR))
		{
			_jumpGhost = CharacterConstants.kJumpGhosting;
		}
		
		if (_hoverUpDuration != 0) 
		{
			acceleration.y = _gravity;
			_hoverUpDuration = 0;
		}
	}
	
	
	
	/**
	 * Charges up a dash. Hold to charge, release to dash. Direction
	 * is set from MoveDirection..
	 */
	function DashCharge() : Void
	{
		// If the character has touched the ground since the last dash
		if (_dashReady) 
		{
			_jumpHold = 0;
			// If dash has just started (-1 from touching ground)
			if (_dashLength < 0)
			{
				// Remove previous momentum
				velocity.x = 0;
				velocity.y = 0;
				
				// Set dash direction to default...
				_dashDirection.X = 0;
				_dashDirection.Y = 0;
				
				// And start charging up some dash.
				_dashLength++;
			}
			// If dash has started but hasn't fully charged...
			else if (_dashLength < CharacterConstants.kDashLength)
			{
				// Charge it!
				_dashLength++;
			}
			
			acceleration.x = 0;
			acceleration.y = 0;
			
			_dashDirection = MoveDirection;
		}
		else
		{
			DashRelease();
		}
	}
	
	
	
	/**
	 * Dash release. If a dash has been charged up, speeds off in that direction,
	 * phasing through thin walls. Direction is determined by _dashDirection, as
	 * last set in DashCharge()
	 */
	function DashRelease() : Void
	{
		if (_dashLength > 0)
		{
			// Do the dash. Phase out!
			velocity.x = _dashSpeed * _dashDirection.X;
			velocity.y = _dashSpeed * _dashDirection.Y;
			
			// If dashing in any direction, phase through walls
			if ((_dashDirection.X != 0) || (_dashDirection.Y != 0)) 
			{
				PhasesThroughWalls = true;
				maxVelocity.set(CharacterConstants.kDashSpeed , CharacterConstants.kDashSpeed);
				_dashLength--;
			}
			else
			{
				_dashLength = 0;
			}
			
			_dashReady = false;
		}
		else if (_dashLength == 0)
		{
			// If a dash was just finished (either dash direction isn't zero)
			if ((_dashDirection.X != 0) || (_dashDirection.Y != 0))
			{
				// Set gravity, phase, and standard maxVelocity
				acceleration.y = _gravity;
				PhasesThroughWalls = false;
				maxVelocity.set(_currentSpeed.max, _maxFall);
				
				// Reset momentum in effected axes
				if (_dashDirection.X != 0)
				{
					// Stop momentum and set dash direction to 0
					velocity.x = 0;
					_dashDirection.X = 0;
				}
				if (_dashDirection.Y != 0)
				{
					// Stop momentum and set dash direction to 0
					velocity.y = 0;
					_dashDirection.Y = 0;
				}
			}
			
			// Touching the ground sets _dashLength to -1, meaning a new dash can begin.
			if (isTouching(FlxObject.FLOOR))
			{
				_dashLength = -1;
				_dashReady = true;
			}
		}
	}
	
	
	
	function PhaseShifted() : Void
	{
		PhasesThroughWalls = true;
	}
	
	
	
	function PhaseUnshifted() : Void
	{
		PhasesThroughWalls = false;
	}
	
	
	// Common helper functions
	/**
	 * Skid function. Used when changing directions on the ground,
	 * simply to prevent retyping it all the time. Override to add
	 * special animations?
	 * @param	accelSign		1 or -1, indicating the direction
	 * 							of movement.
	 */
	private function skid(accelSign : Int) : Void
	{
		var velocitySign : Int = 0;
		
		if (velocity.x > 0)
		{
			velocitySign = 1;
		}
		else if (velocity.x < 0)
		{
			velocitySign = -1;
		}
		
		if (velocitySign != accelSign)
		{		
			if (this.isTouching(FlxObject.FLOOR))
			{
				velocity.x *= CharacterConstants.kSkidMultiplier;
			}
		}	
	}
	
	
	/**
	 * Cling(). Allows the owner to cling to walls if they touch them, reducing
	 * their fall speed. 
	 */
	public function Cling() : Void
	{
		var clingBoundary = Std.int(_baseSpeed.accel / 2);
		
		if (isTouching(FlxObject.WALL))
		{
			if ((velocity.y > clingBoundary) || (velocity.y < -2 * clingBoundary))
			{
				velocity.y /= CharacterConstants.kClimbGrip;
			}
			
			// Set dashReady to be true, so that if you have cling and grab a wall,
			// you can dash again. :)
			_dashReady = true;
		}
	}
	
	
	
	// Just a quicky function for permanent ability checks. Things that should
	// be triggered always.
	public function Permanent() : Bool
	{
		return true;
	}
	
	
	// Math helper functions
	/**
	 * Gets the sign of a number - positive or negative.
	 * @param	number	An integer to be checked
	 * @return	1, if the number is positive.
	 * 			-1, if the number is negative.
	 */
	function Sign(number : Int) : Int
	{
		var returnValue = 0;
		
		if (number > 0)
		{
			returnValue = 1;
		}
		else if (number < 0)
		{
			returnValue = -1;
		}
		
		return returnValue;
	}
	
	
	
	/**
	 * actionCheck(). See what abilities are being triggered,
	 * and activate/inactivate them as necessary.
	 */
	private function actionCheck() : Void
	{
		// Check if there is an action one...
		for (action in _actionList)
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
	 * moveCheck(). Check for movement data, and activate
	 * the appropriate movement style.
	 */
	private function moveCheck() : Void
	{
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
		// Decrement the jumpDelay counter if it isn't already 0.
		if (_jumpGhost > 0)
		{
			_jumpGhost -= 1;
		}
		
		
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