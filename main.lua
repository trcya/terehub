-- [[ terehub | WindUI Edition ]] --
local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/main/windui"))()

local Window = WindUI:CreateWindow({
    Title = "terehub | Admin Tester",
    Icon = "rbxassetid://4483362458",
    Author = "David",
    Folder = "terehub_configs"
})

-- [[ TABS ]] --
local MainTab = Window:CreateTab("Movement", "walking")
local VisualTab = Window:CreateTab("Visuals", "eye")
local WorldTab = Window:CreateTab("Exploits", "zap")

-- [[ MOVEMENT SECTION ]] --
MainTab:AddSlider("WalkSpeed", 16, 500, 16, function(v)
    if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end)

MainTab:AddToggle("Infinite Jump", false, function(state)
    _G.InfJump = state
end)

-- [[ VISUALS SECTION ]] --
local espActive = false
VisualTab:AddToggle("Player ESP (Chams)", false, function(state)
    espActive = state
    if not state then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Highlight") then
                p.Character.Highlight:Destroy()
            end
        end
    end
end)

VisualTab:AddButton("Fullbright", function()
    game.Lighting.Brightness = 2
    game.Lighting.ClockTime = 14
    game.Lighting.GlobalShadows = false
end)

-- [[ EXPLOITS SECTION ]] --
WorldTab:AddToggle("Noclip (Tembus Tembok)", false, function(state)
    _G.Noclip = state
end)

WorldTab:AddButton("Click TP Tool", function()
    local mouse = game.Players.LocalPlayer:GetMouse()
    local tool = Instance.new("Tool")
    tool.Name = "terehub TP"
    tool.RequiresHandle = false
    tool.Activated:Connect(function()
        game.Players.LocalPlayer.Character:MoveTo(mouse.Hit.p + Vector3.new(0, 3, 0))
    end)
    tool.Parent = game.Players.LocalPlayer.Backpack
end)

-- [[ LOGIC RUNTIME ]] --
game:GetService("RunService").Stepped:Connect(function()
    if _G.Noclip and game.Players.LocalPlayer.Character then
        for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if espActive then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character and not p.Character:FindFirstChild("Highlight") then
                local h = Instance.new("Highlight", p.Character)
                h.FillColor = Color3.fromRGB(80, 120, 255)
            end
        end
    end
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfJump then 
        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") 
    end
end)

Window:Notify("terehub Loaded", "Selamat testing, David!", "success")