--------------------------------
--   QuestOutLoud_Quest.lua   --
--------------------------------


----
QuestOutLoud_Quest = QuestOutLoud:NewModule("QuestOutLoud_Quest", "AceEvent-3.0")
QuestOutLoud_Quest.parent = QuestOutLoud
----


----
QuestOutLoud_Quest.defaults = {
    profile =  {
		playOnQuestOpen = false,
		playOnQuestAccept = true,
		pauseForTalkingHeads = true,
		playOnQuestProgressOpen = true,
		playOnQuestCompleteOpen = false,
		playOnQuestCompleted = true,
		showQuestLogButton = true,
    },
}
----


----
local options = {
    name = "Quest Out Loud - Quests",
    handler = QuestOutLoud,
    type = "group",
    args = {
        autoplay = {
            type = "group",
            name = "Automatic Play Settings",
            inline = true,
    		args = {
    			playOnQuestOpen = {
		            type = "toggle",
		            name = "Play on Accept Open",
		            desc = "Automatically plays the quest accept text on when opening the quest before accepting it",
		            get = function(info) return QuestOutLoudDB_Quest.profile.playOnQuestOpen end,
		            set = function(info,val) QuestOutLoudDB_Quest.profile.playOnQuestOpen = val end
		        },
		        playOnQuestAccept = {
		            type = "toggle",
		            name = "Play on Accept Clicked",
		            desc = "Automatically plays the quest accept text on accepting a quest",
		            get = function(info) return QuestOutLoudDB_Quest.profile.playOnQuestAccept end,
		            set = function(info,val) QuestOutLoudDB_Quest.profile.playOnQuestAccept = val end
		        },
		        pauseForTalkingHeads = {
		            type = "toggle",
		            name = "Talking Head Pause",
		            desc = "Pause playback while the built in voice-overs from the \"Talking Heads\" frame are active",
		            get = function(info) return QuestOutLoudDB_Quest.profile.pauseForTalkingHeads end,
		            set = function(info,val) QuestOutLoudDB_Quest.profile.pauseForTalkingHeads = val end
		        },
		        playOnQuestProgressOpen = {
		            type = "toggle",
		            name = "Play on Progress Open",
		            desc = "Automatically plays the quest progress text on when opening the quest before completing it",
		            get = function(info) return QuestOutLoudDB_Quest.profile.playOnQuestProgressOpen end,
		            set = function(info,val) QuestOutLoudDB_Quest.profile.playOnQuestProgressOpen = val end
		        },
		        playOnQuestCompleteOpen = {
		            type = "toggle",
		            name = "Play on Completion Open",
		            desc = "Automatically plays the quest completion text on when opening the quest before completing it",
		            get = function(info) return QuestOutLoudDB_Quest.profile.playOnQuestCompleteOpen end,
		            set = function(info,val) QuestOutLoudDB_Quest.profile.playOnQuestCompleteOpen = val end
		        },
		        playOnQuestCompleted = {
		            type = "toggle",
		            name = "Play on Complete Clicked",
		            desc = "Automatically plays the quest complete text on completing a quest",
		            get = function(info) return QuestOutLoudDB_Quest.profile.playOnQuestCompleted end,
		            set = function(info,val) QuestOutLoudDB_Quest.profile.playOnQuestCompleted = val end
		        },
    		}
        },
        display = {
            type = "group",
            name = "Display Settings",
            inline = true,
    		args = {
		        showQuestLogButton = {
		            type = "toggle",
		            name = "Show Button In Log",
		            desc = "Whether or not we should show the play button in the quest log.",
		            get = function(info) return QuestOutLoudDB_Quest.profile.showQuestLogButton end,
		            set = function(info,val) 
		            	QuestOutLoudDB_Quest.profile.showQuestLogButton = val
		            	if QuestOutLoudDB_Quest.profile.showQuestLogButton == true then
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
        
    },
}
----


-- OnInitialize --
---- Called before all addons have loaded, but after saved variables have loaded. --
function QuestOutLoud_Quest:OnInitialize()	
	self.parent:Debug("Quest Module Enabled.")

	-- Load settings --
	QuestOutLoudDB_Quest = LibStub("AceDB-3.0"):New("QuestOutLoudData_Quest", QuestOutLoud_Quest.defaults, true) -- Creates DB object to use with Ace
	
	-- Options Setup ---
	LibStub("AceConfig-3.0"):RegisterOptionsTable("QuestOutLoud_Quest", options, {"questoutloud_quest", "qol_q"})
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("QuestOutLoud_Quest", "Quest Out Loud - Quests", "QuestOutLoud")

	-- Event Setup --
	self:RegisterEvents( {
		"QUEST_DETAIL", "QUEST_GREETING", "QUEST_TURNED_IN", "QUEST_PROGRESS", "QUEST_ACCEPTED", "QUEST_COMPLETE", "TALKINGHEAD_CLOSE", "TALKINGHEAD_REQUESTED"
		--, "QUEST_LOG_UPDATE"
	})

	-- Quest log buttons --
	QuestOutLoud_Quest.QuestFrameButton = self:CreateQuestLogButton(QuestFrame, "QuestFrameButton", -10, -30)
	QuestOutLoud_Quest.QuestMapFrameButton = self:CreateQuestLogButton(QuestMapFrame.DetailsFrame, "QuestMapFrameButton", 10, 30)
end
----


-- OnEnable --
---- Called when the addon is enabled, and on log-in and /reload, after all addons have loaded
function QuestOutLoud_Quest:OnEnable()
	if QuestOutLoudDB_Quest.profile.showQuestLogButton == true then
		QuestOutLoud_Quest.QuestFrameButton:Show()
		QuestOutLoud_Quest.QuestMapFrameButton:Show()
	else
		QuestOutLoud_Quest.QuestFrameButton:Hide()
		QuestOutLoud_Quest.QuestMapFrameButton:Hide()
	end
end	
----


-- OnDisable --
---- Called when the addon is disabled
function QuestOutLoud:OnDisable()
	self:Debug("Disabled.")
	QuestOutLoud_Quest.QuestFrameButton:Hide()
	QuestOutLoud_Quest.QuestMapFrameButton:Hide()
end
----


-- RegisterEvents --
---- Iterates through the supplied table of events, and registers each event to the guide frame.
function QuestOutLoud_Quest:RegisterEvents(eventtable)
	for _, event in ipairs(eventtable) do
		self:RegisterEvent(event)
	end
end
----


-- CreateQuestLogButton
---- Creates the button on the quest log entry
---- Will be attached to QuestLogPopupDetailFrame, QuestFrame
function QuestOutLoud_Quest:CreateQuestLogButton(parent, name, posX, posY)
	self.parent:Debug("CreateQuestLogButton()")
	--
	local button = CreateFrame("Button", "QuestOutLoud."..name, parent)
	button:SetPoint("TOPRIGHT", parent, "TOPRIGHT", posX, posY)
	button:SetWidth(24)
	button:SetHeight(24)
	local iconTex = button:CreateTexture()
	iconTex:SetTexture("Interface\\Addons\\QuestOutLoud\\QOLButton")
	iconTex:SetAllPoints(button)
	button.texture = iconTex
	--
	button:SetScript("OnClick", function(self, button)
		local index = GetQuestLogSelection()
		local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory, isHidden = GetQuestLogTitle(index)
		if questID == 0 then questID = GetQuestID() end
		QuestOutLoud:Debug("Quest log button: QID = "..questID)
		local triggerType = "questAccept"
		if QuestFrameProgressPanel:IsVisible() then
			triggerType = "questProgress"
		elseif QuestFrameRewardPanel:IsVisible() then
			triggerType = "questCompletion"
		end
		QuestOutLoud:RequestSound(triggerType,questID, true)
	end)
	---
	return button
end
----


-- QUEST_GREETING
---- EVENT - Called when the quest greeting is shown
function QuestOutLoud_Quest:QUEST_GREETING()
	self.parent:Debug("QUEST_GREETING()")
end
----


-- QUEST_DETAIL
---- EVENT - Called the quest detail page is shown (to accept a quest)
function QuestOutLoud_Quest:QUEST_DETAIL()
	self.parent:Debug("QUEST_DETAIL()")
	if (QuestOutLoudDB_Quest.profile.playOnQuestOpen) then
		QuestOutLoud:RequestSound("questAccept",GetQuestID(), true)
	end
end
----


-- QUEST_ACCEPTED
---- EVENT - Called when a quest is accepted
function QuestOutLoud_Quest:QUEST_ACCEPTED()
	self.parent:Debug("QUEST_ACCEPTED()")
	if (QuestOutLoudDB_Quest.profile.playOnQuestAccept) then
		QuestOutLoud:RequestSound("questAccept",GetQuestID(), true)
	end
end
----


-- QUEST_PROGRESS
---- EVENT - Called when the quest progress page is shown (when speaking to an NPC whose quest you are working on but have NOT completed)
function QuestOutLoud_Quest:QUEST_PROGRESS()
	self.parent:Debug("QUEST_PROGRESS()")
	if (QuestOutLoudDB_Quest.profile.playOnQuestProgressOpen) then
		QuestOutLoud:RequestSound("questProgress",GetQuestID(), true)
	end
end
----


-- QUEST_COMPLETE
---- EVENT - Called when a quest complete page is shown (about to turn in)
function QuestOutLoud_Quest:QUEST_COMPLETE()
	self.parent:Debug("QUEST_COMPLETE()")
	if (QuestOutLoudDB_Quest.profile.playOnQuestCompleteOpen) then
		QuestOutLoud:RequestSound("questCompletion",GetQuestID(), true)
	end
end
----


-- QUEST_TURNED_IN
---- EVENT - Called when a quest is turned in
function QuestOutLoud_Quest:QUEST_TURNED_IN()
	self.parent:Debug("QUEST_TURNED_IN()")
	if (QuestOutLoudDB_Quest.profile.playOnQuestCompleted) then
		QuestOutLoud:RequestSound("questCompletion",GetQuestID(), true)
	end
end
----


-- QUEST_LOG_UPDATE
---- EVENT - Called when a quest is updated
function QuestOutLoud_Quest:QUEST_LOG_UPDATE()
	self.parent:Debug("QUEST_LOG_UPDATE()")
end
----


-- TALKINGHEAD_CLOSE
---- EVENT - Called when the talking heads frame closes
function QuestOutLoud_Quest:TALKINGHEAD_REQUESTED()
	self.parent:Debug("TALKINGHEAD_REQUESTED()")
	if (QuestOutLoudDB_Quest.profile.pauseForTalkingHeads) then
		QuestOutLoud:StopSound()
	end
end
----


-- TALKINGHEAD_CLOSE
---- EVENT - Called when the talking heads frame closes
function QuestOutLoud_Quest:TALKINGHEAD_CLOSE()
	self.parent:Debug("TALKINGHEAD_CLOSE()")
	if (QuestOutLoudDB_Quest.profile.pauseForTalkingHeads) then
		QuestOutLoud:ResumeSound()
	end
end
----