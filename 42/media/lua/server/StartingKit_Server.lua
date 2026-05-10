-- v1.7 server-side: switch from AddXP to LevelPerk loop for Body skills.
-- v1.6 server applied AddXP(perk, 999999) but the level didn't change in-game
-- (Strength 5 -> 5). B42 Body skills (Strength/Fitness) don't level reliably from
-- AddXP alone -- the admin RCON `addxp` command works because it has special
-- handling. LevelPerk is what actually increments the level integer; calling it
-- in a loop until target reached is the canonical pattern for force-leveling.

local SERVER_FLAG = "StartingKit_v7_serverApplied"
local TARGET_LEVEL = 10
local MAX_ITERATIONS = 15
local BATON_ID = "Base.Nightstick"

local function bumpPerk(player, perk, perkName)
    if not perk then
        print("[StartingKit-Server] ERROR " .. perkName .. " perk is nil")
        return
    end
    local pre = player:getPerkLevel(perk)
    local current = pre
    local iterations = 0
    while current < TARGET_LEVEL and iterations < MAX_ITERATIONS do
        local ok, err = pcall(function() player:LevelPerk(perk) end)
        if not ok then
            print("[StartingKit-Server] ERROR " .. perkName .. " LevelPerk: " .. tostring(err))
            break
        end
        local newLvl = player:getPerkLevel(perk)
        if newLvl == current then
            print("[StartingKit-Server] WARN " .. perkName .. " LevelPerk did not advance from " .. tostring(current) .. " - aborting")
            break
        end
        current = newLvl
        iterations = iterations + 1
    end
    print("[StartingKit-Server] " .. perkName .. " " .. tostring(pre) .. " -> " .. tostring(current) .. " (iters=" .. tostring(iterations) .. ")")
end

local function applyKit(player)
    if not player then return end

    local md = player:getModData()
    if md[SERVER_FLAG] then
        print("[StartingKit-Server] already applied to " .. tostring(player:getUsername()) .. ", skipping")
        return
    end
    md[SERVER_FLAG] = true

    print("[StartingKit-Server] applying to " .. tostring(player:getUsername()))

    if Perks then
        bumpPerk(player, Perks.Strength, "Strength")
        bumpPerk(player, Perks.Fitness, "Fitness")
    else
        print("[StartingKit-Server] ERROR Perks table is nil")
    end

    local inv = player:getInventory()
    if inv and inv:getItemCount(BATON_ID) == 0 then
        local ok, err = pcall(function() inv:AddItem(BATON_ID) end)
        if ok then
            print("[StartingKit-Server] added " .. BATON_ID)
        else
            print("[StartingKit-Server] ERROR Baton: " .. tostring(err))
        end
    else
        print("[StartingKit-Server] baton already present, skipping")
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
print("[StartingKit-Server] hook registered (v1.7)")
