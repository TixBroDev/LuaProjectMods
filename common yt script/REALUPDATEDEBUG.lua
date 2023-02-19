--[[
	Base Script by Kevin Kuntz
	Modified by Raltyro
--]]

-- uncomment this if you want it to print on the command prompt instead or not wanting psych to crash LMAO
local debugPrint = print

function math.clamp(x,min,max)return math.max(min,math.min(x,max))end

function math.truncate(x, precision, round)
	if (precision == 0) then return math.floor(x) end
	
	precision = type(precision) == "number" and precision or 2
	
	x = x * math.pow(10, precision);
	return (round and math.floor(x + .5) or math.floor(x)) / math.pow(10, precision)
end

function cgProperty(i, v)
	return setProperty(i, getProperty(i) + v)
end

function cgPropertyFromGroup(o, id, i, v)
	return setPropertyFromGroup(o, id, i, getPropertyFromGroup(o, id, i) + v)
end

function cgPropertyFromClass(c, i, v)
	return setPropertyFromClass(c, i, getPropertyFromClass(c, i) + v)
end

local function getJustPressedKey(str)
	local b = keyboardJustPressed and keyboardJustPressed(str) or
		getPropertyFromClass("flixel.FlxG", "keys.justPressed." .. str)
	return type(b) == "boolean" and b or false
end

local function getPressedKey(str)
	local b = keyboardPressed and keyboardPressed(str) or
		getPropertyFromClass("flixel.FlxG", "keys.pressed." .. str)
	return type(b) == "boolean" and b or false
end

local function getJustReleasedKey(str)
	local b = keyboardReleased and keyboardReleased(str) or
		getPropertyFromClass("flixel.FlxG", "keys.justReleased." .. str)
	return type(b) == "boolean" and b or false
end

local travelHealth, travelBotplay = 100, -1
local function travel(ms)
	local prev = getPropertyFromClass("Conductor", "songPosition")
	
	local pos = math.clamp(
		prev + (type(ms) == "number" and ms or 0),
		1,
		getPropertyFromClass("flixel.FlxG", "sound.music.length") - 50
	)
	
	setPropertyFromClass("Conductor", "songPosition", pos)
	
	if (type(getPropertyFromClass("flixel.FlxG", "sound.music._channel.position")) == "number" and ms > 0) then
		setPropertyFromClass("flixel.FlxG", "sound.music._channel.position", pos)
	else
		setPropertyFromClass("flixel.FlxG", "sound.music.time", pos)
	end
	if (type(getProperty("vocals._channel.position")) == "number" and ms > 0) then
		setProperty("vocals._channel.position", pos)
	else
		setProperty("vocals.time", pos)
	end
	
	if (not getProperty('cpuControlled')) then
		travelHealth = getProperty("health")
		travelBotplay = 8
		setProperty('cpuControlled', true)
	end
	
	debugPrint("Traveled from " .. tostring(math.truncate(prev)) .. " to " .. tostring(math.truncate(pos)))
	
	return pos
end

local function toggleBotplay(b)
	local curBotplay = getProperty('cpuControlled')
	if (type(b) ~= "boolean") then b = not curBotplay end
	
	if (b == curBotplay) then return end
	setProperty('cpuControlled', b)
	setProperty('botplayTxt.visible', b)
	
	debugPrint("BotPlay " .. (b and "On" or "Off"))
end

local function togglePractice(b)
	local curPractice = getProperty('practiceMode')
	if (type(b) ~= "boolean") then b = not curPractice end
	
	if (b == curBotplay) then return end
	setProperty('practiceMode', b)
	
	debugPrint("Practice " .. (b and "On" or "Off"))
end

local optim = false
local ccc = false
function onCreate()
	ccc = getPropertyFromClass("PlayState", "chartingMode")
	if (runHaxeCode ~= nil) then
		optim = true
		
		addHaxeLibrary("Math")
		addHaxeLibrary("Reflect")
		
		addHaxeLibrary("FlxG", "flixel")
		
		addHaxeLibrary("PauseSubState")
		
		runHaxeCode([[
	keys = FlxG.keys;
	justPressed = keys.justPressed;
	pressed = keys.pressed;
	justReleased = keys.justReleased;
	
	truncate = function(x, ?precision, ?round) {
		if (precision == null) precision = 2;
		if (round == null) round = true;
		if (precision == 0) return Math.floor(x);
		
		x = x * Math.pow(10, precision);
		return (round ? Math.round(x) : Math.floor(x)) / Math.pow(10, precision);
	}
	
	clamp = function(x, ?min, ?max) {
		if (min == null) min = -99999999;
		if (max == null) max = 99999999;
		return Math.max(min, Math.min(x, max));
	}
	
	debugPrint = function(?v1, ?v2, ?v3) {
		var str = '';
		if (v1 != null) str = v1;
		if (v2 != null) str = str + ", " + v2;
		if (v3 != null) str = str + ", " + v3;
		if (]] .. (debugPrint == print and "true" or "false") .. [[)
			trace(str);
		else {
			var str = '';
			if (v1 != null) str = v1;
			if (v2 != null) str = str + ", " + v2;
			if (v3 != null) str = str + ", " + v3;
			game.addTextToDebug(str, 0xFFFFFFFF);
		}
	}
	
	var travelBotplay = -1;
	var travelHealth = 100;
	afterTravel = function() {
		game.cpuControlled = false;
		var songPos = Conductor.songPosition + 150;
		for (i in 0...game.notes.length) {
			var v = game.notes.members[i];
			if (v.strumTime > songPos) break;
			v.ignoreNote = true;
		}
	}
	
	travel = function(?ms) {
		if (ms == null) ms = 0;
		var prev = Conductor.songPosition;
		
		var pos = clamp(
			prev + ms,
			1,
			FlxG.sound.music.length - 50
		);
		
		Conductor.songPosition = pos;
		ms = pos - prev;
		
		if (FlxG.sound.music._channel != null && ms > 0)
			Reflect.setProperty(FlxG.sound.music._channel, "position", pos);
		else if (ms < 0)
			FlxG.sound.music.time = pos;
		
		if (game.vocals._channel != null && ms > 0)
			Reflect.setProperty(game.vocals._channel, "position", pos);
		else if (ms < 0)
			game.vocals.time = pos;
		
		if (!game.cpuControlled) {
			travelHealth = game.health;
			travelBotplay = 8;
			game.cpuControlled = true;
		}
		
		debugPrint("Traveled from " + truncate(prev) + " to " + truncate(pos));
		return pos;
	}
	
	toggleBotplay = function(?b) {
		if (b == null) b = !game.cpuControlled;
		if (b == game.cpuControlled) return;
		
		game.cpuControlled = b;
		game.botplayTxt.visible = b;
		
		debugPrint("BotPlay " + (b ? "On" : "Off"));
	}
	
	togglePractice = function(?b) {
		if (b == null) b = !game.practiceMode;
		if (b == game.practiceMode) return;
		
		game.practiceMode = b;
		
		debugPrint("Practice " + (b ? "On" : "Off"));
	}
	
	var nya = false;
	update = function(?e) {
		if (!nya || FlxG._lostFocus) {
			nya = true;
			return;
		}
		
		travelBotplay -= 1;
		if (travelBotplay >= 0)
			game.health = travelHealth;
		
		if (travelBotplay == 0) {
			travelBotplay = -1;
			afterTravel();
		}
		
		var shift = pressed.SHIFT;
		var ctrl = pressed.CONTROL;
		
		if (justPressed.F2)
			travel(shift ? 10000 : (ctrl ? 1000 : 5000));
		else if (justPressed.F1)
			travel(-(shift ? 10000 : (ctrl ? 1000 : 5000)));
		
		if (shift) {
			if (justPressed.F3 && !game.startingSong)
				game.endSong();
			else if (justPressed.F4) {
				game.persistentUpdate = false;
				PauseSubState.restartSong(false);
			}
		}
		
		if (justPressed.F6) {
			game.cameraSpeed += .5;
			debugPrint("Speeded Up Camera " + game.cameraSpeed);
		}
		else if (justPressed.F5) {
			game.cameraSpeed -= .5;
			debugPrint("Slowed Down Camera " + game.cameraSpeed);
		}
	
		if (justPressed.F8) {
			game.songSpeed += .5;
			debugPrint("Speeded Up Scroll Speed " + game.songSpeed);
		}
		else if (justPressed.F7) {
			game.songSpeed -= .5;
			debugPrint("Slowed Down Scroll Speed " + game.songSpeed);
		}
		
		if (justPressed.F10) {
			game.defaultCamZoom += .1;
			debugPrint("Zoomed In " + game.defaultCamZoom);
		}
		else if (justPressed.F9) {
			game.defaultCamZoom -= .1;
			debugPrint("Zoomed Out " + game.defaultCamZoom);
		}
		
		if (travelBotplay <= -1 && justPressed.O)
			toggleBotplay();
		
		if (justPressed.P)
			togglePractice();
		
		]] .. ((setSoundPitch and getSoundPitch) and [[
		var c_pitchreset = justPressed.BACKSLASH;
		var c_pitchdown = justPressed.LBRACKET;
		var c_pitchup = justPressed.RBRACKET;
		
		if (c_pitchreset || c_pitchdown || c_pitchup) {
			var v = (shift ? 2 : (ctrl ? .5 : 1)) * .25;
			var prevPitch = FlxG.sound.music.pitch;
			
			if (c_pitchreset)
				v = 1;
			else if (c_pitchup)
				v = prevPitch + v;
			else if (c_pitchdown)
				v = prevPitch - v;
			
			FlxG.sound.music.pitch = v;
			if (game.vocals != null) game.vocals.pitch = v;
		}
		]] or "") .. [[
	}
	
	FlxG.stage.addEventListener("enterFrame", update);
	update();
		]])
		
		onUpdatePost = nil
	end
end

local function afterTravel()
	setProperty('cpuControlled', false)
	local songPos = getSongPosition() + 150
	for i = 0, getProperty("notes.length") - 1 do
		if (getPropertyFromGroup("notes", i, "strumTime") > songPos) then
			break
		end
		setPropertyFromGroup("notes", i, "ignoreNote", true)
	end
end

function onUpdatePost(elapsed)
	--[[if (optim) then
		return
	end]]
	
	travelBotplay = travelBotplay - 1
	if (travelBotplay >= 0) then
		setProperty("health", travelHealth)
	end
	if (travelBotplay == 0) then
		travelBotplay = -1
		afterTravel()
	end
	
	local shift = getPressedKey("SHIFT")
	local ctrl = getPressedKey("CONTROL")

	if (getJustPressedKey("F2")) then -- travel 10 seconds
		travel(shift and 10000 or ctrl and 1000 or 5000)
	elseif (getJustPressedKey("F1")) then -- go back 10 seconds
		travel(-(shift and 10000 or ctrl and 1000 or 5000))
	end
	
	if (shift) then
		if (getJustPressedKey("F3") and not getProperty('startingSong')) then -- endSong
			endSong()
		end
		
		if (getJustPressedKey("F4")) then -- restart song
			restartSong(false)
		end
	end
	
	if (getJustPressedKey("F6")) then -- Speed Up Camera Movement
		cgProperty('cameraSpeed', .5)
		debugPrint("Speeded Up Camera " .. tostring(getProperty("cameraSpeed")))
	elseif (getJustPressedKey("F5")) then --  Slow Down Movement
		cgProperty('cameraSpeed', -.5)
		debugPrint("Slowed Down Camera " .. tostring(getProperty("cameraSpeed")))
	end
	
	if (getJustPressedKey("F8")) then -- Speed Up Scroll Speed
		cgProperty('songSpeed', .5)
		debugPrint("Speeded Up Scroll Speed " .. tostring(getProperty("songSpeed")))
	elseif (getJustPressedKey("F7")) then --  Slow Scroll Speed
		cgProperty('songSpeed', -.5)
		debugPrint("Slowed Down Scroll Speed " .. tostring(getProperty("songSpeed")))
	end
	
	if (getJustPressedKey("F10")) then -- Zoom In
		cgProperty('defaultCamZoom', .1)
		debugPrint("Zoomed In " .. tostring(getProperty("defaultCamZoom")))
	elseif (getJustPressedKey("F9")) then --  Zoom Out
		cgProperty('defaultCamZoom', -.1)
		debugPrint("Zoomed Out " .. tostring(getProperty("defaultCamZoom")))
	end
	
	if (travelBotplay <= -1 and getJustPressedKey("O")) then -- toggle botplay
		toggleBotplay()
	end
	
	if (getJustPressedKey("P")) then -- toggle practice
		togglePractice()
	end
	
	local c_pitchreset = getJustPressedKey("BACKSLASH")
	local c_pitchdown = getJustPressedKey("LBRACKET")
	local c_pitchup = getJustPressedKey("RBRACKET")
	
	if (setSoundPitch and getSoundPitch and 
		(c_pitchreset or c_pitchdown or c_pitchup)
	) then
		local v = (shift and 2 or ctrl and .5 or 1) * .25--* elapsed
		local prevPitch = getSoundPitch()
		
		if (c_pitchreset) then
			v = 1
		elseif (c_pitchup) then
			v = prevPitch + v
		elseif (c_pitchdown) then
			v = prevPitch - v
		end
		
		setSoundPitch("", v)
		setProperty("vocals.pitch", v)
	end
end

function onPause()
	setPropertyFromClass("PlayState", "chartingMode", true)
	return Function_Continue
end

function switchBack()
	setPropertyFromClass("PlayState", "chartingMode", ccc)
end

onResume = switchBack
onGameOver = switchBack

function onDestroy()
	switchBack()
	
	if (optim) then
		runHaxeCode([[
			if (FlxG.stage.hasEventListener("enterFrame"))
				FlxG.stage.removeEventListener("enterFrame", update);
		]])
	end
end
