
local mt = {}
mt.__index = mt

local tinsert = table.insert

function mt.shuffle_children(self)
	local ci = self.child_idx
	for i =#ci, 1, -1 do
		local j = random.rand(1, i)
		local idx = c[j]
		tinsert(self.execute_order, idx)
		ci[j] = ci[i]
		ci[i] = idx
	end
end


return {}