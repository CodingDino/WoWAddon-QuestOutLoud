---------------------------------
--   QuestOutLoud_Frames.lua   --
---------------------------------


-- CreateFrames
---- Creates the UI
function QuestOutLoud:CreateFrames()
	self:Debug("CreateFrames()")
	self:CreateMainFrame();
	self:CreateMiniMapButton();
end
----


-- CreateMainFrame
---- Creates the parent frame for the QuestOutLoud UI
function QuestOutLoud:CreateMainFrame()
	self:Debug("CreateMainFrame()")
	--
	local frame = CreateFrame("Button", "QuestOutLoud.MainFrame", UIParent,  BackdropTemplateMixin and "BackdropTemplate")
	--
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	--
	frame:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			frame:StartMoving()
		--elseif button == "RightButton" then
			-- TODO: EasyMenu(WoWPro.DropdownMenu, menuFrame, "cursor", 0 , 0, "MENU");
		end
	end)
	frame:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			frame:StopMovingOrSizing()
			QuestOutLoudDB.profile.posX = frame:GetLeft() - UIParent:GetWidth()*0.5 + frame:GetWidth()*0.5
			QuestOutLoudDB.profile.posY = frame:GetTop() - UIParent:GetHeight()
		end
	end)
	--
	self:CreateClearButton(frame)
	self:CreateSkipButton(frame)
	self:CreateStopButton(frame)
	self:CreateQueueCounter(frame)
	--
	self.MainFrame = frame
	frame:Hide()
	--
	self:CreateTitle(frame);
	--
	--self:CreateModel()
	--self:CreateSpeakerName(frame)
end
----


-- CreateModel
---- Creates the model to be used in the main frame
function QuestOutLoud:CreateModel()
	local model = CreateFrame("PlayerModel", "QuestOutLoud.Model", self.MainFrame,  BackdropTemplateMixin and "BackdropTemplate")
	model:SetPoint("TOPLEFT", self.MainFrame ,"TOPLEFT", 5, -5)
	model:SetPoint("BOTTOMRIGHT", self.MainFrame ,"BOTTOMLEFT", 95, 25)
	
	-- Textures and Borders --
	model:SetBackdrop( {
		bgFile = QuestOutLoudDB.profile.bgtexture,
		edgeFile = QuestOutLoudDB.profile.bordertexture,
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 4,  right = 3,  top = 4,  bottom = 3 }
	})
	
	self:SetModelID(model,0)
	self.Model = model
end
----


-- SetModelID
---- Sets the model id of the model displayed in the main frame
function QuestOutLoud:SetModelID(model, id)
	model:SetCreature(id)
	model:SetCamera(0)
end
----


-- CreateSpeakerName
---- Creates the text for the speaking character's name
function QuestOutLoud:CreateSpeakerName(parent)
	local text = CreateFrame("Button", "QuestOutLoud.SpeakerName", parent)
	text:SetPoint("TOP", parent, "BOTTOM", 0,0)
	text:SetWidth(75)
	text:SetHeight(25)
	text:SetText("TEST NAME")
	text:SetNormalFontObject("GameFontNormal")
	self.SpeakerName = text
end
----


-- SetSpeakerName
---- Sets the name of the speaker displayed on the main frame
function QuestOutLoud:SetSpeakerName(frame, name)
	frame:SetText(name)
end
----


-- CreateTitle
---- Creates the text for the current content's title
function QuestOutLoud:CreateTitle(parent)
	local text = CreateFrame("Button", "QuestOutLoud.Title", parent)
	text:SetPoint("TOP", parent, "TOP", 0,-5)
	text:SetWidth(75)
	text:SetHeight(25)
	text:SetText("TEST TITLE")
	text:SetNormalFontObject("GameFontNormal")
	self.Title = text

	--
	local icon = CreateFrame("Button", "QuestOutLoud.ContentTypeIcon", parent)
	icon:SetPoint("CENTER", parent, "TOPLEFT", 5, -5)
	icon:SetWidth(24)
	icon:SetHeight(24)
	local iconTex = icon:CreateTexture()
	iconTex:SetTexture("Interface\\Addons\\QuestOutLoud\\AcceptIcon")
	iconTex:SetAllPoints(icon)
	icon.texture = iconTex

	QuestOutLoud.ContentTypeIcon = iconTex;

	return text
end
----


-- SetTitle
---- Sets the name of the speaker displayed on the main frame
function QuestOutLoud:SetTitle(frame, name)
	frame:SetText(name)
end
----


-- CreateClearButton
---- Create button to stop sound playing and clear all sounds in queue
function QuestOutLoud:CreateClearButton(parent)
	self:Debug("CreateClearButton()")
	--
	local button = CreateFrame("Button", "QuestOutLoud.ClearButton", parent)
	button:SetPoint("CENTER", parent, "CENTER", -30,-10)
	button:SetWidth(24)
	button:SetHeight(24)

	local icon = CreateFrame("Frame", "QuestOutLoud.ClearButtonIcon", button)
	icon:SetPoint("CENTER", button, "CENTER", 0,0)
	icon:SetWidth(12)
	icon:SetHeight(12)
	local iconTex = icon:CreateTexture()
	iconTex:SetTexture("Interface\\Addons\\QuestOutLoud\\ExitButton")
	iconTex:SetAllPoints(icon)
	icon.texture = iconTex

	--
	button:SetScript("OnClick", function(self, button)
		if QuestOutLoud.currentSoundHandle ~= nil then
			QuestOutLoud:StopSound()
		end
		QuestOutLoud:ClearSound()
		QuestOutLoud:ClearSoundQueue()
		QuestOutLoud.MainFrame:Hide()
	end)
	--
	local ntex = button:CreateTexture()
	ntex:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
	ntex:SetTexCoord(0, 0.625, 0, 0.6875)
	ntex:SetAllPoints()	
	button:SetNormalTexture(ntex)
	--
	local htex = button:CreateTexture()
	htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
	htex:SetTexCoord(0, 0.625, 0, 0.6875)
	htex:SetAllPoints()
	button:SetHighlightTexture(htex)
	--
	local ptex = button:CreateTexture()
	ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
	ptex:SetTexCoord(0, 0.625, 0, 0.6875)
	ptex:SetAllPoints()
	button:SetPushedTexture(ptex)
	--
	return button
end
----


-- CreateSkipButton
---- Create button to stop the current sound and skip to the next sound
function QuestOutLoud:CreateSkipButton(parent)
	self:Debug("CreateSkipButton()")
	--
	local button = CreateFrame("Button", "QuestOutLoud.SkipButton", parent)
	button:SetPoint("CENTER", parent, "CENTER", 0,-10)
	button:SetWidth(24)
	button:SetHeight(24)

	local icon = CreateFrame("Frame", "QuestOutLoud.SkipButtonIcon", button)
	icon:SetPoint("CENTER", button, "CENTER", 0,0)
	icon:SetWidth(12)
	icon:SetHeight(12)
	local iconTex = icon:CreateTexture()
	iconTex:SetTexture("Interface\\Addons\\QuestOutLoud\\SkipButton")
	iconTex:SetAllPoints(icon)
	icon.texture = iconTex

	--
	button:SetScript("OnClick", function(self, button)
		if QuestOutLoud.currentSoundHandle ~= nil then
			QuestOutLoud:StopSound()
		end
		QuestOutLoud:SoundPlaybackFinished()
	end)
	--
	local ntex = button:CreateTexture()
	ntex:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
	ntex:SetTexCoord(0, 0.625, 0, 0.6875)
	ntex:SetAllPoints()	
	button:SetNormalTexture(ntex)
	--
	local htex = button:CreateTexture()
	htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
	htex:SetTexCoord(0, 0.625, 0, 0.6875)
	htex:SetAllPoints()
	button:SetHighlightTexture(htex)
	--
	local ptex = button:CreateTexture()
	ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
	ptex:SetTexCoord(0, 0.625, 0, 0.6875)
	ptex:SetAllPoints()
	button:SetPushedTexture(ptex)
	--
	return button
end
----


-- CreateStopButton
---- Create button to stop sound playing
function QuestOutLoud:CreateStopButton(parent)
	self:Debug("CreateStopButton()")
	--
	local button = CreateFrame("Button", "QuestOutLoud.StopButton", parent)
	button:SetPoint("CENTER", parent, "CENTER", 30,-10)
	button:SetWidth(24)
	button:SetHeight(24)

	local icon = CreateFrame("Frame", "QuestOutLoud.StopButtonIcon", button)
	icon:SetPoint("CENTER", button, "CENTER", 0,0)
	icon:SetWidth(12)
	icon:SetHeight(12)
	local iconTex = icon:CreateTexture()
	iconTex:SetTexture("Interface\\Addons\\QuestOutLoud\\PauseButton")
	iconTex:SetAllPoints(icon)
	icon.texture = iconTex
	QuestOutLoud.PauseIcon = iconTex;

	--
	button:SetScript("OnClick", function(self, button)
		if QuestOutLoud.currentSoundHandle ~= nil then
			QuestOutLoud:StopSound()
			QuestOutLoud.PauseIcon:SetTexture("Interface\\Addons\\QuestOutLoud\\PlayButton")
		elseif QuestOutLoud.currentSoundInfo ~= nil then
			QuestOutLoud:ResumeSound()
			QuestOutLoud.PauseIcon:SetTexture("Interface\\Addons\\QuestOutLoud\\PauseButton")
		end
	end)
	--
	local ntex = button:CreateTexture()
	ntex:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
	ntex:SetTexCoord(0, 0.625, 0, 0.6875)
	ntex:SetAllPoints()	
	button:SetNormalTexture(ntex)
	--
	local htex = button:CreateTexture()
	htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
	htex:SetTexCoord(0, 0.625, 0, 0.6875)
	htex:SetAllPoints()
	button:SetHighlightTexture(htex)
	--
	local ptex = button:CreateTexture()
	ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
	ptex:SetTexCoord(0, 0.625, 0, 0.6875)
	ptex:SetAllPoints()
	button:SetPushedTexture(ptex)
	--
	return button
end
----


-- CreateQueueCounter
---- Create button to stop sound playing and clear all sounds in queue
function QuestOutLoud:CreateQueueCounter(parent)
	self:Debug("CreateQueueCounter()")
	--
	local button = CreateFrame("Button", "QuestOutLoud.CreateQueueCounter", parent)
	button:SetPoint("CENTER", parent, "TOPRIGHT", -5,-5)
	button:SetWidth(24)
	button:SetHeight(24)
	local iconTex = button:CreateTexture()
	iconTex:SetTexture("Interface\\Addons\\QuestOutLoud\\CounterWindow")
	iconTex:SetAllPoints(button)
	button.texture = iconTex

	button:SetText("0")
	button:SetNormalFontObject("GameFontNormal")

	QuestOutLoud.QueueCounter = button;
	button:Hide(); -- should be hidden to start with

	return button
end
----


-- CreateMiniMapButton
---- Creates the mini map or LDB button for QuestOutLoud
function QuestOutLoud:CreateMiniMapButton()
	self:Debug("CreateMiniMapButton()")
	local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
	local icon = LibStub("LibDBIcon-1.0")

	local miniMapButton = ldb:NewDataObject("QuestOutLoud", {
		type = "launcher",
		icon = "Interface\\Addons\\QuestOutLoud\\QOLIcon",
		OnClick = function(clickedframe, button)
			if button == "LeftButton" then
				self:Debug("Left-click on minimap button")
				if QuestOutLoudDB.profile.enabled then
					self:Debug("Attempting Disable")
					QuestOutLoudDB.profile.enabled = false
					QuestOutLoud:Disable()
				else
					self:Debug("Attempting Enable")
					QuestOutLoudDB.profile.enabled = true
					QuestOutLoud:Enable()
				end
			elseif button == "RightButton" then
				self:Debug("Right-click on minimap button")
				InterfaceOptionsFrame_OpenToCategory("Quest Out Loud")
				InterfaceOptionsFrame_OpenToCategory("Quest Out Loud") -- twice because blizz bugs suck
			end
		end,
		OnTooltipShow = function(self) 
			if (QuestOutLoudDB.profile.enabled) then
				self:AddLine("QuestOutLoud - |cff00ff00Enabled|r")
			else
				self:AddLine("QuestOutLoud - |cffff0000Disabled|r")
			end
			self:AddLine("Left-click to enable/disable addon", 1, 1, 1)
			self:AddLine("Right-click to open config panel", 1, 1, 1) 
		end,
	})
	icon:Register("QuestOutLoudIcon", miniMapButton, QuestOutLoudDB.profile.minimap)
end
----


-- SetupFrames
---- Applies user preferences to frames
function QuestOutLoud:SetupFrames()
	self:Debug("SetupFrames()")
	self:SetFramePoints(); 
	self:SetupBackground(); 
end
----


-- SetFramePoints
---- Sets up the position, width, and height of the frame
function QuestOutLoud:SetFramePoints()
	local frame = self.MainFrame
	frame:ClearAllPoints()
	frame:SetPoint("TOP", "UIParent" ,"TOP", QuestOutLoudDB.profile.posX, QuestOutLoudDB.profile.posY)
	frame:SetHeight(70)
	frame:SetWidth(200)

end
----


-- SetupBackground
---- Applies user preferences to main frame background
function QuestOutLoud:SetupBackground()
	self:Debug("SetupBackground()")
	local mainFrame = self.MainFrame

	-- Textures and Borders --
	mainFrame:SetBackdrop( {
		bgFile = QuestOutLoudDB.profile.bgtexture,
		edgeFile = QuestOutLoudDB.profile.bordertexture,
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 4,  right = 3,  top = 4,  bottom = 3 }
	})
	
	-- Colors --
	mainFrame:SetBackdropColor(QuestOutLoudDB.profile.bgcolor[1], QuestOutLoudDB.profile.bgcolor[2], QuestOutLoudDB.profile.bgcolor[3], QuestOutLoudDB.profile.bgcolor[4])

	-- Border enable/disable --
	if QuestOutLoudDB.profile.border then 
		mainFrame:SetBackdropBorderColor(1, 1, 1, 1) 
	else 
		mainFrame:SetBackdropBorderColor(1, 1, 1, 0) 
	end
end	
----