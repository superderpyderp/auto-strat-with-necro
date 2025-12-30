local TDS = {}
shared.TDS_Table = TDS

local function identify_game_state()
    local players = game:GetService("Players")
    local temp_player = players.LocalPlayer or players.PlayerAdded:Wait()
    local temp_gui = temp_player:WaitForChild("PlayerGui")
    
    while true do
        if temp_gui:FindFirstChild("LobbyGui") then
            return "LOBBY"
        elseif temp_gui:FindFirstChild("GameGui") then
            return "GAME"
        end
        task.wait(1)
    end
end

local game_state = identify_game_state()

function TDS:Addons()
    if game_state ~= "GAME" then
        return false
    end
    local url = "https://api.junkie-development.de/api/v1/luascripts/public/57fe397f76043ce06afad24f07528c9f93e97730930242f57134d0b60a2d250b/download"
    local success, code = pcall(game.HttpGet, game, url)

    if not success then
        return false
    end

    loadstring(code)()

    while not TDS.Equip do
        task.wait(0.1)
    end

    return true
end

--Example usage: TDS:Equip("TowerName")