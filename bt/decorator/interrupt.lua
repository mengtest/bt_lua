local Status = require('bt.task.task_status')
local Decorator = require('bt.decorator.decorator')


local mt = {}
mt.__index = mt

function mt.new(cls)
	local self = Decorator.new(cls)
	self.interrput_status = Status.failure
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

function mt:interrupt(status)
	self.interrput_status = status
	global.bt_mgr:interrupt(self.owner, self)
end

function mt:on_end()
	self.interrput_status = Status.failure
	self.execution_status = Status.inactive
end


return mt