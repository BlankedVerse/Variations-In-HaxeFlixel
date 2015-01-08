package ;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxPoint;

import Controller;


/**
 * ...
 * @author ...
 */
class UIFrame extends FlxSprite
{
	/**
	 * The anchor to tie this frame to, which it will follow.
	 * If null, the frame is tied to a position on the screen.
	 */
	var _anchor : FlxObject;
	
	/**
	 * The offset of the upper left point of the frame from its anchor.
	 */
	var _offset : FlxPoint;
	
	var _controller : Controller;

	/**
	 * 
	 * @param	xOffset
	 * @param	yOffset
	 * @param	anchor
	 */
	public function new(xOffset:Float = 0, yOffset:Float = 0,
						controller : Controller,
						?anchor : FlxObject = null) 
	{
		_controller = controller;
		_anchor = anchor;
		
		if (_anchor = null)
		{
			super((_anchor.x + xOffset), (_anchor.y + yOffset));
		}
		else
		{
			scrollFactor(0, 0);
			super(xOffset, yOffset);
		}
	}
	
	override public function update() : Void
	{
		super.update();
	}
	
	override public function destroy() : Void
	{
		super.destroy();
	}
}



