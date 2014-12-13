package ;

import flixel.FlxSprite;
import flixel.FlxObject;

import Controller.IntPoint;


enum Facing
{
	LEFT;
	RIGHT;
}



enum MoveStyleDirectory
{
	// Movement abilities
	WALK;
	CLIMB;
	RUN;
	SHIFTCLIMB;
}



enum AbilityDirectory
{
	SHIFTMOVE;
	JUMP;
	WALLJUMP;
	HOVER;
}



class CharacterConstants
{
	public inline static var kGravity : Int = 600;
	
	public inline static var kBaseDragX : Int = 300;
	public inline static var kBaseDragY : Int = 20;
	public inline static var kBaseFallSpeed : Int = 800;
	
	public inline static var kJumpGhosting : Int = 6;
	public inline static var kJumpHold : Int = 15;
	
	public inline static var kHoverDuration : Int = 20;
	
	public inline static var kSkidDivisor : Int = 3;
	public inline static var kClimbGrip : Int = 2;
	
	public inline static var kDashLength : Int = 20;
	public inline static var kDashSpeed : Int = 50;
}


class SpeedProfile
{
	public var accel : Int = 0;
	public var max : Int = 0;
}



/**
 * An collection of functions for different movements and actions.
 * Creatures created from this base have access to these abilities
 * as delegates for their actions.
 * @author ...
 */
class AbilityBase extends FlxSprite
{
	public var _phasesThroughWalls : Bool = false;
	
	var _facing : Facing = RIGHT;
	
	var _gravity : Int = CharacterConstants.kGravity;
	
	
	// Movement variables and delegates
	var _currentSpeed : SpeedProfile = new SpeedProfile();
	
	var _baseSpeed : SpeedProfile;
	var _shiftedSpeed : SpeedProfile;
	
	var _maxFall : Int = CharacterConstants.kBaseFallSpeed;
	
	var _jumpStrength : Int = 0;
	var _jumpHold : Int = 0;
	var _jumpGhost : Int = CharacterConstants.kJumpGhosting;
	
	// Special flag value. Extensions of this class can do special
	// flags to prevent jumping in certain scenarios (i.e. controller
	// jump button not released)
	var _jumpPossible : Bool = true;
	
	var _hoverStrength : Int = 0;
	var _hoverDuration : Int = 0;
	
	var _climbSpeed : Int = 0;
	
	var _dashLength : Int = -1;
	var _dashSpeed : Int = CharacterConstants.kDashSpeed;
	var _dashDirection : IntPoint = new IntPoint(0, 0);
	
	var _moveStyleShifted : Bool = false;
	
	// The left and right movement delegate for a character.
	var _lrMovement : Int -> Void = null;
	// Secondary l/r movement delegate.
	var _lrMovementShifted : Int -> Void = null;
	
	
	// Action delegates
	var _actionOneActivate : Void -> Void = null;
	var _actionTwoActivate : Void -> Void = null;
	
	var _actionOneInactive : Void -> Void = null;
	var _actionTwoInactive : Void -> Void = null;
	

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
	 * @param	moveType	The move style, from the MoveStyle enum
	 * @param	accel		Acceleration of this move declaration
	 * @param	maxSpeed	Maximum speed for this move declaration
	 */
	function SetMove(moveType : MoveStyleDirectory, baseSpeed : Int, maxSpeed : Int = 0) : Void
	{		
		switch(moveType)
		{
			// Set walk as base movement, with speed and max
			case WALK:
				_lrMovement = Walk;
				
				_baseSpeed = new SpeedProfile();
				_baseSpeed.accel = baseSpeed;
				_baseSpeed.max = maxSpeed;
				
				_currentSpeed = _baseSpeed;
				maxVelocity.set(_currentSpeed.max, _maxFall);
				
			// Set climbing speed and max
			case CLIMB:
				_lrMovement = WalkClimb;
				
				_baseSpeed = new SpeedProfile();
				_baseSpeed.accel = baseSpeed;
				_baseSpeed.max = maxSpeed;
				
				_currentSpeed = _baseSpeed;
				maxVelocity.set(_currentSpeed.max, _maxFall);
				
				_climbSpeed = Std.int(baseSpeed / 2);
				
			// Set run as the shifted movestyle, with speed and max
			case RUN:
				_lrMovementShifted = Run;
				
				_shiftedSpeed = new SpeedProfile();
				_shiftedSpeed.accel = baseSpeed;
				_shiftedSpeed.max = maxSpeed;
				
			// Set climb speed and max as a shifted move type
			case SHIFTCLIMB:
				_lrMovementShifted = WalkClimb;
			
				_shiftedSpeed = new SpeedProfile();
				_shiftedSpeed.accel = baseSpeed;
				_shiftedSpeed.max = maxSpeed;
				
				_climbSpeed = Std.int(baseSpeed / 2);
		}
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
			/* maxVelocity on its own doesn't drop velocity fast enough if
			you have a lot of momentum before grabbing to the wall,
			so this expression just makes things a little bit stickier.
			It's kinda hacky, but it feels better. Because sliding up
			walls is weird. That being said, sliding up walls could be
			nifty as an ability for another move type...*/
			if ((velocity.y > _climbSpeed) || (velocity.y < -2 * _climbSpeed))
			{
				velocity.y /= CharacterConstants.kClimbGrip;
			}
			maxVelocity.y = _climbSpeed;
			
			// Touching wall in the direction you're moving...
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
		if (_jumpHold > 0)
		{
			velocity.y = -_jumpStrength;
			_jumpHold--;
			_jumpPossible = false;
		}
		
		
		if (_jumpPossible) 
		{
			// If the jumpGhosting forgiveness counter hasn't
			// hit 0 yet, then the character can start a jump.
			if (_jumpGhost > 0)
			{
				velocity.y = -_jumpStrength;
				_jumpGhost = 0;
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
		// If the character is already jumping, allow them
		// to gain more height as long as they hold the button.
		if (_jumpHold > 0)
		{
			velocity.y = -_jumpStrength;
			_jumpHold--;
			_jumpPossible = false;
		}
		
		
		if (_jumpPossible) 
		{
			// If the character is touching a wall but not the floor...
			if ((isTouching(FlxObject.WALL)) && (!isTouching(FlxObject.FLOOR)))
			{
				// Do a jump...
				velocity.y = -_jumpStrength;
				_jumpGhost = 0;
				_jumpHold = CharacterConstants.kJumpHold;
				
				// .. and add a horizontal element in the opposite direction.
				if (isTouching(FlxObject.RIGHT))
				{
					velocity.x = -_jumpStrength;
				}
				else if (isTouching(FlxObject.LEFT))
				{
					velocity.x = _jumpStrength;
				}
				
			}
			// Otherwise, standard jump check. If the jumpGhosting forgiveness counter hasn't
			// hit 0 yet, then the character can start a jump.
			else if (_jumpGhost > 0)
			{
				velocity.y = -_jumpStrength;
				_jumpGhost = 0;
				_jumpHold = CharacterConstants.kJumpHold;
			}
		}
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
		
		_jumpPossible = true;
		
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
			_hoverDuration = -1;
		}
		
		// If capable of jumping...
		if (_jumpGhost > 0)
		{
			// Drop to half gravity, give a slight upwards momentum, and set
			// hover duration.
			acceleration.y = CharacterConstants.kGravity/2;
			velocity.y = -(_hoverStrength);
			_hoverDuration = CharacterConstants.kHoverDuration;
		}
		// Otherwise, tick down hover counter to 0
		else if (_hoverDuration > 0)
		{
			_hoverDuration--;
		}
		// Or, if it is zero...
		else if (_hoverDuration == 0)
		{
			// Taper velocity off, set vertical acceleration to nil, and tick down
			velocity.y = velocity.y/10;
			acceleration.y = 0;
			_hoverDuration--;
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
		acceleration.y = _gravity;
		_hoverDuration = 0;
	}
	
	
	
	/**
	 * Charges up a dash. Hold to charge, release to dash. To get direction,
	 * either have AI decision-making change _dashDirection while charging,
	 * or override this function, call super() and set _dashDirection from UI.
	 */
	function DashCharge() : Void
	{
		if (_dashLength < 0)
		{
			// Stop all previous momentum...
			velocity.x = 0;
			velocity.y = 0;
			
			// Set dash direction to default...
			_dashDirection.X = 0;
			_dashDirection.Y = 0;
			
			// And start charging up some dash.
			_dashLength++;
		}
		else if (_dashLength < CharacterConstants.kDashLength)
		{
			acceleration.x = 0;
			acceleration.y = 0;
			_dashLength++;
		}
	}
	
	
	
	/**
	 * Dash release. If a dash has been charged up, speeds off in that direction,
	 * phasing through thin walls. Direction is determined by changing _dashDirection
	 * by external functionality/AI decision-making or taking user input to _dashDirection
	 * BEFORE the release is called. Changing _dashDirection WHILE this is called
	 * causes a dash that can bend... which is maybe a whole other kettle of fish.
	 */
	function DashRelease() : Void
	{
		if (_dashLength > 0)
		{
			// Do the dash. Phase out!
			velocity.x = _dashSpeed * _dashDirection.X;
			velocity.y = _dashSpeed * _dashDirection.Y;
			
			_phasesThroughWalls = true;
			_dashLength--;
		}
		else if (_dashLength == 0)
		{
			// Resume normal acceleration. MAYBE drop preceding velocity a bit?
			acceleration.y = _gravity;
			_phasesThroughWalls = false;
			
			// Touching the ground sets _dashLength to -1, meaning a new dash can begin.
			if (isTouching(FlxObject.FLOOR))
			{
				_dashLength = -1;
			}
		}
	}
	
	
	
	// Common helper functions
	/**
	 * Skid function. Used when changing directions on the ground,
	 * simply to prevent retyping it all the time. Override to add
	 * special animations?
	 * @param	directionSign	1 or -1, indicating the direction
	 * 							of movement.
	 */
	private function skid(directionSign : Int) : Void
	{
		var newDirection : Facing = _facing;
		
		if (directionSign > 0)
		{
			newDirection = RIGHT;
		}
		else if (directionSign < 0)
		{
			newDirection = LEFT;
		}
		
		if (_facing != newDirection)
		{
			_facing = newDirection;
		
			if (this.isTouching(FlxObject.FLOOR))
			{
				velocity.x /= CharacterConstants.kSkidDivisor;
			}
		}	
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
	 * Update the character.
	 */
	override public function update() : Void
	{		
		super.update();
		
		// Decrement the jumpDelay counter if it isn't already 0.
		if (_jumpGhost > 0)
		{
			_jumpGhost -= 1;
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