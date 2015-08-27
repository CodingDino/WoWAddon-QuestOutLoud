---------------------------------
--   QuestOutLoud_Frames.lua   --
---------------------------------

local parent = ObjectiveTrackerBlocksFrame

-- CreateFrames
---- Creates the UI
function QuestOutLoud:CreateFrames()
	QuestOutLoud:CreateMainFrame();
	QuestOutLoud:CreateMiniMapButton();
	
	QuestOutLoud:SetupFrames();
end
----

-- CreateMainFrame
---- Creates the parent frame for the QuestOutLoud UI
function QuestOutLoud:CreateMainFrame()
	QuestOutLoud.MainFrame = CreateFrame("Button", "QuestOutLoud.MainFrame", parent)
	QuestOutLoud.MainFrame:SetParent(parent)
	QuestOutLoud.MainFrame:Show()
	QuestOutLoud.MainFrame:SetPoint("CENTER", "UIParent", "CENTER", 0, 0);
end
----

-- CreateMiniMapButton
---- Creates the mini map or LDB button for QuestOutLoud
function QuestOutLoud:CreateMiniMapButton()
	local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
	local icon = LibStub("LibDBIcon-1.0")

	local miniMapButton = ldb:NewDataObject("QuestOutLoud", {
		type = "launcher",
		icon = "Interface\\Icons\\Inv_inscription_scroll", -- TODO: Better icon!
		OnClick = function(clickedframe, button)
			if button == "LeftButton" then
				QuestOutLoud:Enable(not QuestOutLoudDB.Enabled);
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
	--QuestOutLoud:ResizeSet(); 
	--QuestOutLoud:TitlebarSet(); 
	--QuestOutLoud:PaddingSet(); 
	QuestOutLoud:SetupBackground(); 
	--QuestOutLoud:RowSet(); 
	--QuestOutLoud:MinimapSet();
end
----

-- SetupBackground
---- Applies user preferences to main frame background
function QuestOutLoud:SetupBackground()
-- Textures and Borders --
	QuestOutLoud.MainFrame:SetBackdrop( {
		bgFile = QuestOutLoudDB.profile.bgtexture,
		edgeFile = QuestOutLoudDB.profile.bordertexture,
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 4,  right = 3,  top = 4,  bottom = 3 }
	})
-- Colors --
	QuestOutLoud.MainFrame:SetBackdropColor(QuestOutLoudDB.profile.bgcolor[1], QuestOutLoudDB.profile.bgcolor[2], QuestOutLoudDB.profile.bgcolor[3], QuestOutLoudDB.profile.bgcolor[4])
-- Border enable/disable --
	if QuestOutLoudDB.profile.border then 
		QuestOutLoud.MainFrame:SetBackdropBorderColor(1, 1, 1, 1) 
	else 
		QuestOutLoud.MainFrame:SetBackdropBorderColor(1, 1, 1, 0) 
	end
end	
----

-- GetQuadrant
---- Utility function that gets the quadrant of the screen the window is in
local function GetQuadrant(frame)
	local x,y = frame:GetCenter()
	local horizontal, vertical
	if x > (UIParent:GetWidth()/2) then horizontal = "RIGHT" else horizontal = "LEFT" end
	if y > (UIParent:GetHeight()/2) then vertical = "TOP" else vertical = "BOTTOM" end
	return horizontal, vertical
end