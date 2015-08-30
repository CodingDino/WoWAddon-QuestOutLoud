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
	
	local frame = CreateFrame("Button", "QuestOutLoud.MainFrame", UIParent)
	frame:SetParent(UIParent)
	frame:Show()
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
	self.MainFrame = frame
	--
	self:CreateModel()
end
----

-- CreateModel
---- Creates the model to be used in the main frame
function QuestOutLoud:CreateModel()
	local model = CreateFrame("PlayerModel", "QuestOutLoud.Model", self.MainFrame)
	model:SetPoint("TOPLEFT", self.MainFrame ,"TOPLEFT", 5, -5)
	model:SetPoint("BOTTOMRIGHT", self.MainFrame ,"BOTTOMLEFT", 95, 5)
	self:SetModelID(model,823)
	self.Model = model
end
----


-- SetModel
---- Creates the model to be used in the main frame
function QuestOutLoud:SetModelID(model, id)
	-- default
	model:SetModel("world/expansion04/doodads/pandaren/scroll/pa_scroll_10.mo3")
	--
	model:SetCreature(id)
	model:SetCamera(0)
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
		icon = "Interface\\Icons\\Inv_inscription_scroll", -- TODO: Better icon!
		OnClick = function(clickedframe, button)
			if button == "LeftButton" then
				self:Enable(not QuestOutLoudDB.Enabled);
			elseif button == "RightButton" then
				InterfaceOptionsFrame_OpenToCategory("QuestOutLoud")
				InterfaceOptionsFrame_OpenToCategory("QuestOutLoud") -- Do this twice because Blizz Bugs Suck.....
			end
		end,
		OnTooltipShow = function(self) 
			self:AddLine("QuestOutLoud")
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
	frame:SetHeight(QuestOutLoudDB.profile.height)
	frame:SetWidth(QuestOutLoudDB.profile.width)
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