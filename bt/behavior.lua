
local Status = require('bt.task.task_status')

local mt = {}
mt.__index = mt

function mt.new(cls)
	local self = setmetatable({}, cls)
	self.start_when_enabled = false
	self.pause_when_disabled = false
	self.group = ''
	self.reset_val_when_reset = false

	self.is_paused = false
	self.execution_status = Status.inactive
	self.inited = false

	self.default_values = {}
	self.default_var_values = {}

	self.has_event = {}
	

	return self
end

return mt