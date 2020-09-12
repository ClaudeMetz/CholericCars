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


function entity_damaged(event)
    local entity = event.entity
    local position = entity.position
    local driver = entity.get_driver()
    local volume = settings.global["cc_volume"].value / 100

    if driver == nil then  -- Rate limiting is not needed on driverless cars anyways
        entity.surface.play_sound{path="cc_expletives", position=position, volume_modifier=volume}
    else
        local player = global.players[driver.player.index]
        local tick = game.tick

        if (tick - player.last_tick) > 60 and util.distance(player.last_position, position) > 0.01 then
            entity.surface.play_sound{path="cc_expletives", position=position, volume_modifier=volume}
            player.last_tick = tick
        end

        player.last_position = position
    end
end

local on_entity_damaged_filter = {{filter="type", type="car"}, {filter="damage-type", type="impact", mode="and"}}
script.on_event(defines.events.on_entity_damaged, entity_damaged, on_entity_damaged_filter)