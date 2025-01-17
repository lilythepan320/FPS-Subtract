package funkin.substates;

import config.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import funkin.states.menus.*;
import funkin.states.PlayState;
import funkin.ui.Alphabet;
#if (flixel >= "5.3.0")
import flixel.sound.FlxSound;
#else
import flixel.system.FlxSound;
#end

class PauseSubState extends funkin.backend.MusicBeat.MusicBeatSubState
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', "Options", 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	public function new(x:Float, y:Float)
	{
		super();

		openfl.Lib.current.stage.frameRate = Main.frameRate;

		FlxTween.globalManager.active = false;

		if (PlayState.storyPlaylist.length > 1 && PlayState.isStoryMode)
		{
			menuItems.insert(2, "Skip Song");
		}

		if (!PlayState.isStoryMode)
		{
			menuItems.insert(2, "Chart Editor");
		}

		if (!PlayState.isStoryMode && PlayState.sectionStart)
		{
			menuItems.insert(1, "Restart Section");
		}

		var pauseSongName = "breakfast";

		switch (PlayState.SONG.song.toLowerCase())
		{
			case "ugh" | "guns" | "stress":
				pauseSongName = "distorto";
		}

		pauseMusic = new FlxSound().loadEmbedded(Paths.music(pauseSongName), true, true);

		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.8)
			pauseMusic.volume += 0.05 * elapsed;

		super.update(elapsed);

		if (controls.UP_P || controls.DOWN_P)
			changeSelection(controls.DOWN_P ? 1 : -1);

		if (controls.ACCEPT)
		{
			FlxTween.globalManager.active = true;

			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					unpause();

				case "Restart Song":
					FlxTween.globalManager.clear();
					PlayState.instance.switchState(new PlayState());
					PlayState.sectionStart = false;

				case "Restart Section":
					FlxTween.globalManager.clear();
					PlayState.instance.switchState(new PlayState());

				case "Chart Editor":
					subtract.input.PlayerSettings.menuControls();
					FlxTween.globalManager.clear();
					PlayState.instance.switchState(new funkin.states.debug.ChartingState());

				case "Skip Song":
					FlxTween.globalManager.clear();
					PlayState.instance.endSong();

				case "Options":
					FlxTween.globalManager.clear();
					PlayState.instance.switchState(new ConfigMenu());
					ConfigMenu.exitTo = PlayState;

				case "Exit to menu":
					FlxTween.globalManager.clear();
					PlayState.sectionStart = false;

					switch (PlayState.returnLocation)
					{
						case "freeplay":
							PlayState.instance.switchState(new FreeplayMenu());
						case "story":
							PlayState.instance.switchState(new StoryMenu());
						default:
							PlayState.instance.switchState(new MainMenu());
					}
			}
		}
	}

	function unpause()
	{
		if (Config.noFpsCap)
			openfl.Lib.current.stage.frameRate = 999;
		close();
	}

	override function destroy()
	{
		pauseMusic.destroy();
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected = flixel.math.FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);

		var bullShit:Int = 0;
		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			item.alpha = item.targetY == 0 ? 1.0 : 0.6;
			bullShit++;
		}
	}
}
