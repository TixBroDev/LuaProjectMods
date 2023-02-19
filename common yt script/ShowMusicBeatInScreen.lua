function onCreatePost()

	addHaxeLibrary('FlxCamera', 'flixel');
	runHaxeCode([[
	MadPause = new FlxCamera();
	MadPause.bgColor = 0x0000000000;
	FlxG.cameras.add(MadPause, false);
	game.boyfriend.cameras = [MadPause];
	]])
	end
	
	 