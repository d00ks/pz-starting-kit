-- v1.5 server-side: authoritative kit application.
-- Client requests via sendClientCommand("StartingKit", "applyKit", {}).
-- We apply XP + items to the player on the server side; the server then syncs to client.
-- modData flag (StartingKit_v5_serverApplied) persists in players.db, so each character
-- only gets the kit once even across reconnections. Death + reroll = new char = fresh apply.

local SERVER_FLAG = "StartingKit_v6_serverApplied"
local XP_DUMP = 999999
local BATON_ID = "Base.Nightstick"

local function applyKit(player)
    if not player then return end

    local md = player:getModData()
    if md[SERVER_FLAG] then
        print("[StartingKit-Server] already applied to " .. tostring(player:getUsername()) .. ", skipping")
        return
    end
    md[SERVER_FLAG] = true

    print("[StartingKit-Server] applying to " .. tostring(player:getUsername()))

    local xp = player:getXp()
    if xp then
        if Perks and Perks.Strength then
            local pre = player:getPerkLevel(Perks.Strength)
            local ok, err = pcall(function() xp:AddXP(Perks.Strength, XP_DUMP) end)
            local post = player:getPerkLevel(Perks.Strength)
            if ok then
                print("[StartingKit-Server] Strength " .. tostring(pre) .. " -> " .. tostring(post))
            else
                print("[StartingKit-Server] ERROR Strength: " .. tostring(err))
            end
        end
        if Perks and Perks.Fitness then
            local pre = player:getPerkLevel(Perks.Fitness)
            local ok, err = pcall(function() xp:AddXP(Perks.Fitness, XP_DUMP) end)
            local post = player:getPerkLevel(Perks.Fitness)
            if ok then
                print("[StartingKit-Server] Fitness " .. tostring(pre) .. " -> " .. tostring(post))
            else
                print("[StartingKit-Server] ERROR Fitness: " .. tostring(err))
            end
        end
    else
        print("[StartingKit-Server] ERROR getXp() nil")
    end

    local inv = player:getInventory()
    if inv and inv:getItemCount(BATON_ID) == 0 then
        local ok, err = pcall(function() inv:AddItem(BATON_ID) end)
        if ok then
            print("[StartingKit-Server] added " .. BATON_ID)
        else
            print("[StartingKit-Server] ERROR Baton: " .. tostring(err))
        end
    end
end

local function onClientCommand(module, command, player, args)
    if module ~= "StartingKit" then return end
    print("[StartingKit-Server] received command=" .. tostring(command) ..
          " player=" .. tostring(player and player:getUsername() or "nil"))
    if command ~= "applyKit" then return end
    local ok, err = pcall(applyKit, player)
    if not ok then print("[StartingKit-Server] FATAL: " .. tostring(err)) end
end

Events.OnClientCommand.Add(onClientCommand)
print("[StartingKit-Server] hook registered (v1.6)")
