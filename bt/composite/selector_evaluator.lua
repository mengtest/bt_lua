-- The selector evaluator is a selector task which reevaluates its children every tick. 
-- It will run the lowest priority child which returns a task status of running.
-- This is done each tick. 
-- If a higher priority child is running and the next frame a lower priority child wants to run it will interrupt the higher priority child.
-- The selector evaluator will return success as soon as the first child returns success otherwise it will keep trying higher priority children.
-- This task mimics the conditional abort functionality except the child tasks don't always have to be conditional tasks.

local Status = require('bt.task.task_status')
local Composite = require('bt.composite.composite')

local mt = {}
mt.__index = mt

function mt.new(cls)
	local self = Composite.new(cls)
	self.cur_child = 1
	self.run_status = Status.inactive
	self.sorted_cur_child = 0
	self.sorted_run_status = Status.inactive
	return self
end

function mt:get_cur_child_idx()
	return self.cur_child
end

function mt:on_child_started(idx)
	self.cur_child = self.cur_child +1
	self.run_status = Status.running
end

function mt:can_execute( )
	if self.run_status == Status.running || self.run_status == Status.succee thene
		return false
	end

	if self.sorted_cur_child > 0 then
		return self.cur_child < self.sorted_cur_child -1
	end

	return self.cur_child <= #self.children
end

function mt:on_child_executed(idx, status)
	local cur_st = self.run_status
	-- A disabled task is the equivalent of the task failing for a selector evaluator.
	if cur_st ==  Status.inactive and 
		self.children[self.cur_child].disabled  then
		self.run_status = Status.failure
	end

	if cur_st != Status.inactive and cur_st ~= Status.running then
		self.run_status = status
	end
end

function mt:can_run_parallel_children()
	return true
end

function mt:can_reevaluate( ... )
	return true
end

-- The behavior tree wants to start reevaluating the tree.
function mt:on_reevaluation_started()
	if self.run_status == Status.inactive then
		return false
	end

	self.sorted_cur_child = self.cur_child
	self.sorted_run_status = self.run_status
	self.cur_child = 1
	self.run_status = Status.inactive
	return true
end

function mt:on_reevaluation_ended(status)
	local cur_st = self.run_status
	if cur_st ~= Status.inactive and cur_st ~= Status.failure then
		global.bt_mgr:interrupt(self.owner, self.children[self.sorted_cur_child -1], self)
	else
		self.cur_child = self.sorted_cur_child
		self.run_status = self.sorted_run_status
	end

	self.sorted_cur_child = -1
	self.sorted_run_status = Status.inactive
end

function mt:override_status(status)
	return self.run_status
end

function mt:on_contional_abort(idx)
	self.cur_child = idx
	self.run_status = Status.inactive
end

function mt:on_end()
	self.run_status = Status.inactive
	self.cur_child = 1
end

return mt
