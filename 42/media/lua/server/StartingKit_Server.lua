-- Grants every new character 10 Strength + 10 Fitness + a Police Baton.
-- Server-side, runs once per character (modData flag).

local function giveStartingKit(playerNum, player)
    if not player then return end
    local md = player:getModData()
    if md.StartingKit_v1_applied then return end
    md.StartingKit_v1_applied = true

    local strLvl = player:getPerkLevel(Perks.Strength)
    for i = strLvl, 9 do player:LevelPerk(Perks.Strength) end
    local fitLvl = player:getPerkLevel(Perks.Fitness)
    for i = fitLvl, 9 do player:LevelPerk(Perks.Fitness) end

    local inv = player:getInventory()
    if inv and inv:getItemCount("Base.Baton") == 0 then
        inv:AddItem("Base.Baton")
    end
end
Events.OnCreatePlayer.Add(giveStartingKit)
