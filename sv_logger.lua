-- =============================================
--  Logger
-- =============================================

-- Micro optimization & variables
local sub = string.sub
local tonumber = tonumber
local tostring = tostring

-- An internal server handler, this is NOT exposed to the client
local function getLogPlayerName(src)
    if type(src) == 'number' then
        local name = sub(GetPlayerName(src) or "unknown", 1, 75)
        return '[#' .. src .. '] ' .. name
    else
        return '[??] ' .. (src or "unknown")
    end
end

--- function logger
--- Sends logs through fd3 to the server & displays the logs on the panel.
---@param src number the source of the player who did the action, or 'tx' if internal
---@param type string the action type
---@param data table|nil the event data
local function logger(src, type, data)
    if data then
        if GetResourceState('d_lib') == 'started' then
            exports['d_lib']:SendWebhook({
                webhook = Config.txAdminWebhook,
                anticheat = false,
                color = 65280,
                title = 'Tx Event Logs - '..tostring(data.action),
                desc = tostring(data.message),
                source = src
            })
        else
            sendToDiscord(tostring(data.action), "Author: **" .. getLogPlayerName(src) .. "**\nMessage: **" .. tostring(data.message) .. "", 65280)
        end
    end
end

AddEventHandler('txsv:logger:menuEvent', function(source, action, allowed, data)
    if not allowed then return end
    local message

    --SELF menu options
    if action == 'playerModeChanged' then
        if data == 'godmode' then
            message = "enabled god mode"
        elseif data == 'noclip' then
            message = "enabled noclip"
        elseif data == 'superjump' then
            message = "enabled super jump"
        elseif data == 'none' then
            message = "became mortal (standard mode)"
        else
            message = "changed playermode to unknown"
        end
    elseif action == 'teleportWaypoint' then
        message = "teleported to a waypoint"
    elseif action == 'teleportCoords' then
        if type(data) ~= 'table' then return end
        local x = data.x
        local y = data.y
        local z = data.z
        message = ("teleported to coordinates (x=%.3f, y=%0.3f, z=%0.3f)"):format(x or 0.0, y or 0.0, z or 0.0)
    elseif action == 'spawnVehicle' then
        if type(data) ~= 'string' then return end
        message = "spawned a vehicle (model: " .. data .. ")"
    elseif action == 'deleteVehicle' then
        message = "deleted a vehicle"
    elseif action == 'vehicleRepair' then
        message = "repaired their vehicle"
    elseif action == 'vehicleBoost' then
        message = "boosted their vehicle"
    elseif action == 'healSelf' then
        message = "healed themself"
    elseif action == 'healAll' then
        message = "healed all players!"
    elseif action == 'announcement' then
        if type(data) ~= 'string' then return end
        message = "made a server-wide announcement: " .. data
    elseif action == 'clearArea' then
        if type(data) ~= 'number' then return end
        message = "cleared an area with " .. data .. "m radius"

        --INTERACTION modal options
    elseif action == 'spectatePlayer' then
        message = 'started spectating player ' .. getLogPlayerName(data)
    elseif action == 'freezePlayer' then
        message = 'toggled freeze on player ' .. getLogPlayerName(data)
    elseif action == 'teleportPlayer' then
        if type(data) ~= 'table' then return end
        local playerName = getLogPlayerName(data.target)
        local x = data.x or 0.0
        local y = data.y or 0.0
        local z = data.z or 0.0
        message = ("teleported to player %s (x=%.3f, y=%.3f, z=%.3f)"):format(playerName, x, y, z)
    elseif action == 'healPlayer' then
        message = "healed player " .. getLogPlayerName(data)
    elseif action == 'summonPlayer' then
        message = "summoned player " .. getLogPlayerName(data)

        --TROLL modal options
    elseif action == 'drunkEffect' then
        message = "triggered drunk effect on " .. getLogPlayerName(data)
    elseif action == 'setOnFire' then
        message = "set " .. getLogPlayerName(data) .. " on fire"
    elseif action == 'wildAttack' then
        message = "triggered wild attack on " .. getLogPlayerName(data)
    elseif action == 'showPlayerIDs' then
        if type(data) ~= 'boolean' then return end
        if data then
            message = "turned show player IDs on"
        else
            message = "turned show player IDs off"
        end

        --In case of unknown event
    else
        logger(source, 'DebugMessage', "unknown menu event " .. action)
        return
    end

    logger(source, 'MenuEvent', {
        action = action,
        message = message
    })
end)
