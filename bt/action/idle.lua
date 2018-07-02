local Status = require('bt.task.task_status')
local Action = require('bt.action.action')

local mt = {}
mt.__index = mt

function mt.new(cls)
	local self = Action.new(cls)
	return self
end

function mt:update()
	return Status.running
end

return mt
