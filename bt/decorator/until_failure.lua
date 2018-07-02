-- The until failure task will keep executing its child task until the child task returns failure.
local Status = require('bt.task.task_status')
local Decorator = require('bt.decorator.decorator')


local mt = {}
mt.__index = mt

function mt.new(cls)
	local self = Decorator.new(cls)
	self.run_status = Status.inactive
	return self
end


function mt:can_execute()
	local st = self.run_status
	return st == Status.succee or st == Status.inactive
end

function mt:on_child_executed(child_status)
	self.run_status = child_status
end

function mt:on_end()
	self.run_status = Status.inactive
end


return mt