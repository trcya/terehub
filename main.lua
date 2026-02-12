-- [[ terehub | Kavo UI Edition v5.0 ]] --
local KavoLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Colors = {
    SchemeColor = Color3.fromRGB(0, 255, 136), -- Warna tema terehub
    Background = Color3.fromRGB(20, 20, 20),
    Header = Color3.fromRGB(30, 30, 30)
}

local Window = KavoLib.CreateLib("terehub | Visual & Exploits", "DarkScene")

-- [[ TAB VISUALS (TEMBUS PANDANG & TRACKING) ]] --
local VisualTab = Window:NewTab("Visuals Pro")
local VisualSection = VisualTab:NewSection("ESP & Render")

local espHighlight = false
VisualSection:NewToggle("Player Highlight (Chams)", "Membuat pemain tembus pandang berwarna", function(state)
    espHighlight = state
end)

local tracersEnabled = false
VisualSection:NewToggle("Player Tracers (Garis)", "Menarik garis ke posisi pemain lain", function(state)
    tracersEnabled = state
end)

VisualSection:NewButton("Fullbright", "Menghilangkan kegelapan map", function()
    game:GetService("Lighting").Brightness = 2
    game:GetService("Lighting").GlobalShadows = false
    game:GetService("Lighting").ClockTime = 14
end)

-- [[ TAB MOVEMENT (ANALOG FLY & JUMP) ]] --
local MoveTab = Window:NewTab("Movement")
local MoveSection = MoveTab:NewSection("Physics Testing")

local flyActive = false
local flySpeed = 50
MoveSection:NewToggle("Analog Fly", "Terbang ke arah kamera", function(state)
    flyActive = state
    if state then
        local bv = Instance.new("BodyVelocity", game.Players.LocalPlayer.Character.HumanoidRootPart)
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
end)

MoveSection:NewSlider("Fly Speed", "Atur kecepatan terbang", 300, 10, function(s)
    flySpeed = s
end)

local infJump = false
MoveSection:NewToggle("Infinite Jump", "Lompat tanpa batas", function(state)
    infJump = state
end)

-- [[ LOGIC RUNTIME CORE ]] --
game:GetService("RunService").RenderStepped:Connect(function()
    -- ESP Highlight Logic
    if espHighlight then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                if not p.Character:FindFirstChild("Highlight") then
                    local h = Instance.new("Highlight", p.Character)
                    h.FillColor = Colors.SchemeColor
                end
            end
        end
    else
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Highlight") then
                p.Character.Highlight:Destroy()
            end
        end
    end

    -- Tracers Logic (Garis Tembus Pandang)
    if tracersEnabled then
        -- Fitur ini biasanya membutuhkan library tambahan, 
        -- di sini kita gunakan highlight outline sebagai alternatif ringan
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("Highlight") then
                p.Character.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            end
        end
    end
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJump then game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
end)