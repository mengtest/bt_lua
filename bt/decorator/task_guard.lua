-- The task guard
-- task is similar to a semaphore in multithreaded programming. The task guard task is there to ensure a limited resource is not being overused.
-- For example, you may place a task guard above a task that plays an animation. Elsewhere within your behavior tree you may also have another task that plays a different
-- animation but uses the same bones for that animation. Because of this you don't want that animation to play twice at the same time. Placing a task guard will let you 
-- specify how many times a particular task can be accessed at the same time.\n\nIn the previous animation task example you would specify an access count of 1. With this setup
-- the animation task can be only controlled by one task at a time. If the first task is playing the animation and a second task wants to control the animation as well, it will
-- either have to wait or skip over the task completely.

local Status = require('bt.task.task_status')
local Decorator = require('bt.decorator.decorator')


local mt = {}
mt.__index = mt

function mt.new(cls)
	local self = Decorator.new(cls)
	self.exe_status = Status.inactive
	self.max_access = 1 -- max_access_can_accept
	self.linked_task_guard = {}
	self.cur_time = 0 -- cur executing time
	self.executing = false
	self.wait_task_available = true
	return self
end


function mt:can_execute()
	return self.cur_time < self.max_access and not self.executing
end

function mt:on_child_started()
	self.cur_time = self.cur_time +1
	self.executing = true
	local tasks = self.linked_task_guard
	for i =1, #task do
		task[i]:task_executing(true)
	end
end

function mt:task_executing(increase)
	local c = increase and 1 or -1
	self.cur_time = self.cur_time + c
end

function mt:override_status(status)
	return (self.wait_task_available and not self.executing) and Status.running or status
end

function mt:on_end()
	if self.executing then
		self.cur_time  = self.cur_time -1
		local tasks = self.linked_task_guard
		for i =1, #task do
			task[i]:task_executing(false)
		end
		self.executing = false
	end

end
function mt:on_reset()
	self.max_access = 0
	self.linked_task_guard = {}
	self.wait_task_available = true
end


return mt