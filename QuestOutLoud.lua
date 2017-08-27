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
QuestOutLoud.defaults = {
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
		showButton = true,
    },
}
----


----
local options = {
    name = "Quest Out Loud",
    handler = QuestOutLoud,
    type = "group",
    args = {
        buttons = {
            type = "group",
            name = "Button Settings",
            inline = true,
    		args = {
		        showButton = {
		            type = "toggle",
		            name = "Show Button In Log",
		            desc = "Whether or not we should show the play button in the quest log.",
		            get = function(info) return QuestOutLoudDB.profile.showButton end,
		            set = function(info,val) 
		            	QuestOutLoudDB.profile.showButton = val
		            	if QuestOutLoudDB.profile.showButton == true then
		            		QuestOutLoud_Quest.QuestFrameButton:Show()
		            		QuestOutLoud_Quest.QuestMapFrameButton:Show()
		            	else
		            		QuestOutLoud_Quest.QuestFrameButton:Hide()
		            		QuestOutLoud_Quest.QuestMapFrameButton:Hide()
		            	end
		        	end
		        }
    		}
        },
        autoplay = {
            type = "group",
            name = "Automatic Play Settings",
            inline = true,
    		args = {
    			playOnQuestOpen = {
		            type = "toggle",
		            name = "Play on Open",
		            desc = "Automatically plays the quest accept text on when opening the quest before accepting it",
		            get = function(info) return QuestOutLoudDB.profile.playOnQuestOpen end,
		            set = function(info,val) QuestOutLoudDB.profile.playOnQuestOpen = val end
		        },
		        playOnQuestAccept = {
		            type = "toggle",
		            name = "Play on Accept",
		            desc = "Automatically plays the quest accept text on accepting a quest",
		            get = function(info) return QuestOutLoudDB.profile.playOnQuestAccept end,
		            set = function(info,val) QuestOutLoudDB.profile.playOnQuestAccept = val end
		        },
		        playOnQuestProgressOpen = {
		            type = "toggle",
		            name = "Play on Progress Open",
		            desc = "Automatically plays the quest progress text on when opening the quest before completing it",
		            get = function(info) return QuestOutLoudDB.profile.playOnQuestProgressOpen end,
		            set = function(info,val) QuestOutLoudDB.profile.playOnQuestProgressOpen = val end
		        },
		        playOnQuestCompleteOpen = {
		            type = "toggle",
		            name = "Play on Completion Open",
		            desc = "Automatically plays the quest completion text on when opening the quest before completing it",
		            get = function(info) return QuestOutLoudDB.profile.playOnQuestCompleteOpen end,
		            set = function(info,val) QuestOutLoudDB.profile.playOnQuestCompleteOpen = val end
		        },
		        playOnQuestCompleted = {
		            type = "toggle",
		            name = "Play on Complete",
		            desc = "Automatically plays the quest complete text on completing a quest",
		            get = function(info) return QuestOutLoudDB.profile.playOnQuestCompleted end,
		            set = function(info,val) QuestOutLoudDB.profile.playOnQuestCompleted = val end
		        },
    		}
        },
        
    },
}
----


-- OnInitialize --
---- Called before all addons have loaded, but after saved variables have loaded. --
function QuestOutLoud:OnInitialize()	
	QuestOutLoudDB = LibStub("AceDB-3.0"):New("QuestOutLoudData", QuestOutLoud.defaults, true) -- Creates DB object to use with Ace
	LibStub("AceConfig-3.0"):RegisterOptionsTable("QuestOutLoud", options, {"questoutloud", "qol"})
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("QuestOutLoud", "Quest Out Loud")
	self.soundQueue = QuestOutLoud.Queue:new()
	
	self:Debug("OnInitialize()");
	self:RegisterChatCommands();
	self:CreateFrames()
end
----


-- OnEnable --
---- Called when the addon is enabled, and on log-in and /reload, after all addons have loaded
function QuestOutLoud:OnEnable()
	self:QOLPrint("Enabled.")
	
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
		for k2,triggerID in pairs(sound.triggerIDs) do
			QOL_sounds[sound.triggerType][triggerID] = sound
			--self:Debug("Registered sound for "..sound.triggerType.." - "..triggerID.." - "..sound.soundFiles[1])
		end
		--self:Debug("Registered sound for "..sound.triggerType.." - "..sound.displayTitle)
	end
end
----


-- RequestSound --
---- Requests the specified sound
function QuestOutLoud:RequestSound(triggerType, triggerID)
	self:Debug("RequestSound("..triggerType..", "..triggerID..")")
	local soundInfo = self.sounds[triggerType][triggerID]
	if soundInfo == nil then
		self:Debug("No sound registered.")
		return
	end
	for k1,soundFile in pairs(soundInfo.soundFiles) do
		local filePath = "interface\\addons\\"..soundFile
		self:QueueSound(filePath, soundInfo)
	end
end
----


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
----


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
----


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
		self:SetSpeakerName(self.SpeakerName, soundInfo.NPCName)
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
	end
end
