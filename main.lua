-- [[ terehub | WindUI Fixed Version ]] --
-- Mengambil source langsung dari GitHub agar tidak 404
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

-- [[ MOVEMENT ]] --
MainTab:Slider({
    Title = "WalkSpeed",
    Step = 1,
    Value = { Min = 16, Max = 500, Default = 16 },
    Callback = function(v)
        if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    end
})

local infJump = false
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

-- [[ LOGIC RUNTIME ]] --
game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJump then 
        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") 
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