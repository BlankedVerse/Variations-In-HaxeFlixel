package ;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxPoint;
import flixel.util.FlxColor;

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
	
	var _headText : FlxText;
	var _bodyText : FlxText;
	
	/**
	 * Whether the UI frame is closed
	 */
	var Finished : Bool;

	/**
	 * 
	 * @param	xOffset
	 * @param	yOffset
	 * @param	anchor
	 */
	public function new(xOffset:Float = 0, yOffset:Float = 0,
						controller : Controller,
						header : String,
						?initWidth : Int,
						?initHeight : Int,
						?anchor : FlxObject = null) 
	{
		_controller = controller;
		_anchor = anchor;
		width = initWidth;
		height = initHeight;
		
		
		if (_anchor == null)
		{
			super((_anchor.x + xOffset), (_anchor.y + yOffset));
		}
		else
		{
			scrollFactor = new FlxPoint(0, 0);
			super(xOffset, yOffset);
		}
		
		_headText = new FlxText(0, 0, 0, header);
		shiftText();
		
		hide();
		
		makeGraphic(initWidth, initHeight, FlxColor.BLACK);
	}
	
	private function shiftText() : Void
	{
		_headText.x = this.x;
		_headText.y = this.y;
		_headText.update();
		
		if (_bodyText != null)
		{
			var midway : FlxPoint = this.getMidpoint();
			_bodyText.x = this.x;
			_bodyText.y = midway.y;
			_bodyText.update();
		}
	}
	
	private function hide() : Void
	{
		this.set_visible(false);
		
		_headText.set_visible(false);
		if (_bodyText != null)
		{
			_bodyText.set_visible(false);
		}
	}
	
	private function show() : Void
	{
		this.set_visible(true);
		
		_headText.set_visible(true);
		if (_bodyText != null)
		{
			_bodyText.set_visible(true);
		}
	}
	
	override public function update() : Void
	{
		super.update();
		
		if (_anchor != null)
		{
			
		}
		else
		{
			
		}
		
		shiftText();
		// Check for input and stuff...
	}
	
	override public function destroy() : Void
	{
		super.destroy();
	}
}



