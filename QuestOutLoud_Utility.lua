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
	return queue
end
----

