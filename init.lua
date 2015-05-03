local RADIUS = 1

local nc = {}

minetest.register_entity("worms:worm", {
    physical = true,
    weight = 30,
    collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
    visual = "cube",
    visual_size = {x=1, y=1},
    textures = {"default_nc_side.png", "default_nc_side.png", "default_nc_side.png",
                "default_nc_side.png", "default_nc_back.png", "default_nc_front.png"},
    on_rightclick = function(self,clicker)
        if self.driver == nil then
            self.driver = clicker
            clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
        elseif self.driver == clicker then
            self.driver = nil
            clicker:set_detach()
        end
    end,
    on_activate = function(self)
        local pos = self.object:getpos()
        self.object:setacceleration({x = 0, y = -8, z = 0})
        nc.rotation = pos.z * pos.y / (math.pi * 10)
        local h_velocity = 5 * math.sin(pos.x * pos.y / (math.pi * 10))
        local elevation = 2 * math.sin(pos.z * pos.x / (math.pi * 10))
        nc.velocity = {x=h_velocity * math.sin(nc.rotation), y=elevation, z=h_velocity * math.cos(nc.rotation)}
    end,
    on_step = function(self, dtime)
        self.object:setyaw(nc.rotation)
        self.object:setvelocity(nc.velocity)

        local pos = self.object:getpos()
	local p = {x = math.floor(pos.x), y = math.floor(pos.y) + RADIUS, z = math.floor(pos.z)}
	local p_n = {x = math.floor(pos.x + math.cos(nc.rotation)), y = p.y, z = math.floor(pos.z + math.sin(nc.rotation))}

        -- Move forward and change direction if facing anything exept stone
        local p_node = minetest.get_node(p_n)
        if pos.x == pos.y then
            nc.rotation = pos.z * pos.y / (math.pi * 10)
            local h_velocity = 5 * math.sin(pos.x * pos.y / (math.pi * 10))
            local elevation = 2 * math.sin(pos.z * pos.x / (math.pi * 10))
            nc.velocity = {x=h_velocity * math.sin(nc.rotation), y=elevation, z=h_velocity * math.cos(nc.rotation)}
        end

        -- Dig the way
        for dx=-RADIUS,RADIUS do
            for dz=-RADIUS,RADIUS do
                for dy=-RADIUS,RADIUS do
                    local np = {x=p.x + dx, y=p.y + dy, z=p.z + dz}
                    local nnode = minetest.get_node(np)
                    if nnode.name == "default:stone"
                    or nnode.name == "default:mossycobble" then
                        minetest.remove_node(np)
                    end
                end
            end
        end

        -- Create mossy walls:
        while true do
            local stone = minetest.find_node_near(p, RADIUS + 1, "default:stone")
            if not stone then
                return
            end
            minetest.set_node(stone, {name="default:mossycobble"})
        end
    end,
})

-- Turn node nyancats into object nyancats
minetest.register_abm({
    nodenames = {"default:nyancat"},
    interval = 1.0,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        minetest.add_entity(pos, "worms:worm")
        minetest.remove_node(pos)
    end,
})

-- Place torches
minetest.register_abm({
    nodenames = {"air"},
    neighbors = {"default:mossycobble"},
    interval = 1.0,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        local above = {x = pos.x, y = pos.y + 1, z = pos.z}
        local above_node = minetest.get_node(above)
        local worm = minetest.get_objects_inside_radius(pos, 2 * RADIUS)
        local another_torch = minetest.find_node_near(pos, 3, {"default:torch"})

        if above_node.name == "default:mossycobble" and worm and not another_torch then
            minetest.set_node(pos, {name="default:torch"})
        end        
    end,
})
