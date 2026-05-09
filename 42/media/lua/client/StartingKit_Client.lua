-- Grants every new character 10 Strength + 10 Fitness + a Police Baton.
-- v1.2: switched from LevelPerk loop to AddXP (LevelPerk was throwing on 2nd call in B42).
--       wrapped each step in pcall so one failure doesn't take down the rest.
--       new modData flag (StartingKit_v2_applied) so existing chars re-apply.

local KIT_FLAG = "StartingKit_v2_applied"
local XP_DUMP = 50000  -- comfortably above the cumulative XP needed for level 10 (~36750)

local function applyKit(player)
    local md = player:getModData()
    if md[KIT_FLAG] then
        print("[StartingKit] v2 flag set, skipping")
        return
    end
    md[KIT_FLAG] = true

    print("[StartingKit] applying to " .. tostring(player:getUsername()))

    local xp = player:getXp()
    if not xp then
        print("[StartingKit] ERROR getXp() nil")
        return
    end

    -- Strength
    if Perks and Perks.Strength then
        local pre = player:getPerkLevel(Perks.Strength)
        local ok, err = pcall(function() xp:AddXP(Perks.Strength, XP_DUMP) end)
        local post = player:getPerkLevel(Perks.Strength)
        if ok then
            print("[StartingKit] Strength " .. tostring(pre) .. " -> " .. tostring(post))
        else
            print("[StartingKit] ERROR Strength AddXP: " .. tostring(err))
        end
    else
        print("[StartingKit] ERROR Perks.Strength is nil")
    end

    -- Fitness
    if Perks and Perks.Fitness then
        local pre = player:getPerkLevel(Perks.Fitness)
        local ok, err = pcall(function() xp:AddXP(Perks.Fitness, XP_DUMP) end)
        local post = player:getPerkLevel(Perks.Fitness)
        if ok then
            print("[StartingKit] Fitness " .. tostring(pre) .. " -> " .. tostring(post))
        else
            print("[StartingKit] ERROR Fitness AddXP: " .. tostring(err))
        end
    else
        print("[StartingKit] ERROR Perks.Fitness is nil")
    end

    -- Baton
    local inv = player:getInventory()
    if inv then
        local count = inv:getItemCount("Base.Baton")
        if count == 0 then
            local ok, err = pcall(function() inv:AddItem("Base.Baton") end)
            if ok then
                print("[StartingKit] added Base.Baton")
            else
                print("[StartingKit] ERROR Baton AddItem: " .. tostring(err))
            end
        else
            print("[StartingKit] baton already present (count=" .. tostring(count) .. ")")
        end
    else
        print("[StartingKit] ERROR getInventory() nil")
    end
end

local function giveStartingKit(playerNum, player)
    if not player then return end
    if not player:isLocalPlayer() then return end
    local ok, err = pcall(applyKit, player)
    if not ok then print("[StartingKit] FATAL: " .. tostring(err)) end
end

Events.OnCreatePlayer.Add(giveStartingKit)
print("[StartingKit] hook registered (client-side, v1.2)")
