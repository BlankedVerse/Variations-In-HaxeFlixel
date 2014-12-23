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



class ActionButton
{
	public var ButtonName : String;
	public var Keys : Array<String> = new Array<String>();
	
	var _style : KeyStyle = PRESS;
	
	var _active : Bool = false;
	
	public function new (name : String, keyList : Array<String> = null, inputStyle : KeyStyle)
	{
		ButtonName = name;
		Keys = keyList;
		_style = inputStyle;
		_active = false;
	}
	
	
	
	/**
	 * Set a key, adding to its input list and changing its style.
	 * @param	keyList			Keys to add to this key's list.
	 * @param	?inputStyle		The new input style. Defaults to PRESS.
	 */
	public function SetKey(keyList : Array<String>, inputStyle : KeyStyle) : Void
	{
		// Add the newly assigned keys to this one, and change styles.
		if (keyList != null) 
		{
			Keys = Keys.concat(keyList);
		}
		
		_style = inputStyle;
		_active = false;
	}
	
	
	
	/**
	 * Get the value of an action key, based on its key style.
	 * If it's a hold, it returns 1 for held and 0 for not. 
	 * If it's a press, it returns whether it was just pressed.
	 * If it's a toggle, it returns the on/off state of that key toggle.
	 * @return					Boolean, for if that action is active/
	 * 							toggled.
	 */
	public function GetKeyInput() : Bool
	{
		var _returnValue : Bool = false;
		
		switch (_style)
		{
			case PRESS:
				_returnValue = FlxG.keys.anyJustPressed(Keys);
			case TOGGLE:
				if (FlxG.keys.anyJustPressed(Keys))
				{
					_active = !_active;
				}
				_returnValue = _active;
			case HOLD:
				_returnValue = FlxG.keys.anyPressed(Keys);
				//_active = _returnValue;
		}
		
		return _returnValue;
	}
}



/**
 * The controller is meant to provide a control interface. 
 * @author Colin McMillan
 */
class Controller
{
	var _actionList : Array<ActionButton>;
	var _buttonsInUse : Array<String>;
	
	
	/**
	 * Create a new controller.
	 */
	public function new()
	{		
		_actionList = new Array<ActionButton>();
		_buttonsInUse = new Array<String>();
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

	
	
	
	


	public function SetButton(actionName : String, ?keyList : Array<String> = null, inputStyle : KeyStyle) : ActionButton
	{	
		var buttonChanged : ActionButton = null;
		
		// If keys are given...
		if (keyList != null) 
		{
			// For each key provided...
			for (enteredKey in keyList) 
			{
				// ... remove that key from the existing "in use" list. If the key is removed thusly...
				if (_buttonsInUse.remove(enteredKey))
				{
					// Go through the action list and remove that key from other actions.
					for (action in _actionList)
					{
						action.Keys.remove(enteredKey);
					}
					// Now each key is free for the new assignment.
				}
				// And add the entered key into the buttonsInUse array.
				_buttonsInUse.push(enteredKey);
			}
			// Now every key in the new key list is freed and entered into the list of in-use keys for the controller.
		}
		// This SHOULD prevent keys being used for multiple actions. Yanks out already-in-use keys if applicable,
		// and adds the new keys into the list of all keys in use either way.
		
		// For each action button that already exists...
		for (existingActionButton in _actionList)
		{
			// Check if its name matches the new one.
			if (existingActionButton.ButtonName == actionName)
			{
				// If so, add to its keylist and set inputStyle.
				existingActionButton.SetKey(keyList, inputStyle);
				buttonChanged = existingActionButton;
			}
		} // The combination of the for scan and the if SHOULD prevent duplicate action names.
		
		// If the above sequence didn't change a key...
		if (buttonChanged == null)
		{
			// Create a new ActionButton, and add it to the actionList.
			buttonChanged = new ActionButton(actionName, keyList, inputStyle);
			_actionList.push(buttonChanged);
		}
		
		
		return buttonChanged;
	}
}