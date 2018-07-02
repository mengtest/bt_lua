-- The selector task is similar to an \"or\" operation.
-- It will return success as soon as one of its child tasks return success.
-- If a child task returns failure then it will sequentially run the next task.
-- If no child task returns success then it will return failure.

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

function mt:can_execute( )
	return self.cur_idx < #self.children and self.run_status ~= Status.success
end

function mt:on_child_executed(idx, status)
	self.cur_child = idx +1
	self.run_status = status
end

function mt:on_contional_abort(idx)
	self.cur_child = idx
	self.run_status = Status.inactive
end

function mt:on_end()
	self.cur_child = 0
	self.run_status = Status.inactive
end

return mt
