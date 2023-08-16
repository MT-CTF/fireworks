fireworks = {}

function fireworks.on_use(_user)
	-- Intended to be overwritten by mods
end

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

	local rand = math.random(1, 3) == 1
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
		texture = "fireworks_spark.png"..(rand and "^[multiply:yellow" or ""),
	})
end

local F_TIME = 1.5
local F_VEL = 1
function fireworks.activate(pos, firework_texture, color, distance)
	distance = distance or math.random(14, 30)

	minetest.sound_play("fireworks_launch", {
		pos = pos,
		max_hear_distance = 40,
		gain = 4.0
	})

	if minetest.get_node(pos).name:match("firework") then
		minetest.remove_node(pos)
	end

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
		texture = firework_texture,
	})
	pos.y = pos.y + distance

	minetest.after(F_TIME, fireworks.explode_firework, pos, color)
end

local timer = {}
for name, def in pairs(ctf_teams.team) do
	local color = def.color
	local texture = "fireworks_firework.png^(fireworks_overlay.png^[multiply:"..color..")"

	minetest.register_node("fireworks:"..name, {
		description = HumanReadable(name).." Fireworks",
		tiles = {texture},
		groups = {oddly_breakable_by_hand = 2},
		drawtype = "plantlike",
		paramtype = "light",
		selection_box = {
			type = "fixed",
			fixed = { - 2 / 16, - 0.5, - 2 / 16, 2 / 16, 3 / 16, 2 / 16},
		},
		on_use = function(itemstack, user, _pointed_thing)
			if user and user:is_player() then
				local pname = user:get_player_name()

				if timer[pname] then
					return
				else
					timer[pname] = true
					minetest.after(0.5, function()
						timer[pname] = nil
					end)
				end

				fireworks.on_use(user)

				fireworks.activate(user:get_pos():add(
					user:get_look_dir():multiply(2.2)):add(
					vector.new(0, user:get_properties().eye_height, 0)
				), texture, color)

				if ctf_teams.get(user) then
					itemstack:set_count(itemstack:get_count()-1)

					return itemstack
				end
			end
		end,
		on_punch = function(pos, _node, puncher, _pointed_thing)
			if puncher and puncher:is_player() then
				local pname = puncher:get_player_name()

				if timer[pname] then
					return
				else
					timer[pname] = true
					minetest.after(0.4, function()
						timer[pname] = nil
					end)
				end

				fireworks.on_use(puncher)

				fireworks.activate(pos, texture, color)
			end
		end,
		sounds = default.node_sound_stone_defaults(),
	})
end

local FIREWORKS_TREASURE = false

local check_interval = 60 * 60 * 6 -- 6 hour interval
local check_timer = check_interval -- Have it check when the server starts
minetest.register_globalstep(function(dtime)
	check_timer = check_timer + dtime

	if check_timer >= check_interval then
		check_timer = 0

		local date = os.date("*t")

		if (date.day >= 16 and date.month == 8) or
		(date.day <= 1 and date.month == 9) then
			FIREWORKS_TREASURE = true
		elseif FIREWORKS_TREASURE then
			FIREWORKS_TREASURE = false
		end
	end
end)

local tlist = {}
ctf_api.register_on_new_match(function()
	for k in pairs(ctf_map.current_map.teams) do
		table.insert(tlist, k)
	end
end)

local old_func = ctf_map.treasure.treasurefy_node
function ctf_map.treasure.treasurefy_node(inv, ...)
	if FIREWORKS_TREASURE then
		for _, name in pairs(tlist) do
			local item = ItemStack("fireworks:"..name)

			if math.random() < 0.5 then
				item:set_count(math.random(1, 4))

				inv:add_item("main", item)
			end
		end
	end

	return old_func(inv, ...)
end
