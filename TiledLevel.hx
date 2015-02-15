package;

import flixel.FlxBasic;
import haxe.io.Path;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;

import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledTileSet;

import PlayerCharacter;
import Controller;

/**
 * ...
 * @author Samuel Batista
 */
class TiledLevel extends TiledMap
{
	// For each "Tile Layer" in the map, you must define a "tileset" property which contains the name of a tile sheet image 
	// used to draw tiles in that layer (without file extension). The image file must be located in the directory specified bellow.
	private inline static var c_PATH_LEVEL_TILESHEETS = "assets/data/";
	
	public var foregroundTiles:FlxGroup;
	public var backgroundTiles:FlxGroup;
	
	private var collidableTileLayers:FlxGroup;
	private var ghostCollidableTileLayers:FlxGroup;
	
	private var playerOneControls : Controller;

	public function new(tiledLevel:Dynamic, playerOne : Controller)
	{
		super(tiledLevel);
		
		playerOneControls = playerOne;
		
		foregroundTiles = new FlxGroup();
		backgroundTiles = new FlxGroup();
		
		FlxG.camera.setBounds(0, 0, fullWidth, fullHeight, true);
		
		// Load Tile Maps
		for (tileLayer in layers)
		{
			var tileSheetName:String = tileLayer.properties.get("tileset");
			
			if (tileSheetName == null)
				throw "'tileset' property not defined for the '" + tileLayer.name + "' layer. Please add the property to the layer.";
				
			var tileSet:TiledTileSet = null;
			for (ts in tilesets)
			{
				if (ts.name == tileSheetName)
				{
					tileSet = ts;
					break;
				}
			}
			
			if (tileSet == null)
				throw "Tileset '" + tileSheetName + " not found. Did you mispell the 'tilesheet' property in " + tileLayer.name + "' layer?";
				
			var imagePath 		= new Path(tileSet.imageSource);
			var processedPath 	= c_PATH_LEVEL_TILESHEETS + imagePath.file + "." + imagePath.ext;
			
			var tilemap:FlxTilemap = new FlxTilemap();
			tilemap.widthInTiles = width;
			tilemap.heightInTiles = height;
			tilemap.loadMap(tileLayer.tileArray, processedPath, tileSet.tileWidth, tileSet.tileHeight, 0, 1, 1, 1);
			
			if (tileLayer.properties.contains("nocollide"))
			{
				backgroundTiles.add(tilemap);
			}
			else
			{
				foregroundTiles.add(tilemap);
				
				if (collidableTileLayers == null)
				{
					collidableTileLayers = new FlxGroup();
				}
				collidableTileLayers.add(tilemap);
				
				// This checks for a property "ghostCollide" and sets those layers
				// to the ghostcollision layer, to collide with ghost-types. These are just
				// the thick walls ghosts can't drift through. Thin walls AND thick
				// walls are included in collidableTileLayers.
				if (tileLayer.properties.contains("ghostCollide"))
				{
					if (ghostCollidableTileLayers == null)
					{
						ghostCollidableTileLayers = new FlxGroup();
					}
					ghostCollidableTileLayers.add(tilemap);
				}
			}
		}
	}
	
	public function loadObjects(state:PlayState)
	{
		for (group in objectGroups)
		{
			for (o in group.objects)
			{
				loadObject(o, group, state);
			}
		}
	}
	
	private function loadObject(o:TiledObject, g:TiledObjectGroup, state:PlayState)
	{
		var x:Int = o.x;
		var y:Int = o.y;
		
		var player : PlayerCharacter;
		
		// objects in tiled are aligned bottom-left (top-left in flixel)
		if (o.gid != -1)
		{
			y -= g.map.getGidOwner(o.gid).tileHeight;
		}
		switch (o.type.toLowerCase())
		{
			// Switch the different types of critters here.
			case "player":
				// Define and set the critter.
				player = new PlayerCharacter(x, y, playerOneControls);
				state.add(player);
		}
	}
	
	public function collideWithLevel(obj:FlxBasic, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool, ?ghost:Bool = false):Bool
	{
		if (!ghost)
		{
			if (collidableTileLayers != null)
			{
				//for (map in collidableTileLayers)
				{
					// IMPORTANT: Always collide the map with objects, not the other way around. 
					//			  This prevents odd collision errors (collision separation code off by 1 px).
					return FlxG.overlap(collidableTileLayers, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate);
				}
			}
		}
		else if (ghost)
		{
			if (ghostCollidableTileLayers != null)
			{
				//for (map in ghostCollidableTileLayers)
				{
					// IMPORTANT: Always collide the map with objects, not the other way around. 
					//			  This prevents odd collision errors (collision separation code off by 1 px).
					return FlxG.overlap(ghostCollidableTileLayers, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate);
				}
			}
		}
		return false;
	}
	
	public function clearLevel():Void
	{
		foregroundTiles.destroy();
		backgroundTiles.destroy();
		collidableTileLayers.destroy();
		ghostCollidableTileLayers.destroy();
	}
}
