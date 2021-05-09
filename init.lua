local MODNAME = minetest.get_current_modname()

-- Setting defaults
local defaults = {
    distance = 32,
    show_distance = false,
    global_privs = "shout",
    player_config = false,
}

-- Get setting or default
local function setting(key)
    local s, d = minetest.settings:get(MODNAME .. "." .. key), defaults[key]
    -- "Cast" the value because settings:get() always returns a string
    return ({string = tostring, number = tonumber, boolean = minetest.is_yes})[type(d)](s or d)
end

-- Get player-configured distance
local function player_config_dist(name)
    return minetest.get_player_by_name(name):get_meta():get_int(MODNAME .. ":chat_distance")
end

-- Intercept chat messages and send to players in range (including self)
minetest.register_on_chat_message(function(name, msg)
    local pos = minetest.get_player_by_name(name):get_pos()

    for _, player in ipairs(minetest.get_connected_players()) do
        local dist = vector.distance(pos, player:get_pos())
        local config_dist = player_config_dist(name)
        -- If per-player distance is enabled and the player has a configured value, use it, or use the default
        local max_dist = (setting("player_config") and config_dist > 0 and config_dist) or tonumber(setting("distance"))

        if dist <= max_dist then
            -- Append distance from player if enabled
            local show_dist = setting("show_distance") and ("(%sm) "):format(math.floor(dist)) or ""
            minetest.chat_send_player(player:get_player_name(), ("%s<%s> %s"):format(show_dist, name, msg))
        end
    end

    return true
end)

-- Global chat
minetest.register_chatcommand("global", {
    func = function(name, msg)
        -- Require these privileges if defined
        local can_use, missing = minetest.check_player_privs(name, unpack(setting("global_privs"):split("[, ]", false, -1, true)))
        if can_use then
            if msg ~= "" then
                minetest.chat_send_all(("(Global) <%s> %s"):format(name, msg))
            else
                return false, "Cannot send empty message."
            end
        else
            return false, "You are missing the required privs: " .. table.concat(missing, ", ")
        end
    end,
})

minetest.register_chatcommand("chat_distance", {
    func = function(name, param)
        local res, notice

        if param == "" then -- Get current distance
            local config_dist = player_config_dist(name)
            res, notice = true, "Chat distance is currently " .. (config_dist > 0 and config_dist or "not set") .. "."
        elseif tonumber(param) and tonumber(param) > 0 then -- Set distance if valid
            minetest.get_player_by_name(name):get_meta():set_int(MODNAME .. ":chat_distance", tonumber(param))
            res, notice = true, "Chat distance set to " .. param .. "."
        else -- Bad input
            res, notice = false, "Chat distance must be a number greater than 0."
        end

        return res, notice .. (setting("player_config") and "" or " Per-player distance is not enabled by the server.")
    end,
})
