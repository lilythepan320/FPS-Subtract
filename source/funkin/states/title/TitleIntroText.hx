package funkin.states.title;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import funkin.ui.Alphabet;

using StringTools;

class TitleIntroText extends funkin.backend.MusicBeat.MusicBeatState
{
	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	override public function create():Void
	{
		useDefaultTransIn = false;
		useDefaultTransOut = false;

		curWacky = FlxG.random.getObject(getIntroTextShit());

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		Conductor.bpm = 102;
		FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.8);
		Main.menuMusic = "freakyMenu";
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = CoolUtil.getText(Paths.text("introText"));
		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
			swagGoodArray.push(i.split('--'));

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		Conductor.songPosition = FlxG.sound.music.time;

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter)
			skipIntro();

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		switch (curBeat)
		{
			case 1:
				createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er', 'Rozebud']);
			case 3:
				deleteCoolText();
				addMoreText('present');
			case 5:
				deleteCoolText();
				addMoreText('In association');
			case 6:
				addMoreText('with');
			case 7:
				addMoreText('newgrounds');
				ngSpr.visible = true;
			case 8:
				deleteCoolText();
				ngSpr.visible = false;
			case 9:
				createCoolText([curWacky[0]]);
			case 11:
				addMoreText(curWacky[1]);
			case 12:
				deleteCoolText();
			case 13:
				addMoreText('Friday');
			case 14:
				addMoreText('Night');
			case 15:
				addMoreText('Funkin');
			case 16:
				skipIntro();
		}
	}

	function skipIntro():Void
	{
		switchState(new TitleScreen());
	}
}