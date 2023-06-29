package;

import config.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Assets;
import openfl.media.Sound;
import openfl.system.System;
import sys.FileSystem;
import title.*;
import transition.data.*;

using StringTools;

class Startup extends FlxState
{
    var splash:FlxSprite;
    var loadingBar:FlxBar;
    var loadingText:FlxText;

    var currentLoaded:Int = 0;
    var loadTotal:Int = 0;

    var songsCached:Bool;
    public static final songs:Array<String> =   ["Tutorial", 
                                "Bopeebo", "Fresh", "Dadbattle", 
                                "Spookeez", "South", "Monster",
                                "Pico", "Philly", "Blammed", 
                                "Satin-Panties", "High", "Milf", 
                                "Cocoa", "Eggnog", "Winter-Horrorland", 
                                "Senpai", "Roses", "Thorns",
                                "Ugh", "Guns", "Stress",
                                "Lil-Buddies",
                                "klaskiiLoop", "freakyMenu"]; //Start of the non-gameplay songs.
                                
    //List of character graphics and some other stuff.
    //Just in case it want to do something with it later.
    var charactersCached:Bool;
    var startCachingCharacters:Bool = false;
    var charI:Int = 0;
    public static final characters:Array<String> =   ["BOYFRIEND", "week4/bfCar", "week5/bfChristmas", "week6/bfPixel", "week6/bfPixelsDEAD", "week7/bfAndGF", "week7/bfHoldingGF-DEAD",
                                    "GF_assets", "week4/gfCar", "week5/gfChristmas", "week6/gfPixel", "week7/gfTankmen",
                                    "week1/DADDY_DEAREST", 
                                    "week2/spooky_kids_assets", "week2/Monster_Assets",
                                    "week3/Pico_FNF_assetss", "week7/picoSpeaker",
                                    "week4/Mom_Assets", "week4/momCar",
                                    "week5/mom_dad_christmas_assets", "week5/monsterChristmas",
                                    "week6/senpai", "week6/spirit",
                                    "week7/tankmanCaptain"];

    var graphicsCached:Bool;
    var startCachingGraphics:Bool = false;
    var gfxI:Int = 0;
    public static final graphics:Array<String> =    ["logoBumpin", "logoBumpin2", "gfDanceTitle2", "titleEnter", "fpsPlus/title/backgroundBf", "fpsPlus/title/barBottom", "fpsPlus/title/barTop", "fpsPlus/title/gf", "fpsPlus/title/glow", 
                                    "week1/stageback", "week1/stagefront", "week1/stagecurtains",
                                    "week2/halloween_bg",
                                    "week3/philly/sky", "week3/philly/city", "week3/philly/behindTrain", "week3/philly/train", "week3/philly/street", "week3/philly/win0", "week3/philly/win1", "week3/philly/win2", "week3/philly/win3", "week3/philly/win4",
                                    "week4/limo/bgLimo", "week4/limo/fastCarLol", "week4/limo/limoDancer", "week4/limo/limoDrive", "week4/limo/limoSunset",
                                    "week5/christmas/bgWalls", "week5/christmas/upperBop", "week5/christmas/bgEscalator", "week5/christmas/christmasTree", "week5/christmas/bottomBop", "week5/christmas/fgSnow", "week5/christmas/santa",
                                    "week5/christmas/evilBG", "week5/christmas/evilTree", "week5/christmas/evilSnow",
                                    "week6/weeb/weebSky", "week6/weeb/weebSchool", "week6/weeb/weebStreet", "week6/weeb/weebTreesBack", "week6/weeb/weebTrees", "week6/weeb/petals", "week6/weeb/bgFreaks",
                                    "week6/weeb/animatedEvilSchool", "week6/weeb/senpaiCrazy",
                                    "week7/stage/tank0", "week7/stage/tank1", "week7/stage/tank2", "week7/stage/tank3", "week7/stage/tank4", "week7/stage/tank5", "week7/stage/tankmanKilled1", 
                                    "week7/stage/smokeLeft", "week7/stage/smokeRight", "week7/stage/tankBuildings", "week7/stage/tankClouds", "week7/stage/tankGround", "week7/stage/tankMountains", "week7/stage/tankRolling", "week7/stage/tankRuins", "week7/stage/tankSky", "week7/stage/tankWatchtower"];

    var cacheStart:Bool = false;

    public static var thing = false;

    public static var hasEe2:Bool;

    function initSave():Void {
        FlxG.save.bind('data');

        Highscore.load();
        KeyBinds.keyCheck();
        PlayerSettings.init();
        PlayerSettings.player1.controls.loadKeyBinds();
        Config.configCheck();
    }

    function loadData():Void {
        if (FlxG.save.data.weekUnlocked != null) {
            // FIX LATER!!!
            // WEEK UNLOCK PROGRESSION!!
            // StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

            if (StoryMenuState.weekUnlocked.length < 4)
                StoryMenuState.weekUnlocked.insert(0, true);

            // QUICK PATCH OOPS!
            if (!StoryMenuState.weekUnlocked[0])
                StoryMenuState.weekUnlocked[0] = true;
        }

        if( FlxG.save.data.musicPreload2 == null ||
            FlxG.save.data.charPreload2 == null ||
            FlxG.save.data.graphicsPreload2 == null)
        {
            openPreloadSettings();
        }
        else {
            songsCached = !FlxG.save.data.musicPreload2;
            charactersCached = !FlxG.save.data.charPreload2;
            graphicsCached = !FlxG.save.data.graphicsPreload2;
        }
    }

	override function create()
	{
        FlxG.mouse.visible = false;
        FlxG.sound.muteKeys = null;

        UIStateExt.defaultTransIn = ScreenWipeIn;
        UIStateExt.defaultTransInArgs = [1.2];
        UIStateExt.defaultTransOut = ScreenWipeOut;
        UIStateExt.defaultTransOutArgs = [0.6];

        DiscordClient.start();
        DiscordClient.changePresence("Work in Progress!", "FPS Subtract");

        initSave();
        loadData();

        hasEe2 = CoolUtil.exists(Paths.inst("Lil-Buddies"));

        splash = new FlxSprite(0, 0);
        splash.frames = Paths.getSparrowAtlas('fpsPlus/rozeSplash');
        splash.animation.addByPrefix('start', 'Splash Start', 24, false);
        splash.animation.addByPrefix('end', 'Splash End', 24, false);
        splash.animation.play("start");
        splash.updateHitbox();
        splash.screenCenter();
        add(splash);

        loadTotal = (!songsCached ? songs.length : 0) + (!charactersCached ? characters.length : 0) + (!graphicsCached ? graphics.length : 0);

        if(loadTotal > 0){
            loadingBar = new FlxBar(0, 605, LEFT_TO_RIGHT, 600, 24, this, 'currentLoaded', 0, loadTotal);
            loadingBar.createFilledBar(0xFF333333, 0xFF95579A);
            loadingBar.screenCenter(X);
            loadingBar.visible = false;
            add(loadingBar);
        }

        loadingText = new FlxText(5, FlxG.height - 30, 0, '', 24);
        loadingText.setFormat(Paths.font("vcr"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(loadingText);

        new FlxTimer().start(1.1, function(tmr:FlxTimer) {
            FlxG.sound.play(Paths.sound("splashSound"));
            new FlxTimer().start(1.0, function(tmr:FlxTimer) {
                splash.animation.play("end", true);
                splash.animation.finishCallback = function(anim:String):Void
                    FlxG.switchState(new TitleVideo());
            });
        });

        super.create();
    }

    override function update(elapsed:Float):Void
    {
        // REDO ALL OF THIS LATER SO IT ISN'T ON BOOT LOL!!!!
        /*
            if (splash.animation.curAnim.finished && splash.animation.curAnim.name == "start" && !cacheStart) {
                #if web
                new FlxTimer().start(1.5, function(tmr:FlxTimer) {
                    songsCached = charactersCached = graphicsCached = true;
                });
                #else
                if (!songsCached || !charactersCached || !graphicsCached)
                    preload(); 
                #end
                cacheStart = true;
            }

            if (splash.animation.curAnim.finished && splash.animation.curAnim.name == "end")
                FlxG.switchState(new TitleVideo());

            if (songsCached && charactersCached && graphicsCached && splash.animation.curAnim.finished && splash.animation.curAnim.name != "end") {
                splash.animation.play("end");
                splash.updateHitbox();
                splash.screenCenter();

                new FlxTimer().start(0.3, function(tmr:FlxTimer) {
                    loadingText.text = "Done!";
                    if(loadingBar != null)
                        FlxTween.tween(loadingBar, {alpha: 0}, 0.3);
                });
            }

            if(!cacheStart && FlxG.keys.justPressed.ANY)
                openPreloadSettings();

            if(startCachingCharacters){
                if(charI >= characters.length){
                    loadingText.text = "Characters cached...";
                    startCachingCharacters = false;
                    charactersCached = true;
                }
                else {
                    if(CoolUtil.exists(Paths.file(characters[charI], "images", "png")))
                        ImageCache.add(Paths.file(characters[charI], "images", "png"));

                    charI++;
                    currentLoaded++;
                }
            }

            if(startCachingGraphics){
                if(gfxI >= graphics.length){
                    loadingText.text = "Graphics cached...";
                    startCachingGraphics = false;
                    graphicsCached = true;
                }
                else {
                    if(CoolUtil.exists(Paths.file(graphics[gfxI], "images", "png")))
                        ImageCache.add(Paths.file(graphics[gfxI], "images", "png"));

                    gfxI++;
                    currentLoaded++;
                }
            }
        */
        super.update(elapsed);
    }

    function preload() {
        loadingText.text = "Caching Assets...";

        if(loadingBar != null)
            loadingBar.visible = true;

        if(!songsCached) { 
            #if sys sys.thread.Thread.create(() -> { #end
                preloadMusic();
            #if sys }); #end
        }

        if(!charactersCached) startCachingCharacters = true;
        if(!graphicsCached) startCachingGraphics = true;
    }

    function preloadMusic() {
        for(x in songs) {
            if(CoolUtil.exists(Paths.inst(x)))
                FlxG.sound.cache(Paths.inst(x));
            else
                FlxG.sound.cache(Paths.music(x));
            currentLoaded++;
        }
        loadingText.text = "Songs cached...";
        songsCached = true;
    }

    function preloadCharacters() {
        for(x in characters)
            ImageCache.add(Paths.file(x + ".png", "images"));

        loadingText.text = "Characters cached...";
        charactersCached = true;
    }

    function preloadGraphics(){
        for(x in graphics)
            ImageCache.add(Paths.file(x + ".png", "images"));

        loadingText.text = "Graphics cached...";
        graphicsCached = true;
    }

    function openPreloadSettings() {
        #if desktop
        CacheSettings.noFunMode = true;
        FlxG.switchState(new CacheSettings());
        CacheSettings.returnLoc = new Startup();
        #end
    }

}
