local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "Terehub",
    Icon = "rbxassetid://136360402262473",
    Author = "Beta Tester",
    Folder = "Terehub",
    Size = UDim2.fromOffset(600, 360),
    MinSize = Vector2.new(560, 250),
    MaxSize = Vector2.new(950, 760),
    Transparent = true,
    Theme = "Indigo",
    Resizable = true,
    SideBarWidth = 190,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = false,  -- Ubah ke false biar bisa search fitur
    ScrollBarEnabled = true,
})

-- [[ TABS ]] --
local MainTab = Window:Tab({ Title = "Movement", Icon = "walking" })
local WorldTab = Window:Tab({ Title = "Exploits", Icon = "zap" })
local PlayerTab = Window:Tab({ Title = "Players", Icon = "users" })

-- [[ MOVEMENT: ANALOG FLY ]] --
local flyActive = false
local flySpeed = 50
MainTab:Toggle({
    Title = "Analog Fly",
    Callback = function(state)
        flyActive = state
        local char = game.Players.LocalPlayer.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if state then
            local bv = Instance.new("BodyVelocity", hrp)
            bv.Name = "TereFly"
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            task.spawn(function()
                while flyActive do
                    -- Mengikuti arah analog/kamera
                    bv.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * flySpeed
                    task.wait()
                end
                bv:Destroy()
            end)
        end
    end
})

MainTab:Slider({
    Title = "Fly Speed",
    Value = { Min = 10, Max = 300, Default = 50 },
    Callback = function(v) flySpeed = v end
})

-- [[ EXPLOITS: ESP PLAYER ]] --
local espActive = false
WorldTab:Toggle({
    Title = "ESP Player (Highlight)",
    Callback = function(state)
        espActive = state
        if not state then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("Highlight") then
                    p.Character.Highlight:Destroy()
                end
            end
        end
    end
})

-- [[ PLAYERS: TELEPORT ]] --
local selectedPlayer = ""
local playerList = {}

for _, p in pairs(game.Players:GetPlayers()) do
    if p ~= game.Players.LocalPlayer then table.insert(playerList, p.Name) end
end

PlayerTab:Dropdown({
    Title = "Select Player",
    Multi = false,
    AllowNone = false,
    Options = playerList,
    Callback = function(v) selectedPlayer = v end
})

PlayerTab:Button({
    Title = "Teleport to Player",
    Callback = function()
        local target = game.Players:FindFirstChild(selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end
})

-- [[ RUNTIME LOGIC ]] --
game:GetService("RunService").RenderStepped:Connect(function()
    if espActive then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                if not p.Character:FindFirstChild("Highlight") then
                    local h = Instance.new("Highlight", p.Character)
                    h.FillColor = Color3.fromRGB(0, 255, 136)
                end
            end
        end
    end
end)

Window:Notify({ Title = "Terehub", Content = "Fitur Analog & Teleport Aktif!", Duration = 5 })