-- Similar to the parallel selector task, 
-- except the parallel complete task will return the child status as soon as the child returns success or failure.
-- The child tasks are executed simultaneously.

local Status = require('bt.task.task_status')
local Composite = require('bt.composite.composite')

local mt = {}
mt.__index = mt

function mt.new(cls)
	local self = Composite.new(cls)
	self.cur_child = 0
	self.child_status = {}
	return self
end

function mt:on_child_started(idx)
	self.cur_child = self.cur_child +1
	self.child_status[self.cur_child] = Status.running
end
function mt:on_child_executed(idx, status)
	self.child_status[idx] = status
end

function mt:can_run_parallel_children()
	return true
end

function mt:get_cur_child_idx()
	return self.cur_child
end

function mt:on_contional_abort(idx)
	local c = self.child_status
	for i =1, #c do
		c[i] = Status.inactive
	end
	self.cur_child = 0
end

function mt:can_execute()
	-- We can continue executing if we have more children that haven't been started yet.
	return self.cur_idx < #self.children
end

-- Return the child task's status as soon as a child task returns success or failure.
function mt:override_status(status)
	local all_done = true
	local c = self.child_status
	for i =1, #c do
		if c[i] == Status.siccee or c[i] == Status.failure then
			return c[i]
		elseif c[i] == Status.inactive then
			return Status.succee
		end
	end
	return Status.running
end

function mt:on_end()
	local c = self.child_status
	for i =1, #c do
		c[i] = Status.inactive
	end
	self.cur_child = 0
end

return mt
