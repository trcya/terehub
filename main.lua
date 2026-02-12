-- [[ terehub CUSTOM UI v1.0 ]] --
-- Dibuat murni menggunakan Instance.new (Tanpa Library Luar)

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Container = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

-- Setup ScreenGui
ScreenGui.Name = "terehub_UI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Main Frame (Background)
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Active = true
MainFrame.Draggable = true -- Biar bisa digeser-geser

-- Title
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "terehub | CUSTOM v1.0"
Title.TextColor3 = Color3.fromRGB(0, 255, 136)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold

-- Container for Buttons
Container.Parent = MainFrame
Container.Position = UDim2.new(0, 5, 0, 45)
Container.Size = UDim2.new(1, -10, 1, -50)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 2

UIListLayout.Parent = Container
UIListLayout.Padding = UDim.new(0, 5)

-- FUNCTION UNTUK MEMBUAT TOMBOL
local function CreateButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = Container
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    
    btn.MouseButton1Click:Connect(callback)
    
    -- Efek Hover sederhana
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45) end)
end

-- [[ FITUR-FITUR ]] --

-- 1. Visual: ESP
local espActive = false
CreateButton("Visual: Toggle ESP", function()
    espActive = not espActive
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "terehub", Text = "ESP: " .. tostring(espActive)})
end)

-- 2. Movement: Fly
local flyActive = false
CreateButton("Movement: Toggle Fly", function()
    flyActive = not flyActive
    local char = game.Players.LocalPlayer.Character
    if flyActive then
        local bv = Instance.new("BodyVelocity", char.HumanoidRootPart)
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        task.spawn(function()
            while flyActive do
                bv.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * 50
                task.wait()
            end
            bv:Destroy()
        end)
    end
end)

-- 3. World: Fullbright
CreateButton("World: Fullbright", function()
    game.Lighting.Brightness = 2
    game.Lighting.ClockTime = 14
    game.Lighting.GlobalShadows = false
end)

-- 4. Destroy UI
CreateButton("Close UI", function()
    ScreenGui:Destroy()
end)

-- [[ RUNTIME CORE ]] --
game:GetService("RunService").RenderStepped:Connect(function()
    if espActive then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                if not p.Character:FindFirstChild("Highlight") then
                    local h = Instance.new("Highlight", p.Character)
                    h.FillColor = Color3.fromRGB(0, 255, 136)
                end
            end
        end
    end
end)