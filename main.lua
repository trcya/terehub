local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()

print("Terehub Ultimate: Initializing Custom Explorer & Remote Spy...")

-- [[ CLEANUP OLD UI ]] --
if CoreGui:FindFirstChild("TerehubCustomUI") then
    CoreGui.TerehubCustomUI:Destroy()
end
if CoreGui:FindFirstChild("TereExplorerWindow") then
    CoreGui.TereExplorerWindow:Destroy()
end

-- [[ CREATE WINDUI STYLE SCREEN GUI ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TerehubCustomUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Main Window Frame (WindUI Exact Style: 600x420, Dark Slate Rounded)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 420)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 19, 26)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 48, 64)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- TopBar Header (WindUI Layout)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(14, 15, 21)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TitleIcon = Instance.new("ImageLabel")
TitleIcon.Size = UDim2.new(0, 24, 0, 24)
TitleIcon.Position = UDim2.new(0, 14, 0, 10)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Image = "rbxassetid://136360402262473"
TitleIcon.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 300, 1, 0)
TitleLabel.Position = UDim2.new(0, 46, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Terehub <font color='#818CF8'>| Violence District V10</font>"
TitleLabel.RichText = true
TitleLabel.TextColor3 = Color3.fromRGB(240, 242, 248)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- WindUI Window Control Buttons (Minimize -, Close X)
local ControlContainer = Instance.new("Frame")
ControlContainer.Size = UDim2.new(0, 70, 0, 30)
ControlContainer.Position = UDim2.new(1, -78, 0, 7)
ControlContainer.BackgroundTransparency = 1
ControlContainer.Parent = TopBar

local ControlLayout = Instance.new("UIListLayout")
ControlLayout.FillDirection = Enum.FillDirection.Horizontal
ControlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ControlLayout.Padding = UDim.new(0, 6)
ControlLayout.Parent = ControlContainer

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(28, 30, 42)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 205, 220)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 16
MinimizeBtn.Parent = ControlContainer

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.Parent = ControlContainer

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 600, 0, 45) or UDim2.new(0, 600, 0, 420)
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Make Window Draggable
local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
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
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Sidebar & Content Container
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 160, 1, -45)
Sidebar.Position = UDim2.new(0, 0, 0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 15, 21)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarPad = Instance.new("UIPadding")
SidebarPad.PaddingTop = UDim.new(0, 10)
SidebarPad.PaddingLeft = UDim.new(0, 10)
SidebarPad.PaddingRight = UDim.new(0, 10)
SidebarPad.Parent = Sidebar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 5)
TabListLayout.Parent = Sidebar

local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -160, 1, -45)
ContentContainer.Position = UDim2.new(0, 160, 0, 45)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- [[ WINDUI SYSTEM BUILDER ]] --
local Tabs = {}
local TabButtons = {}

local function CreateTab(tabName, iconText)
    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Name = tabName .. "Page"
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.ScrollBarThickness = 4
    TabPage.ScrollBarImageColor3 = Color3.fromRGB(129, 140, 248)
    TabPage.Visible = false
    TabPage.Parent = ContentContainer

    local PageList = Instance.new("UIListLayout")
    PageList.SortOrder = Enum.SortOrder.LayoutOrder
    PageList.Padding = UDim.new(0, 8)
    PageList.Parent = TabPage

    local PagePad = Instance.new("UIPadding")
    PagePad.PaddingTop = UDim.new(0, 10)
    PagePad.PaddingLeft = UDim.new(0, 12)
    PagePad.PaddingRight = UDim.new(0, 12)
    PagePad.PaddingBottom = UDim.new(0, 10)
    PagePad.Parent = TabPage

    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 36)
    TabBtn.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
    TabBtn.Text = (iconText or "•") .. "   " .. tabName
    TabBtn.TextColor3 = Color3.fromRGB(160, 165, 185)
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextSize = 13
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = Sidebar

    local BtnPad = Instance.new("UIPadding")
    BtnPad.PaddingLeft = UDim.new(0, 12)
    BtnPad.Parent = TabBtn

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = TabBtn

    TabBtn.MouseButton1Click:Connect(function()
        for name, page in pairs(Tabs) do page.Visible = (name == tabName) end
        for name, btn in pairs(TabButtons) do
            local active = (name == tabName)
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = active and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(22, 24, 34),
                TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 165, 185)
            }):Play()
        end
    end)

    Tabs[tabName] = TabPage
    TabButtons[tabName] = TabBtn

    local Elements = {}

    function Elements:AddSection(title)
        local SecLabel = Instance.new("TextLabel")
        SecLabel.Size = UDim2.new(1, 0, 0, 20)
        SecLabel.BackgroundTransparency = 1
        SecLabel.Text = string.upper(title)
        SecLabel.TextColor3 = Color3.fromRGB(129, 140, 248)
        SecLabel.Font = Enum.Font.GothamBold
        SecLabel.TextSize = 11
        SecLabel.TextXAlignment = Enum.TextXAlignment.Left
        SecLabel.Parent = TabPage
    end

    function Elements:AddButton(text, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 40)
        Btn.BackgroundColor3 = Color3.fromRGB(25, 27, 38)
        Btn.Text = text
        Btn.TextColor3 = Color3.fromRGB(240, 242, 248)
        Btn.Font = Enum.Font.GothamMedium
        Btn.TextSize = 13
        Btn.Parent = TabPage

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = Btn

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Color3.fromRGB(45, 48, 68)
        Stroke.Thickness = 1
        Stroke.Parent = Btn

        Btn.MouseButton1Click:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(99, 102, 241)}):Play()
            task.wait(0.1)
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 27, 38)}):Play()
            pcall(callback)
        end)
    end

    function Elements:AddToggle(text, default, callback)
        local state = default or false

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 44)
        Frame.BackgroundColor3 = Color3.fromRGB(25, 27, 38)
        Frame.Parent = TabPage

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = Frame

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Color3.fromRGB(45, 48, 68)
        Stroke.Thickness = 1
        Stroke.Parent = Frame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0, 14, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(230, 232, 242)
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame

        local SwitchBg = Instance.new("Frame")
        SwitchBg.Size = UDim2.new(0, 44, 0, 22)
        SwitchBg.Position = UDim2.new(1, -56, 0.5, -11)
        SwitchBg.BackgroundColor3 = state and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(40, 44, 60)
        SwitchBg.Parent = Frame

        local SwitchCorner = Instance.new("UICorner")
        SwitchCorner.CornerRadius = UDim.new(0, 11)
        SwitchCorner.Parent = SwitchBg

        local SwitchDot = Instance.new("Frame")
        SwitchDot.Size = UDim2.new(0, 16, 0, 16)
        SwitchDot.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        SwitchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SwitchDot.Parent = SwitchBg

        local DotCorner = Instance.new("UICorner")
        DotCorner.CornerRadius = UDim.new(0, 8)
        DotCorner.Parent = SwitchDot

        local ClickBtn = Instance.new("TextButton")
        ClickBtn.Size = UDim2.new(1, 0, 1, 0)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text = ""
        ClickBtn.Parent = Frame

        ClickBtn.MouseButton1Click:Connect(function()
            state = not state
            local targetBg = state and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(40, 44, 60)
            local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            
            TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
            TweenService:Create(SwitchDot, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetPos}):Play()
            pcall(callback, state)
        end)
    end

    function Elements:AddParagraph(title, content)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 60)
        Frame.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
        Frame.Parent = TabPage

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = Frame

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Color3.fromRGB(99, 102, 241)
        Stroke.Transparency = 0.5
        Stroke.Thickness = 1
        Stroke.Parent = Frame

        local TitleL = Instance.new("TextLabel")
        TitleL.Size = UDim2.new(1, -20, 0, 22)
        TitleL.Position = UDim2.new(0, 12, 0, 6)
        TitleL.BackgroundTransparency = 1
        TitleL.Text = title
        TitleL.TextColor3 = Color3.fromRGB(129, 140, 248)
        TitleL.Font = Enum.Font.GothamBold
        TitleL.TextSize = 13
        TitleL.TextXAlignment = Enum.TextXAlignment.Left
        TitleL.Parent = Frame

        local ContentL = Instance.new("TextLabel")
        ContentL.Size = UDim2.new(1, -20, 0, 26)
        ContentL.Position = UDim2.new(0, 12, 0, 28)
        ContentL.BackgroundTransparency = 1
        ContentL.Text = content
        ContentL.TextColor3 = Color3.fromRGB(200, 205, 220)
        ContentL.Font = Enum.Font.Gotham
        ContentL.TextSize = 12
        ContentL.TextXAlignment = Enum.TextXAlignment.Left
        ContentL.Parent = Frame

        return {
            Set = function(_, data)
                if data.Title then TitleL.Text = data.Title end
                if data.Content then ContentL.Text = data.Content end
            end
        }
    end

    return Elements
end

-- Create Pages
local MainTab = CreateTab("Main", "✦")
local CharTab = CreateTab("Character", "◈")
local CombatTab = CreateTab("Combat", "⚔")
local VisualTab = CreateTab("Visuals", "⦿")
local ShopTab = CreateTab("Shops", "❖")
local PlayerTab = CreateTab("Players", "⎔")

TabButtons["Shops"].BackgroundColor3 = Color3.fromRGB(99, 102, 241)
TabButtons["Shops"].TextColor3 = Color3.fromRGB(255, 255, 255)
Tabs["Shops"].Visible = true

-- [[ FLOATING TOGGLE BUTTON ]] --
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "TerehubFloatingBtn"
FloatBtn.Size = UDim2.new(0, 48, 0, 48)
FloatBtn.Position = UDim2.new(0, 15, 0.5, -24)
FloatBtn.BackgroundColor3 = Color3.fromRGB(18, 19, 26)
FloatBtn.Text = ""
FloatBtn.Parent = ScreenGui

local FloatIcon = Instance.new("ImageLabel")
FloatIcon.Size = UDim2.new(0, 26, 0, 26)
FloatIcon.Position = UDim2.new(0.5, -13, 0.5, -13)
FloatIcon.BackgroundTransparency = 1
FloatIcon.Image = "rbxassetid://136360402262473"
FloatIcon.Parent = FloatBtn

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 12)
FloatCorner.Parent = FloatBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(99, 102, 241)
FloatStroke.Thickness = 2
FloatStroke.Parent = FloatBtn

FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ================================================================= --
-- [[ TEREHUB ULTIMATE EXPLORER & REMOTE SPY (DARK DEX + SIMPLESPY) ]] --
-- ================================================================= --

local function OpenTereExplorer()
    if ScreenGui:FindFirstChild("TereExplorerWindow") then
        ScreenGui.TereExplorerWindow.Visible = not ScreenGui.TereExplorerWindow.Visible
        return
    end

    local ExpFrame = Instance.new("Frame")
    ExpFrame.Name = "TereExplorerWindow"
    ExpFrame.Size = UDim2.new(0, 520, 0, 380)
    ExpFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
    ExpFrame.BackgroundColor3 = Color3.fromRGB(14, 15, 21)
    ExpFrame.BorderSizePixel = 0
    ExpFrame.ClipsDescendants = true
    ExpFrame.Parent = ScreenGui

    local ExpCorner = Instance.new("UICorner")
    ExpCorner.CornerRadius = UDim.new(0, 10)
    ExpCorner.Parent = ExpFrame

    local ExpStroke = Instance.new("UIStroke")
    ExpStroke.Color = Color3.fromRGB(129, 140, 248)
    ExpStroke.Thickness = 1.5
    ExpStroke.Parent = ExpFrame

    -- Header
    local ExpTop = Instance.new("Frame")
    ExpTop.Size = UDim2.new(1, 0, 0, 40)
    ExpTop.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
    ExpTop.Parent = ExpFrame

    local ExpTitle = Instance.new("TextLabel")
    ExpTitle.Size = UDim2.new(0.7, 0, 1, 0)
    ExpTitle.Position = UDim2.new(0, 12, 0, 0)
    ExpTitle.BackgroundTransparency = 1
    ExpTitle.Text = "Terehub <font color='#818CF8'>Explorer & Remote Spy</font>"
    ExpTitle.RichText = true
    ExpTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExpTitle.Font = Enum.Font.GothamBold
    ExpTitle.TextSize = 13
    ExpTitle.TextXAlignment = Enum.TextXAlignment.Left
    ExpTitle.Parent = ExpTop

    local ExpClose = Instance.new("TextButton")
    ExpClose.Size = UDim2.new(0, 26, 0, 26)
    ExpClose.Position = UDim2.new(1, -32, 0, 7)
    ExpClose.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    ExpClose.Text = "X"
    ExpClose.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExpClose.Font = Enum.Font.GothamBold
    ExpClose.TextSize = 12
    ExpClose.Parent = ExpTop

    local ExpCloseCorner = Instance.new("UICorner")
    ExpCloseCorner.CornerRadius = UDim.new(0, 6)
    ExpCloseCorner.Parent = ExpClose

    ExpClose.MouseButton1Click:Connect(function() ExpFrame.Visible = false end)

    -- Draggable
    local expDrag, expStart, expPosStart
    ExpTop.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            expDrag = true
            expStart = input.Position
            expPosStart = ExpFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if expDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - expStart
            ExpFrame.Position = UDim2.new(expPosStart.X.Scale, expPosStart.X.Offset + delta.X, expPosStart.Y.Scale, expPosStart.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            expDrag = false
        end
    end)

    -- Search Box
    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -24, 0, 30)
    SearchBox.Position = UDim2.new(0, 12, 0, 48)
    SearchBox.BackgroundColor3 = Color3.fromRGB(24, 27, 38)
    SearchBox.PlaceholderText = "🔍 Cari nama PlayerGui, RemoteEvent, atau Object..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(140, 145, 165)
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 12
    SearchBox.Parent = ExpFrame

    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 6)
    SearchCorner.Parent = SearchBox

    -- Log Scroll List
    local ScrollList = Instance.new("ScrollingFrame")
    ScrollList.Size = UDim2.new(1, -24, 1, -90)
    ScrollList.Position = UDim2.new(0, 12, 0, 84)
    ScrollList.BackgroundTransparency = 1
    ScrollList.ScrollBarThickness = 4
    ScrollList.ScrollBarImageColor3 = Color3.fromRGB(129, 140, 248)
    ScrollList.Parent = ExpFrame

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 5)
    ListLayout.Parent = ScrollList

    local function AddLogItem(name, pathStr, objType, onCopy)
        local ItemFrame = Instance.new("Frame")
        ItemFrame.Size = UDim2.new(1, 0, 0, 36)
        ItemFrame.BackgroundColor3 = Color3.fromRGB(24, 27, 38)
        ItemFrame.Parent = ScrollList

        local ItemCorner = Instance.new("UICorner")
        ItemCorner.CornerRadius = UDim.new(0, 6)
        ItemCorner.Parent = ItemFrame

        local TypeLabel = Instance.new("TextLabel")
        TypeLabel.Size = UDim2.new(0, 60, 0, 20)
        TypeLabel.Position = UDim2.new(0, 8, 0.5, -10)
        TypeLabel.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
        TypeLabel.Text = objType
        TypeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TypeLabel.Font = Enum.Font.GothamBold
        TypeLabel.TextSize = 10
        TypeLabel.Parent = ItemFrame

        local TypeCorner = Instance.new("UICorner")
        TypeCorner.CornerRadius = UDim.new(0, 4)
        TypeCorner.Parent = TypeLabel

        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(1, -150, 0, 18)
        NameLabel.Position = UDim2.new(0, 74, 0, 2)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = name
        NameLabel.TextColor3 = Color3.fromRGB(240, 242, 250)
        NameLabel.Font = Enum.Font.GothamMedium
        NameLabel.TextSize = 12
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.Parent = ItemFrame

        local PathLabel = Instance.new("TextLabel")
        PathLabel.Size = UDim2.new(1, -150, 0, 14)
        PathLabel.Position = UDim2.new(0, 74, 0, 20)
        PathLabel.BackgroundTransparency = 1
        PathLabel.Text = pathStr
        PathLabel.TextColor3 = Color3.fromRGB(140, 145, 165)
        PathLabel.Font = Enum.Font.Gotham
        PathLabel.TextSize = 10
        PathLabel.TextXAlignment = Enum.TextXAlignment.Left
        PathLabel.Parent = ItemFrame

        local CopyBtn = Instance.new("TextButton")
        CopyBtn.Size = UDim2.new(0, 60, 0, 24)
        CopyBtn.Position = UDim2.new(1, -66, 0.5, -12)
        CopyBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 62)
        CopyBtn.Text = "COPY"
        CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CopyBtn.Font = Enum.Font.GothamBold
        CopyBtn.TextSize = 10
        CopyBtn.Parent = ItemFrame

        local CopyCorner = Instance.new("UICorner")
        CopyCorner.CornerRadius = UDim.new(0, 4)
        CopyCorner.Parent = CopyBtn

        CopyBtn.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(onCopy or pathStr)
                CopyBtn.Text = "COPIED!"
                task.wait(1)
                CopyBtn.Text = "COPY"
            end
        end)
    end

    -- Initial Population: Scan PlayerGui & Remotes
    local function PopulateExplorer(filter)
        for _, child in pairs(ScrollList:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        filter = string.lower(filter or "")

        -- Scan PlayerGui
        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        if pGui then
            for _, gui in pairs(pGui:GetDescendants()) do
                if gui:IsA("GuiObject") or gui:IsA("ScreenGui") then
                    local gName = gui.Name
                    local gPath = gui:GetFullName()
                    if filter == "" or string.find(string.lower(gName), filter) or string.find(string.lower(gPath), filter) then
                        AddLogItem(gName, gPath, gui.ClassName, gPath)
                    end
                end
            end
        end

        -- Scan Remotes (ReplicatedStorage)
        for _, remote in pairs(game.ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local rName = remote.Name
                local rPath = remote:GetFullName()
                if filter == "" or string.find(string.lower(rName), filter) or string.find(string.lower(rPath), filter) then
                    local code = string.format("game:GetService(\"ReplicatedStorage\").%s:%s()", rPath:gsub("ReplicatedStorage%.", ""), remote:IsA("RemoteEvent") and "FireServer" or "InvokeServer")
                    AddLogItem(rName, rPath, "REMOTE", code)
                end
            end
        end
    end

    PopulateExplorer()

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        PopulateExplorer(SearchBox.Text)
    end)
end

-- Add Button to Open TereExplorer in ShopTab
ShopTab:AddSection("Built-in Dark Dex & Remote Spy")

ShopTab:AddButton("Launch TereExplorer & Remote Spy (Bawaan)", function()
    OpenTereExplorer()
end)

-- [[ SHOPS TAB FEATURES ]] --
ShopTab:AddSection("Developer Tools")

ShopTab:AddButton("Scan All Remotes (Lihat di Console F9)", function()
    print("=== [TEREHUB REMOTE SCANNER] ===")
    local count = 0
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = string.lower(obj.Name)
            if string.find(name, "buy") or string.find(name, "shop") or string.find(name, "dice") or string.find(name, "potion") then
                count = count + 1
                print(string.format("[%d] %s (%s) -> Path: %s", count, obj.Name, obj.ClassName, obj:GetFullName()))
            end
        end
    end
    print("================================")
end)

ShopTab:AddSection("Auto Buy & Restock")

ShopTab:AddButton("Buy All Items (Direct Remote Buy)", function()
    pcall(function()
        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        local buyDice = remotes and remotes:FindFirstChild("BuyDice")
        local buyPotion = remotes and remotes:FindFirstChild("BuyPotion")
        local purchase = remotes and remotes:FindFirstChild("Purchase")

        local defaultItems = {"Abyssal", "Arcane", "Bronze", "Celestial", "Crystal", "Demonic", "Dice", "Potion", "Luck Potion", "Speed Potion"}
        for _, item in ipairs(defaultItems) do
            if buyDice then pcall(function() buyDice:FireServer(item) end) end
            if buyPotion then pcall(function() buyPotion:FireServer(item) end) end
            if purchase then pcall(function() purchase:FireServer(item) end) end
        end
    end)
end)

local autoBuyAllShops = false
ShopTab:AddToggle("Auto Buy All (Loop)", false, function(state)
    autoBuyAllShops = state
end)

ShopTab:AddSection("Live Restock Timer Status")

local RestockParagraph = ShopTab:AddParagraph("Restock Countdown", "Memantau waktu restock...")

task.spawn(function()
    while true do
        pcall(function()
            local pGui = LocalPlayer:FindFirstChild("PlayerGui")
            local mapShops = pGui and pGui:FindFirstChild("MapShops")
            local mainFrame = mapShops and mapShops:FindFirstChild("Main")
            local timerLabel = mainFrame and (mainFrame:FindFirstChild("Timer") or mainFrame:FindFirstChild("RestockTime") or mainFrame:FindFirstChildWhichIsA("TextLabel", true))
            
            if timerLabel and timerLabel:IsA("TextLabel") and timerLabel.Text ~= "" then
                RestockParagraph:Set({ Title = "Restock Countdown", Content = "Waktu Restock Saat Ini: " .. tostring(timerLabel.Text) })
            else
                RestockParagraph:Set({ Title = "Restock Countdown", Content = "Status Shop: Memantau restock (Buka MapShops GUI)" })
            end
        end)
        task.wait(1)
    end
end)

local catchRestockToggle = false
ShopTab:AddToggle("Catch Restock Time & Auto Buy", false, function(state)
    catchRestockToggle = state
end)

task.spawn(function()
    while true do
        if autoBuyAllShops then
            pcall(function()
                local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                local buyDice = remotes and remotes:FindFirstChild("BuyDice")
                local buyPotion = remotes and remotes:FindFirstChild("BuyPotion")
                local defaultItems = {"Abyssal", "Arcane", "Bronze", "Celestial", "Crystal", "Demonic", "Dice", "Potion"}
                for _, item in ipairs(defaultItems) do
                    if buyDice then pcall(function() buyDice:FireServer(item) end) end
                    if buyPotion then pcall(function() buyPotion:FireServer(item) end) end
                end
            end)
        end
        task.wait(1)
    end
end)

-- [[ MAIN TAB FEATURES ]] --
local autoSkillCheck = false
MainTab:AddToggle("Auto Perfect Skill Check", false, function(state) autoSkillCheck = state end)

task.spawn(function()
    while true do
        if autoSkillCheck then
            pcall(function()
                local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                if pGui then
                    for _, v in pairs(pGui:GetDescendants()) do
                        if v.Name == "SkillCheck" or v.Name == "Pointer" then
                            local needle = v
                            local successZone = v.Parent:FindFirstChild("SuccessZone") or v.Parent:FindFirstChild("WhiteArea")
                            if needle and successZone and needle:IsA("GuiObject") and successZone:IsA("GuiObject") then
                                if math.abs(needle.Rotation - successZone.Rotation) < 8 then
                                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                                    task.wait(0.01)
                                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                                    task.wait(0.5)
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait()
    end
end)

-- [[ CHARACTER TAB FEATURES ]] --
local wsToggle = false
CharTab:AddToggle("Enable WalkSpeed (100)", false, function(state)
    wsToggle = state
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = state and 100 or 16 end
end)

local infJump = false
CharTab:AddToggle("Infinite Jump", false, function(state) infJump = state end)

UserInputService.JumpRequest:Connect(function()
    if infJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- [[ COMBAT TAB FEATURES ]] --
local autoAim = false
CombatTab:AddToggle("Auto Aim Killer", false, function(state) autoAim = state end)

RunService.RenderStepped:Connect(function()
    if autoAim then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                if p.Team and string.find(p.Team.Name, "Killer") then
                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, p.Character.Head.Position)
                    break
                end
            end
        end
    end
end)

print("Terehub Ultimate Explorer & Remote Spy: Successfully Loaded!")
