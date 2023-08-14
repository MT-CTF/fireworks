fireworks = {}

local colors = {
	{"red", "Red"},
	{"orange", "Orange"},
	{"violet", "Violet"},
	{"green", "Green"},
}


for _, i in pairs(colors) do
	local texture = "fireworks_"..i[1]..".png"
	minetest.register_node("fireworks:"..i[1], {
		description = i[2].." Fireworks",
		tiles = {"fireworks_"..i[1]..".png"},
		groups = {cracky = 3, mesecon = 2},
		drawtype = "plantlike",
		paramtype = "light",
		selection_box = {
			type = "fixed",
			fixed = { - 2 / 16, - 0.5, - 2 / 16, 2 / 16, 3 / 16, 2 / 16},
		},
		on_punch = function(pos)
			fireworks.fireworks_activate(pos, texture, i[1])
		end,
		mesecons = {
			effector = {
				action_on = function(pos)
					fireworks.fireworks_activate(pos, texture, i[1])
				end
			},
		},
		sounds = default.node_sound_stone_defaults(),
	})
end


minetest.register_craft({
	output = "fireworks:orange",
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

function fireworks.explode_firework(pos, color)
	local explosion_vel = vector.new(1, 1, 1)

	minetest.sound_play("fireworks_explosion", {
		pos = pos,
		max_hear_distance = 100,
		gain = 8.0
	})

	minetest.add_particlespawner({
		amount = 150,
		time = 0.001,
		minpos = pos,
		maxpos = pos,
		minvel = explosion_vel:multiply(-8),
		maxvel = explosion_vel:multiply(8),
		minacc = vector.zero(),
		maxacc = vector.zero(),
		minexptime = 0.8,
		maxexptime = 1.6,
		minsize = 2,
		maxsize = 3,
		collisiondetection = false,
		vertical = false,
		glow = minetest.LIGHT_MAX,
		texture = "fireworks_spark.png^[multiply:"..color,
	})

	minetest.add_particlespawner({
		amount = 100,
		time = 0.001,
		minpos = pos,
		maxpos = pos,
		minvel = explosion_vel:multiply(-4),
		maxvel = explosion_vel:multiply(4),
		minacc = vector.zero(),
		maxacc = vector.zero(),
		minexptime = 0.8,
		maxexptime = 1.6,
		minsize = 2,
		maxsize = 3,
		collisiondetection = false,
		vertical = false,
		glow = minetest.LIGHT_MAX,
		texture = "fireworks_spark.png^[multiply:#3262ff",
	})
end

local F_TIME = 1.5
local F_VEL = 1
function fireworks.fireworks_activate(pos, texture, color, distance)
	distance = distance or math.random(14, 30)

	minetest.sound_play("fireworks_launch", {
		pos = pos,
		max_hear_distance = 40,
		gain = 4.0
	})
	minetest.remove_node(pos)
	minetest.add_particle({
		pos = pos,
		velocity = vector.new(0, F_VEL, 0),
		-- If my math is right this should get the rocket to the explosion pos in the time given by F_TIME
		acceleration = vector.new(0, (2 * distance / math.pow(F_TIME, 2)) - (2 * F_VEL / F_TIME), 0),
		expirationtime = F_TIME,
		size = 8,
		collisiondetection = false,
		vertical = true,
		glow = minetest.LIGHT_MAX,
		texture = texture,
	})
	pos.y = pos.y + distance

	minetest.after(F_TIME, fireworks.explode_firework, pos, color)
end
