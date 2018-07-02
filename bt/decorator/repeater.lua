-- The repeater task will repeat execution of its child task until the child task has been run a specified number of times.
-- It has the option of continuing to execute the child task even if the child task returns a failure.
local Status = require('bt.task.task_status')
local Decorator = require('bt.decorator.decorator')


local mt = {}
mt.__index = mt

function mt.new(cls)
	local self = Decorator.new(cls)
	self.exe_status = Status.inactive
	self.r_cnt = 1 -- request repeat cnt
	self.end_on_failure = true
	self.c_cnt = 0 -- current execution cnt
	return self
end


function mt:can_execute()
	local r_cnt = self.repeat_cnt
	local c_cnt = self.execution_cnt
	return (not (self.end_on_failure and self.exe_status == Status.failure)) and
	(self.r_cnt < 0 or self.r_cnt  > self.c_cnt)
end

function mt:on_child_executed(child_status)
	self.c_cnt = self.c_cnt +1
	self.exe_status = child_status
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
	self.c_cnt = 0
	self.exe_status = Status.inactive
end
function mt:on_reset()
	self.r_cnt = 0;
	self.end_on_failure = true
end


return mt