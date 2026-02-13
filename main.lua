-- Delta Executor UI - Purple Blue Theme
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Hapus UI lama jika ada agar tidak tumpang tindih
if CoreGui:FindFirstChild("RockHubDelta") then
    CoreGui.RockHubDelta:Destroy()
end

-- Main Container
local RockHub = Instance.new("ScreenGui")
RockHub.Name = "RockHubDelta"
RockHub.Parent = CoreGui
RockHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 300) -- Ukuran pas untuk layar HP/PC
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = RockHub

-- Styling (Rounded & Gradient)
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 20, 110)), -- Ungu
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 70, 130))  -- Biru
})
Gradient.Rotation = 45
Gradient.Parent = MainFrame

-- Neon Border
local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 1.5
Stroke.Color = Color3.fromRGB(120, 120, 255)
Stroke.Transparency = 0.5
Stroke.Parent = MainFrame

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Sidebar.BackgroundTransparency = 0.6
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 12)
SidebarCorner.Parent = Sidebar

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = " ROCKHUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Sidebar

-- Status Info (Kanan)
local Stats = Instance.new("TextLabel")
Stats.Size = UDim2.new(0, 150, 0, 100)
Stats.Position = UDim2.new(1, -160, 0, 20)
Stats.BackgroundTransparency = 1
Stats.Text = "NETWORK\n<font color='#00d2ff'>Current: 5.64</font>\n<font color='#9d50bb'>Average: 7.75</font>"
Stats.TextColor3 = Color3.fromRGB(200, 200, 200)
Stats.TextSize = 12
Stats.RichText = true
Stats.Font = Enum.Font.GothamSemibold
Stats.TextXAlignment = Enum.TextXAlignment.Right
Stats.Parent = MainFrame

-- --- FUNGSI DRAG (Agar bisa digeser di Delta) ---
local dragging, dragInput, dragStart, startPos
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

UserInputService.InputEnded:Connect(function(input)
    dragging = false
end)

-- --- TOMBOL TOGGLE (Sembunyikan/Munculkan) ---
-- Tekan tombol "K" di keyboard atau gunakan tombol ini
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, -25)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
ToggleBtn.Text = "RH"
ToggleBtn.TextColor3 = Color3.white
ToggleBtn.Parent = RockHub

local TCorner = Instance.new("UICorner")
TCorner.CornerRadius = UDim.new(1, 0)
TCorner.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)