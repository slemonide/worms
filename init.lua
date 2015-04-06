local RADIUS = 1

minetest.register_abm({
    nodenames = {"default:nyancat"},
    interval = 1.0,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        local dir = minetest.facedir_to_dir(node.param2, true)
        local p = {x=pos.x-dir.x,y=pos.y-dir.y,z=pos.z-dir.z}
        -- Dig the way
        for dx=-RADIUS,RADIUS do
            for dz=-RADIUS,RADIUS do
                for dy=-RADIUS,RADIUS do
                    local npos = {x=pos.x + dx, y=pos.y + dy, z=pos.z + dz}
                    local nnode = minetest.get_node(pos)
                    if nnode ~= node then
                        minetest.remove_node(npos)
                    end
                end
            end
        end
        -- Occasionally change direction
        if math.random(1, 20) == 1 then
            node.param2 = math.random(1,22)
        end
        minetest.set_node(p, node)
        minetest.remove_node(pos)
    end,
})
