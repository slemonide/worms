local RADIUS = 1

local nc = {}

minetest.register_entity("worms:worm", {
	physical = true,
	weight = 30,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	visual_size = {x=1, y=1},
	textures = {
		"pbj_pup_sides.png",
		"pbj_pup_jelly.png",
		"pbj_pup_sides.png",
		"pbj_pup_sides.png",
		"pbj_pup_back.png",
		"pbj_pup_front.png"
	},
	on_rightclick = function(self,clicker)
		if self.driver == nil then
			self.driver = clicker
			clicker:set_attach(self.object, "", {x=0,y=0,z=0}, {x=0,y=0,z=0})
		elseif self.driver == clicker then
			self.driver = nil
			clicker:set_detach()
		end
	end,
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if puncher:is_player() and puncher:get_inventory() then
			puncher:get_inventory():add_item("main", "pbj_pup:pbj_pup")
			if math.random(3) == 1 then
				puncher:get_inventory():add_item("main", "pbj_pup:pbj_pup_candies")
			end
			self.object:remove()
		end
	end,
	on_activate = function(self)
		local pos = self.object:getpos()
		nc.rotation = 2*math.pi*math.random() -- Random angle
		local h_velocity = 2
		local elevation = math.sin(2*math.pi*math.random())
		nc.velocity = {x=h_velocity * math.sin(nc.rotation), y=elevation, z=h_velocity * math.cos(nc.rotation)}
	end,
	on_step = function(self, dtime)
		if math.random(4) == 1 then
			return
		end

		self.object:setyaw(nc.rotation)
		self.object:setvelocity(nc.velocity)

		local pos = self.object:getpos()
	local p = {x = math.floor(pos.x), y = math.floor(pos.y), z = math.floor(pos.z)}
	local p_n = {x = math.floor(pos.x + math.cos(nc.rotation)), y = p.y, z = math.floor(pos.z + math.sin(nc.rotation))}

		-- Move forward and change direction if facing anything exept stone
		local p_node = minetest.get_node(p_n)
		if math.random(100) == 1 then
		nc.rotation = 2*math.pi*math.random() -- Random angle
			local h_velocity = 2
			local elevation = math.sin(2*math.pi*math.random())
			nc.velocity = {x=h_velocity * math.sin(nc.rotation), y=h_velocity * elevation, z=h_velocity * math.cos(nc.rotation)}
		end

		-- Dig the way
		for dx=-RADIUS,RADIUS do
			for dz=-RADIUS,RADIUS do
				for dy=-RADIUS,RADIUS do
					local np = {x=p.x + dx, y=p.y + dy, z=p.z + dz}
					local nnode = minetest.get_node(np)
					if nnode.name == "default:stone"
					or nnode.name == "default:mossycobble"
                    or nnode.name == "default:cobble"
                    or nnode.name == "default:stonebrick" then
						minetest.remove_node(np)
					end
				end
			end
		end

		-- Create mossy walls:
	local n = 0
		while n <= (RADIUS*2+1)*4 do
			local stone = minetest.find_node_near(p, RADIUS + 1, "default:stone")
			if not stone then
				return
			end
		local random = math.random(3)
		if random == 1 then
			minetest.set_node(stone, {name="default:mossycobble"})
		elseif random == 2 then
			minetest.set_node(stone, {name="default:cobble"})
		else
			minetest.set_node(stone, {name="default:stonebrick"})
		end
		n = n+1
		end
	end,
})

-- Turn node nyancats into object nyancats
minetest.register_abm({
	nodenames = {"pbj_pup:pbj_pup"},
	interval = 5,
	chance = 4,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.add_entity(pos, "worms:worm")
		minetest.remove_node(pos)
	end,
})

-- Place torches
minetest.register_abm({
	nodenames = {"air"},
	neighbors = {"default:mossycobble"},
	interval = 6,
	chance = 5,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local worm = minetest.get_objects_inside_radius(pos, 2 * RADIUS)
		if not worm then
			return
		end

		local above = {x = pos.x, y = pos.y + 1, z = pos.z}
		local above_node = minetest.get_node(above)
		local another_torch = minetest.find_node_near(pos, 3, {"default:torch", "group:torch"})

	if (above_node.name == "default:mossycobble"
	or above_node.name == "default:cobble"
	or above_node.name == "default:stonebrick")
	and not another_torch then
			minetest.set_node(pos, {name="default:torch"})
	end		
	end,
})

local grasses = {
		"default:grass_1",
		"default:grass_2",
		"default:grass_3",
		"default:grass_4",
		"default:grass_5",
		"default:dry_grass_1",
		"default:dry_grass_2",
		"default:dry_grass_3",
		"default:dry_grass_4",
		"default:dry_grass_5"
		}

-- Place grasses
minetest.register_abm({
	nodenames = {"air"},
	neighbors = {"default:mossycobble"},
	interval = 6,
	chance = 5,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local worm = minetest.get_objects_inside_radius(pos, 2 * RADIUS)
		if not worm then
			return
		end

		local below = {x = pos.x, y = pos.y - 1, z = pos.z}
		local below_node = minetest.get_node(below)
		local igniter = minetest.find_node_near(pos, 4, {"group:igniter"})

	if below_node.name == "default:mossycobble" and not igniter then
			local grass = grasses[math.random(#grasses)]
			minetest.set_node(pos, {name = grass})
	end		
	end,
})
