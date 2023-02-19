-- not guranteed to pfc most of time
-- script by raltyro
-- uh ok bye

function onSongStart()
	addHaxeLibrary("Math")
	addHaxeLibrary("Timer", "haxe")
	addHaxeLibrary("KeyboardEvent", "openfl.events")
	local rateratewoah = type(getProperty("playbackRate")) == "number"
	runHaxeCode([[
		var strums = [];
		var sperms = [];
		var rate = 1;
		var rate2 = 1;

		function fillKeysPressed() {
			for (i in 0...game.keysArray.length-strums.length) {
				strums.push(-1);
				sperms.push(false);
			}
		}
		fillKeysPressed();

		var reqNotes = [];
		var timers = [];
		var reqNote;
		var kps = 0;

		function unpress(data) {
			fillKeysPressed();

			var ffuwu = ClientPrefs.controllerMode;
			ClientPrefs.controllerMode = true;
			game.onKeyRelease(new KeyboardEvent("keyUp", true, true, -1, game.keysArray[data][0]));
			ClientPrefs.controllerMode = ffuwu;

			strums[data] = -1;
		}
		function press(data) {
			fillKeysPressed();

			if (strums[data] >= 0) return unpress(data);
			var ffuwu = ClientPrefs.controllerMode;
			ClientPrefs.controllerMode = true;
			game.onKeyPress(new KeyboardEvent("keyDown", true, true, -1, game.keysArray[data][0]));
			ClientPrefs.controllerMode = ffuwu;

			kps++;
			strums[data] = .23 / (reqNotes.length / 14 + 1);
			strums[data] = strums[data] < .1 ? .1 : strums[data];
			sperms[data] = true;
		}

		pb_stop = function(?bool) {
			var i = timers.length;
			while (--i >= 0) timers[i].stop();
			if (!bool) for (i in 0...strums.length) strums[i] = -1;
			reqNotes.resize(0);
			timers.resize(0);
			kps = 0;
		}

		reqNote = function(note) {
			reqNotes.push(note);
			timers.push(Timer.delay(function() {
				if (strums[note.noteData] >= 0) unpress(note.noteData);
			}, ((note.strumTime - (note.strumTime - Conductor.songPosition / 2)) - Conductor.songPosition) / (rate * rate2)));
			for (vnote in reqNotes) {
				if (vnote == note) continue;
				if (Math.abs(vnote.strumTime - note.strumTime) < 4) return;
			}
			timers.push(Timer.delay(function() {
				if ((note.strumTime - Conductor.songPosition) / (rate * rate2) > 66) {
					reqNotes.remove(note);
					if (note.wasGoodHit) return;
					return reqNote(note);
				}

				var i = reqNotes.length;
				while (--i >= 0) {
					var rnote = reqNotes[i];
					if (rnote.wasGoodHit) {
						reqNotes.remove(rnote);
						continue;
					}
					if (rnote == note || Math.abs(rnote.strumTime - note.strumTime) < 4) {
						reqNotes.remove(rnote);
						if (strums[rnote.noteData] > 0) unpress(rnote.noteData);
						press(rnote.noteData);
					}
				}
			}, ((note.strumTime - Conductor.songPosition) / (rate * rate2)) - (FlxG.elapsed * 200 / rate2)));
		}

		var closestDis = 0;
		var closestNotes = [];
		function searchNotes(daNote) {
			if (daNote.isSustainNote) {
				if (game.generatedMusic && !game.inCutscene && game.strumsBlocked[daNote.noteData] != true && daNote.isSustainNote
				&& daNote.canBeHit && daNote.prevNote.wasGoodHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.blockHit) {
					game.goodNoteHit(daNote);
					kps += .1;
					strums[daNote.noteData] = .29 / (reqNotes.length / 14 + 1);
					strums[daNote.noteData] = strums[daNote.noteData] < .1 ? .1 : strums[daNote.noteData];
					sperms[daNote.noteData] = true;
				}

				return;
			}
			if (daNote.blockHit || !daNote.mustPress || daNote.wasGoodHit || daNote.ignoreNote) return;
			var v = daNote.strumTime - Conductor.songPosition;
			var v2 = 300 - (strums[daNote.noteData] * 5331);
			if (v < (v2 < 66 ? 66 : v2) && (closestNotes.length <= 0 || v < closestDis)) {
				closestNotes.push(daNote);
				closestDis = v < 0 ? 0 : v;
			}
		}

		pb_run = function() {
			var prev = Conductor.songPosition;
			var prevRate = rate;
			var prevRate2 = rate2;
			]] .. (rateratewoah and "rate = game.playbackRate;") .. [[
			rate2 = FlxG.timeScale;
			if (prevRate != rate || prevRate2 != rate2) pb_stop(true);
			if (FlxG.sound.music != null && FlxG.sound.music.playing && !game.startingSong) Conductor.songPosition = FlxG.sound.music._channel.position;
			else if (game.startedCountdown) Conductor.songPosition += FlxG.elapsed * 1000 * rate;
			closestNotes.resize(0);

			if (kps > 0) kps -= (FlxG.elapsed * rate) * (kps + 1) * 3.6;
			if (kps < 0) kps = 0;
			for (i in 0...strums.length) {
				if (strums[i] < 0) {
					if (!sperms[i]) continue;
					var spr = game.playerStrums.members[i];
					if (spr != null && spr.animation.curAnim.name != 'static') {
						spr.playAnim('static');
						spr.resetAnim = 0;
						sperms[i] = false;
					}
					continue;
				}

				strums[i] -= (FlxG.elapsed * rate) * (kps / 6 + 1);
				if (strums[i] < 0) unpress(i);
			}

			game.notes.forEachAlive(searchNotes);
			for (note in closestNotes) {
				if (!reqNotes.contains(note)) reqNote(note);
			}
			Conductor.songPosition = prev;
		}
		return;
	]])

	-- i purposely put these here ok
	function onDestroy()
		runHaxeCode("pb_stop();available = false;stop = true;")
	end

	function onPause()
		runHaxeCode("pb_stop();")
	end

	function onUpdate()
		if inGameOver then return end
		runHaxeCode("pb_run();")
		setProperty("cpuControlled", false)
	end

	function onGameOverStart()
		runHaxeCode("pb_stop();")
		onUpdate = nil
	end
end
