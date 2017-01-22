

lavaplus={}
lavaplus.finite_blocks = {}
lavaplus.register_step = function(a,height)
	minetest.register_node("finite:lava_"..a, {
		description = "Finite lava "..a,
		tiles = {
					   {name="default_lava.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0}}
		},

		drawtype = "nodebox",
		paramtype = "light",
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = true,
		liquid_viscosity = 1, --added lava-like viscosity
		liquidtype = "source",
		liquid_alternative_flowing = "finite:lava_"..a,
		liquid_alternative_source = "finite:lava_"..a,
		liquid_renewable = false,
		liquid_range = 0,
		groups = {},
		node_box = {
			type="fixed",
			fixed={
				{-0.5,-0.5,-0.5,0.5,height-0.5,0.5},
			},
		},
	})
	table.insert(lavaplus.finite_blocks,"finite:lava_"..a)
	bucket.register_liquid(
		"finite:lava_"..a,
		"",
		"finite:bucket_finitelava_"..a,
		"bucket_lava.png"
	)
end

--Create blocks
for a=1, 10 do
	lavaplus.register_step(a,a/10)
	lavaplus.finite_lava_steps_id = a
end

minetest.register_node("finite:lava_0", {
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
	nodenames = lavaplus.finite_blocks,
	interval = 5,
	chance = 1,
	action = function(pos,node)
		local level = getlevel_lava(pos,nil)
		local coords = {
			{x=pos.x+1,y=pos.y,z=pos.z},
			{x=pos.x-1,y=pos.y,z=pos.z},
			{x=pos.x,y=pos.y,z=pos.z+1},
			{x=pos.x,y=pos.y,z=pos.z-1},
		}

		
		local levelf=math.floor(level)
		--print (levelf.." "..level)
		if level<9 then
			for i,tg in pairs(coords) do
				local name = minetest.env:get_node(tg).name
				if name == "default:lava_source" then
					minetest.set_node(tg,{name="finite:lava_10"})
				end
			end
		end
		local pos_top={x=pos.x,y=pos.y+1,z=pos.z}
		local name_top = minetest.env:get_node(pos_top).name
		if name_top == "default:lava_source" then
			minetest.set_node(pos_top,{name="finite:lava_10"})
		end

		--
		
		local pos_down={x=pos.x,y=pos.y-1,z=pos.z}
		local level_down=getlevel_lava(pos_down,nil)
		if level_down~=nil then
			if level_down<10 then
				if level_down+level>10 then
					setlevel_lava(pos_down,10)
					setlevel_lava(pos,(level_down+level-10))
				else
					setlevel_lava(pos_down,(level_down+level))
					setlevel_lava(pos,0)
				end
				return
			end
		end

		--
		
		if level<2 then
			for i,tg in pairs(coords) do
				local side_down={x=tg.x,y=tg.y-1,z=tg.z}
				local level_side = getlevel_lava(tg,10)
				local level_side_down = getlevel_lava(side_down,10)
				if level_side==0 and level_side_down==0 then
						setlevel_lava(pos,0)
						setlevel_lava(side_down,level)
						return
				end
			end
		end

		--
		
		local cont=true	
		for i,tg in pairs(coords) do
			local level_side = getlevel_lava(tg,nil)
			if level_side ~= nil then
				if level > level_side+1 then
					level=level-1
					setlevel_lava(pos,level)
					setlevel_lava(tg,level_side+1)
					cont=false
				end
			end
		end
		if cont==false then
			return
		end

		--

		if level>9.9 then
			cont=true
			for i,tg in pairs(coords) do
				local level_side = getlevel_lava(tg,10)
				if level_side < 8 then
					cont=false
				end
			end
			if cont==true then
				local pos_down={x=pos.x,y=pos.y-1,z=pos.z}
				local level_down=getlevel_lava(pos_down,10)
				if level_down > 9.9 then
					minetest.set_node(pos,{name="default:lava_source"})
					return
				end
			end
		end
		
	end,
})

function getlevel_lava(pos,rt)
	local name = minetest.env:get_node(pos).name
	if name == "air" or name == "default:lava_flowing" then
		return 0
	elseif name == "default:lava_source" then
		return 10
	elseif s_start(name,"finite:lava_") then
		return getNumberFromName_lava(name)
	else
		return rt
	end
end
function setlevel_lava(pos,level)
	minetest.set_node(pos,{name="finite:lava_"..(level)})
end



minetest.register_abm({
	nodenames = {"default:lava_flowing"},
	interval = 1,
	chance = 1,
	action = function(pos,node)
		minetest.set_node(pos,{name="finite:lava_0"})
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
			if name == "default:lava_source" then
				minetest.set_node(tg,{name="finite:lava_10"})
			end
		end
	end
})

function getNumberFromName_lava(name)
	return tonumber(string.gsub(name, "finite:lava_", ""),10)
end

function s_start(String,Start)
	if string.len(String)<string.len(Start) then
		return false
	end
   return string.sub(String,1,string.len(Start))==Start
end
