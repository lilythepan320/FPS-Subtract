package funkin.states.menus;

import config.*;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import funkin.states.title.TitleScreen;

using StringTools;

class MainMenu extends funkin.backend.MusicBeat.MusicBeatState
{
	var curSelected:Int = 0;
	var menuItems:FlxTypedGroup<FlxSprite>;
	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', "options"];

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	var versionText:FlxText;
	var keyWarning:FlxText;

	override function create()
	{
		openfl.Lib.current.stage.frameRate = 144;

		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music(Main.menuMusic), 1);

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menu/menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.18));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menu/menuBGMagenta'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.18));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		add(magenta);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('menu/FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
			menuItem.frames = tex;

			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
		}

		FlxG.camera.follow(camFollow, null, 0.004);

		versionText = new FlxText(5, FlxG.height - 21, 0, "FPS / Plus: v4.0.1 / Subtract: v0.01", 16);
		versionText.scrollFactor.set();
		versionText.setFormat(Paths.font("vcr"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionText);

		keyWarning = new FlxText(5, FlxG.height - 21 + 16, 0, "If your controls aren't working, try pressing CTRL + BACKSPACE to reset them.", 16);
		keyWarning.scrollFactor.set();
		keyWarning.setFormat(Paths.font("vcr"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		keyWarning.alpha = 0;
		add(keyWarning);

		FlxTween.tween(versionText, {y: versionText.y - 16}, 0.75, {ease: FlxEase.quintOut, startDelay: 10});
		FlxTween.tween(keyWarning, {alpha: 1, y: keyWarning.y - 16}, 0.75, {ease: FlxEase.quintOut, startDelay: 10});

		changeItem();

		// Offset Stuff
		Config.reload();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (!selectedSomethin)
		{
			if (controls.UP_P || controls.DOWN_P)
				changeItem(controls.DOWN_P ? 1 : -1);

			if (FlxG.keys.justPressed.BACKSPACE && FlxG.keys.pressed.CONTROL)
			{
				KeyBinds.resetBinds();
				switchState(new MainMenu());
			}

			if (controls.BACK)
				switchState(new TitleScreen());

			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				var daChoice:String = optionShit[curSelected];

				switch (daChoice)
				{
					case 'freeplay':
						FlxG.sound.music.stop();
					case 'options':
						FlxG.sound.music.stop();
				}

				FlxFlicker.flicker(magenta, 1.1, 0.15, false);

				menuItems.forEach(function(spr:FlxSprite)
				{
					if (curSelected != spr.ID)
					{
						FlxTween.tween(spr, {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
					}
					else
					{
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
						{
							// var daChoice:String = optionShit[curSelected];

							spr.visible = true;

							switch (daChoice)
							{
								case 'story mode':
									switchState(new StoryMenu());
								case 'freeplay':
									FreeplayMenu.startingSelection = 0;
									switchState(new FreeplayMenu());
								case 'options':
									switchState(new ConfigMenu());
							}
						});
					}
				});
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected = flixel.math.FlxMath.wrap(curSelected + huh, 0, menuItems.length - 1);

		if (huh != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'));

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}