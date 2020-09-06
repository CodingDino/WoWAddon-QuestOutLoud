----------------------------------
--   QuestOutLoud_Utility.lua   --
----------------------------------


-- Queues --
QuestOutLoud.Queue = {}
function QuestOutLoud.Queue:new ()
	local queue = {
		first = 0,
		last = -1
	}
	--
	queue.empty = function(self)
	  if self.first > self.last then 
		return true
	  else
		return false
	  end
	end
	--
	queue.size = function(self)
	  if self.first > self.last then 
		return 0
	  else
		return self.last-self.first + 1;
	  end
	end
	--
	queue.contains = function(self, value)
		if self:empty() then return false end
		local pointer = self.first
		while pointer <= self.last do 
			if self[pointer] == value then return true end
			pointer = pointer + 1
		end
		return false
	end
	--
	queue.push = function(self, value)
	  local last = self.last + 1
	  self.last = last
	  self[last] = value
	end
	--
	queue.pop = function(self)
	  local first = self.first
	  if first > self.last then error("queue is empty") end
	  local value = self[first]
	  self[first] = nil        -- to allow garbage collection
	  self.first = first + 1
	  return value
	end
	--
	queue.clear = function(self)
		self.first = 0;
		self.last = -1;
	end
	--
	return queue
end
----

----
function QuestOutLoud.Dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. QuestOutLoud.Dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end
----
