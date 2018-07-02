-- Similar to the sequence task, the random sequence task will return success as soon as every child task returns success.
-- The difference is that the random sequence class will run its children in a random order. The sequence task is deterministic
-- in that it will always run the tasks from left to right within the tree. The random sequence task shuffles the child tasks up and then begins
-- execution in a random order. Other than that the random sequence class is the same as the sequence class. It will stop running tasks
-- as soon as a single task ends in failure. On a task failure it will stop executing all of the child tasks and return failure.
-- If no child returns failure then it will return success."

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

local function shuffle_children(self)
	local ci = self.child_idx
	for i =#ci, 1, -1 do
		local j = random.rand(1, i)
		local idx = c[j]
		tinsert(self.execute_order, idx)
		ci[j] = ci[i]
		ci[i] = idx
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
	return #self.execute_order > 0 and self.run_status ~= Status.failure
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
