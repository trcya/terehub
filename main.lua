-- [[ terehub | Fluent Edition v6.0 ]] --
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "terehub | Admin Tester",
    SubTitle = "by David",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- Efek blur transparan yang keren
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- [[ TABS ]] --
local Tabs = {
    Main = Window:AddTab({ Title = "Movement", Icon = "run" }),
    Visual = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    World = Window:AddTab({ Title = "World", Icon = "globe" })
}

-- [[ MOVEMENT: FLY ANALOG & INF JUMP ]] --
local flyActive = false
local flySpeed = 50
Tabs.Main:AddToggle("FlyToggle", {Title = "Fly (Analog/Camera)", Default = false})
:OnChanged(function(v)
    flyActive = v
    if v then
        local char = game.Players.LocalPlayer.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        task.spawn(function()
            while flyActive do
                bv.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * flySpeed
                task.wait()
            end
            bv:Destroy()
        end)
    end
end)

Tabs.Main:AddSlider("FlySpeed", {Title = "Fly Speed", Default = 50, Min = 10, Max = 300, Rounding = 1})
:OnChanged(function(v) flySpeed = v end)

local infJump = false
Tabs.Main:AddToggle("InfJump", {Title = "Infinite Jump", Default = false})
:OnChanged(function(v) infJump = v end)

-- [[ VISUALS: ESP & FULLBRIGHT ]] --
local espActive = false
Tabs.Visual:AddToggle("ESPToggle", {Title = "Player ESP (Highlighter)", Default = false})
:OnChanged(function(v)
    espActive = v
    if not v then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Highlight") then
                p.Character.Highlight:Destroy()
            end
        end
    end
end)

Tabs.Visual:AddButton({
    Title = "Fullbright (Tembus Pandang Cahaya)",
    Callback = function()
        game.Lighting.Brightness = 2
        game.Lighting.ClockTime = 14
        game.Lighting.GlobalShadows = false
    end
})

-- [[ WORLD: NOCLIP ]] --
local noclipActive = false
Tabs.World:AddToggle("NoclipToggle", {Title = "Noclip (Tembus Tembok)", Default = false})
:OnChanged(function(v) noclipActive = v end)

-- [[ LOGIC RUNTIME ]] --
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
                h.FillColor = Color3.fromRGB(0, 120, 255)
            end
        end
    end
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJump then game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
end)

Window:SelectTab(1)