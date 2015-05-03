local RADIUS = 1

local nc = {}

minetest.register_entity("worms:worm", {
    physical = true,
    collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
    visual = "cube",
    visual_size = {x=1, y=1},
    textures = {"default_nc_side.png", "default_nc_side.png", "default_nc_side.png",
                "default_nc_side.png", "default_nc_back.png", "default_nc_front.png"},
    on_rightclick = function(self,clicker)
        if self.driver == nil then
            self.driver = clicker
            clicker:set_attach(self.object, "", {x=0,y=0,z=0}, {x=0,y=0,z=0})
        elseif self.driver == clicker then
            self.driver = nil
            clicker:set_detach()
        end
    end,
    on_activate = function(self)
        self.object:setacceleration({x = 0, y = -9.81, z = 0})
        nc.rotation = (math.random(1, 100) / math.pi)
        local h_velocity = math.random(-5, 5)
        local elevation = math.random(-1, 1)
        nc.velocity = {x=h_velocity * math.cos(nc.rotation), y=elevation, z=h_velocity * math.sin(nc.rotation)}
    end,
    on_step = function(self, dtime)
        self.object:setyaw(nc.rotation)
        self.object:setvelocity(nc.velocity)

        local pos = self.object:getpos()
	local p = {x = math.floor(pos.x), y = math.floor(pos.y), z = math.floor(pos.z)}
	local p_n = {x = math.floor(pos.x + math.cos(nc.rotation)), y = p.y, z = math.floor(pos.z + math.sin(nc.rotation))}

        -- Move forward and change direction if facing anything exept stone
        local p_node = minetest.get_node(p_n)
        if math.random(1,100) == 1 and
        (p_node.name ~= "default:stone"
        or p_node.name ~= "default:mossycobble"
        or p_node.name ~= "default:torch"
        or p_node.name ~= "air") then
	    nc.rotation = (math.random(1, 100) / math.pi)
            local h_velocity = math.random(-5, 5)
            local elevation = math.random(-1, 1)
            nc.velocity = {x=h_velocity * math.cos(nc.rotation), y=elevation, z=h_velocity * math.sin(nc.rotation)}
        end

        -- Dig the way
        for dx=-RADIUS,RADIUS do
            for dz=-RADIUS,RADIUS do
                for dy=-RADIUS,RADIUS do
                    local np = {x=p.x + dx, y=p.y + dy, z=p.z + dz}
                    local nnode = minetest.get_node(np)
                    if nnode.name == "default:stone"
                    or nnode.name == "default:mossycobble" then
                        if math.random(1, 30) == 1 then
                            minetest.set_node(np, {name="default:torch"})
                        else
                            minetest.remove_node(np)
                        end
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
