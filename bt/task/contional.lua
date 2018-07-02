local Task = require('bt.task.task')

local mt = {}
mt.__index = mt

function mt.new(cls)
	local self = Task.new(cls)
	return self
end

return mt
