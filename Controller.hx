package ;


import flixel.FlxBasic;
import flixel.FlxG;
import flixel.util.FlxPoint;


enum KeyStyle
{
	TOGGLE;
	HOLD;
	PRESS;
}



class IntPoint
{
	public var X : Int = 0;
	public var Y : Int = 0;
	
	public function new(newX : Int, newY : Int)
	{
		X = newX;
		Y = newY;
	}
}



/**
 * The controller is meant to provide a control interface. 
 * @author Colin McMillan
 */
class Controller
{
	var _actionOneKeys : Array<String> = new Array<String>();
	var _actionTwoKeys : Array<String> = new Array<String>();
	
	var _actionOneStyle : KeyStyle = PRESS;
	var _actionTwoStyle : KeyStyle = PRESS;
	
	var _actionOneOn : Bool = false;
	var _actionTwoOn : Bool = false;
	
	
	/**
	 * Create a new controller.
	 */
	public function new(?actionOne : Array<String> = null, ?actionTwo : Array<String> = null)
	{		
		SetActionKeys(actionOne, actionTwo);
	}
	
	
	
	/**
	 * Gets the direction keys currently pressed. Validates to ensure
	 * that opposite directions being pressed results in 0.
	 * @return 	A FlxPoint, with x and y being either 1 or -1,
	 * 			corresponding to the direction keys pressed.
	 * 			1 for down/right, -1 for up/left.
	 * 			0 for neither/both in that axis.
	 */
	public function GetDirection() : IntPoint
	{
		var _directions : IntPoint = new IntPoint(0, 0);
		
		// Update all direction keys pressed.
		var _up = FlxG.keys.anyPressed(["UP", "W"]);
		var _down = FlxG.keys.anyPressed(["DOWN", "S"]);
		var _right = FlxG.keys.anyPressed(["RIGHT", "D"]);
		var _left = FlxG.keys.anyPressed(["LEFT", "A"]);
		
		if ((_up) && (!_down))
		{
			_directions.Y = -1;
		}
		else if ((_down) && (!_up))
		{
			_directions.Y = 1;		
		}
		
		if ((_left) && (!_right))
		{
			_directions.X = -1;
		}
		else if ((!_left) && (_right))
		{
			_directions.X = 1;	
		}
		
		return _directions;
	}
	
	
	
	/**
	 * Get the value of an action key, based on its key style.
	 * If it's a hold, it returns 1 for held and 0 for not. 
	 * If it's a press, it returns whether it was just pressed.
	 * If it's a toggle, it returns the on/off state of that key toggle.
	 * @param	actionNumber	1 or 2, for the respective action key
	 * @return					Boolean, for if that action is active/
	 * 							toggled.
	 */
	public function GetActionKeyValue(actionNumber : Int) : Bool
	{
		var _returnValue : Bool = false;
		
		// Check what action number is set.
		if ((actionNumber == 1) && (_actionOneStyle != null))
		{
			switch (_actionOneStyle)
			{
			case PRESS:
				_returnValue = FlxG.keys.anyJustPressed(_actionOneKeys);
			case TOGGLE:
				if (FlxG.keys.anyJustPressed(_actionOneKeys))
				{
					_actionOneOn = !_actionOneOn;
				}
				_returnValue = _actionOneOn;
			case HOLD:
				_returnValue = FlxG.keys.anyPressed(_actionOneKeys);
			}
		}
		else if ((actionNumber == 2) && (_actionTwoStyle != null))
		{
			switch (_actionTwoStyle)
			{
			case PRESS:
				_returnValue = FlxG.keys.anyJustPressed(_actionTwoKeys);
			case TOGGLE:
				if (FlxG.keys.anyJustPressed(_actionTwoKeys))
				{
					_actionTwoOn = !_actionTwoOn;
					_returnValue = _actionTwoOn;
				}
			case HOLD:
				_returnValue = FlxG.keys.anyPressed(_actionTwoKeys);
			}
		}
		
		return _returnValue;
	}
	
	
	
	/**
	 * Set up action keys. Called when creating a controller, but can also be
	 * set separately.
	 * @param	actionOne		The set of keys usable to trigger action one.
	 * @param	actionTwo		The set of keys usable to trigger action one.
	 */
	public function SetActionKeys(actionOne : Array<String>, actionTwo : Array<String>) : Void
	{	
		if (actionOne != null)
		{
			_actionOneKeys = actionOne;
			_actionOneOn = false;
		}
		
		if (actionTwo != null)
		{
			_actionTwoKeys = actionTwo;
			_actionTwoOn = false;
		}
	}
	
	
	
	/**
	 * Set up action keys. Called when creating a controller, but can also be
	 * set separately.
	 * @param	oneStyle		The button style of action one.
	 * @param	twoStyle		The button style of action one.
	 */
	public function SetActionStyle(slot : Int, style : KeyStyle) : Void
	{	
		if (slot == 1)
		{
			_actionOneStyle = style;
		}
		else if (slot == 2)
		{
			_actionTwoStyle = style;
		}
	}
}