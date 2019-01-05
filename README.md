# haxeflixel-tiled-grouped-layers-demo

This is a demo for Adding Support for Tiled Grouped Layers to HaxeFlixel.

HaxeFlixel/flixel-addons issue: [319](https://github.com/HaxeFlixel/flixel-addons/issues/319)

### Use Case

Group layers can be added in Tiled to help organize other layers. 
Currently `TiledMap` loads layers which are direct children of **Layers** in Tiled. 
This feature will allow `TiledMap` to load nested children of **Layers**.

![Tiled Editor Demo](assets/html_images/grouped_layers_four.png)  
*Various objects and layers added to Tiled Group Layers*

### In Code

Layers from Tiled group layers are recursively added to `TiledMap.layers` property. Developers can then acccess layers normally from a map, without need to loop through nested layers.

```
var map = new TiledMap(flxTiledMapAsset);  
for (layer in map.layers)  
{  
    trace('loaded a layer of type ' + layer.type);
}
```

### In Tiled Editor

To add a Group Layer in Tiled:

1. Select **Layers**  
![Tiled Editor Select Layers](assets/html_images/grouped_layers_one.png)

2. Select **New Layer** >> **Group Layer**  
![Tiled Editor New Layer](assets/html_images/grouped_layers_two.png)

3. Optionally add more layers of any type in the new Group Layer (including more Group Layers)  
![Tiled Editor Nested Layers](assets/html_images/grouped_layers_three.png)