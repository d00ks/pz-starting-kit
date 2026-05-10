-- v1.6: switch from OnCreatePlayer to OnGameStart + delayed retry.
--       OnCreatePlayer fires on a placeholder "Bob" IsoPlayer during the loading
--       transition before the real character has spawned server-side, so the
--       sendClientCommand reaches the server before there's a real player to associate.
--       OnGameStart fires after the world has loaded and getPlayer() returns the real
--       authoritative player object. Add a small Events.OnTick guard to wait for the
--       player to be fully ready before sending.
-- v1.5: switched to server-authoritative pattern (client requests, server applies).
-- v1.4: fix item ID Base.Baton -> Base.Nightstick.
-- v1.3: bump XP_DUMP to 999999 (B42 body skills need ~450k for L10).
-- v1.2: switched from LevelPerk loop to AddXP, wrapped each step in pcall.

local CLIENT_FLAG = "StartingKit_v6_clientRequested"

local function trySend()
    local player = getPlayer()
    if not player then return false end
    local username = player:getUsername()
    if not username or username == "" or username == "Bob" then
        -- placeholder character during loading; wait
        return false
    end
    local md = player:getModData()
    if md[CLIENT_FLAG] then return true end
    md[CLIENT_FLAG] = true
    sendClientCommand(player, "StartingKit", "applyKit", {})
    print("[StartingKit] requested kit from server for " .. tostring(username))
    return true
end

-- OnGameStart fires once when the local client is fully in-game (after world load).
-- We defer one tick to give the player object time to fully resolve.
local function onGameStart()
    local attempts = 0
    local function tick()
        attempts = attempts + 1
        if trySend() or attempts > 60 then
            Events.OnTick.Remove(tick)
        end
    end
    Events.OnTick.Add(tick)
end

Events.OnGameStart.Add(onGameStart)
print("[StartingKit] client hook registered (v1.6) on OnGameStart")
