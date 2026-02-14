-- VIOLENCE DISTRICT UI TEMPLATE
-- Purple Blue Theme
-- UI Only (No Features)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

pcall(function()
    game.CoreGui:FindFirstChild("VD_UI"):Destroy()
end)

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "VD_UI"

-- MAIN FRAME
local Main = Instance.new("Frame", gui)
Main.Size = UDim2.new(0, 750, 0, 450)
Main.Position = UDim2.new(0.5, -375, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(20, 15, 35)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 18)

-- GRADIENT
local Gradient = Instance.new("UIGradient", Main)
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 40, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 90, 255))
}
Gradient.Rotation = 45

-- TOP BAR
local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Violence District"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- MINIMIZE
local Minimize = Instance.new("TextButton", TopBar)
Minimize.Size = UDim2.new(0, 40, 0, 30)
Minimize.Position = UDim2.new(1, -90, 0.5, -15)
Minimize.Text = "-"
Minimize.Font = Enum.Font.GothamBold
Minimize.TextSize = 18
Minimize.BackgroundColor3 = Color3.fromRGB(80, 60, 180)
Minimize.TextColor3 = Color3.new(1,1,1)
Minimize.BorderSizePixel = 0
Instance.new("UICorner", Minimize).CornerRadius = UDim.new(1,0)

-- CLOSE
local Close = Instance.new("TextButton", TopBar)
Close.Size = UDim2.new(0, 40, 0, 30)
Close.Position = UDim2.new(1, -45, 0.5, -15)
Close.Text = "X"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 14
Close.BackgroundColor3 = Color3.fromRGB(120, 40, 180)
Close.TextColor3 = Color3.new(1,1,1)
Close.BorderSizePixel = 0
Instance.new("UICorner", Close).CornerRadius = UDim.new(1,0)

-- SIDEBAR
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 180, 1, -45)
Sidebar.Position = UDim2.new(0, 0, 0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 20, 60)
Sidebar.BorderSizePixel = 0

Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 18)

-- CONTENT PANEL
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -190, 1, -55)
Content.Position = UDim2.new(0, 190, 0, 50)
Content.BackgroundColor3 = Color3.fromRGB(25, 20, 50)
Content.BorderSizePixel = 0

Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 16)

-- EMPTY LABEL
local Empty = Instance.new("TextLabel", Content)
Empty.Size = UDim2.new(1, 0, 1, 0)
Empty.BackgroundTransparency = 1
Empty.Text = "UI Template Ready"
Empty.Font = Enum.Font.Gotham
Empty.TextSize = 20
Empty.TextColor3 = Color3.fromRGB(200, 200, 255)

-- BUTTON FUNCTIONS
Close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local minimized = false
Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    Content.Visible = not minimized
    Sidebar.Visible = not minimized
end)