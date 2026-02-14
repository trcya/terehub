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
local CombatTab = Window:Tab({ Title = "Combat", Icon = "crosshair" })
local VisualTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local PlayerTab = Window:Tab({ Title = "Players", Icon = "users" })
local ServerTab = Window:Tab({ Title = "Server", Icon = "server" })

-- [[ MOVEMENT: ANALOG FLY FIX ]] --
local flyActive = false
local flySpeed = 50
MainTab:Toggle({
    Title = "True Analog Fly (Move Dir)",
    Callback = function(state)
        flyActive = state
        local char = game.Players.LocalPlayer.Character
        local hum = char:WaitForChild("Humanoid")
        local hrp = char:WaitForChild("HumanoidRootPart")
        
        if state then
            local bv = Instance.new("BodyVelocity", hrp)
            bv.Name = "TereFly"
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            task.spawn(function()
                while flyActive do
                    -- Bergerak berdasarkan input analog (MoveDirection)
                    if hum.MoveDirection.Magnitude > 0 then
                        bv.Velocity = hum.MoveDirection * flySpeed
                    else
                        bv.Velocity = Vector3.new(0, 0, 0)
                    end
                    task.wait()
                end
                bv:Destroy()
            end)
        end
    end
})

MainTab:Slider({
    Title = "Speed",
    Value = { Min = 16, Max = 300, Default = 16 },
    Callback = function(v) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end
})

-- [[ COMBAT: AUTO CLICK ]] --
local autoClick = false
CombatTab:Toggle({
    Title = "Auto Clicker",
    Callback = function(state)
        autoClick = state
        task.spawn(function()
            while autoClick do
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(0,0))
                task.wait(0.1)
            end
        end)
    end
})

-- [[ VISUALS: ESP TOTAL ]] --
local espActive = false
VisualTab:Toggle({
    Title = "Enable Player ESP",
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
    Title = "Select Target",
    Options = getPlayers(),
    Callback = function(v) selectedPlayer = v end
})

PlayerTab:Button({
    Title = "Refresh & Fix List",
    Callback = function() PlayerDrop:SetOptions(getPlayers()) end
})

PlayerTab:Button({
    Title = "Teleport",
    Callback = function()
        local target = game.Players:FindFirstChild(selectedPlayer)
        if target and target.Character then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end
})

-- [[ SERVER: UTILITIES ]] --
ServerTab:Button({
    Title = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    end
})

ServerTab:Button({
    Title = "Copy JobId",
    Callback = function() setclipboard(game.JobId) end
})

-- [[ RUNTIME LOGIC ]] --
game:GetService("RunService").RenderStepped:Connect(function()
    if espActive then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                if not p.Character:FindFirstChild("Highlight") then
                    Instance.new("Highlight", p.Character)
                end
            end
        end
    end
end)

Window:Notify({ Title = "Terehub V4", Content = "Welcome", Duration = 5 })