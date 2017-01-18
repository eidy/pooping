 
minetest.register_on_item_eat(function(hp_change, replace_with_item, itemstack, user, pointed_thing)
 
   local satiated = false
   local pos = user:getpos()

   if minetest.get_modpath("hunger") and hunger.players and hunger.players[name] then
      satiated = (hunger.players[name].lvl == HUNGER_MAX)
   else
      if user:get_hp() >= 20 then satiated = true end
   end

   if satiated and math.random(1, 15) == 1 then
       minetest.sound_play("pooping_rumble", {pos = pos, gain = 0.8})
       minetest.after(5, pooper.dopoop , pos)
   end

end)


local po_cbox = {
	type = "fixed",
	fixed = { -0.3, -0.3, -0.3, 0.3, -0.125, 0.3}
}

minetest.register_node("pooping:poop", {
	description = "Poo",
	tiles = {"pooping_poop.png"},
    inventory_image = "pooping_poopinv.png",
    drawtype = "mesh",
	mesh = "pooping_poop.obj",
    paramtype = "light",
    buildable_to = true,   
	floodable = true,
	selection_box = po_cbox,
	collision_box = po_cbox,
	groups = {crumbly = 3, soil = 1, falling_node = 1}, 
	sounds = default.node_sound_dirt_defaults(),
    on_use = function(itemstack, user, pointed_thing)

        if minetest.get_modpath("bonemeal") then 

        	 -- did we point at a node?
		    if pointed_thing.type ~= "node" then
                return minetest.item_eat(1)(itemstack, user, pointed_thing)
			 
		    end

		    -- is area protected?
		    if minetest.is_protected(pointed_thing.under, user:get_player_name()) then
			    return
		    end

		    -- take item if not in creative
		    if not minetest.setting_getbool("creative_mode") then
			    itemstack:take_item()
		    end

           	-- get position and call global on_use function
		    bonemeal:on_use(pointed_thing.under)

		    return itemstack
      end
end
})

if minetest.get_modpath("hunger") then
    hunger.register_food("pooping:poop", 1, nil, 6, nil, nil) 
end

minetest.register_abm(
	{nodenames = {"pooping:poop"},
	interval = 2,
	chance = 1,
	 
	action = function(pos)

    local tod = minetest.get_timeofday() * 24000 

    if tod > 6000 and tod < 18752 then  -- Only do this at daytime

	    local objects = minetest.get_objects_inside_radius(pos, 5)
	    -- Poll players for names to pass to set_breath()
	    for i, obj in ipairs(objects) do
		    if (obj:is_player()) then

               -- Flies
               for i=1,math.random(1,3) do
                   minetest.add_particle({
	                    pos = vector.add(pos,{x=0,y=0.1*math.random(5),z=0}),
	                    velocity = {x=0, y=0.1*math.random(-1,1), z=0},
	                    acceleration = {x=0.1*math.random(-1,1), y=0.1*math.random(-1,1), z=0},
	                    expirationtime = 2,
	                    size = 0.2,
	                    collisiondetection = false,
	                    vertical = false,
	                    texture = "pooping_fly.png",
	                    playername = "singleplayer"
                    })
                end

               
                if math.random(1,50) == 1 then
			         -- Transform poop into something nice, it's the miracle of poo!
                     local stuff
                     if math.random(1,2) == 1 then
                         if minetest.get_node_light({x=pos.x, y=pos.y + 1, z=pos.z}, 0.5) > 10 then
                            stuff={"rose","tulip","dandelion_yellow","viola","geranium","dandelion_white"} 
                         else
                            stuff={"mushroom_red","mushroom_brown"}
                         end
                         minetest.set_node(pos,{name = "flowers:" .. stuff[math.random(1,#stuff)] }) 
                     else
                         minetest.set_node(pos,{name = "air"}) 
                     end
                     
                 end
		    end
	     end
    end
end,
}) 

-- pooping api
pooper = {}
pooper.dopoop = function(pos)
    minetest.sound_play("pooping_defecate", {pos = pos, gain = 0.8})   
    minetest.set_node(pos,{name = "pooping:poop"}) 
end
 