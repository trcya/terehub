-- [[ terehub | WindUI Fixed ]] --
-- Menggunakan link raw GitHub yang valid atau alternatif UI Library
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/Source.lua"))()
end)

if not success or not WindUI then
    warn("Gagal memuat UI Library (404/Network Error). Pastikan link GitHub valid.")
    return
end

local Window = WindUI:CreateWindow({
    Title = "terehub | Admin Tester",
    Icon = "rbxassetid://4483362458",
    Author = "David", -- Nama kamu sudah terpasang
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

-- [[ MOVEMENT VARIABLES ]] --
local flyActive = false
local flySpeed = 50
local infJump = false

-- [[ LOGIC: FLY ]] --
MainTab:Toggle({
    Title = "Analog Fly (Camera)",
    Callback = function(state)
        flyActive = state
        local char = game.Players.LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        
        if state and hrp then
            local bv = hrp:FindFirstChild("terehub_Fly") or Instance.new("BodyVelocity")
            bv.Name = "terehub_Fly"
            bv.Parent = hrp
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            
            task.spawn(function()
                while flyActive and hrp.Parent do
                    bv.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * flySpeed
                    task.wait()
                end
                if bv then bv:Destroy() end
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

-- [[ VISUALS: ESP ]] --
local espActive = false
VisualTab:Toggle({
    Title = "Player ESP",
    Callback = function(state) 
        espActive = state 
        if not state then
            -- Hapus highlight jika dimatikan
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("terehub_ESP") then
                    p.Character.terehub_ESP:Destroy()
                end
            end
        end
    end
})

-- [[ EXPLOITS: NOCLIP ]] --
local noclipActive = false
WorldTab:Toggle({
    Title = "Noclip (Tembus Tembok)",
    Callback = function(state) noclipActive = state end
})

-- [[ RUNTIME LOGIC ]] --
-- Loop untuk Noclip
game:GetService("RunService").Stepped:Connect(function()
    if noclipActive and game.Players.LocalPlayer.Character then
        for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- Loop untuk ESP
game:GetService("RunService").RenderStepped:Connect(function()
    if espActive then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                if not p.Character:FindFirstChild("terehub_ESP") then
                    local h = Instance.new("Highlight")
                    h.Name = "terehub_ESP"
                    h.Parent = p.Character
                    h.FillColor = Color3.fromRGB(0, 255, 136)
                end
            end
        end
    end
end)

-- Loop untuk Infinite Jump
game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJump and game.Players.LocalPlayer.Character then 
        local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)