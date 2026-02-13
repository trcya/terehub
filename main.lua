-- Memastikan script berjalan meski ada error sound di background
local success, err = pcall(function()
    local CoreGui = game:GetService("CoreGui")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")

    -- Bersihkan UI lama jika ada
    if CoreGui:FindFirstChild("RockHub_Delta") then
        CoreGui:FindFirstChild("RockHub_Delta"):Destroy()
    end

    -- Root UI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RockHub_Delta"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false

    -- Window Utama
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 450, 0, 280)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -140)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    -- Tema Ungu-Biru (Gradient)
    local Grad = Instance.new("UIGradient")
    Grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 40, 150)), -- Ungu
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 80, 180))  -- Biru
    })
    Grad.Parent = MainFrame

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    
    local Stroke = Instance.new("UIStroke", MainFrame)
    Stroke.Color = Color3.fromRGB(120, 120, 255)
    Stroke.Thickness = 1.2
    Stroke.Transparency = 0.4

    -- Label Judul
    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(0, 200, 0, 40)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "ROCKHUB <font color='#00ffff'>V2</font>"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextSize = 18
    Title.RichText = true
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Panel Status Kanan
    local Info = Instance.new("TextLabel", MainFrame)
    Info.Size = UDim2.new(0, 150, 0, 80)
    Info.Position = UDim2.new(1, -165, 0, 10)
    Info.BackgroundTransparency = 1
    Info.Text = "SYSTEM OK\n<font color='#9d50bb'>Delta Mode</font>\n<font color='#00d2ff'>UI Loaded</font>"
    Info.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    Info.TextSize = 12
    Info.RichText = true
    Info.Font = Enum.Font.GothamSemibold
    Info.TextXAlignment = Enum.TextXAlignment.Right

    -- Fitur Dragging (Khusus Mobile/Delta)
    local dragStart, startPos, dragging
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)

    print("RockHub Loaded Successfully!")
end)

if not success then
    warn("Gagal memuat UI: " .. tostring(err))
end