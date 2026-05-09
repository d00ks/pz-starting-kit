-- Grants every new character 10 Strength + 10 Fitness + a Police Baton.
-- Client-side hook on OnCreatePlayer (fires reliably for the local player on every connection).
-- modData flag makes it once-per-character; loop bounds make it idempotent if the flag is missing.

local function giveStartingKit(playerNum, player)
    if not player then return end
    if not player:isLocalPlayer() then return end

    local md = player:getModData()
    if md.StartingKit_v1_applied then
        print("[StartingKit] kit already applied to " .. tostring(player:getUsername()) .. ", skipping")
        return
    end
    md.StartingKit_v1_applied = true

    print("[StartingKit] applying kit to " .. tostring(player:getUsername()))

    local strLvl = player:getPerkLevel(Perks.Strength)
    print("[StartingKit] str level pre = " .. tostring(strLvl))
    for i = strLvl, 9 do player:LevelPerk(Perks.Strength) end
    print("[StartingKit] str level post = " .. tostring(player:getPerkLevel(Perks.Strength)))

    local fitLvl = player:getPerkLevel(Perks.Fitness)
    print("[StartingKit] fit level pre = " .. tostring(fitLvl))
    for i = fitLvl, 9 do player:LevelPerk(Perks.Fitness) end
    print("[StartingKit] fit level post = " .. tostring(player:getPerkLevel(Perks.Fitness)))

    local inv = player:getInventory()
    if inv and inv:getItemCount("Base.Baton") == 0 then
        inv:AddItem("Base.Baton")
        print("[StartingKit] added Base.Baton")
    else
        print("[StartingKit] baton already present or no inventory")
    end
end

Events.OnCreatePlayer.Add(giveStartingKit)
print("[StartingKit] hook registered (client-side)")
