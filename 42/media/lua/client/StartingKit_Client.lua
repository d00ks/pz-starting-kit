-- v1.5: switched to server-authoritative pattern. Client-side AddXP for body skills
--       (Strength/Fitness) gets reverted by the server in B42 MP -- the server is
--       authoritative. Now the client just requests the kit via sendClientCommand and
--       the server handler does the real work.
-- v1.4: fix item ID Base.Baton -> Base.Nightstick (vanilla police baton).
-- v1.3: bump XP_DUMP to 999999 (B42 body skills need ~450k for L10).
-- v1.2: switched from LevelPerk loop to AddXP, wrapped each step in pcall.

local CLIENT_FLAG = "StartingKit_v5_clientRequested"

local function requestKit(playerNum, player)
    if not player or not player:isLocalPlayer() then return end
    local md = player:getModData()
    if md[CLIENT_FLAG] then return end
    md[CLIENT_FLAG] = true
    sendClientCommand(player, "StartingKit", "applyKit", {})
    print("[StartingKit] requested kit from server for " .. tostring(player:getUsername()))
end

Events.OnCreatePlayer.Add(requestKit)
print("[StartingKit] client hook registered (v1.5)")
