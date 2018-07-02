local Status = require('bt.task.task_status')
local Decorator = require('bt.decorator.decorator')


local mt = {}
mt.__index = mt

function mt.new(cls)
	local self = Decorator.new(cls)
	self.execution_status = Status.inactive
	return self
end


function mt:can_execute()
	local st = self.execution_status
	return st == Status.inactive or st == Status.running
end

function mt:on_child_executed(child_status)
	self.execution_status = child_status
end

function mt:decorate(status)
	if status == Status.succee then
		return Status.failure
	elseif status == Status.failure then
		return Status.succee
	end
	return status
end

function mt:on_end()
	self.execution_status = Status.inactive
end


return mt