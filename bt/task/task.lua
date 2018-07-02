local Status = require('bt.task.task_status')

local mt = {}
mt.__index = mt

function mt.new(cls)
	local self = setmetatable({}, cls)
	self.id = -1
	self.friendly_name = ''
	self.instant = true
	self.ref_id = -1
	self.disable = true
	return self
end

function mt:on_awake()
end

function mt:on_start()
end

function mt:update()
	return Status.runing
end

function mt:on_pause()
end

function mt:on_conditional_abort()

end

function mt:on_end()
end

function mt:on_reset()
end

function mt:get_priority()
	return 0.0
end

function mt:get_utility()
	return 0.0
end


return mt