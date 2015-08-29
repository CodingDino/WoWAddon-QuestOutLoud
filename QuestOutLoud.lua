--------------------------
--   QuestOutLoud.lua   --
--------------------------

----
QuestOutLoud = LibStub("AceAddon-3.0"):NewAddon("QuestOutLoud","AceEvent-3.0")
QuestOutLoud.Version = GetAddOnMetadata("QuestOutLoud", "Version")
----

-- Tern --
---- Functional approximation of the ternary operator
function QuestOutLoud:Tern(check, ifTrue, ifFalse)
	if check then
		return ifTrue;
	else
		return ifFalse;
	end
end
----

-- GetDefaultProfile --
---- Creates a default profile object --
function GetDefaultProfile()
	return { profile = {  
			drag = true,
			bgtexture = [[Interface\Tooltips\UI-Tooltip-Background]],
			bgcolor = {0.2, 0.2, 0.2, 0.7},
			bordertexture = [[Interface\Tooltips\UI-Tooltip-Border]],
			border = true,
			position = { 0, -10 }
		} }
end
----

-- OnInitialize --
---- Called before all addons have loaded, but after saved variables have loaded. --
function QuestOutLoud:OnInitialize()	
	QuestOutLoudDB = LibStub("AceDB-3.0"):New("QuestOutLoudData", GetDefaultProfile(), true) -- Creates DB object to use with Ace
	
	
	QuestOutLoud:Print("Initialized.");
end
----

-- OnEnable --
---- Called when the addon is enabled, and on log-in and /reload, after all addons have loaded
function QuestOutLoud:OnEnable()
	QuestOutLoud:Print("Enabled.")
	
	-- Loading Frames --
	if not QuestOutLoud.FramesLoaded then --First time the addon has been enabled since UI Load
		QuestOutLoud:CreateFrames();
		QuestOutLoud.EventFrame = CreateFrame("Button", "QuestOutLoud.EventFrame", UIParent)
		QuestOutLoud.EventFrame:SetScript("OnEvent",QuestOutLoud.EventHandler)
		QuestOutLoud.FramesLoaded = true
	else -- Addon was previously disabled, so no need to create frames, just turn them back on
		-- TODO: Enable frames!
	end
	
	QuestOutLoud:SetupFrames()	-- Applies profile display settings

	-- Event Setup --
	QuestOutLoud:RegisterEvents( {
		"QUEST_LOG_UPDATE", "QUEST_DETAIL", "QUEST_GREETING", "QUEST_TURNED_IN", "QUEST_PROGRESS", "QUEST_ACCEPTED"
	})
	
	QuestOutLoud.EventFrame:SetScript("OnEvent",QuestOutLoud.EventHandler)
end	
----


-- OnDisable --
---- Called when the addon is disabled
function QuestOutLoud:OnDisable()
	QuestOutLoud.EventFrame:UnregisterAllEvents()	-- Unregisters all events
end
----


-- RegisterEvents --
---- Iterates through the supplied table of events, and registers each event to the guide frame.
function QuestOutLoud:RegisterEvents(eventtable)
	for _, event in ipairs(eventtable) do
		QuestOutLoud.EventFrame:RegisterEvent(event)
	end
end
----