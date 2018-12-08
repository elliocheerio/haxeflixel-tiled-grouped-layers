package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledImageLayer;
import flixel.addons.editors.tiled.TiledImageTile;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.editors.tiled.TiledTilePropertySet;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.addons.tile.FlxTilemapExt;
import flixel.addons.tile.FlxTileSpecial;
import haxe.io.Path;

/**
 * @author Samuel Batista
 */
class TiledLevel extends TiledMap
{
	// For each "Tile Layer" in the map, you must define a "tileset" property which contains the name of a tile sheet image 
	// used to draw tiles in that layer (without file extension). The image file must be located in the directory specified bellow.
	inline static var c_PATH_LEVEL_TILESHEETS = "assets/";
	
	public var backgroundLayer:FlxGroup;
	public var imagesLayer:FlxGroup;
	public var coins:FlxGroup;
	var collidableTileLayers:Array<FlxTilemap>;
	
	public var player:FlxSprite;
	
	public function new(tiledLevel:FlxTiledMapAsset, state:PlayState)
	{
		super(tiledLevel);
		
		imagesLayer = new FlxGroup();
		backgroundLayer = new FlxGroup();
		coins = new FlxGroup();
		
		FlxG.camera.setScrollBoundsRect(0, 0, fullWidth, fullHeight, true);
		
		loadTiledLayers();
	}

	public function loadTiledLayers():Void
	{
		for (layer in layers)
		{
			switch (layer.type)
			{
				case TiledLayerType.TILE:
					loadLayerMap(layer);
				case TiledLayerType.OBJECT:
					loadLayerObjects(layer);
				case TiledLayerType.IMAGE:
					loadLayerImages(layer);
				default:
					// no layer type. do nothing
			}
		}
	}

	public function loadLayerMap(layer:TiledLayer):Void
	{
			var tileLayer:TiledTileLayer = cast layer;
			
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
				throw "Tileset '" + tileSheetName + " not found. Did you misspell the 'tilesheet' property in " + tileLayer.name + "' layer?";
				
			var imagePath 	  = new Path(tileSet.imageSource);
			var processedPath = c_PATH_LEVEL_TILESHEETS + imagePath.file + "." + imagePath.ext;
			
			// could be a regular FlxTilemap if there are no animated tiles
			var tilemap = new FlxTilemapExt();
			tilemap.loadMapFromArray(tileLayer.tileArray, width, height, processedPath,
				tileSet.tileWidth, tileSet.tileHeight, OFF, tileSet.firstGID, 1, 1);
			
			backgroundLayer.add(tilemap);

			if (collidableTileLayers == null)
				collidableTileLayers = new Array<FlxTilemap>();
				
			collidableTileLayers.push(tilemap);
	}

	public function loadLayerObjects(layer:TiledLayer)
	{
		var objectLayer:TiledObjectLayer = cast layer;

		for (object in objectLayer.objects)
		{
			loadObject(object, objectLayer);
		}
	}
	
	function loadObject(tiledObject:TiledObject, objectLayer:TiledObjectLayer)
	{
		var x:Int = tiledObject.x;
		var y:Int = tiledObject.y;
		
		// objects in tiled are aligned bottom-left (top-left in flixel)
		if (tiledObject.gid != -1)
			y -= objectLayer.map.getGidOwner(tiledObject.gid).tileHeight;
		
		switch (tiledObject.type.toLowerCase())
		{		
			case "coin":
				var coin = new FlxSprite(x, y, "assets/coin.png");
				coins.add(coin);

			default:
				// no object type provided in Tiled
		}
	}

	public function loadLayerImages(layer:TiledLayer)
	{
		var image:TiledImageLayer = cast layer;
		var sprite = new FlxSprite(image.x, image.y, c_PATH_LEVEL_TILESHEETS + image.imagePath);
		imagesLayer.add(sprite);
	}
	
	public function collideWithLevel(obj:FlxObject, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool
	{
		if (collidableTileLayers == null)
			return false;

		for (map in collidableTileLayers)
		{
			// IMPORTANT: Always collide the map with objects, not the other way around.
			//            This prevents odd collision errors (collision separation code off by 1 px).
			if (FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate))
			{
				return true;
			}
		}
		return false;
	}
}