

waterplus={}
waterplus.finite_blocks = {}
waterplus.register_step = function(a,height)
	minetest.register_node("finite:water_"..a, {
		description = "Finite Water "..a,
		tiles = {
					   {name="default_water.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0}}
		},

		drawtype = "nodebox",
		paramtype = "light",
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = true,
		liquid_viscosity = 1, --added water-like viscosity
		liquidtype = "source",
		liquid_alternative_flowing = "finite:water_"..a,
		liquid_alternative_source = "finite:water_"..a,
		liquid_renewable = false,
		liquid_range = 0,
		groups = {water=3,puts_out_fire=1, cools_lava = 1},
		node_box = {
			type="fixed",
			fixed={
				{-0.5,-0.5,-0.5,0.5,height-0.5,0.5},
			},
		},
	})
	table.insert(waterplus.finite_blocks,"finite:water_"..a)
	bucket.register_liquid(
		"finite:water_"..a,
		"",
		"finite:bucket_finitewater_"..a,
		"bucket_water.png"
	)
end

--Create blocks
for a=1, 10 do
	waterplus.register_step(a,a/10)
	waterplus.finite_water_steps_id = a
end

minetest.register_node("finite:water_0", {
	description = "Fake Air",
	drawtype = "airlike",
	paramtype = 'light',
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	groups = {not_in_creative_inventory=1},
})

minetest.register_abm({
	nodenames = waterplus.finite_blocks,
	interval = 1,
	chance = 1,
	action = function(pos,node)
		local level = getlevel(pos,nil)
		local coords = {
			{x=pos.x+1,y=pos.y,z=pos.z},
			{x=pos.x-1,y=pos.y,z=pos.z},
			{x=pos.x,y=pos.y,z=pos.z+1},
			{x=pos.x,y=pos.y,z=pos.z-1},
		}

		if level<9 then
			for i,tg in pairs(coords) do
				local name = minetest.env:get_node(tg).name
				if name == "default:water_source" then
					minetest.set_node(tg,{name="finite:water_10"})
				end
			end
		end
		local pos_top={x=pos.x,y=pos.y+1,z=pos.z}
		local name_top = minetest.env:get_node(pos_top).name
		if name_top == "default:water_source" then
			minetest.set_node(pos_top,{name="finite:water_10"})
		end

		--
		
		local pos_down={x=pos.x,y=pos.y-1,z=pos.z}
		local level_down=getlevel(pos_down,nil)
		if level_down~=nil then
			if level_down<10 then
				if level_down+level>10 then
					setlevel(pos_down,10)
					setlevel(pos,(level_down+level-10))
				else
					setlevel(pos_down,(level_down+level))
					setlevel(pos,0)
				end
				return
			end
		end

		--
		
		if level<2 then
			for i,tg in pairs(coords) do
				local side_down={x=tg.x,y=tg.y-1,z=tg.z}
				local level_side = getlevel(tg,10)
				local level_side_down = getlevel(side_down,10)
				if level_side==0 and level_side_down==0 then
						setlevel(pos,0)
						setlevel(side_down,level)
						return
				end
			end
		end

		--
	
		
		local cont=true	
		for i,tg in pairs(coords) do
			local level_side = getlevel(tg,nil)
			if level_side ~= nil then
				if level > level_side+1 then
					level=level-1
					setlevel(pos,level)
					setlevel(tg,level_side+1)
					cont=false
				end
			end
		end
		if cont==false then
			return
		end

		--

		local tt=level
		local n=1
		for i,tg in pairs(coords) do
			local level_side = getlevel(tg,nil)
			if level_side ~= nil then
				n=n+1
				tt=tt+level_side
			end
		end
		if n>1 then
			local m=tt/n
			for i,tg in pairs(coords) do
				local level_side = getlevel(tg,nil)
				if level_side ~= nil then
					setlevel(tg,m)
				end
			end
			setlevel(pos,m)
			return
		end

		--

		if level>9.9 then
			cont=true
			for i,tg in pairs(coords) do
				local level_side = getlevel(tg,10)
				if level_side < 8 then
					cont=false
				end
			end
			if cont==true then
				local pos_down={x=pos.x,y=pos.y-1,z=pos.z}
				local level_down=getlevel(pos_down,10)
				if level_down > 9.9 then
					minetest.set_node(pos,{name="default:water_source"})
					return
				end
			end
		end
		
	end,
})

function getlevel(pos,rt)
	local meta = minetest.get_meta(pos)
	local level = meta:get_string("level")
	if level ~= nil then
		if string.len(level) > 0 then
			return tonumber(level,10)
		end
	end
	local name = minetest.env:get_node(pos).name
	if name == "air" or name == "default:water_flowing" then
		return 0
	elseif name == "default:water_source" then
		return 10
	elseif s_start(name,"finite:water_") then
		return getNumberFromName(name)
	else
		return rt
	end
end
function setlevel(pos,level)
	if level <0.001 then
		minetest.set_node(pos,{name="air"})
		return
	end
	local levelf=math.floor(level)
	minetest.set_node(pos,{name="finite:water_"..(levelf)})
	local meta = minetest.get_meta(pos)
	meta:set_string("level", level)
end



minetest.register_abm({
	nodenames = {"default:water_flowing"},
	interval = 1,
	chance = 1,
	action = function(pos,node)
		minetest.set_node(pos,{name="finite:water_0"})
		local coords = {
			{x=pos.x,y=pos.y+1,z=pos.z},
			{x=pos.x+1,y=pos.y,z=pos.z},
			{x=pos.x-1,y=pos.y,z=pos.z},
			{x=pos.x,y=pos.y,z=pos.z+1},
			{x=pos.x,y=pos.y,z=pos.z-1},

			{x=pos.x+1,y=pos.y,z=pos.z+1},
			{x=pos.x-1,y=pos.y,z=pos.z+1},
			{x=pos.x+1,y=pos.y,z=pos.z-1},
			{x=pos.x-1,y=pos.y,z=pos.z-1},

			
		}
		for i,tg in pairs(coords) do
			local name = minetest.env:get_node(tg).name
			if name == "default:water_source" then
				minetest.set_node(tg,{name="finite:water_10"})
			end
		end
	end
})

function getNumberFromName(name)
	return tonumber(string.gsub(name, "finite:water_", ""),10)
end

function s_start(String,Start)
	if string.len(String)<string.len(Start) then
		return false
	end
   return string.sub(String,1,string.len(Start))==Start
end
