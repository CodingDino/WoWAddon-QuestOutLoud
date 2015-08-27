--------------------------
--   QuestOutLoud.lua   --
--------------------------

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


-- Debug --
---- If high enough debug level enabled, 
function QuestOutLoud:Debug(message,level)
	if message ~= nil then
		level = level or QuestOutLoud.LOGLEVEL.DEBUG
	    local msg = "|cffFF9900QuestOutLoud|r-|cffcc0000DEBUG|r: "..message
		if QuestOutLoud.DebugLevel >= level then
			DEFAULT_CHAT_FRAME:AddMessage( msg )
		end
		QuestOutLoud:AddLog(msg)
	end
end
----


-- Print --
---- Shows message if debugging is enabled
function QuestOutLoud:Print(message)
	if message ~= nil then
	    local msg = "|cffFF9900QuestOutLoud|r: "..message
		DEFAULT_CHAT_FRAME:AddMessage( msg )
		QuestOutLoud:AddLog(msg)
	end
end
----