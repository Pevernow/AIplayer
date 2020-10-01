AIplayer = {
    version = 20201001,
    maintainer = "Pevernow",
    S = minetest.get_translator("aiplayer"),
    ticktime = 0.5
}

local node_ok = function(pos, fallback)

	local node = minetest.get_node_or_nil(pos)

	if node and minetest.registered_nodes[node.name] then
		return node
	end

	return minetest.registered_nodes[fallback]
end

AIplayer.roundpos = function(pos)
	if pos and pos.x and pos.y and pos.z then
		pos.x = math.floor(pos.x+0.5)
		pos.y = math.floor(pos.y+0.5)
		pos.z = math.floor(pos.z+0.5)
		return pos
	end
    return nil
end

AIplayer.on_activate = function(self)
    self.deltatime = 0
    self.old_y = self.object:get_pos().y
    self.falling = function(self,pos)
        if(self.standing_on=="air") then
            self.object:set_acceleration({
                x = 0,
                y = -9.8,
                z = 0
            })
        else
            if(self.old_y-self.pos.y>3) then
                self.object:set_hp(self.object:get_hp()-(self.old_y-self.pos.y-3), "Fall down")
                if(self.object:get_hp()==0) then
                    self.object:remove()
                end
            end
            self.old_y = self.pos.y
        end
    end
end

AIplayer.on_step = function(self, dtime, null)
    self.deltatime = self.deltatime + dtime
    if(deltatime>=AIplayer.ticktime) then
        self.deltatime = self.deltatime - AIplayer.ticktime
    else
        return
    end
    
    self.pos = self.object:get_pos()
    local y_level = self.collisionbox[2]
    self.dtime = dtime
    self.standing_on = node_ok({x = self.pos.x, y = self.pos.y-1.5, z = self.pos.z}, "air").name
    self.standing_in = node_ok({x = self.pos.x, y = self.pos.y-0.5, z = self.pos.z}, "air").name
    if minetest.registered_nodes[self.standing_in].walkable and
			minetest.registered_nodes[self.standing_in].drawtype == "normal" then
				self.object:set_velocity({
					x = 0,
					y = 1,
					z = 0
				})
    end
    self:falling(pos)
end

AIplayer.register_NPC = function(name,def)
    minetest.register_entity("aiplayer:"..name,{
        hp_max = def.hp or 20,
        physical = true,
        weight = 5,
        collisionbox = def.collisionbox or {-0.35,-1.0,-0.35,0.35,0.8,0.35}, -- new box {-0.35,0,-0.35,0.35,1.8,0.35}
        visual = def.visual or "mesh",
        visual_size = def.visual_size or {x=1,y=1},
        mesh = def.mesh or "aiplayer_character.b3d",
        textures = {def.texture},
        colors = {},
        spritediv = {x=1, y=1},
        initial_sprite_basepos = {x=0, y=0},
        is_visible = true,
        makes_footstep_sound = true,
        automatic_rotate = 0,
        on_activate = AIplayer.on_activate,
        on_step = AIplayer.on_step
    })
    minetest.register_craftitem("aiplayer:Sam_egg", {
        description = "Sam_egg",
        inventory_image = def.texture,
        on_place = function(itemstack, user, pointed_thing)
            if pointed_thing.type=="node" then
				local pos=AIplayer.roundpos(pointed_thing.above)
				minetest.add_entity(pos, "aiplayer:Sam"):set_yaw(math.random(0,6.28))
				itemstack:take_item()
			end
            return itemstack
        end
    })
end

AIplayer.register_NPC("Sam",{
    texture = "aiplayer_Sam.png"
})