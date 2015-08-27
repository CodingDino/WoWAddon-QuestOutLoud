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

-- OnInitialize --
---- Called before all addons have loaded, but after saved variables have loaded. --
function QuestOutLoud:OnInitialize()

	local defaults = { profile = {  
		drag = true,
		bgtexture = [[Interface\Tooltips\UI-Tooltip-Background]],
		bgcolor = {0.2, 0.2, 0.2, 0.7},
		bordertexture = [[Interface\Tooltips\UI-Tooltip-Border]],
		border = true
	} }
	QuestOutLoudDB = LibStub("AceDB-3.0"):New("QuestOutLoudData", defaults, true) -- Creates DB object to use with Ace
	
	QuestOutLoud:CreateFrames();
	
	QuestOutLoud:Print("Initialized.");
end
----

-- Coord --
---- Creates a coordinate with default or supplied values
function QuestOutLoud:Coord(zoneName, x, y)

	local coord = {};
	
	coord.zoneName = "";	-- Zone name for the coordinates. If zone not found, will use current zone.
	coord.x = 0;			-- X coordinate
	coord.y = 0;			-- Y coordinate
	
	-- Use values if provided
	if zoneName ~= nil then 	coord.zoneName = zoneName; end
	if x ~= nil then 			coord.x = x; end
	if y ~= nil then 			coord.x = x; end

	return coord;
end
----

-- Task --
---- Creates a task with default or supplied values
function QuestOutLoud:Task(id, name, details, coords, OnClick, IsComplete)
	local task = {};
	
	task.id = 0;					-- Unique ID used internally to identify the task. Assigned on task creation.
	task.name = "";					-- Name of the task (non-unique)
	task.details = "";				-- Detail text for the task
	task.icon = "";					-- Name of the icon to be used for this task
	task.coords = nil;				-- Coordinates that will be mapped for this task
	task.OnClick = nil; 			-- Function to be performed when task is clicked
	task.IsComplete = nil;			-- Function to check if the task is completed
	task.completedAt = 0;			-- The last time the task was completed (used for repeatable tasks)
	task.complete = false;			-- Whether or not the task has been completed since last being reset
	task.active = true;				-- Whether or not the task should be eligible to show on the tracker, assuming it's list is active
	
	-- Use values if provided
	if id ~= nil then			task.id = id; end
	if name ~= nil then			task.name = name; end
	if details ~= nil then		task.details = details; end
	if icon ~= nil then			task.icon = icon; end
	if coords ~= nil then		task.coords = coords; end
	if OnClick ~= nil then		task.OnClick = OnClick; end
	if IsComplete ~= nil then	task.IsComplete = IsComplete; end
	
	return task;
end
----