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
local WorldTab = Window:Tab({ Title = "World", Icon = "globe" })
local PlayerTab = Window:Tab({ Title = "Players", Icon = "users" })

-- [[ MOVEMENT: ANALOG CAMERA FLY ]] --
local flyActive = false
local flySpeed = 50
MainTab:Toggle({
    Title = "Camera Fly (Analog)",
    Callback = function(state)
        flyActive = state
        local char = game.Players.LocalPlayer.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if state then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "TereFly"
            bv.Parent = hrp
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

MainTab:Button({
    Title = "Reset Speed & Jump",
    Callback = function()
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
    end
})

-- [[ WORLD FEATURES ]] --
local fullBright = false
WorldTab:Toggle({
    Title = "Full Bright (No Dark)",
    Callback = function(state)
        fullBright = state
        if state then
            game:GetService("Lighting").Brightness = 2
            game:GetService("Lighting").ClockTime = 14
            game:GetService("Lighting").GlobalShadows = false
        else
            game:GetService("Lighting").Brightness = 1
            game:GetService("Lighting").GlobalShadows = true
        end
    end
})

WorldTab:Button({
    Title = "Anti-AFK (Stay Active)",
    Callback = function()
        local vu = game:GetService("VirtualUser")
        game.Players.LocalPlayer.Idled:Connect(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
            Window:Notify({Title = "Anti-AFK", Content = "Karakter tetap aktif!"})
        end)
    end
})

-- [[ PLAYERS: TELEPORT & ESP ]] --
local selectedPlayer = ""
local dropDown = PlayerTab:Dropdown({
    Title = "Select Player",
    Options = {}, -- Akan diisi otomatis
    Callback = function(v) selectedPlayer = v end
})

-- Fungsi Refresh Nama Player
local function updatePlayerList()
    local pList = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then table.insert(pList, p.Name) end
    end
    dropDown:SetOptions(pList)
end

PlayerTab:Button({
    Title = "Refresh Player List",
    Callback = function() updatePlayerList() end
})

PlayerTab:Button({
    Title = "Teleport to Player",
    Callback = function()
        local target = game.Players:FindFirstChild(selectedPlayer)
        if target and target.Character then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        else
            Window:Notify({Title = "Error", Content = "Pilih pemain & klik refresh!"})
        end
    end
})

-- [[ ESP LOGIC ]] --
local espActive = false
PlayerTab:Toggle({
    Title = "ESP Player",
    Callback = function(state) espActive = state end
})

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

updatePlayerList() -- Jalankan refresh pertama kali
Window:Notify({ Title = "Terehub", Content = "V2 Loaded! Klik Refresh Player List.", Duration = 5 })