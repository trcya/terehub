-- [[ terehub | WindUI Fixed & Powered ]] --
-- Load langsung dari GitHub Source (Anti-Paused/404)
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/Source.lua"))()

local Window = WindUI:CreateWindow({
    Title = "terehub | Admin Tester",
    Icon = "rbxassetid://4483362458",
    Author = "David",
    Folder = "terehub_configs",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200
})

-- [[ TABS ]] --
local MainTab = Window:Tab({ Title = "Movement", Icon = "walking" })
local VisualTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local WorldTab = Window:Tab({ Title = "Exploits", Icon = "zap" })

-- [[ MOVEMENT ]] --
local flyActive = false
local flySpeed = 50
local infJump = false

MainTab:Toggle({
    Title = "Analog Fly (Camera)",
    Callback = function(state)
        flyActive = state
        if state then
            local char = game.Players.LocalPlayer.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local bv = Instance.new("BodyVelocity", hrp)
            bv.Name = "terehub_Fly"
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            task.spawn(function()
                while flyActive do
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
    Step = 1,
    Value = { Min = 10, Max = 300, Default = 50 },
    Callback = function(v) flySpeed = v end
})

MainTab:Toggle({
    Title = "Infinite Jump",
    Callback = function(state) infJump = state end
})

-- [[ VISUALS ]] --
local espActive = false
VisualTab:Toggle({
    Title = "Player ESP",
    Callback = function(state) espActive = state end
})

VisualTab:Button({
    Title = "Fullbright",
    Callback = function()
        game.Lighting.Brightness = 2
        game.Lighting.ClockTime = 14
        game.Lighting.GlobalShadows = false
    end
})

-- [[ EXPLOITS ]] --
local noclipActive = false
WorldTab:Toggle({
    Title = "Noclip (Tembus Tembok)",
    Callback = function(state) noclipActive = state end
})

-- [[ RUNTIME LOGIC ]] --
game:GetService("RunService").Stepped:Connect(function()
    if noclipActive and game.Players.LocalPlayer.Character then
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
                h.FillColor = Color3.fromRGB(0, 255, 136)
            end
        end
    end
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJump then 
        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") 
    end
end)