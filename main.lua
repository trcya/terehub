local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()

print("Terehub Modern UI: Initializing...")

-- [[ CLEANUP EXISITING UI ]] --
if CoreGui:FindFirstChild("TerehubUI") then
    CoreGui.TerehubUI:Destroy()
end

-- [[ DESIGN SYSTEM & THEME ]] --
local Theme = {
    BGDeep          = Color3.fromRGB(10, 11, 16),
    BGMain          = Color3.fromRGB(15, 17, 24),
    BGSidebar       = Color3.fromRGB(12, 13, 19),
    BGCard          = Color3.fromRGB(21, 24, 34),
    BGCardHover     = Color3.fromRGB(28, 32, 45),
    BGTopBar        = Color3.fromRGB(12, 14, 20),
    Accent          = Color3.fromRGB(0, 210, 180),
    AccentGradient  = Color3.fromRGB(99, 102, 241), -- Electric Indigo
    AccentDim       = Color3.fromRGB(0, 150, 130),
    AccentBright    = Color3.fromRGB(0, 240, 205),
    AccentGlow      = Color3.fromRGB(0, 210, 180),
    TextPri         = Color3.fromRGB(240, 243, 250),
    TextSec         = Color3.fromRGB(130, 140, 165),
    TextMuted       = Color3.fromRGB(80, 88, 112),
    Border          = Color3.fromRGB(32, 37, 52),
    BorderLight     = Color3.fromRGB(45, 52, 72),
    Danger          = Color3.fromRGB(248, 113, 113),
    ToggleOff       = Color3.fromRGB(32, 36, 50),
}

-- [[ SCREEN GUI ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TerehubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- [[ TOAST NOTIFICATION CONTAINER ]] --
local NotificationHolder = Instance.new("Frame")
NotificationHolder.Name = "Notifications"
NotificationHolder.Size = UDim2.new(0, 260, 1, -40)
NotificationHolder.Position = UDim2.new(1, -270, 0, 20)
NotificationHolder.BackgroundTransparency = 1
NotificationHolder.ZIndex = 100
NotificationHolder.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.Parent = NotificationHolder

local function Notify(cfg)
    local title = cfg.Title or "Terehub"
    local desc = cfg.Description or ""
    local duration = cfg.Duration or 3

    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(1, 0, 0, 50)
    NotifFrame.BackgroundColor3 = Theme.BGCard
    NotifFrame.BorderSizePixel = 0
    NotifFrame.BackgroundTransparency = 1
    NotifFrame.Parent = NotificationHolder

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = NotifFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Accent
    Stroke.Thickness = 1
    Stroke.Transparency = 1
    Stroke.Parent = NotifFrame

    local AccBar = Instance.new("Frame")
    AccBar.Size = UDim2.new(0, 3, 1, -12)
    AccBar.Position = UDim2.new(0, 6, 0.5, 0)
    AccBar.AnchorPoint = Vector2.new(0, 0.5)
    AccBar.BackgroundColor3 = Theme.Accent
    AccBar.BorderSizePixel = 0
    AccBar.BackgroundTransparency = 1
    AccBar.Parent = NotifFrame

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -20, 0, 18)
    TitleLbl.Position = UDim2.new(0, 16, 0, 6)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title
    TitleLbl.TextColor3 = Theme.TextPri
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 12
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.TextTransparency = 1
    TitleLbl.Parent = NotifFrame

    local DescLbl = Instance.new("TextLabel")
    DescLbl.Size = UDim2.new(1, -20, 0, 18)
    DescLbl.Position = UDim2.new(0, 16, 0, 24)
    DescLbl.BackgroundTransparency = 1
    DescLbl.Text = desc
    DescLbl.TextColor3 = Theme.TextSec
    DescLbl.Font = Enum.Font.Gotham
    DescLbl.TextSize = 11
    DescLbl.TextXAlignment = Enum.TextXAlignment.Left
    DescLbl.TextTransparency = 1
    DescLbl.Parent = NotifFrame

    -- Slide in animation
    TweenService:Create(NotifFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.05}):Play()
    TweenService:Create(Stroke, TweenInfo.new(0.35), {Transparency = 0.4}):Play()
    TweenService:Create(AccBar, TweenInfo.new(0.35), {BackgroundTransparency = 0}):Play()
    TweenService:Create(TitleLbl, TweenInfo.new(0.35), {TextTransparency = 0}):Play()
    TweenService:Create(DescLbl, TweenInfo.new(0.35), {TextTransparency = 0}):Play()

    task.delay(duration, function()
        TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        TweenService:Create(AccBar, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(TitleLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        local tw = TweenService:Create(DescLbl, TweenInfo.new(0.3), {TextTransparency = 1})
        tw:Play()
        tw.Completed:Wait()
        NotifFrame:Destroy()
    end)
end

-- [[ MAIN WINDOW ]] --
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainWindow"
MainFrame.Size = UDim2.new(0, 640, 0, 440)
MainFrame.Position = UDim2.new(0.5, -320, 0.5, -220)
MainFrame.BackgroundColor3 = Theme.BGMain
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Border
MainStroke.Thickness = 1
MainStroke.Transparency = 0.2
MainStroke.Parent = MainFrame

-- Background subtle gradient overlay
local BgGradient = Instance.new("UIGradient")
BgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.BGMain),
    ColorSequenceKeypoint.new(1, Theme.BGDeep),
})
BgGradient.Rotation = 45
BgGradient.Parent = MainFrame

-- Top Glow Bar Accent
local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.Position = UDim2.new(0, 0, 0, 0)
AccentLine.BackgroundColor3 = Theme.Accent
AccentLine.BorderSizePixel = 0
AccentLine.Parent = MainFrame

local AccentLineGradient = Instance.new("UIGradient")
AccentLineGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Accent),
    ColorSequenceKeypoint.new(0.5, Theme.AccentGradient),
    ColorSequenceKeypoint.new(1, Theme.Accent),
})
AccentLineGradient.Parent = AccentLine

-- [[ TOPBAR ]] --
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.Position = UDim2.new(0, 0, 0, 2)
TopBar.BackgroundColor3 = Theme.BGTopBar
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarSep = Instance.new("Frame")
TopBarSep.Size = UDim2.new(1, 0, 0, 1)
TopBarSep.Position = UDim2.new(0, 0, 1, -1)
TopBarSep.BackgroundColor3 = Theme.Border
TopBarSep.BorderSizePixel = 0
TopBarSep.Parent = TopBar

-- Title Logo Icon
local TitleIcon = Instance.new("ImageLabel")
TitleIcon.Size = UDim2.new(0, 20, 0, 20)
TitleIcon.Position = UDim2.new(0, 14, 0.5, -10)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Image = "rbxassetid://136360402262473"
TitleIcon.ImageColor3 = Theme.Accent
TitleIcon.Parent = TopBar

-- Title Text
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 80, 1, 0)
TitleLabel.Position = UDim2.new(0, 40, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "TEREHUB"
TitleLabel.TextColor3 = Theme.TextPri
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local TitleSep = Instance.new("TextLabel")
TitleSep.Size = UDim2.new(0, 10, 1, 0)
TitleSep.Position = UDim2.new(0, 115, 0, 0)
TitleSep.BackgroundTransparency = 1
TitleSep.Text = "|"
TitleSep.TextColor3 = Theme.TextMuted
TitleSep.TextSize = 12
TitleSep.Font = Enum.Font.GothamMedium
TitleSep.Parent = TopBar

local SubtitleLabel = Instance.new("TextLabel")
SubtitleLabel.Size = UDim2.new(0, 220, 1, 0)
SubtitleLabel.Position = UDim2.new(0, 130, 0, 0)
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.Text = "Violence District - Modern Edition"
SubtitleLabel.TextColor3 = Theme.TextSec
SubtitleLabel.TextSize = 11
SubtitleLabel.Font = Enum.Font.GothamMedium
SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
SubtitleLabel.Parent = TopBar

-- Control Buttons Container
local ControlContainer = Instance.new("Frame")
ControlContainer.Size = UDim2.new(0, 64, 0, 28)
ControlContainer.Position = UDim2.new(1, -74, 0.5, -14)
ControlContainer.BackgroundTransparency = 1
ControlContainer.Parent = TopBar

local ControlLayout = Instance.new("UIListLayout")
ControlLayout.FillDirection = Enum.FillDirection.Horizontal
ControlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ControlLayout.Padding = UDim.new(0, 6)
ControlLayout.Parent = ControlContainer

-- Minimize Button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.BackgroundColor3 = Theme.BGCard
MinimizeBtn.Text = ""
MinimizeBtn.Parent = ControlContainer

local MinIcon = Instance.new("Frame")
MinIcon.Size = UDim2.new(0, 10, 0, 2)
MinIcon.Position = UDim2.new(0.5, -5, 0.5, -1)
MinIcon.BackgroundColor3 = Theme.TextSec
MinIcon.BorderSizePixel = 0
MinIcon.Parent = MinimizeBtn

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.BackgroundColor3 = Theme.Danger
CloseBtn.Text = ""
CloseBtn.Parent = ControlContainer

local CloseX1 = Instance.new("Frame")
CloseX1.Size = UDim2.new(0, 10, 0, 2)
CloseX1.Position = UDim2.new(0.5, -5, 0.5, -1)
CloseX1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseX1.BorderSizePixel = 0
CloseX1.Rotation = 45
CloseX1.Parent = CloseBtn

local CloseX2 = Instance.new("Frame")
CloseX2.Size = UDim2.new(0, 10, 0, 2)
CloseX2.Position = UDim2.new(0.5, -5, 0.5, -1)
CloseX2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseX2.BorderSizePixel = 0
CloseX2.Rotation = -45
CloseX2.Parent = CloseBtn

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Control Button Hover Animations
MinimizeBtn.MouseEnter:Connect(function()
    TweenService:Create(MinimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.BGCardHover}):Play()
end)
MinimizeBtn.MouseLeave:Connect(function()
    TweenService:Create(MinimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.BGCard}):Play()
end)
CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(220, 80, 80)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Danger}):Play()
end)

-- Window Minimize Toggle
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 640, 0, 44) or UDim2.new(0, 640, 0, 440)
    TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

-- [[ CONFIRMATION CLOSE MODAL ]] --
local ConfirmModal = Instance.new("Frame")
ConfirmModal.Name = "ConfirmModal"
ConfirmModal.Size = UDim2.new(1, 0, 1, 0)
ConfirmModal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ConfirmModal.BackgroundTransparency = 0.5
ConfirmModal.ZIndex = 50
ConfirmModal.Visible = false
ConfirmModal.Parent = MainFrame

local ModalCard = Instance.new("Frame")
ModalCard.Size = UDim2.new(0, 320, 0, 150)
ModalCard.Position = UDim2.new(0.5, -160, 0.5, -75)
ModalCard.BackgroundColor3 = Theme.BGCard
ModalCard.BorderSizePixel = 0
ModalCard.ZIndex = 51
ModalCard.Parent = ConfirmModal

local ModalCorner = Instance.new("UICorner")
ModalCorner.CornerRadius = UDim.new(0, 10)
ModalCorner.Parent = ModalCard

ModalCard.ClipsDescendants = true

local ModalStroke = Instance.new("UIStroke")
ModalStroke.Color = Theme.BorderLight
ModalStroke.Thickness = 1
ModalStroke.Parent = ModalCard

local ModalTitle = Instance.new("TextLabel")
ModalTitle.Size = UDim2.new(1, -30, 0, 24)
ModalTitle.Position = UDim2.new(0, 15, 0, 16)
ModalTitle.BackgroundTransparency = 1
ModalTitle.Text = "Konfirmasi Penutupan"
ModalTitle.TextColor3 = Theme.TextPri
ModalTitle.Font = Enum.Font.GothamBold
ModalTitle.TextSize = 14
ModalTitle.TextXAlignment = Enum.TextXAlignment.Left
ModalTitle.ZIndex = 52
ModalTitle.Parent = ModalCard

local ModalText = Instance.new("TextLabel")
ModalText.Size = UDim2.new(1, -30, 0, 36)
ModalText.Position = UDim2.new(0, 15, 0, 44)
ModalText.BackgroundTransparency = 1
ModalText.Text = "Apakah Anda setuju untuk menutup tab ini?"
ModalText.TextColor3 = Theme.TextSec
ModalText.Font = Enum.Font.Gotham
ModalText.TextSize = 12
ModalText.TextWrapped = true
ModalText.TextXAlignment = Enum.TextXAlignment.Left
ModalText.ZIndex = 52
ModalText.Parent = ModalCard

local BtnContainer = Instance.new("Frame")
BtnContainer.Size = UDim2.new(1, -30, 0, 34)
BtnContainer.Position = UDim2.new(0, 15, 1, -48)
BtnContainer.BackgroundTransparency = 1
BtnContainer.ZIndex = 52
BtnContainer.Parent = ModalCard

local CancelBtn = Instance.new("TextButton")
CancelBtn.Size = UDim2.new(0.47, 0, 1, 0)
CancelBtn.Position = UDim2.new(0, 0, 0, 0)
CancelBtn.BackgroundColor3 = Theme.BGMain
CancelBtn.Text = "Batal"
CancelBtn.TextColor3 = Theme.TextPri
CancelBtn.Font = Enum.Font.GothamMedium
CancelBtn.TextSize = 12
CancelBtn.ZIndex = 53
CancelBtn.Parent = BtnContainer

local CancelCorner = Instance.new("UICorner")
CancelCorner.CornerRadius = UDim.new(0, 6)
CancelCorner.Parent = CancelBtn

local ConfirmBtn = Instance.new("TextButton")
ConfirmBtn.Size = UDim2.new(0.47, 0, 1, 0)
ConfirmBtn.Position = UDim2.new(0.53, 0, 0, 0)
ConfirmBtn.BackgroundColor3 = Theme.Danger
ConfirmBtn.Text = "Setuju"
ConfirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfirmBtn.Font = Enum.Font.GothamBold
ConfirmBtn.TextSize = 12
ConfirmBtn.ZIndex = 53
ConfirmBtn.Parent = BtnContainer

local ConfirmCorner = Instance.new("UICorner")
ConfirmCorner.CornerRadius = UDim.new(0, 6)
ConfirmCorner.Parent = ConfirmBtn

CancelBtn.MouseEnter:Connect(function()
    TweenService:Create(CancelBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.BGCardHover}):Play()
end)
CancelBtn.MouseLeave:Connect(function()
    TweenService:Create(CancelBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.BGMain}):Play()
end)

ConfirmBtn.MouseEnter:Connect(function()
    TweenService:Create(ConfirmBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(220, 80, 80)}):Play()
end)
ConfirmBtn.MouseLeave:Connect(function()
    TweenService:Create(ConfirmBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Danger}):Play()
end)

CancelBtn.MouseButton1Click:Connect(function()
    ConfirmModal.Visible = false
end)

ConfirmBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

CloseBtn.MouseButton1Click:Connect(function()
    ConfirmModal.Visible = true
end)

-- Smooth Window Dragging
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

-- [[ SIDEBAR ]] --
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 150, 1, -44)
Sidebar.Position = UDim2.new(0, 0, 0, 44)
Sidebar.BackgroundColor3 = Theme.BGSidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarSep = Instance.new("Frame")
SidebarSep.Size = UDim2.new(0, 1, 1, 0)
SidebarSep.Position = UDim2.new(1, -1, 0, 0)
SidebarSep.BackgroundColor3 = Theme.Border
SidebarSep.BorderSizePixel = 0
SidebarSep.Parent = Sidebar

local SidebarPad = Instance.new("UIPadding")
SidebarPad.PaddingTop = UDim.new(0, 10)
SidebarPad.PaddingLeft = UDim.new(0, 8)
SidebarPad.PaddingRight = UDim.new(0, 8)
SidebarPad.Parent = Sidebar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 4)
TabListLayout.Parent = Sidebar

-- [[ CONTENT AREA ]] --
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "Content"
ContentContainer.Size = UDim2.new(1, -150, 1, -44)
ContentContainer.Position = UDim2.new(0, 150, 0, 44)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- [[ UI SYSTEM BUILDER ]] --
local Tabs = {}
local TabButtons = {}
local currentActiveTab = nil

local function CreateTab(tabName, iconText)
    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Name = tabName .. "Page"
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.ScrollBarThickness = 3
    TabPage.ScrollBarImageColor3 = Theme.Accent
    TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabPage.Visible = false
    TabPage.Parent = ContentContainer

    local PageList = Instance.new("UIListLayout")
    PageList.SortOrder = Enum.SortOrder.LayoutOrder
    PageList.Padding = UDim.new(0, 8)
    PageList.Parent = TabPage

    local PagePad = Instance.new("UIPadding")
    PagePad.PaddingTop = UDim.new(0, 12)
    PagePad.PaddingLeft = UDim.new(0, 14)
    PagePad.PaddingRight = UDim.new(0, 14)
    PagePad.PaddingBottom = UDim.new(0, 14)
    PagePad.Parent = TabPage

    -- Sidebar Tab Button
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 36)
    TabBtn.BackgroundColor3 = Theme.BGCard
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = ""
    TabBtn.Parent = Sidebar

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = TabBtn

    -- Active Accent Pillar
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 3, 0, 0)
    Indicator.Position = UDim2.new(0, 0, 0.5, 0)
    Indicator.AnchorPoint = Vector2.new(0, 0.5)
    Indicator.BackgroundColor3 = Theme.Accent
    Indicator.BorderSizePixel = 0
    Indicator.BackgroundTransparency = 1
    Indicator.Parent = TabBtn

    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(0, 2)
    IndCorner.Parent = Indicator

    -- Icon Label
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(0, 24, 0, 36)
    IconLabel.Position = UDim2.new(0, 8, 0, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = iconText or "✦"
    IconLabel.TextColor3 = Theme.TextMuted
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.TextSize = 13
    IconLabel.Parent = TabBtn

    -- Text Label
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, -40, 0, 36)
    TextLabel.Position = UDim2.new(0, 34, 0, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = tabName
    TextLabel.TextColor3 = Theme.TextMuted
    TextLabel.Font = Enum.Font.GothamMedium
    TextLabel.TextSize = 12
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Parent = TabBtn

    local function setActive(active)
        local bgTarget = active and Theme.BGCard or Color3.fromRGB(0, 0, 0)
        local bgAlpha = active and 0.5 or 1
        local textTarget = active and Theme.TextPri or Theme.TextMuted
        local iconTarget = active and Theme.Accent or Theme.TextMuted
        local indSize = active and UDim2.new(0, 3, 0, 20) or UDim2.new(0, 3, 0, 0)
        local indAlpha = active and 0 or 1

        TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = bgAlpha, BackgroundColor3 = bgTarget}):Play()
        TweenService:Create(TextLabel, TweenInfo.new(0.2), {TextColor3 = textTarget}):Play()
        TweenService:Create(IconLabel, TweenInfo.new(0.2), {TextColor3 = iconTarget}):Play()
        TweenService:Create(Indicator, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = indSize, BackgroundTransparency = indAlpha}):Play()
    end

    TabBtn.MouseEnter:Connect(function()
        if currentActiveTab ~= tabName then
            TweenService:Create(TabBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.85}):Play()
        end
    end)
    TabBtn.MouseLeave:Connect(function()
        if currentActiveTab ~= tabName then
            TweenService:Create(TabBtn, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        end
    end)

    TabBtn.MouseButton1Click:Connect(function()
        if currentActiveTab == tabName then return end
        currentActiveTab = tabName

        for name, page in pairs(Tabs) do page.Visible = (name == tabName) end
        for name, btn in pairs(TabButtons) do
            btn.setActive(name == tabName)
        end
    end)

    Tabs[tabName] = TabPage
    TabButtons[tabName] = { button = TabBtn, setActive = setActive }

    local Elements = {}

    -- [[ SECTION HEADER ]] --
    function Elements:AddSection(title)
        local SecFrame = Instance.new("Frame")
        SecFrame.Size = UDim2.new(1, 0, 0, 26)
        SecFrame.BackgroundTransparency = 1
        SecFrame.Parent = TabPage

        local SecLabel = Instance.new("TextLabel")
        SecLabel.Size = UDim2.new(1, 0, 1, 0)
        SecLabel.BackgroundTransparency = 1
        SecLabel.Text = string.upper(title)
        SecLabel.TextColor3 = Theme.TextMuted
        SecLabel.Font = Enum.Font.GothamBold
        SecLabel.TextSize = 10
        SecLabel.TextXAlignment = Enum.TextXAlignment.Left
        SecLabel.Parent = SecFrame

        local SecLine = Instance.new("Frame")
        SecLine.Size = UDim2.new(0, 24, 0, 2)
        SecLine.Position = UDim2.new(0, 0, 1, -3)
        SecLine.BackgroundColor3 = Theme.Accent
        SecLine.BackgroundTransparency = 0.3
        SecLine.BorderSizePixel = 0
        SecLine.Parent = SecFrame
    end

    -- [[ BUTTON COMPONENT ]] --
    function Elements:AddButton(text, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 38)
        Btn.BackgroundColor3 = Theme.BGCard
        Btn.Text = ""
        Btn.Parent = TabPage

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = Btn

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Theme.Border
        Stroke.Thickness = 1
        Stroke.Transparency = 0.5
        Stroke.Parent = Btn

        -- Accent hover bar
        local AccBar = Instance.new("Frame")
        AccBar.Size = UDim2.new(0, 3, 0, 0)
        AccBar.Position = UDim2.new(0, 0, 0.5, 0)
        AccBar.AnchorPoint = Vector2.new(0, 0.5)
        AccBar.BackgroundColor3 = Theme.Accent
        AccBar.BorderSizePixel = 0
        AccBar.BackgroundTransparency = 1
        AccBar.Parent = Btn

        local AccBarCorner = Instance.new("UICorner")
        AccBarCorner.CornerRadius = UDim.new(0, 1)
        AccBarCorner.Parent = AccBar

        local BtnLabel = Instance.new("TextLabel")
        BtnLabel.Size = UDim2.new(1, -20, 1, 0)
        BtnLabel.Position = UDim2.new(0, 14, 0, 0)
        BtnLabel.BackgroundTransparency = 1
        BtnLabel.Text = text
        BtnLabel.TextColor3 = Theme.TextPri
        BtnLabel.Font = Enum.Font.GothamMedium
        BtnLabel.TextSize = 12
        BtnLabel.TextXAlignment = Enum.TextXAlignment.Left
        BtnLabel.Parent = Btn

        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.BGCardHover}):Play()
            TweenService:Create(AccBar, TweenInfo.new(0.15), {Size = UDim2.new(0, 3, 0, 20), BackgroundTransparency = 0}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.15), {Color = Theme.Accent, Transparency = 0.6}):Play()
        end)
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.BGCard}):Play()
            TweenService:Create(AccBar, TweenInfo.new(0.15), {Size = UDim2.new(0, 3, 0, 0), BackgroundTransparency = 1}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.15), {Color = Theme.Border, Transparency = 0.5}):Play()
        end)

        Btn.MouseButton1Click:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.08), {BackgroundColor3 = Theme.AccentDim}):Play()
            task.wait(0.08)
            TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.BGCardHover}):Play()
            pcall(callback)
        end)
    end

    -- [[ TOGGLE COMPONENT ]] --
    function Elements:AddToggle(text, default, callback)
        local state = default or false

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 40)
        Frame.BackgroundColor3 = Theme.BGCard
        Frame.Parent = TabPage

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = Frame

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Theme.Border
        Stroke.Thickness = 1
        Stroke.Transparency = 0.5
        Stroke.Parent = Frame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -60, 1, 0)
        Label.Position = UDim2.new(0, 14, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Theme.TextPri
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame

        -- Switch track background
        local SwitchBg = Instance.new("Frame")
        SwitchBg.Size = UDim2.new(0, 38, 0, 20)
        SwitchBg.Position = UDim2.new(1, -50, 0.5, -10)
        SwitchBg.BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff
        SwitchBg.Parent = Frame

        local SwitchCorner = Instance.new("UICorner")
        SwitchCorner.CornerRadius = UDim.new(1, 0)
        SwitchCorner.Parent = SwitchBg

        -- Switch glow backdrop
        local SwitchGlow = Instance.new("Frame")
        SwitchGlow.Size = UDim2.new(0, 44, 0, 26)
        SwitchGlow.Position = UDim2.new(1, -53, 0.5, -13)
        SwitchGlow.BackgroundColor3 = Theme.AccentGlow
        SwitchGlow.BackgroundTransparency = state and 0.75 or 1
        SwitchGlow.ZIndex = 0
        SwitchGlow.Parent = Frame

        local GlowCorner = Instance.new("UICorner")
        GlowCorner.CornerRadius = UDim.new(1, 0)
        GlowCorner.Parent = SwitchGlow

        -- Switch Knob
        local SwitchDot = Instance.new("Frame")
        SwitchDot.Size = UDim2.new(0, 14, 0, 14)
        SwitchDot.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        SwitchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SwitchDot.Parent = SwitchBg

        local DotCorner = Instance.new("UICorner")
        DotCorner.CornerRadius = UDim.new(1, 0)
        DotCorner.Parent = SwitchDot

        local ClickBtn = Instance.new("TextButton")
        ClickBtn.Size = UDim2.new(1, 0, 1, 0)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text = ""
        ClickBtn.Parent = Frame

        ClickBtn.MouseButton1Click:Connect(function()
            state = not state
            local targetBg = state and Theme.Accent or Theme.ToggleOff
            local targetPos = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            local glowAlpha = state and 0.75 or 1

            TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
            TweenService:Create(SwitchDot, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = targetPos}):Play()
            TweenService:Create(SwitchGlow, TweenInfo.new(0.2), {BackgroundTransparency = glowAlpha}):Play()
            pcall(callback, state)
        end)
    end

    -- [[ PARAGRAPH COMPONENT ]] --
    function Elements:AddParagraph(title, content)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 54)
        Frame.BackgroundColor3 = Theme.BGCard
        Frame.Parent = TabPage

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = Frame

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Theme.Border
        Stroke.Thickness = 1
        Stroke.Transparency = 0.5
        Stroke.Parent = Frame

        local LeftAccent = Instance.new("Frame")
        LeftAccent.Size = UDim2.new(0, 3, 0.6, 0)
        LeftAccent.Position = UDim2.new(0, 0, 0.2, 0)
        LeftAccent.BackgroundColor3 = Theme.Accent
        LeftAccent.BackgroundTransparency = 0.3
        LeftAccent.BorderSizePixel = 0
        LeftAccent.Parent = Frame

        local LAccCorner = Instance.new("UICorner")
        LAccCorner.CornerRadius = UDim.new(0, 1)
        LAccCorner.Parent = LeftAccent

        local TitleL = Instance.new("TextLabel")
        TitleL.Size = UDim2.new(1, -22, 0, 18)
        TitleL.Position = UDim2.new(0, 14, 0, 6)
        TitleL.BackgroundTransparency = 1
        TitleL.Text = title
        TitleL.TextColor3 = Theme.Accent
        TitleL.Font = Enum.Font.GothamBold
        TitleL.TextSize = 11
        TitleL.TextXAlignment = Enum.TextXAlignment.Left
        TitleL.Parent = Frame

        local ContentL = Instance.new("TextLabel")
        ContentL.Size = UDim2.new(1, -22, 0, 22)
        ContentL.Position = UDim2.new(0, 14, 0, 24)
        ContentL.BackgroundTransparency = 1
        ContentL.Text = content
        ContentL.TextColor3 = Theme.TextSec
        ContentL.Font = Enum.Font.Gotham
        ContentL.TextSize = 11
        ContentL.TextXAlignment = Enum.TextXAlignment.Left
        ContentL.TextWrapped = true
        ContentL.Parent = Frame

        return {
            Set = function(_, data)
                if data.Title then TitleL.Text = data.Title end
                if data.Content then ContentL.Text = data.Content end
            end
        }
    end

    -- [[ SLIDER COMPONENT ]] --
    function Elements:AddSlider(text, min, max, default, callback)
        local value = default or min

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 52)
        Frame.BackgroundColor3 = Theme.BGCard
        Frame.Parent = TabPage

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = Frame

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Theme.Border
        Stroke.Thickness = 1
        Stroke.Transparency = 0.5
        Stroke.Parent = Frame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.6, 0, 0, 18)
        Label.Position = UDim2.new(0, 14, 0, 6)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Theme.TextPri
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(0.3, 0, 0, 18)
        ValueLabel.Position = UDim2.new(0.7, 0, 0, 6)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = tostring(value)
        ValueLabel.TextColor3 = Theme.Accent
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.TextSize = 12
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = Frame

        local TrackBg = Instance.new("Frame")
        TrackBg.Size = UDim2.new(1, -28, 0, 5)
        TrackBg.Position = UDim2.new(0, 14, 0, 34)
        TrackBg.BackgroundColor3 = Theme.ToggleOff
        TrackBg.BorderSizePixel = 0
        TrackBg.Parent = Frame

        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(1, 0)
        TrackCorner.Parent = TrackBg

        local fillPercent = (value - min) / (max - min)

        local TrackFill = Instance.new("Frame")
        TrackFill.Size = UDim2.new(fillPercent, 0, 1, 0)
        TrackFill.BackgroundColor3 = Theme.Accent
        TrackFill.BorderSizePixel = 0
        TrackFill.Parent = TrackBg

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = TrackFill

        local Thumb = Instance.new("Frame")
        Thumb.Size = UDim2.new(0, 13, 0, 13)
        Thumb.Position = UDim2.new(fillPercent, -6, 0.5, -6)
        Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Thumb.ZIndex = 2
        Thumb.Parent = TrackBg

        local ThumbCorner = Instance.new("UICorner")
        ThumbCorner.CornerRadius = UDim.new(1, 0)
        ThumbCorner.Parent = Thumb

        local sliding = false

        local function updateSlider(inputX)
            local absPos = TrackBg.AbsolutePosition.X
            local absSize = TrackBg.AbsoluteSize.X
            local relative = math.clamp((inputX - absPos) / absSize, 0, 1)
            value = math.floor(min + (max - min) * relative)
            local pct = (value - min) / (max - min)

            TrackFill.Size = UDim2.new(pct, 0, 1, 0)
            Thumb.Position = UDim2.new(pct, -6, 0.5, -6)
            ValueLabel.Text = tostring(value)
            pcall(callback, value)
        end

        TrackBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = true
                updateSlider(input.Position.X)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input.Position.X)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = false
            end
        end)
    end

    return Elements
end

-- [[ CREATE TAB PAGES ]] --
local MainTab    = CreateTab("Main", "✦")
local CharTab    = CreateTab("Character", "◈")
local CombatTab  = CreateTab("Combat", "⚔")
local VisualTab  = CreateTab("Visuals", "👁")
local ShopTab    = CreateTab("Shops", "🛒")
local PlayerTab  = CreateTab("Players", "👤")

-- Set initial active tab
currentActiveTab = "Main"
TabButtons["Main"].setActive(true)
Tabs["Main"].Visible = true

-- [[ FLOATING TOGGLE BUTTON ]] --
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "TerehubFloat"
FloatBtn.Size = UDim2.new(0, 44, 0, 44)
FloatBtn.Position = UDim2.new(0, 16, 0.5, -22)
FloatBtn.BackgroundColor3 = Theme.BGMain
FloatBtn.Text = ""
FloatBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Theme.Accent
FloatStroke.Thickness = 1.5
FloatStroke.Parent = FloatBtn

local FloatIcon = Instance.new("ImageLabel")
FloatIcon.Size = UDim2.new(0, 22, 0, 22)
FloatIcon.Position = UDim2.new(0.5, -11, 0.5, -11)
FloatIcon.BackgroundTransparency = 1
FloatIcon.Image = "rbxassetid://136360402262473"
FloatIcon.ImageColor3 = Theme.Accent
FloatIcon.Parent = FloatBtn

-- Breathing pulse glow animation
task.spawn(function()
    while true do
        TweenService:Create(FloatStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.5}):Play()
        task.wait(1.5)
        TweenService:Create(FloatStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0}):Play()
        task.wait(1.5)
    end
end)

-- Draggable Floating Button Logic
local floatDragging = false
local floatDragStart, floatStartPos
local isFloatMoved = false

FloatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        floatDragging = true
        floatDragStart = input.Position
        floatStartPos = FloatBtn.Position
        isFloatMoved = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if floatDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - floatDragStart
        if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then
            isFloatMoved = true
        end
        FloatBtn.Position = UDim2.new(floatStartPos.X.Scale, floatStartPos.X.Offset + delta.X, floatStartPos.Y.Scale, floatStartPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        floatDragging = false
    end
end)

FloatBtn.MouseButton1Click:Connect(function()
    if not isFloatMoved then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

FloatBtn.MouseEnter:Connect(function()
    TweenService:Create(FloatBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.BGCard}):Play()
    TweenService:Create(FloatIcon, TweenInfo.new(0.15), {ImageColor3 = Theme.AccentBright}):Play()
end)
FloatBtn.MouseLeave:Connect(function()
    TweenService:Create(FloatBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.BGMain}):Play()
    TweenService:Create(FloatIcon, TweenInfo.new(0.15), {ImageColor3 = Theme.Accent}):Play()
end)

-- [[ MAIN TAB FEATURES ]] --
MainTab:AddSection("Skill Check Automation")

local autoSkillCheck = false
MainTab:AddToggle("Auto Perfect Skill Check", false, function(state)
    autoSkillCheck = state
    Notify({Title = "Skill Check", Description = state and "Auto Skill Check diaktifkan!" or "Auto Skill Check dimatikan.", Duration = 2})
end)

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
CharTab:AddSection("Movement Modifiers")

local wsValue = 16
local wsToggle = false

CharTab:AddToggle("Enable Custom WalkSpeed", false, function(state)
    wsToggle = state
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = state and wsValue or 16 end
end)

CharTab:AddSlider("WalkSpeed Speed", 16, 200, 100, function(val)
    wsValue = val
    if wsToggle then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = val end
    end
end)

local infJump = false
CharTab:AddToggle("Infinite Jump", false, function(state)
    infJump = state
    Notify({Title = "Movement", Description = state and "Infinite Jump diaktifkan." or "Infinite Jump dimatikan.", Duration = 2})
end)

UserInputService.JumpRequest:Connect(function()
    if infJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- [[ COMBAT TAB FEATURES ]] --
CombatTab:AddSection("Targeting")

local autoAim = false
CombatTab:AddToggle("Auto Aim Killer", false, function(state)
    autoAim = state
end)

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

-- [[ SHOPS TAB FEATURES ]] --
ShopTab:AddSection("Developer Scanner")

ShopTab:AddButton("Scan All Remotes (Console F9)", function()
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
    Notify({Title = "Scanner", Description = "Scan remote selesai! Cek Console (F9).", Duration = 3})
end)

ShopTab:AddSection("Auto Purchase")

ShopTab:AddButton("Buy All Default Items (Once)", function()
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
        Notify({Title = "Auto Buy", Description = "Selesai memicu pembelian semua item.", Duration = 3})
    end)
end)

local autoBuyAllShops = false
ShopTab:AddToggle("Auto Buy All (Loop 1s)", false, function(state)
    autoBuyAllShops = state
end)

ShopTab:AddSection("Restock Monitor")

local RestockParagraph = ShopTab:AddParagraph("Restock Countdown", "Memantau status restock...")

task.spawn(function()
    while true do
        pcall(function()
            local pGui = LocalPlayer:FindFirstChild("PlayerGui")
            local mapShops = pGui and pGui:FindFirstChild("MapShops")
            local mainFrame = mapShops and mapShops:FindFirstChild("Main")
            local timerLabel = mainFrame and (mainFrame:FindFirstChild("Timer") or mainFrame:FindFirstChild("RestockTime") or mainFrame:FindFirstChildWhichIsA("TextLabel", true))

            if timerLabel and timerLabel:IsA("TextLabel") and timerLabel.Text ~= "" then
                RestockParagraph:Set({ Title = "Restock Countdown", Content = "Waktu Restock: " .. tostring(timerLabel.Text) })
            else
                RestockParagraph:Set({ Title = "Restock Countdown", Content = "Status: Memantau restock (Buka GUI Shop)" })
            end
        end)
        task.wait(1)
    end
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

-- Initial Welcome Toast
Notify({Title = "Terehub", Description = "UI Modern berhasil dimuat!", Duration = 4})
print("Terehub Modern UI: Successfully Loaded!")
