----------------------------------
--   QuestOutLoud_Logging.lua   --
----------------------------------


-- Logging defines
----
QuestOutLoud.LOGLEVEL = {};
QuestOutLoud.LOGLEVEL.NONE = 0;
QuestOutLoud.LOGLEVEL.ERROR = 1;
QuestOutLoud.LOGLEVEL.WARNING = 2;
QuestOutLoud.LOGLEVEL.DEBUG = 3;
QuestOutLoud.DebugLevel = QuestOutLoud.LOGLEVEL.DEBUG -- TODO: CHANGE ME!
QuestOutLoud.LogSerial = 0
QuestOutLoud.Log = {}
----


-- AddLog --
---- Adds a message to the internal log
function QuestOutLoud:AddLog(message)
	QuestOutLoud.LogSerial = QuestOutLoud.LogSerial + 1
	if QuestOutLoud.LogSerial > 9999 then
	    QuestOutLoud.LogSerial = 0
	end
	if QuestOutLoudDB and QuestOutLoudDB.global and QuestOutLoudDB.global.Log then
	    if QuestOutLoud.Log then
	        QuestOutLoudDB.global.Log = QuestOutLoud.Log
	        QuestOutLoud.Log = nil
	    end
	    QuestOutLoudDB.global.Log[date("%H%M.")..string.format("%04d",QuestOutLoud.LogSerial)] = msg
	else
	    QuestOutLoud.Log[date("%H%M.")..string.format("%04d",QuestOutLoud.LogSerial)] = msg
	end
end
----


-- Error --
---- displays error in chat
function QuestOutLoud:Error(message)
	if message ~= nil then
		local msg = "|cffcc0000ERROR|r-"..message
		self:Print( msg )
		QuestOutLoud:AddLog(msg)
	end
end
----


-- Debug --
---- If high enough debug level enabled, 
function QuestOutLoud:Debug(message,level)
	if message ~= nil then
		level = level or QuestOutLoud.LOGLEVEL.DEBUG
		if QuestOutLoud.DebugLevel >= level then
			local msg = "|cffcc0000DEBUG|r-"..message
			self:Print( msg )
		end
		QuestOutLoud:AddLog(msg)
	end
end
----


-- QOLPrint --
---- Print message to chat log
function QuestOutLoud:QOLPrint(message)
	if message ~= nil then
		self:Print( message )
		QuestOutLoud:AddLog(message)
	end
end
----
