local Status = require('bt.task.task_status')
local Action = require('bt.action.action')

local mt = {}
mt.__index = mt

function mt.new(cls)
	local self = Action.new(cls)
	self.text = ''
	return self
end

function mt:update()
	print('action.log:',self.text)
	return Status.success
end

function mt:on_reset()
	self.text = ''
end

return mt
