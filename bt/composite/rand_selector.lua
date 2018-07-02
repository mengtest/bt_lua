-- Similar to the selector task, the random selector task will return success as soon as a child task returns success.
-- The difference is that the random selector class will run its children in a random order. The selector task is deterministic
-- in that it will always run the tasks from left to right within the tree. The random selector task shuffles the child tasks up and then begins
-- execution in a random order. Other than that the random selector class is the same as the selector class. It will continue running tasks
-- until a task completes successfully. If no child tasks return success then it will return failure.

local Status = require('bt.task.task_status')
local Composite = require('bt.composite.composite')
local Utils = require('bt.utils')

local tinsert = table.insert
local tremove = table.remove

local mt = {}
mt.__index = mt

function mt.new(cls)
	local self = Composite.new(cls)
	self.child_idx = {}
	self.execute_order = {}
	self.run_status = Status.inactive
	return self
end

function mt:on_awake()
	for i =1, #self.children do
		tinsert(self.child_idx, i)
	end
end

function mt:on_start()
	Utils.shuffle_children(self)
end

function mt:get_cur_child_idx()
	local len = #self.execute_order
	return self.execute_order[len]
end

function mt:can_execute()
	return #self.execute_order > 0 and self.run_status ~= Status.success
end

function mt:on_child_executed(idx, status)
	local len = #self.execute_order
	if len >0 then
		self.execute_order[len] = nil
	end
	self.run_status = status
end

function mt:on_contional_abort(idx)
	-- Start from the beginning on an abort
	self.execute_order = {}
	self.run_status = Status.inactive
	Utils.shuffle_children(self)
end

function mt:on_end()
	self.run_status = Status.inactive
	self.execute_order = {}
end

return mt
