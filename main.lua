--[[
    TEREHUB - VIOLENCE DISTRICT SCRIPT (INTEGRATED VERSION)
    Game: Violence District
    Personalized for: David
]]

-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Variabel Global
local autoGenActive = false
local autoAimActive = false
local espKillerActive = false
local espSurvivorActive = false
local espGenActive = false
local noclipActive = false
local walkSpeedValue = 16
local autoPerfectActive = true -- Auto Skill Check (Area Putih)
local genConnection, aimConnection, noclipConnection
local generators, killers, survivors = {}, {}, {}
local targetKiller, targetGenerator
local aimFov, aimSmoothness, aimPriority = 120, 5, "Killer Terdekat"
local killerESPColor = Color3.new(1, 0, 0)
local survivorESPColor = Color3.new(0, 1, 0)

-- ================ INITIALIZE WINDOW (YOUR PREFERENCES) ================
local Window = WindUI:CreateWindow({
    Title = "Terehub",
    Icon = "rbxassetid://136360402262473",
    Author = "David", -- Updated to your name
    Folder = "Terehub",
    Size = UDim2.fromOffset(700, 450), -- Diatur sedikit lebih lebar agar proporsional
    MinSize = Vector2.new(560, 250),
    MaxSize = Vector2.new(950, 760),
    Transparent = true,
    Theme = "Indigo", -- Sesuai permintaan
    Resizable = true,
    SideBarWidth = 190,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = false, 
    ScrollBarEnabled = true,
})

-- ================ FUNCTIONS (SCANNER) ================
local function scanGenerators()
    local newGens = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") then
            local name = v.Name:lower()
            if name:find("generator") or name:find("gen") or v:FindFirstChild("ProximityPrompt") then
                local rootPart = v:IsA("Model") and (v.PrimaryPart or v:FindFirstChild("Part") or v:FindFirstChild("Handle")) or v
                if rootPart then table.insert(newGens, {name = v.Name, part = rootPart, model = v}) end
            end
        end
    end
    generators = newGens
end

local function scanKillers()
    local newKillers = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(v) then
            local root = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart
            if root then
                table.insert(newKillers, {
                    name = v.Name, character = v, root = root, 
                    health = v.Humanoid.Health, distance = (root.Position - player.Character.HumanoidRootPart.Position).Magnitude
                })
            end
        end
    end
    killers = newKillers
end

-- ================ TABS & SECTIONS ================

-- MAIN TAB (Automation & Movement)
local MainTab = Window:CreateTab({ Title = "Main", Icon = "zap" })
local genSection = MainTab:CreateSection("Generator & Movement")

local genBtn = genSection:AddButton({
    Title = "▶️ Start Auto Generator",
    Callback = function()
        autoGenActive = not autoGenActive
        genBtn:SetTitle(autoGenActive and "⏸️ Stop Auto Generator" or "▶️ Start Auto Generator")
    end
})

genSection:AddToggle({
    Title = "Auto Perfect Skill Check",
    Description = "Otomatis klik area putih (Generator)",
    Default = true,
    Callback = function(state) autoPerfectActive = state end
})

genSection:AddSlider({
    Title = "Speedwalk",
    Min = 16, Max = 150, Default = 16,
    Callback = function(v) walkSpeedValue = v end
})

-- AIM TAB
local AimTab = Window:CreateTab({ Title = "Auto Aim", Icon = "crosshair" })
local aimSection = AimTab:CreateSection("Killer Targeter")

aimSection:AddToggle({
    Title = "🎯 Aktifkan Auto Aim",
    Callback = function(state) autoAimActive = state end
})

aimSection:AddSlider({
    Title = "Smoothness",
    Min = 1, Max = 20, Default = 5,
    Callback = function(v) aimSmoothness = v end
})

-- ESP TAB
local ESPTab = Window:CreateTab({ Title = "Visuals", Icon = "eye" })
local espSection = ESPTab:CreateSection("ESP Settings")

espSection:AddToggle({ Title = "ESP Killer", Callback = function(s) espKillerActive = s end })
espSection:AddToggle({ Title = "ESP Survivor", Callback = function(s) espSurvivorActive = s end })
espSection:AddToggle({ Title = "ESP Generator", Callback = function(s) espGenActive = s end })

-- UTIL TAB
local UtilTab = Window:CreateTab({ Title = "Utilities", Icon = "settings" })
local utilSection = UtilTab:CreateSection("Survival Tools")

utilSection:AddToggle({
    Title = "NoClip (Tembus Tembok)",
    Callback = function(state) noclipActive = state end
})

utilSection:AddButton({
    Title = "🚪 Teleport ke Gate (Exit)",
    Callback = function()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.Name:lower():find("gate") or v.Name:lower():find("exit") then
                player.Character.HumanoidRootPart.CFrame = v:IsA("BasePart") and v.CFrame or v.PrimaryPart.CFrame
                break
            end
        end
    end
})

-- ================ LOGIC CORE (LOOP) ================

-- Logic Perfect Skill Check
task.spawn(function()
    while true do
        if autoPerfectActive then
            local pGui = player:FindFirstChild("PlayerGui")
            if pGui then
                for _, v in pairs(pGui:GetDescendants()) do
                    if v.Name == "Pointer" or v.Name == "Needle" then
                        local white = v.Parent:FindFirstChild("SuccessZone") or v.Parent:FindFirstChild("WhiteArea")
                        if white and math.abs(v.Rotation - white.Rotation) < 6 then
                            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                            task.wait(0.01)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                            task.wait(0.2)
                        end
                    end
                end
            end
        end
        task.wait()
    end
end)

-- Main Loop (Speed, NoClip, ESP, Aim)
RunService.Stepped:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = walkSpeedValue
        if noclipActive then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end

    -- ESP & Aim Refresh (Every Frame)
    if autoAimActive or espKillerActive then scanKillers() end
    
    if autoAimActive and #killers > 0 then
        local target = killers[1]
        camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, target.root.Position), 1/aimSmoothness)
    end
end)

-- Background Scanner (Slower Loop)
task.spawn(function()
    while task.wait(3) do
        scanGenerators()
        if espSurvivorActive then scanSurvivors() end
    end
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then Window:Toggle() end
end)

Window:Notify({
    Title = "Terehub Loaded",
    Content = "Indigo Theme Activated. Press RightShift to Toggle.",
    Duration = 5
})