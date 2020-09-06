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
QuestOutLoud.modules = {}
----


----
QuestOutLoud.PAUSE_DURATION = 2
----


----
QuestOutLoud.defaults = {
    profile =  {
		enabled = true,
		bgtexture = [[Interface\Tooltips\UI-Tooltip-Background]],
		bgcolor = {0.2, 0.2, 0.2, 0.7},
		bordertexture = [[Interface\Tooltips\UI-Tooltip-Border]],
		border = true,
		posX = 0,  		-- relative to center of screen
		posY = -10, 	-- relative to top of screen=
		showMainFrame = true,
    },
}
----

----
local options = {
    name = "Quest Out Loud",
    handler = QuestOutLoud,
    type = "group",
    args = {
        enableButton = {
            type = "toggle",
            name = "Enable Addon",
            desc = "Turn the addon on or off.",
            get = function(info) return QuestOutLoudDB.profile.enabled end,
            set = function(info,val) 
            	QuestOutLoudDB.profile.enabled = val
            	if QuestOutLoudDB.profile.enabled == true then
            		QuestOutLoud:Enable()
            	else
            		QuestOutLoud:Disable()
            	end
        	end
        },
        showMainFrame = {
            type = "toggle",
            name = "Show Control Frame",
            desc = "Whether or not we should show a frame with controls and info while a quest is playing.",
            get = function(info) return QuestOutLoudDB.profile.showMainFrame end,
            set = function(info,val) 
            	QuestOutLoudDB.profile.showMainFrame = val
            	if QuestOutLoudDB.profile.showButton == false then
            		QuestOutLoud_Quest.MainFrame:Hide()
            	end
        	end
        }
    },
}
----


-- OnInitialize --
---- Called before all addons have loaded, but after saved variables have loaded. --
function QuestOutLoud:OnInitialize()	
	self:Debug("OnInitialize()");

	-- Load settings --
	QuestOutLoudDB = LibStub("AceDB-3.0"):New("QuestOutLoudData", QuestOutLoud.defaults, true) -- Creates DB object to use with Ace
	
	-- Options Setup --
	LibStub("AceConfig-3.0"):RegisterOptionsTable("QuestOutLoud", options, {"questoutloud", "qol"})
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("QuestOutLoud", "Quest Out Loud")

	---
	self.soundQueue = QuestOutLoud.Queue:new()
	self:RegisterChatCommands();
	self:CreateFrames()
end
----


-- OnEnable --
---- Called when the addon is enabled, and on log-in and /reload, after all addons have loaded
function QuestOutLoud:OnEnable()
	self:Debug("Enabled.")
	
	self:SetupFrames()	-- Applies profile display settings

	-- Enable all modules
	for name, module in self:IterateModules() do
  		module:Enable()
	end
end	
----


-- OnDisable --
---- Called when the addon is disabled
function QuestOutLoud:OnDisable()
	self:Debug("Disabled.")
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
function QuestOutLoud:RegisterChatCommands()
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
		if sound.triggerID ~= nil then
			sound.triggerIDs = { sound.triggerID }
		end
		if sound.soundFile ~= nil then
			sound.soundFiles = {sound.soundFile }
		end
		for k2,triggerID in pairs(sound.triggerIDs) do
			--self:Debug("sound = "..QuestOutLoud.Dump(sound))
			--self:Debug("sound.triggerType = "..sound.triggerType)
			--self:Debug("triggerID = "..triggerID)
			--self:Debug("QOL_sounds = "..QuestOutLoud.Dump(QOL_sounds))

			QOL_sounds[sound.triggerType][triggerID] = sound
			self:Debug("Registered sound for "..sound.triggerType.." - "..triggerID.." - "..sound.soundFiles[1])
		end

		self:Debug("Registered sound for "..sound.triggerType.." - "..sound.displayTitle)
	end
end
----


-- RequestSound --
---- Requests the specified sound
function QuestOutLoud:RequestSound(triggerType, triggerID, play)
	self:Debug("RequestSound("..triggerType..", "..triggerID..")")
	local soundInfo = self.sounds[triggerType][triggerID]
	if soundInfo == nil then
		self:Debug("No sound registered.")
		return
	end
	for k1,soundFile in pairs(soundInfo.soundFiles) do
		local filePath = "interface\\addons\\"..soundFile
		if play == true then
			QuestOutLoud:QueueSound(filePath, soundInfo)
		end
		return filePath, soundInfo
	end

end
----


-- QueueSound --
---- Queues the specified sound
function QuestOutLoud:QueueSound(filePath, soundInfo)
	self:Debug("QueueSound("..filePath..")")
	--
	if self.soundQueue:empty() == true and self.playing ~= true then
		self:PlaySound(filePath, soundInfo)
	else 
		local alreadyQueued = false
		if self.currentSoundPath == filePath then alreadyQueued = true end
		local pointer = self.soundQueue.first
		while pointer <= self.soundQueue.last and alreadyQueued == false do 
			if self.soundQueue[pointer].file == filePath then alreadyQueued = true end
			pointer = pointer + 1
		end
		if alreadyQueued == false then
			local queuedSound = {
				file = filePath,
				info = soundInfo
			}
			self:Debug("Sound queued.")
			self.soundQueue:push(queuedSound)
			QuestOutLoud.QueueCounter:Show();
			QuestOutLoud.QueueCounter:SetText(self.soundQueue:size());
		else
			self:Debug("Sound not alrady playing or in queue.")
		end
	end
end
----


-- SoundPlaybackFinished --
---- Called when the timer for the current sound playback is done
function QuestOutLoud:SoundPlaybackFinished()
	self:Debug("SoundPlaybackFinished")
	self.currentSoundHandle = nil
	self.currentSoundInfo = nil
	self.currentSoundPath = nil
	self.playing = false
	self.soundTimer = nil
	-- Play new sound from queue
	if self.soundQueue:empty() ~= true then
		local toPlay = self.soundQueue:pop()
		self:Debug("Playing next sound in queue "..toPlay.file )
		self:PlaySound(toPlay.file, toPlay.info)
		if (self.soundQueue:empty()) then
			QuestOutLoud.QueueCounter:Hide()
		else
			QuestOutLoud.QueueCounter:SetText(self.soundQueue:size());
		end
	else
		self:Debug("Queue empty, hiding main frame." )
		self.MainFrame:Hide() -- Hide frame if we're done playing
	end
end
----


-- PlaySound --
---- Plays the specified sound
function QuestOutLoud:PlaySound(filePath, soundInfo)
	self:Debug("PlaySound("..filePath..")")
	--
	if self.playing == true then
		self:Debug("PlaySound() called while already playing, probably an error.",QuestOutLoud.LOGLEVEL.WARNING)
		return -- exit early
	end
	--
	local success, soundHandle = PlaySoundFile(filePath, "Dialog")
	if success ~= nil then
		self:Debug("Playing sound "..filePath)
		self:Debug("Sound info "..QuestOutLoud.Dump(soundHandle))
		self.currentSoundPath = filePath
		self.currentSoundInfo = soundInfo
		self.currentSoundHandle = soundHandle
		self.playing = true
		self.soundTimer = self:ScheduleTimer("SoundPlaybackFinished", soundInfo.duration + QuestOutLoud.PAUSE_DURATION)
		--
		if QuestOutLoudDB.profile.showMainFrame == true then
			self.MainFrame:Show()
			self:SetTitle(self.Title, soundInfo.displayTitle)
			self.PauseIcon:SetTexture("Interface\\Addons\\QuestOutLoud\\PauseButton")
			--self:SetModelID(self.Model, soundInfo.modelID)
			--self:SetSpeakerName(self.SpeakerName, soundInfo.NPCName)

			if soundInfo.triggerType == "questAccept" then
				QuestOutLoud.ContentTypeIcon:SetTexture("Interface\\Addons\\QuestOutLoud\\AcceptIcon")
			elseif soundInfo.triggerType == "questProgress" then
				QuestOutLoud.ContentTypeIcon:SetTexture("Interface\\Addons\\QuestOutLoud\\ProgressIcon")
			elseif soundInfo.triggerType == "questCompletion" then
				QuestOutLoud.ContentTypeIcon:SetTexture("Interface\\Addons\\QuestOutLoud\\CompletionIcon")
			end
		end
	else  
		self:Error("Failed to play sound "..filePath)
	end
	--
end
----


-- StopSound --
---- Stops the current sound from playing
function QuestOutLoud:StopSound()
	if QuestOutLoud.currentSoundHandle ~= nil then
		StopSound(QuestOutLoud.currentSoundHandle)
		self.playing = false
		self:CancelTimer(self.soundTimer)
		self.soundTimer = nil
		self.currentSoundHandle = nil
	end
end
----


-- ResumeSound --
---- Resumes (starts over) the last sound played
function QuestOutLoud:ResumeSound()
	self:Debug("ResumeSound()")
	--
	self:PlaySound(self.currentSoundPath, self.currentSoundInfo)
	--
end
----


-- ClearQueue --
---- Clears the sound queue
function QuestOutLoud:ClearSoundQueue()
	self.soundQueue:clear();
end
