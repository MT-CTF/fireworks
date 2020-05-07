local colors = {
    {"red", "Red"},
    {"orange", "Orange"},
    {"violet", "Violet"},
    {"green", "Green"},
}


for _,i in pairs(colors) do
	minetest.register_node("fireworks:"..i[1], {
		description = i[2].." Fireworks",
		tiles = {"firework_"..i[1]..".png"},
		groups = {cracky=3, mesecon=2},
                drawtype = "plantlike",
                paramtype = "light",
                selection_box = {
			type = "fixed",
			fixed = {-2 / 16, -0.5, -2 / 16, 2 / 16, 3 / 16, 2 / 16},
		},
		on_punch = function(pos)
			fireworks_activate(pos, i[1])
		end,
		mesecons = {
			effector = {
				action_on = function(pos)
					fireworks_activate(pos, i[1])
				end
			},
		},
		sounds = default.node_sound_stone_defaults(),
	})
end


minetest.register_craft({
	output = "fireworks:firework_orange",
	recipe = {
		{"default:paper"},
		{"tnt:gunpowder"},
		{"dye:orange"}
	}
})

minetest.register_craft({
	output = "fireworks:red",
	recipe = {
		{"default:paper"},
		{"tnt:gunpowder"},
		{"dye:red"}
	}
})

minetest.register_craft({
	output = "fireworks:violet",
	recipe = {
		{"default:paper"},
		{"tnt:gunpowder"},
		{"dye:violet"}
	}
})

minetest.register_craft({
	output = "fireworks:green",
	recipe = {
		{"default:paper"},
		{"tnt:gunpowder"},
		{"dye:green"}
	}
})

function fireworks_activate(pos, name)
    minetest.remove_node(pos)
    minetest.add_particlespawner({
		amount = 1,
		time = 0.001,
		minpos = pos,
		maxpos = pos,
		minvel = 0,
		maxvel = 0,
		minacc = {x=0, y=13.2, z=0},
		maxacc = {x=0, y=13.2, z=0},
		minexptime = 1.5,
		maxexptime = 1.5,
		minsize = 8,
		maxsize = 8,
		collisiondetection = false,
		vertical = false,
                glow = 5,
		texture = "firework_"..name..".png",
    })
    minetest.after(1.5, function()
    minetest.sound_play("fireworks", {gain = 10, pos = pos2, max_hear_distance = 50})
    local gravity = -8
    pos.y = pos.y+15
	minetest.add_particlespawner({
		amount = 150,
		time = 0.001,
		minpos = pos,
		maxpos = pos,
		minvel = vector.new(-1,-1,-1),
		maxvel = vector.new(1,1,1),
		minacc = {x=0, y=-0.5, z=0},
		maxacc = {x=0, y=-1, z=0},
		minexptime = 2,
		maxexptime = 2.5,
		minsize = 2,
		maxsize = 3,
		collisiondetection = true,
		vertical = false,
                glow = 5,
		texture = "firework_sparks_"..name..".png",
	})
        minetest.add_particlespawner({
		amount = 100,
		time = 0.001,
		minpos = pos,
		maxpos = pos,
		minvel = vector.new(-1,-1,-1),
		maxvel = vector.new(1,1,1),
		minacc = {x=0, y=-0.5, z=0},
		maxacc = {x=0, y=-1, z=0},
		minexptime = 2,
		maxexptime = 2.5,
		minsize = 2,
		maxsize = 3,
		collisiondetection = true,
		vertical = false,
                glow = 5,
		texture = "firework_sparks_blue.png",
	})
    end)
end

