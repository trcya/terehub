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

-- [[ MOVEMENT FEATURES ]] --
MainTab:Slider({
    Title = "WalkSpeed",
    Step = 1,
    Value = { Min = 16, Max = 500, Default = 16 },
    Callback = function(v)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
})

MainTab:Slider({
    Title = "JumpPower",
    Step = 1,
    Value = { Min = 50, Max = 1000, Default = 50 },
    Callback = function(v)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = v
    end
})

local infJump = false
MainTab:Toggle({
    Title = "Infinite Jump",
    Callback = function(state) infJump = state end
})

-- [[ FLY & NOCLIP ]] --
local flyActive = false
local flySpeed = 50
WorldTab:Toggle({
    Title = "Fly (Camera Direction)",
    Callback = function(state)
        flyActive = state
        if state then
            local char = game.Players.LocalPlayer.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local bv = Instance.new("BodyVelocity", hrp)
            bv.Name = "TereFly"
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

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJump then 
        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") 
    end
end)

Window:Notify({ Title = "Terehub", Content = "Script Loaded Successfully!", Duration = 5 })