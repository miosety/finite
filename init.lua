dofile(minetest.get_modpath("finite").."/water.lua")
dofile(minetest.get_modpath("finite").."/lava.lua")
--[[for i=0,22,1 
do 
   minetest.register_abm({
	nodenames = {"waterplus:finite_"..i},
	interval = 1,
	chance = 1,
	action = function(pos,node)
			minetest.env:remove_node(pos)
		end
	})
end
]]--
