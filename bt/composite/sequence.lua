-- The sequence task is similar to an \"and\" operation. 
-- It will return failure as soon as one of its child tasks return failure.
-- If a child task returns success then it will sequentially run the next task. 
-- If all child tasks return success then it will return success.

local Status = require('bt.task.task_status')
local Composite = require('bt.composite.composite')

local mt = {}
mt.__index = mt

function mt.new(cls)
	local self = Composite.new(cls)
	self.cur_child = 0
	self.run_status = Status.inactive
	return self
end

function mt:get_cur_child_idx()
	return self.cur_child
end

function mt:can_execute()
	return self.cur_idx < #self.children and self.run_status ~= Status.failure
end

function mt:on_child_executed(idx, status)
	self.cur_child = idx +1
	self.run_status = status
end

function mt:on_contional_abort(idx)
	-- Set the current child index to the index that caused the abort
	self.cur_child = idx +1
	self.run_status = Status.inactive
end

function mt:on_end()
	self.run_status = Status.inactive
	self.cur_child = 0
end

return mt
