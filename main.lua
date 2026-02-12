-- [[ terehub Admin Tester Panel ]] --
-- UI Library: OrionLib

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Membuat Window Utama
local Window = OrionLib:MakeWindow({
    Name = "terehub | Admin Tester Panel", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "terehubConfig",
    IntroText = "terehub" 
})

-- [[ TAB MOVEMENT ]] --
local MainTab = Window:MakeTab({
    Name = "Movement",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

MainTab:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 300,
    Default = 16,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end    
})

MainTab:AddSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 500,
    Default = 50,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Power",
    Callback = function(Value)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
            game.Players.LocalPlayer.Character.Humanoid.UseJumpPower = true
        end
    end    
})

local noclipActive = false
MainTab:AddToggle({
    Name = "Noclip Mode",
    Default = false,
    Callback = function(Value)
        noclipActive = Value
    end
})

-- [[ TAB VISUALS ]] --
local VisualTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

VisualTab:AddToggle({
    Name = "Player ESP",
    Default = false,
    Callback = function(Value)
        _G.ESP = Value
        if not Value then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("Highlight") then
                    p.Character.Highlight:Destroy()
                end
            end
        end
    end
})

-- [[ TAB SETTINGS ]] --
local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

SettingsTab:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end
})

SettingsTab:AddButton({
    Name = "Destroy UI",
    Callback = function()
        OrionLib:Destroy()
    end
})

-- [[ LOGIC RUNTIME ]] --
game:GetService("RunService").RenderStepped:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if noclipActive and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    if _G.ESP then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                if not p.Character:FindFirstChild("Highlight") then
                    local h = Instance.new("Highlight", p.Character)
                    h.FillColor = Color3.fromRGB(255, 0, 0)
                    h.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            end
        end
    end
end)

-- Menjalankan Orion
OrionLib:Init()