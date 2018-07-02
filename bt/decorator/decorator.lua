local ParentTask = require('bt.task.parent_task')

local mt = {}
mt.__index = mt

function mt.new(cls)
	local self = ParentTask.new(cls)
	self.abort_type = AbortType.none
	return self
end

function mt:max_children()
	return 1
end


return mt
