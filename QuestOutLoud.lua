--------------------------
--   QuestOutLoud.lua   --
--------------------------

----
QuestOutLoud = LibStub("AceAddon-3.0"):NewAddon("QuestOutLoud", "AceConsole-3.0", "AceEvent-3.0",  "AceTimer-3.0")
QuestOutLoud.Version = GetAddOnMetadata("QuestOutLoud", "Version")
----


----
QuestOutLoud.sounds = {}
QuestOutLoud.sounds.questAccept = {}
QuestOutLoud.sounds.questProgress = {}
QuestOutLoud.sounds.questCompletion = {}
----


----
local defaults = {
    profile =  {
		bgtexture = [[Interface\Tooltips\UI-Tooltip-Background]],
		bgcolor = {0.2, 0.2, 0.2, 0.7},
		bordertexture = [[Interface\Tooltips\UI-Tooltip-Border]],
		border = true,
		posX = 0,  		-- relative to center of screen
		posY = -10, 	-- relative to top of screen
		width = 200,
		height = 100,
		playOnQuestOpen = true,
		playOnQuestAccept = false,
		playOnQuestProgressOpen = true,
		playOnQuestCompleteOpen = true,
		playOnQuestCompleted = false,
    },
}
----

----
local options = {
    name = "Quest Out Loud",
    handler = QuestOutLoud,
    type = "group",
    args = {
        msg = {
            type = "execute",
            name = "Reset Position",
            desc = "Returns the Quest Out Loud play window to it's default position",
            func = function()
				QuestOutLoudDB.profile.posX = defaults.profile.posX
				QuestOutLoudDB.profile.posY = defaults.profile.posY
				QuestOutLoud:SetFramePoints()
			end
        },
    },
}
----

-- OnInitialize --
---- Called before all addons have loaded, but after saved variables have loaded. --
function QuestOutLoud:OnInitialize()	
	QuestOutLoudDB = LibStub("AceDB-3.0"):New("QuestOutLoudData", defaults, true) -- Creates DB object to use with Ace
	LibStub("AceConfig-3.0"):RegisterOptionsTable("QuestOutLoud", options, {"questoutloud", "qol"})
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("QuestOutLoud", "Quest Out Loud")
	self.soundQueue = Queue:new()
	
	self:Debug("OnInitialize()");
	self:RegistChatCommands();
	self:CreateFrames()
end
----

-- OnEnable --
---- Called when the addon is enabled, and on log-in and /reload, after all addons have loaded
function QuestOutLoud:OnEnable()
	self:QOLPrint("Enabled.")
	
	self:SetupFrames()	-- Applies profile display settings

	-- Event Setup --
	self:RegisterEvents( {
		--"QUEST_LOG_UPDATE", "QUEST_DETAIL", "QUEST_GREETING", "QUEST_TURNED_IN", "QUEST_PROGRESS", "QUEST_ACCEPTED"
	})
end	
----


-- OnDisable --
---- Called when the addon is disabled
function QuestOutLoud:OnDisable()
	self:QOLPrint("Disabled.")
end
----


-- RegisterEvents --
---- Iterates through the supplied table of events, and registers each event to the guide frame.
function QuestOutLoud:RegisterEvents(eventtable)
	for _, event in ipairs(eventtable) do
		self:RegisterEvent(event)
	end
end
----


-- RegistChatCommands --
---- Registers chat commands using AceConsole
function QuestOutLoud:RegistChatCommands()
	self:RegisterChatCommand("qol", "ChatCommand")
	self:RegisterChatCommand("questoutloud", "ChatCommand")
	self:RegisterChatCommand("QuestOutLoud", "ChatCommand")
end
----


-- ChatCommand --
---- Handles chat commands
function QuestOutLoud:ChatCommand(input)
    if not input or input:trim() == "" then
		LibStub("AceConfigDialog-3.0"):Open("QuestOutLoud")
    else
        LibStub("AceConfigCmd-3.0"):HandleCommand("qol", "QuestOutLoud", input)
    end
end
----


-- RegisterSounds --
---- Registers sounds to be used by the addon
function QuestOutLoud:RegisterSounds(sounds)
	local QOL_sounds = QuestOutLoud.sounds
	for k1,sound in pairs(sounds) do
		for k2,triggerID in pairs(sound.triggerIDs) do
			QOL_sounds[sound.soundTrigger][triggerID] = sound
			self:Debug("Registered sound for "..sound.soundTrigger.." - "..triggerID.." - "..sound.soundFiles[1])
		end
		self:Debug("Registered sound for "..sound.soundTrigger.." - "..sound.displayTitle)
	end
end


-- RequestSound --
---- Requests the specified sound
function QuestOutLoud:RequestSound(soundTrigger, triggerID)
	self:Debug("RequestSound("..soundTrigger..", "..triggerID..")")
	local soundInfo = self.sounds[soundTrigger][triggerID]
	if soundInfo == nil then
		self:Debug("No sound registered.")
		return
	end
	for k1,soundFile in pairs(soundInfo.soundFiles) do
		local filePath = "interface\\addons\\"..soundFile
		self:QueueSound(filePath, soundInfo)
	end
end


-- QueueSound --
---- Queues the specified sound
function QuestOutLoud:QueueSound(filePath, soundInfo)
	self:Debug("QueueSound("..filePath..")")
	--
	if self.currentSoundHandle == nil then
		self:PlaySound(filePath, soundInfo)
	else
		self:Debug("Sound queued.")
		local queuedSound = {
			file = filePath,
			info = soundInfo
		}
		self.soundQueue:push(queuedSound)
	end
end


-- SoundPlaybackFinished --
---- Called when the timer for the current sound playback is done
function QuestOutLoud:SoundPlaybackFinished()
	self:Debug("SoundPlaybackFinished")
	self.currentSoundHandle = nil
	self.currentSoundInfo = nil
	self.playing = false
	self.soundTimer = nil
	-- Play new sound from queue
	if self.soundQueue:empty() == false then
		local toPlay = self.soundQueue:pop()
		self:Debug("Queuing up new sound "..toPlay.file )
		self:PlaySound(toPlay.file, toPlay.info)
	else
		self:Debug("Queue empty, hiding main frame." )
		self.MainFrame:Hide() -- Hide frame if we're done playing
	end
end


-- PlaySound --
---- Plays the specified sound
function QuestOutLoud:PlaySound(filePath, soundInfo)
	self:Debug("PlaySound("..filePath..")")
	--
	if self.currentSoundHandle ~= nil then
		self:Debug("PlaySound() called when currentSoundHandle not nil, probably an error.")
		self:StopSound()
	end
	--
	local success, soundHandle = PlaySoundFile(filePath, "Dialog")
	if success ~= nil then
		self:Debug("Playing sound "..filePath)
		self.currentSoundHandle = soundHandle
		self.currentSoundInfo = soundInfo
		self.playing = true
		self.soundTimer = self:ScheduleTimer("SoundPlaybackFinished", soundInfo.duration)
		--
		self.MainFrame:Show()
		self:SetModelID(self.Model, soundInfo.modelID)
	else
		self:Error("Failed to play sound "..filePath)
	end
	--
end


-- StopSound --
---- Stops the current sound from playing
function QuestOutLoud:StopSound()
	if QuestOutLoud.currentSoundHandle ~= nil then
		StopSound(QuestOutLoud.currentSoundHandle)
		self.playing = false
		self:CancelTimer(self.soundTimer)
		self.soundTimer = nil
	end
end
