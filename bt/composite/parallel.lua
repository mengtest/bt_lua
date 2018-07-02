
-- Similar to the sequence task, the parallel task will run each child task until a child task returns failure.
-- The difference is that the parallel task will run all of its children tasks simultaneously versus running each task one at a time
-- Like the sequence class, the parallel task will return success once all of its children tasks have return success
-- If one tasks returns failure the parallel task will end all of the child tasks and return failure

local Status = require('bt.task.task_status')
local Composite = require('bt.composite.composite')

local mt = {}
mt.__index = mt

function mt.new(cls)
	local self = Composite.new(cls)
	self.cur_child = 1
	self.child_status = {}
	return self
end

function mt:on_child_started(idx)
	self.child_status[self.cur_child] = Status.running
	self.cur_child = self.cur_child +1
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

function mt:can_execute( )
	return self.cur_idx <= #self.children
end

function mt:override_status(status)
	local all_done = true
	local c = self.child_status
	for i =1, #c do
		if c[i] == Status.running then
			all_done = false
		elseif c[i] == Status.failure then
			return Status.failure
		end
	end
	return all_done and Status.succee or Status.running
end

function mt:on_contional_abort(idx)
	local c = self.child_status
	for i =1, #c do
		c[i] = Status.inactive
	end
	self.cur_child = 0
end

function mt:on_end()
	local c = self.child_status
	for i =1, #c do
		c[i] = Status.inactive
	end
	self.cur_child = 0
end

return mt
