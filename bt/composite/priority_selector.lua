-- Similar to the selector task,
-- the priority selector task will return success as soon as a child task returns success.
-- Instead of running the tasks sequentially from left to right within the tree
-- the priority selector will ask the task what its priority is to determine the order.
-- The higher priority tasks have a higher chance at being run first."

local Status = require('bt.task.task_status')
local Composite = require('bt.composite.composite')

local tinsert = table.insert

local mt = {}
mt.__index = mt

function mt.new(cls)
	local self = Composite.new(cls)
	self.cur_child = 1
	self.run_status =Status.inactive
	self.execute_order = {}
	return self
end

function mt:on_start()
	local sorted = {}
	-- 按照 priority 排序
	local cs = self.children
	for i =1, #cs do
		local p = cs[i]:get_priority()
		local idx = #sorted
		for j =1, #sorted do
			if cs[sorted[j]]:get_priority() < p then
				tinsert(sorted, idx, i)
				break
			end
		end
	end
	self.execute_order = sorted
end

function mt:get_cur_child_idx()
	return self.execute_order[self.cur_child]
end

function mt:can_execute()
	return self.cur_idx <= #self.execute_order and self.run_status ~= Status.succee
end

function mt:on_child_executed(idx, status)
	self.cur_child = self.cur_child +1
	self.run_status = status
end

function mt:on_contional_abort(idx)
	self.cur_child = idx
	self.run_status = Status.inactive
end

function mt:on_end()
	self.run_status = Status.inactive
	self.cur_child = 0
end

return mt
