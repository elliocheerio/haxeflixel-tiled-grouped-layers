package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flash.system.System;
import flash.Lib;

class PlayState extends FlxState
{
	public var player:FlxSprite;
	public var coins:FlxGroup;

	override public function create():Void
	{
		super.create();

		FlxG.log.redirectTraces = true;

		var level = new TiledLevel("assets/level.tmx", this);

		player = new FlxSprite("assets/player.png");
		player.x = 160;
		player.y = 112;

		coins = level.coins;

		add(player);

		FlxG.camera.follow(player, LOCKON);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		FlxG.overlap(coins, player, pickupCoin);

		input();
	}

	private function pickupCoin(coin:FlxObject, player:FlxObject):Void
	{
		trace("you got a coin!");

		coin.destroy();
	}

	private function input():Void
	{
		var velocity:Int = 50;

		player.velocity.x = 0;
		player.velocity.y = 0;

		if (FlxG.keys.anyPressed([LEFT, A]))
		{
			player.velocity.x -= velocity;
		}
		if (FlxG.keys.anyPressed([RIGHT, D]))
		{
			player.velocity.x += velocity;
		}
		if (FlxG.keys.anyPressed([W, UP]))
		{
			player.velocity.y -= velocity;
		}
		if (FlxG.keys.anyPressed([S, DOWN]))
		{
			player.velocity.y += velocity;
		}

		// restart
		if(FlxG.keys.anyJustPressed(["R"]))
		{
			player = null;
			coins = null;
			FlxG.switchState(new PlayState());
		}

		// quit
		if (FlxG.keys.anyPressed([ESCAPE]))
		{
			#if !flash
			System.exit(0);
			#else
			Lib.fscommand("quit");
			#end
		}
	}
}
