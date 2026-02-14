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
    HideSearchBar = false, 
    ScrollBarEnabled = true,
})

-- [[ TABS ]] --
local MainTab = Window:Tab({ Title = "Movement", Icon = "walking" })
local VisualTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local PlayerTab = Window:Tab({ Title = "Players", Icon = "users" })

-- [[ MOVEMENT: SPEED, JUMP, INF JUMP ]] --
MainTab:Slider({
    Title = "Speedwalk",
    Value = { Min = 16, Max = 500, Default = 16 },
    Callback = function(v) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end
})

MainTab:Slider({
    Title = "Jump High",
    Value = { Min = 50, Max = 1000, Default = 50 },
    Callback = function(v) game.Players.LocalPlayer.Character.Humanoid.JumpPower = v end
})

local infJump = false
MainTab:Toggle({
    Title = "Infinity Jump",
    Callback = function(state) infJump = state end
})

-- [[ FLY: CAMERA & ANALOG SPEED ]] --
local flyActive = false
local flySpeed = 50
MainTab:Toggle({
    Title = "Camera Fly",
    Callback = function(state)
        flyActive = state
        local hrp = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        if state then
            local bv = Instance.new("BodyVelocity", hrp)
            bv.Name = "TereFlyV5"
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
    Value = { Min = 10, Max = 500, Default = 50 },
    Callback = function(v) flySpeed = v end
})

-- [[ VISUALS: ESP NAME & HIGHLIGHT ]] --
local espActive = false
VisualTab:Toggle({
    Title = "ESP (Name + Highlight)",
    Callback = function(state) espActive = state end
})

-- [[ PLAYERS: TELEPORT FIX ]] --
local selectedPlayer = ""
local function getPlayers()
    local tbl = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then table.insert(tbl, p.Name) end
    end
    return tbl
end

local PlayerDrop = PlayerTab:Dropdown({
    Title = "Select Player",
    Options = getPlayers(),
    Callback = function(v) selectedPlayer = v end
})

-- Tombol Refresh Paksa
PlayerTab:Button({
    Title = "Fix Player List",
    Callback = function()
        PlayerDrop:SetOptions(getPlayers())
        Window:Notify({Title = "System", Content = "List Updated!"})
    end
})

PlayerTab:Button({
    Title = "Teleport Now",
    Callback = function()
        local target = game.Players:FindFirstChild(selectedPlayer)
        if target and target.Character then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end
})

-- [[ LOGIC RUNTIME ]] --
game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJump then game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if espActive then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                -- Highlight
                if not p.Character:FindFirstChild("Highlight") then
                    Instance.new("Highlight", p.Character)
                end
                -- Name Tag (Billboard)
                if not p.Character:FindFirstChild("TereName") then
                    local bb = Instance.new("BillboardGui", p.Character)
                    bb.Name = "TereName"
                    bb.AlwaysOnTop = true
                    bb.Size = UDim2.new(0, 200, 0, 50)
                    bb.ExtentsOffset = Vector3.new(0, 3, 0)
                    local lbl = Instance.new("TextLabel", bb)
                    lbl.Text = p.Name
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3 = Color3.new(1, 1, 1)
                    lbl.TextStrokeTransparency = 0
                end
            end
        end
    end
end)

Window:Notify({ Title = "Terehub Loaded", Content = "Tekan Fix Player List jika Dropdown Kosong", Duration = 5 })