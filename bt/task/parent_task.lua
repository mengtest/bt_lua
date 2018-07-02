
local Status = require('bt.task.task_status')
local Task = require('bt.task.task')

local tbl_insert = table.insert

local mt = {}
mt.__index = mt


function mt.new(cls)
	local self = Task.new(cls)
	self.children = {}
	self.max_children = 0xffff
	return self
end

function mt:can_run_parallel_children( )
	return false
end

function  mt:get_max_children( )
	return self.max_children
end

function mt:get_cur_child_idx()
	return 1
end

function mt:can_execute()
	return true
end

function mt:decorate(status)
	return status
end


function mt:can_reevaluate()
	return false
end

function mt:on_reevaluate_started()
	return false
end

function mt:on_reevaluate_ended()
	
end

function mt:on_child_executed(child_status, child_idx)
end

function mt:on_child_started(idx)

end

function mt:override_status(status)
	return status
end

function mt:on_conditional_abort(idx)
end


function mt:get_utility()
	local c = self.children
	local num = 0.0
	for k = 1, #c do
		num = num + c:get_utility()
	end
	return num
end

function mt:add_child(child, idx)
	tbl_insert(self.children, idx, child)
end


function mt:replace_add_child(child, idx)
	if idx <=0 or idx > #this.children then
		tbl_insert(self.children, child)
		return
	end
	self.children[idx] = child
end








return mt