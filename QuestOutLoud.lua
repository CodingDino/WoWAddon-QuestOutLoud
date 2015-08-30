--------------------------
--   QuestOutLoud.lua   --
--------------------------

----
QuestOutLoud = LibStub("AceAddon-3.0"):NewAddon("QuestOutLoud", "AceConsole-3.0", "AceEvent-3.0")
QuestOutLoud.Version = GetAddOnMetadata("QuestOutLoud", "Version")
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