require("util")  -- core.lualib

local function player_init()
    return {
        last_tick = 0,
        last_position = {x=0, y=0}
    }
end

script.on_init(function()
    global.players = {}
    
    for index, _ in pairs(game.players) do
        global.players[index] = player_init()
    end
end)

script.on_event(defines.events.on_player_created, function(event)
    global.players[event.player_index] = player_init()
end)

script.on_event(defines.events.on_player_removed, function(event)
    global.players[event.player_index] = nil
end)


script.on_event(defines.events.on_entity_damaged, function(event)
    local entity = event.entity
    
    if entity.type == "car" and event.damage_type.name == "impact" then
        local player = global.players[entity.get_driver().player.index]
        local position = entity.position
        
        local tick = game.tick
        if (tick - player.last_tick) > 60 and util.distance(player.last_position, position) > 0.01 then
            entity.surface.play_sound{path="cc_expletives", position=position}
            player.last_tick = tick
        end
        player.last_position = position
    end
end)