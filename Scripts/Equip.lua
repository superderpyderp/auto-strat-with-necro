local TDS = {}
shared.TDS_Table = TDS

print("[TDS] Script loaded")

local function identify_game_state()
    print("[TDS] Identifying game state")

    local players = game:GetService("Players")
    local temp_player = players.LocalPlayer or players.PlayerAdded:Wait()
    local temp_gui = temp_player:WaitForChild("PlayerGui")

    while true do
        if temp_gui:FindFirstChild("LobbyGui") then
            print("[TDS] Game state detected: LOBBY")
            return "LOBBY"
        elseif temp_gui:FindFirstChild("GameGui") then
            print("[TDS] Game state detected: GAME")
            return "GAME"
        end
        task.wait(1)
    end
end

local game_state = identify_game_state()
print("[TDS] Cached game_state =", game_state)

function TDS:Addons()
    print("[TDS] Addons() called")

    if game_state ~= "GAME" then
        warn("[TDS] Addons aborted: not in GAME state")
        return false
    end

    local url = "https://api.junkie-development.de/api/v1/luascripts/public/57fe397f76043ce06afad24f07528c9f93e97730930242f57134d0b60a2d250b/download"
    print("[TDS] Fetching addons:", url)

    local success, code = pcall(game.HttpGet, game, url)
    if not success then
        warn("[TDS] HttpGet failed")
        return false
    end

    print("[TDS] Addon code received, executing")
    loadstring(code)()

    print("[TDS] Waiting for TDS.Equip")
    local timeout = os.clock() + 10
    while not TDS.Equip do
        if os.clock() > timeout then
            warn("[TDS] Equip function timeout")
            return false
        end
        task.wait(0.1)
    end

    print("[TDS] Equip function detected")
    return true
end

local addons_ok = TDS:Addons()
print("[TDS] Addons result =", addons_ok)

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

print("[TDS] Creating GUI")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EquipTowerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui
frame.Active = true
frame.Draggable = true

local uiCornerFrame = Instance.new("UICorner")
uiCornerFrame.CornerRadius = UDim.new(0, 4)
uiCornerFrame.Parent = frame

local title = Instance.new("TextLabel")
title.Text = "Tower Equipper"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(230, 230, 230)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

local textbox = Instance.new("TextBox")
textbox.PlaceholderText = "Enter tower name..."
textbox.Size = UDim2.new(1, -20, 0, 30)
textbox.Position = UDim2.new(0, 10, 0, 40)
textbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
textbox.TextColor3 = Color3.fromRGB(230, 230, 230)
textbox.Font = Enum.Font.SourceSans
textbox.TextSize = 18
textbox.ClearTextOnFocus = true
textbox.TextEditable = true
textbox.Parent = frame

local uiCornerTextbox = Instance.new("UICorner")
uiCornerTextbox.CornerRadius = UDim.new(0, 4)
uiCornerTextbox.Parent = textbox

textbox.FocusLost:Connect(function(enterPressed)
    print("[TDS] Textbox focus lost. Enter =", enterPressed)

    if enterPressed then
        local towerName = textbox.Text
        print("[TDS] Tower input =", towerName)

        if towerName ~= "" and TDS.Equip then
            print("[TDS] Calling Equip:", towerName)
            TDS:Equip(towerName)
            textbox.Text = ""
        else
            warn("[TDS] Equip skipped. Invalid name or Equip missing")
        end
    end
end)

print("[TDS] GUI ready")

return TDS
