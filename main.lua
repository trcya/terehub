local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()

-- [[ CLEANUP ]] --
if CoreGui:FindFirstChild("TerehubUI") then
    CoreGui.TerehubUI:Destroy()
end

-- ╔══════════════════════════════════════════════════╗
-- ║            DESIGN SYSTEM & THEME                 ║
-- ╚══════════════════════════════════════════════════╝
local Theme = {
    -- Backgrounds
    BGDeep          = Color3.fromRGB(8, 9, 14),
    BGMain          = Color3.fromRGB(14, 16, 23),
    BGSidebar       = Color3.fromRGB(11, 12, 18),
    BGCard          = Color3.fromRGB(20, 23, 33),
    BGCardHover     = Color3.fromRGB(28, 32, 46),
    BGTopBar        = Color3.fromRGB(11, 13, 19),
    BGInput         = Color3.fromRGB(16, 18, 26),
    -- Accents
    Accent          = Color3.fromRGB(0, 220, 185),
    AccentSecondary = Color3.fromRGB(120, 90, 255),
    AccentPink      = Color3.fromRGB(255, 100, 180),
    AccentDim       = Color3.fromRGB(0, 155, 135),
    AccentBright    = Color3.fromRGB(50, 255, 220),
    AccentGlow      = Color3.fromRGB(0, 220, 185),
    -- Text
    TextPri         = Color3.fromRGB(235, 240, 250),
    TextSec         = Color3.fromRGB(120, 132, 160),
    TextMuted       = Color3.fromRGB(68, 76, 100),
    -- Borders
    Border          = Color3.fromRGB(30, 35, 50),
    BorderLight     = Color3.fromRGB(42, 48, 68),
    -- States
    Danger          = Color3.fromRGB(255, 95, 95),
    Success         = Color3.fromRGB(80, 220, 120),
    Warning         = Color3.fromRGB(255, 190, 60),
    ToggleOff       = Color3.fromRGB(30, 34, 48),
}

-- ╔══════════════════════════════════════════════════╗
-- ║                SCREEN GUI                        ║
-- ╚══════════════════════════════════════════════════╝
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TerehubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- ╔══════════════════════════════════════════════════╗
-- ║         ANIMATED SPLASH / LOADING SCREEN         ║
-- ╚══════════════════════════════════════════════════╝
local SplashOverlay = Instance.new("Frame")
SplashOverlay.Name = "Splash"
SplashOverlay.Size = UDim2.new(1, 0, 1, 0)
SplashOverlay.BackgroundColor3 = Theme.BGDeep
SplashOverlay.BackgroundTransparency = 0
SplashOverlay.ZIndex = 200
SplashOverlay.Parent = ScreenGui

local SplashIcon = Instance.new("ImageLabel")
SplashIcon.Size = UDim2.new(0, 60, 0, 60)
SplashIcon.Position = UDim2.new(0.5, -30, 0.45, -30)
SplashIcon.BackgroundTransparency = 1
SplashIcon.Image = "rbxassetid://136360402262473"
SplashIcon.ImageColor3 = Theme.Accent
SplashIcon.ImageTransparency = 1
SplashIcon.ZIndex = 201
SplashIcon.Parent = SplashOverlay

local SplashTitle = Instance.new("TextLabel")
SplashTitle.Size = UDim2.new(0, 200, 0, 30)
SplashTitle.Position = UDim2.new(0.5, -100, 0.45, 40)
SplashTitle.BackgroundTransparency = 1
SplashTitle.Text = "TEREHUB"
SplashTitle.TextColor3 = Theme.TextPri
SplashTitle.Font = Enum.Font.GothamBold
SplashTitle.TextSize = 22
SplashTitle.TextTransparency = 1
SplashTitle.ZIndex = 201
SplashTitle.Parent = SplashOverlay

local SplashSub = Instance.new("TextLabel")
SplashSub.Size = UDim2.new(0, 300, 0, 20)
SplashSub.Position = UDim2.new(0.5, -150, 0.45, 72)
SplashSub.BackgroundTransparency = 1
SplashSub.Text = "Modern Edition — Loading..."
SplashSub.TextColor3 = Theme.TextMuted
SplashSub.Font = Enum.Font.GothamMedium
SplashSub.TextSize = 12
SplashSub.TextTransparency = 1
SplashSub.ZIndex = 201
SplashSub.Parent = SplashOverlay

-- Progress Bar
local ProgressBg = Instance.new("Frame")
ProgressBg.Size = UDim2.new(0, 200, 0, 3)
ProgressBg.Position = UDim2.new(0.5, -100, 0.45, 100)
ProgressBg.BackgroundColor3 = Theme.ToggleOff
ProgressBg.BorderSizePixel = 0
ProgressBg.ZIndex = 201
ProgressBg.Parent = SplashOverlay

local ProgressCornerBg = Instance.new("UICorner")
ProgressCornerBg.CornerRadius = UDim.new(1, 0)
ProgressCornerBg.Parent = ProgressBg

local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Theme.Accent
ProgressFill.BorderSizePixel = 0
ProgressFill.ZIndex = 202
ProgressFill.Parent = ProgressBg

local ProgressCornerFill = Instance.new("UICorner")
ProgressCornerFill.CornerRadius = UDim.new(1, 0)
ProgressCornerFill.Parent = ProgressFill

local ProgressGrad = Instance.new("UIGradient")
ProgressGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Accent),
    ColorSequenceKeypoint.new(0.5, Theme.AccentSecondary),
    ColorSequenceKeypoint.new(1, Theme.AccentPink),
})
ProgressGrad.Parent = ProgressFill

-- ╔══════════════════════════════════════════════════╗
-- ║          TOAST NOTIFICATION SYSTEM                ║
-- ╚══════════════════════════════════════════════════╝
local NotificationHolder = Instance.new("Frame")
NotificationHolder.Name = "Notifications"
NotificationHolder.Size = UDim2.new(0, 280, 1, -50)
NotificationHolder.Position = UDim2.new(1, -290, 0, 25)
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
    local icon = cfg.Icon or "✦"

    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(1, 0, 0, 58)
    NotifFrame.BackgroundColor3 = Theme.BGCard
    NotifFrame.BorderSizePixel = 0
    NotifFrame.BackgroundTransparency = 1
    NotifFrame.Parent = NotificationHolder

    local NCorner = Instance.new("UICorner")
    NCorner.CornerRadius = UDim.new(0, 10)
    NCorner.Parent = NotifFrame

    local NStroke = Instance.new("UIStroke")
    NStroke.Color = Theme.Accent
    NStroke.Thickness = 1
    NStroke.Transparency = 1
    NStroke.Parent = NotifFrame

    -- Accent left bar
    local NBar = Instance.new("Frame")
    NBar.Size = UDim2.new(0, 3, 0.65, 0)
    NBar.Position = UDim2.new(0, 6, 0.175, 0)
    NBar.BackgroundColor3 = Theme.Accent
    NBar.BorderSizePixel = 0
    NBar.BackgroundTransparency = 1
    NBar.Parent = NotifFrame
    local NBarC = Instance.new("UICorner")
    NBarC.CornerRadius = UDim.new(1, 0)
    NBarC.Parent = NBar

    -- Icon
    local NIcon = Instance.new("TextLabel")
    NIcon.Size = UDim2.new(0, 24, 0, 24)
    NIcon.Position = UDim2.new(0, 14, 0.5, -12)
    NIcon.BackgroundTransparency = 1
    NIcon.Text = icon
    NIcon.TextColor3 = Theme.Accent
    NIcon.Font = Enum.Font.GothamBold
    NIcon.TextSize = 16
    NIcon.TextTransparency = 1
    NIcon.Parent = NotifFrame

    local NTitle = Instance.new("TextLabel")
    NTitle.Size = UDim2.new(1, -48, 0, 18)
    NTitle.Position = UDim2.new(0, 42, 0, 8)
    NTitle.BackgroundTransparency = 1
    NTitle.Text = title
    NTitle.TextColor3 = Theme.TextPri
    NTitle.Font = Enum.Font.GothamBold
    NTitle.TextSize = 12
    NTitle.TextXAlignment = Enum.TextXAlignment.Left
    NTitle.TextTransparency = 1
    NTitle.Parent = NotifFrame

    local NDesc = Instance.new("TextLabel")
    NDesc.Size = UDim2.new(1, -48, 0, 18)
    NDesc.Position = UDim2.new(0, 42, 0, 28)
    NDesc.BackgroundTransparency = 1
    NDesc.Text = desc
    NDesc.TextColor3 = Theme.TextSec
    NDesc.Font = Enum.Font.Gotham
    NDesc.TextSize = 11
    NDesc.TextXAlignment = Enum.TextXAlignment.Left
    NDesc.TextTransparency = 1
    NDesc.TextWrapped = true
    NDesc.Parent = NotifFrame

    -- Countdown bar at bottom
    local NProgress = Instance.new("Frame")
    NProgress.Size = UDim2.new(1, -12, 0, 2)
    NProgress.Position = UDim2.new(0, 6, 1, -6)
    NProgress.BackgroundColor3 = Theme.Accent
    NProgress.BorderSizePixel = 0
    NProgress.BackgroundTransparency = 1
    NProgress.Parent = NotifFrame
    local NPC = Instance.new("UICorner")
    NPC.CornerRadius = UDim.new(1, 0)
    NPC.Parent = NProgress

    -- Animate in
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    TweenService:Create(NotifFrame, tweenInfo, {BackgroundTransparency = 0.04}):Play()
    TweenService:Create(NStroke, tweenInfo, {Transparency = 0.5}):Play()
    TweenService:Create(NBar, tweenInfo, {BackgroundTransparency = 0}):Play()
    TweenService:Create(NIcon, tweenInfo, {TextTransparency = 0}):Play()
    TweenService:Create(NTitle, tweenInfo, {TextTransparency = 0}):Play()
    TweenService:Create(NDesc, tweenInfo, {TextTransparency = 0}):Play()
    TweenService:Create(NProgress, tweenInfo, {BackgroundTransparency = 0.3}):Play()

    -- Countdown bar shrinks
    TweenService:Create(NProgress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)}):Play()

    task.delay(duration, function()
        local outInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        TweenService:Create(NotifFrame, outInfo, {BackgroundTransparency = 1}):Play()
        TweenService:Create(NStroke, outInfo, {Transparency = 1}):Play()
        TweenService:Create(NBar, outInfo, {BackgroundTransparency = 1}):Play()
        TweenService:Create(NIcon, outInfo, {TextTransparency = 1}):Play()
        TweenService:Create(NTitle, outInfo, {TextTransparency = 1}):Play()
        TweenService:Create(NDesc, outInfo, {TextTransparency = 1}):Play()
        local tw = TweenService:Create(NProgress, outInfo, {BackgroundTransparency = 1})
        tw:Play()
        tw.Completed:Wait()
        NotifFrame:Destroy()
    end)
end

-- ╔══════════════════════════════════════════════════╗
-- ║                 MAIN WINDOW                       ║
-- ╚══════════════════════════════════════════════════╝
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainWindow"
MainFrame.Size = UDim2.new(0, 660, 0, 460)
MainFrame.Position = UDim2.new(0.5, -330, 0.5, -230)
MainFrame.BackgroundColor3 = Theme.BGMain
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Border
MainStroke.Thickness = 1.2
MainStroke.Transparency = 0.15
MainStroke.Parent = MainFrame

-- Diagonal background gradient
local BgGradient = Instance.new("UIGradient")
BgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.BGMain),
    ColorSequenceKeypoint.new(1, Theme.BGDeep),
})
BgGradient.Rotation = 135
BgGradient.Parent = MainFrame

-- Animated top accent bar with shifting gradient
local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.Position = UDim2.new(0, 0, 0, 0)
AccentLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
AccentLine.BorderSizePixel = 0
AccentLine.ZIndex = 5
AccentLine.Parent = MainFrame

local AccentGrad = Instance.new("UIGradient")
AccentGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Accent),
    ColorSequenceKeypoint.new(0.35, Theme.AccentSecondary),
    ColorSequenceKeypoint.new(0.7, Theme.AccentPink),
    ColorSequenceKeypoint.new(1, Theme.Accent),
})
AccentGrad.Parent = AccentLine

-- Animate the gradient offset for a flowing effect
task.spawn(function()
    local offset = 0
    while AccentLine and AccentLine.Parent do
        offset = (offset + 0.005) % 1
        AccentGrad.Offset = Vector2.new(offset, 0)
        RunService.Heartbeat:Wait()
    end
end)

-- ╔══════════════════════════════════════════════════╗
-- ║                    TOPBAR                         ║
-- ╚══════════════════════════════════════════════════╝
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 44)
TopBar.Position = UDim2.new(0, 0, 0, 2)
TopBar.BackgroundColor3 = Theme.BGTopBar
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 4
TopBar.Parent = MainFrame

local TopBarSep = Instance.new("Frame")
TopBarSep.Size = UDim2.new(1, 0, 0, 1)
TopBarSep.Position = UDim2.new(0, 0, 1, -1)
TopBarSep.BackgroundColor3 = Theme.Border
TopBarSep.BorderSizePixel = 0
TopBarSep.Parent = TopBar

-- Logo Icon
local TitleIcon = Instance.new("ImageLabel")
TitleIcon.Size = UDim2.new(0, 22, 0, 22)
TitleIcon.Position = UDim2.new(0, 14, 0.5, -11)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Image = "rbxassetid://136360402262473"
TitleIcon.ImageColor3 = Theme.Accent
TitleIcon.Parent = TopBar

-- Title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 90, 1, 0)
TitleLabel.Position = UDim2.new(0, 42, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "TEREHUB"
TitleLabel.TextColor3 = Theme.TextPri
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Version badge
local VerBadge = Instance.new("Frame")
VerBadge.Size = UDim2.new(0, 36, 0, 16)
VerBadge.Position = UDim2.new(0, 130, 0.5, -8)
VerBadge.BackgroundColor3 = Theme.AccentSecondary
VerBadge.BackgroundTransparency = 0.8
VerBadge.Parent = TopBar

local VerBadgeCorner = Instance.new("UICorner")
VerBadgeCorner.CornerRadius = UDim.new(0, 4)
VerBadgeCorner.Parent = VerBadge

local VerLabel = Instance.new("TextLabel")
VerLabel.Size = UDim2.new(1, 0, 1, 0)
VerLabel.BackgroundTransparency = 1
VerLabel.Text = "v2.0"
VerLabel.TextColor3 = Theme.AccentSecondary
VerLabel.Font = Enum.Font.GothamBold
VerLabel.TextSize = 9
VerLabel.Parent = VerBadge

local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(0, 200, 1, 0)
SubLabel.Position = UDim2.new(0, 174, 0, 0)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "Violence District"
SubLabel.TextColor3 = Theme.TextMuted
SubLabel.TextSize = 11
SubLabel.Font = Enum.Font.GothamMedium
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Parent = TopBar

-- Window Control Buttons
local ControlContainer = Instance.new("Frame")
ControlContainer.Size = UDim2.new(0, 66, 0, 28)
ControlContainer.Position = UDim2.new(1, -76, 0.5, -14)
ControlContainer.BackgroundTransparency = 1
ControlContainer.Parent = TopBar

local ControlLayout = Instance.new("UIListLayout")
ControlLayout.FillDirection = Enum.FillDirection.Horizontal
ControlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ControlLayout.Padding = UDim.new(0, 6)
ControlLayout.Parent = ControlContainer

-- Minimize
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
MinCorner.CornerRadius = UDim.new(0, 7)
MinCorner.Parent = MinimizeBtn

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.BackgroundColor3 = Theme.Danger
CloseBtn.BackgroundTransparency = 0.3
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
CloseCorner.CornerRadius = UDim.new(0, 7)
CloseCorner.Parent = CloseBtn

-- Hover animations
MinimizeBtn.MouseEnter:Connect(function()
    TweenService:Create(MinimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.BGCardHover}):Play()
    TweenService:Create(MinIcon, TweenInfo.new(0.15), {BackgroundColor3 = Theme.TextPri}):Play()
end)
MinimizeBtn.MouseLeave:Connect(function()
    TweenService:Create(MinimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.BGCard}):Play()
    TweenService:Create(MinIcon, TweenInfo.new(0.15), {BackgroundColor3 = Theme.TextSec}):Play()
end)
CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0, BackgroundColor3 = Theme.Danger}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.3, BackgroundColor3 = Theme.Danger}):Play()
end)

-- Minimize logic
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 660, 0, 46) or UDim2.new(0, 660, 0, 460)
    TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

-- ╔══════════════════════════════════════════════════╗
-- ║         CONFIRMATION CLOSE MODAL                  ║
-- ╚══════════════════════════════════════════════════╝
local ConfirmModal = Instance.new("Frame")
ConfirmModal.Name = "ConfirmModal"
ConfirmModal.Size = UDim2.new(1, 0, 1, 0)
ConfirmModal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ConfirmModal.BackgroundTransparency = 1
ConfirmModal.ZIndex = 50
ConfirmModal.Visible = false
ConfirmModal.Parent = MainFrame

local ModalCard = Instance.new("Frame")
ModalCard.Name = "ModalCard"
ModalCard.Size = UDim2.new(0, 340, 0, 170)
ModalCard.Position = UDim2.new(0.5, -170, 0.5, -85)
ModalCard.BackgroundColor3 = Theme.BGCard
ModalCard.BorderSizePixel = 0
ModalCard.ZIndex = 51
ModalCard.ClipsDescendants = true
ModalCard.Parent = ConfirmModal

local ModalCorner = Instance.new("UICorner")
ModalCorner.CornerRadius = UDim.new(0, 12)
ModalCorner.Parent = ModalCard

local ModalStroke = Instance.new("UIStroke")
ModalStroke.Color = Theme.Danger
ModalStroke.Thickness = 1
ModalStroke.Transparency = 0.5
ModalStroke.Parent = ModalCard

-- Modal top accent
local ModalAccent = Instance.new("Frame")
ModalAccent.Size = UDim2.new(1, 0, 0, 2)
ModalAccent.BackgroundColor3 = Theme.Danger
ModalAccent.BorderSizePixel = 0
ModalAccent.ZIndex = 52
ModalAccent.Parent = ModalCard

-- Warning Icon
local ModalIcon = Instance.new("TextLabel")
ModalIcon.Size = UDim2.new(0, 30, 0, 30)
ModalIcon.Position = UDim2.new(0, 16, 0, 18)
ModalIcon.BackgroundTransparency = 1
ModalIcon.Text = "⚠"
ModalIcon.TextColor3 = Theme.Danger
ModalIcon.Font = Enum.Font.GothamBold
ModalIcon.TextSize = 20
ModalIcon.ZIndex = 52
ModalIcon.Parent = ModalCard

local ModalTitle = Instance.new("TextLabel")
ModalTitle.Size = UDim2.new(1, -60, 0, 22)
ModalTitle.Position = UDim2.new(0, 50, 0, 18)
ModalTitle.BackgroundTransparency = 1
ModalTitle.Text = "Konfirmasi Penutupan"
ModalTitle.TextColor3 = Theme.TextPri
ModalTitle.Font = Enum.Font.GothamBold
ModalTitle.TextSize = 14
ModalTitle.TextXAlignment = Enum.TextXAlignment.Left
ModalTitle.ZIndex = 52
ModalTitle.Parent = ModalCard

local ModalText = Instance.new("TextLabel")
ModalText.Size = UDim2.new(1, -32, 0, 40)
ModalText.Position = UDim2.new(0, 16, 0, 52)
ModalText.BackgroundTransparency = 1
ModalText.Text = "Apakah Anda yakin ingin menutup Terehub?\nSemua fitur aktif akan dimatikan."
ModalText.TextColor3 = Theme.TextSec
ModalText.Font = Enum.Font.Gotham
ModalText.TextSize = 12
ModalText.TextWrapped = true
ModalText.TextXAlignment = Enum.TextXAlignment.Left
ModalText.ZIndex = 52
ModalText.Parent = ModalCard

local ModalBtnContainer = Instance.new("Frame")
ModalBtnContainer.Size = UDim2.new(1, -32, 0, 36)
ModalBtnContainer.Position = UDim2.new(0, 16, 1, -52)
ModalBtnContainer.BackgroundTransparency = 1
ModalBtnContainer.ZIndex = 52
ModalBtnContainer.Parent = ModalCard

local CancelBtn = Instance.new("TextButton")
CancelBtn.Size = UDim2.new(0.48, 0, 1, 0)
CancelBtn.Position = UDim2.new(0, 0, 0, 0)
CancelBtn.BackgroundColor3 = Theme.BGMain
CancelBtn.Text = "Batal"
CancelBtn.TextColor3 = Theme.TextPri
CancelBtn.Font = Enum.Font.GothamMedium
CancelBtn.TextSize = 12
CancelBtn.ZIndex = 53
CancelBtn.Parent = ModalBtnContainer

local CancelCorner = Instance.new("UICorner")
CancelCorner.CornerRadius = UDim.new(0, 8)
CancelCorner.Parent = CancelBtn

local CancelStroke = Instance.new("UIStroke")
CancelStroke.Color = Theme.Border
CancelStroke.Thickness = 1
CancelStroke.Parent = CancelBtn

local ConfirmBtn = Instance.new("TextButton")
ConfirmBtn.Size = UDim2.new(0.48, 0, 1, 0)
ConfirmBtn.Position = UDim2.new(0.52, 0, 0, 0)
ConfirmBtn.BackgroundColor3 = Theme.Danger
ConfirmBtn.Text = "Ya, Tutup"
ConfirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfirmBtn.Font = Enum.Font.GothamBold
ConfirmBtn.TextSize = 12
ConfirmBtn.ZIndex = 53
ConfirmBtn.Parent = ModalBtnContainer

local ConfirmCorner = Instance.new("UICorner")
ConfirmCorner.CornerRadius = UDim.new(0, 8)
ConfirmCorner.Parent = ConfirmBtn

CancelBtn.MouseEnter:Connect(function()
    TweenService:Create(CancelBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.BGCardHover}):Play()
end)
CancelBtn.MouseLeave:Connect(function()
    TweenService:Create(CancelBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.BGMain}):Play()
end)
ConfirmBtn.MouseEnter:Connect(function()
    TweenService:Create(ConfirmBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(230, 70, 70)}):Play()
end)
ConfirmBtn.MouseLeave:Connect(function()
    TweenService:Create(ConfirmBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Danger}):Play()
end)

local function showModal()
    ConfirmModal.Visible = true
    ConfirmModal.BackgroundTransparency = 1
    ModalCard.Size = UDim2.new(0, 300, 0, 150)
    ModalCard.Position = UDim2.new(0.5, -150, 0.5, -75)

    TweenService:Create(ConfirmModal, TweenInfo.new(0.25), {BackgroundTransparency = 0.45}):Play()
    TweenService:Create(ModalCard, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 340, 0, 170),
        Position = UDim2.new(0.5, -170, 0.5, -85),
    }):Play()
end

local function hideModal()
    TweenService:Create(ConfirmModal, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    local tw = TweenService:Create(ModalCard, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 300, 0, 150),
        Position = UDim2.new(0.5, -150, 0.5, -75),
    })
    tw:Play()
    tw.Completed:Wait()
    ConfirmModal.Visible = false
end

CancelBtn.MouseButton1Click:Connect(function() task.spawn(hideModal) end)
ConfirmBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
CloseBtn.MouseButton1Click:Connect(function() showModal() end)

-- ╔══════════════════════════════════════════════════╗
-- ║               WINDOW DRAGGING                     ║
-- ╚══════════════════════════════════════════════════╝
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

-- ╔══════════════════════════════════════════════════╗
-- ║                   SIDEBAR                         ║
-- ╚══════════════════════════════════════════════════╝
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 155, 1, -46)
Sidebar.Position = UDim2.new(0, 0, 0, 46)
Sidebar.BackgroundColor3 = Theme.BGSidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarSep = Instance.new("Frame")
SidebarSep.Size = UDim2.new(0, 1, 1, 0)
SidebarSep.Position = UDim2.new(1, -1, 0, 0)
SidebarSep.BackgroundColor3 = Theme.Border
SidebarSep.BorderSizePixel = 0
SidebarSep.Parent = Sidebar

-- Sidebar branding area
local SidebarBrand = Instance.new("Frame")
SidebarBrand.Size = UDim2.new(1, 0, 0, 50)
SidebarBrand.BackgroundTransparency = 1
SidebarBrand.Parent = Sidebar

local BrandIcon = Instance.new("ImageLabel")
BrandIcon.Size = UDim2.new(0, 28, 0, 28)
BrandIcon.Position = UDim2.new(0, 14, 0.5, -14)
BrandIcon.BackgroundTransparency = 1
BrandIcon.Image = "rbxassetid://136360402262473"
BrandIcon.ImageColor3 = Theme.Accent
BrandIcon.Parent = SidebarBrand

local BrandText = Instance.new("TextLabel")
BrandText.Size = UDim2.new(1, -52, 1, 0)
BrandText.Position = UDim2.new(0, 48, 0, 0)
BrandText.BackgroundTransparency = 1
BrandText.Text = "Menu"
BrandText.TextColor3 = Theme.TextSec
BrandText.Font = Enum.Font.GothamBold
BrandText.TextSize = 10
BrandText.TextXAlignment = Enum.TextXAlignment.Left
BrandText.Parent = SidebarBrand

local BrandSep = Instance.new("Frame")
BrandSep.Size = UDim2.new(0.7, 0, 0, 1)
BrandSep.Position = UDim2.new(0.15, 0, 1, -1)
BrandSep.BackgroundColor3 = Theme.Border
BrandSep.BorderSizePixel = 0
BrandSep.Parent = SidebarBrand

-- Tab list area
local TabArea = Instance.new("Frame")
TabArea.Size = UDim2.new(1, 0, 1, -50)
TabArea.Position = UDim2.new(0, 0, 0, 50)
TabArea.BackgroundTransparency = 1
TabArea.Parent = Sidebar

local TabPad = Instance.new("UIPadding")
TabPad.PaddingTop = UDim.new(0, 6)
TabPad.PaddingLeft = UDim.new(0, 8)
TabPad.PaddingRight = UDim.new(0, 8)
TabPad.Parent = TabArea

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 3)
TabListLayout.Parent = TabArea

-- ╔══════════════════════════════════════════════════╗
-- ║              CONTENT AREA & STATUS BAR            ║
-- ╚══════════════════════════════════════════════════╝
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "Content"
ContentContainer.Size = UDim2.new(1, -155, 1, -72)
ContentContainer.Position = UDim2.new(0, 155, 0, 46)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- Status bar at the bottom
local StatusBar = Instance.new("Frame")
StatusBar.Name = "StatusBar"
StatusBar.Size = UDim2.new(1, -155, 0, 26)
StatusBar.Position = UDim2.new(0, 155, 1, -26)
StatusBar.BackgroundColor3 = Theme.BGTopBar
StatusBar.BorderSizePixel = 0
StatusBar.Parent = MainFrame

local StatusSep = Instance.new("Frame")
StatusSep.Size = UDim2.new(1, 0, 0, 1)
StatusSep.BackgroundColor3 = Theme.Border
StatusSep.BorderSizePixel = 0
StatusSep.Parent = StatusBar

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 6, 0, 6)
StatusDot.Position = UDim2.new(0, 10, 0.5, -3)
StatusDot.BackgroundColor3 = Theme.Success
StatusDot.BorderSizePixel = 0
StatusDot.Parent = StatusBar

local StatusDotCorner = Instance.new("UICorner")
StatusDotCorner.CornerRadius = UDim.new(1, 0)
StatusDotCorner.Parent = StatusDot

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 80, 1, 0)
StatusLabel.Position = UDim2.new(0, 22, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Connected"
StatusLabel.TextColor3 = Theme.Success
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 10
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusBar

-- Animated status dot pulse
task.spawn(function()
    while StatusDot and StatusDot.Parent do
        TweenService:Create(StatusDot, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.5}):Play()
        task.wait(1)
        TweenService:Create(StatusDot, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0}):Play()
        task.wait(1)
    end
end)

local ClockLabel = Instance.new("TextLabel")
ClockLabel.Size = UDim2.new(0, 60, 1, 0)
ClockLabel.Position = UDim2.new(1, -70, 0, 0)
ClockLabel.BackgroundTransparency = 1
ClockLabel.Text = "00:00"
ClockLabel.TextColor3 = Theme.TextMuted
ClockLabel.Font = Enum.Font.GothamMedium
ClockLabel.TextSize = 10
ClockLabel.TextXAlignment = Enum.TextXAlignment.Right
ClockLabel.Parent = StatusBar

local UserLabel = Instance.new("TextLabel")
UserLabel.Size = UDim2.new(0, 120, 1, 0)
UserLabel.Position = UDim2.new(1, -195, 0, 0)
UserLabel.BackgroundTransparency = 1
UserLabel.Text = LocalPlayer.Name
UserLabel.TextColor3 = Theme.TextMuted
UserLabel.Font = Enum.Font.Gotham
UserLabel.TextSize = 10
UserLabel.TextXAlignment = Enum.TextXAlignment.Right
UserLabel.Parent = StatusBar

-- Live clock update
task.spawn(function()
    while ClockLabel and ClockLabel.Parent do
        local t = os.date("*t")
        ClockLabel.Text = string.format("%02d:%02d", t.hour, t.min)
        task.wait(10)
    end
end)

-- ╔══════════════════════════════════════════════════╗
-- ║            UI COMPONENT SYSTEM                    ║
-- ╚══════════════════════════════════════════════════╝
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
    PageList.Padding = UDim.new(0, 6)
    PageList.Parent = TabPage

    local PagePad = Instance.new("UIPadding")
    PagePad.PaddingTop = UDim.new(0, 10)
    PagePad.PaddingLeft = UDim.new(0, 14)
    PagePad.PaddingRight = UDim.new(0, 14)
    PagePad.PaddingBottom = UDim.new(0, 14)
    PagePad.Parent = TabPage

    -- Sidebar Tab Button
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 34)
    TabBtn.BackgroundColor3 = Theme.BGCard
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = ""
    TabBtn.Parent = TabArea

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = TabBtn

    -- Active indicator bar (left side)
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

    -- Icon
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(0, 24, 0, 34)
    IconLabel.Position = UDim2.new(0, 10, 0, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = iconText or "✦"
    IconLabel.TextColor3 = Theme.TextMuted
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.TextSize = 13
    IconLabel.Parent = TabBtn

    -- Text
    local BtnText = Instance.new("TextLabel")
    BtnText.Size = UDim2.new(1, -42, 0, 34)
    BtnText.Position = UDim2.new(0, 36, 0, 0)
    BtnText.BackgroundTransparency = 1
    BtnText.Text = tabName
    BtnText.TextColor3 = Theme.TextMuted
    BtnText.Font = Enum.Font.GothamMedium
    BtnText.TextSize = 11
    BtnText.TextXAlignment = Enum.TextXAlignment.Left
    BtnText.Parent = TabBtn

    local function setActive(active)
        local bgTarget = active and Theme.BGCard or Color3.fromRGB(0, 0, 0)
        local bgAlpha = active and 0.45 or 1
        local txtTarget = active and Theme.TextPri or Theme.TextMuted
        local iconTarget = active and Theme.Accent or Theme.TextMuted
        local indSize = active and UDim2.new(0, 3, 0, 18) or UDim2.new(0, 3, 0, 0)
        local indAlpha = active and 0 or 1

        TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = bgAlpha, BackgroundColor3 = bgTarget}):Play()
        TweenService:Create(BtnText, TweenInfo.new(0.2), {TextColor3 = txtTarget}):Play()
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

    -- ── SECTION ──
    function Elements:AddSection(title)
        local SecFrame = Instance.new("Frame")
        SecFrame.Size = UDim2.new(1, 0, 0, 28)
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

        -- Gradient underline
        local SecLine = Instance.new("Frame")
        SecLine.Size = UDim2.new(0, 30, 0, 2)
        SecLine.Position = UDim2.new(0, 0, 1, -3)
        SecLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SecLine.BorderSizePixel = 0
        SecLine.Parent = SecFrame

        local SecLineGrad = Instance.new("UIGradient")
        SecLineGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.AccentSecondary),
        })
        SecLineGrad.Parent = SecLine
    end

    -- ── BUTTON ──
    function Elements:AddButton(text, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 40)
        Btn.BackgroundColor3 = Theme.BGCard
        Btn.Text = ""
        Btn.ClipsDescendants = true
        Btn.Parent = TabPage

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 10)
        Corner.Parent = Btn

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Theme.Border
        Stroke.Thickness = 1
        Stroke.Transparency = 0.4
        Stroke.Parent = Btn

        -- Accent hover bar (left side)
        local AccBar = Instance.new("Frame")
        AccBar.Size = UDim2.new(0, 3, 0, 0)
        AccBar.Position = UDim2.new(0, 0, 0.5, 0)
        AccBar.AnchorPoint = Vector2.new(0, 0.5)
        AccBar.BackgroundColor3 = Theme.Accent
        AccBar.BorderSizePixel = 0
        AccBar.BackgroundTransparency = 1
        AccBar.Parent = Btn
        Instance.new("UICorner", AccBar).CornerRadius = UDim.new(0, 1)

        -- Arrow indicator (right side)
        local Arrow = Instance.new("TextLabel")
        Arrow.Size = UDim2.new(0, 20, 1, 0)
        Arrow.Position = UDim2.new(1, -28, 0, 0)
        Arrow.BackgroundTransparency = 1
        Arrow.Text = "›"
        Arrow.TextColor3 = Theme.TextMuted
        Arrow.Font = Enum.Font.GothamBold
        Arrow.TextSize = 16
        Arrow.TextTransparency = 0.5
        Arrow.Parent = Btn

        local BtnLabel = Instance.new("TextLabel")
        BtnLabel.Size = UDim2.new(1, -46, 1, 0)
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
            TweenService:Create(AccBar, TweenInfo.new(0.15), {Size = UDim2.new(0, 3, 0, 22), BackgroundTransparency = 0}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.15), {Color = Theme.Accent, Transparency = 0.5}):Play()
            TweenService:Create(Arrow, TweenInfo.new(0.15), {TextColor3 = Theme.Accent, TextTransparency = 0}):Play()
        end)
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.BGCard}):Play()
            TweenService:Create(AccBar, TweenInfo.new(0.15), {Size = UDim2.new(0, 3, 0, 0), BackgroundTransparency = 1}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.15), {Color = Theme.Border, Transparency = 0.4}):Play()
            TweenService:Create(Arrow, TweenInfo.new(0.15), {TextColor3 = Theme.TextMuted, TextTransparency = 0.5}):Play()
        end)

        Btn.MouseButton1Click:Connect(function()
            -- Ripple flash effect
            local Ripple = Instance.new("Frame")
            Ripple.Size = UDim2.new(0, 0, 0, 0)
            Ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
            Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
            Ripple.BackgroundColor3 = Theme.Accent
            Ripple.BackgroundTransparency = 0.7
            Ripple.BorderSizePixel = 0
            Ripple.ZIndex = 10
            Ripple.Parent = Btn
            Instance.new("UICorner", Ripple).CornerRadius = UDim.new(1, 0)

            local tw = TweenService:Create(Ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
                Size = UDim2.new(2, 0, 3, 0),
                BackgroundTransparency = 1,
            })
            tw:Play()
            tw.Completed:Connect(function() Ripple:Destroy() end)

            pcall(callback)
        end)
    end

    -- ── TOGGLE ──
    function Elements:AddToggle(text, default, callback)
        local state = default or false

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 42)
        Frame.BackgroundColor3 = Theme.BGCard
        Frame.Parent = TabPage

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 10)
        Corner.Parent = Frame

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Theme.Border
        Stroke.Thickness = 1
        Stroke.Transparency = 0.4
        Stroke.Parent = Frame

        -- Status dot beside text
        local StatusIndicator = Instance.new("Frame")
        StatusIndicator.Size = UDim2.new(0, 6, 0, 6)
        StatusIndicator.Position = UDim2.new(0, 12, 0.5, -3)
        StatusIndicator.BackgroundColor3 = state and Theme.Success or Theme.TextMuted
        StatusIndicator.BorderSizePixel = 0
        StatusIndicator.Parent = Frame
        Instance.new("UICorner", StatusIndicator).CornerRadius = UDim.new(1, 0)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -72, 1, 0)
        Label.Position = UDim2.new(0, 24, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Theme.TextPri
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame

        -- Switch track
        local SwitchBg = Instance.new("Frame")
        SwitchBg.Size = UDim2.new(0, 40, 0, 22)
        SwitchBg.Position = UDim2.new(1, -52, 0.5, -11)
        SwitchBg.BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff
        SwitchBg.Parent = Frame
        Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)

        -- Glow
        local SwitchGlow = Instance.new("Frame")
        SwitchGlow.Size = UDim2.new(0, 48, 0, 30)
        SwitchGlow.Position = UDim2.new(1, -56, 0.5, -15)
        SwitchGlow.BackgroundColor3 = Theme.AccentGlow
        SwitchGlow.BackgroundTransparency = state and 0.78 or 1
        SwitchGlow.ZIndex = 0
        SwitchGlow.Parent = Frame
        Instance.new("UICorner", SwitchGlow).CornerRadius = UDim.new(1, 0)

        -- Knob
        local SwitchDot = Instance.new("Frame")
        SwitchDot.Size = UDim2.new(0, 16, 0, 16)
        SwitchDot.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        SwitchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SwitchDot.Parent = SwitchBg
        Instance.new("UICorner", SwitchDot).CornerRadius = UDim.new(1, 0)

        local ClickBtn = Instance.new("TextButton")
        ClickBtn.Size = UDim2.new(1, 0, 1, 0)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text = ""
        ClickBtn.Parent = Frame

        ClickBtn.MouseButton1Click:Connect(function()
            state = not state
            local targetBg = state and Theme.Accent or Theme.ToggleOff
            local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            local glowAlpha = state and 0.78 or 1
            local dotColor = state and Theme.Success or Theme.TextMuted
            local strokeColor = state and Theme.Accent or Theme.Border

            TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
            TweenService:Create(SwitchDot, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = targetPos}):Play()
            TweenService:Create(SwitchGlow, TweenInfo.new(0.2), {BackgroundTransparency = glowAlpha}):Play()
            TweenService:Create(StatusIndicator, TweenInfo.new(0.2), {BackgroundColor3 = dotColor}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = strokeColor}):Play()
            pcall(callback, state)
        end)
    end

    -- ── PARAGRAPH ──
    function Elements:AddParagraph(title, content)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 56)
        Frame.BackgroundColor3 = Theme.BGCard
        Frame.Parent = TabPage

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 10)
        Corner.Parent = Frame

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Theme.Border
        Stroke.Thickness = 1
        Stroke.Transparency = 0.4
        Stroke.Parent = Frame

        local LeftAccent = Instance.new("Frame")
        LeftAccent.Size = UDim2.new(0, 3, 0.55, 0)
        LeftAccent.Position = UDim2.new(0, 0, 0.225, 0)
        LeftAccent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        LeftAccent.BorderSizePixel = 0
        LeftAccent.Parent = Frame
        Instance.new("UICorner", LeftAccent).CornerRadius = UDim.new(0, 1)

        local LAccGrad = Instance.new("UIGradient")
        LAccGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.AccentSecondary),
        })
        LAccGrad.Rotation = 90
        LAccGrad.Parent = LeftAccent

        local TitleL = Instance.new("TextLabel")
        TitleL.Size = UDim2.new(1, -20, 0, 18)
        TitleL.Position = UDim2.new(0, 14, 0, 6)
        TitleL.BackgroundTransparency = 1
        TitleL.Text = title
        TitleL.TextColor3 = Theme.Accent
        TitleL.Font = Enum.Font.GothamBold
        TitleL.TextSize = 11
        TitleL.TextXAlignment = Enum.TextXAlignment.Left
        TitleL.Parent = Frame

        local ContentL = Instance.new("TextLabel")
        ContentL.Size = UDim2.new(1, -20, 0, 22)
        ContentL.Position = UDim2.new(0, 14, 0, 26)
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

    -- ── SLIDER ──
    function Elements:AddSlider(text, min, max, default, callback)
        local value = default or min

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 54)
        Frame.BackgroundColor3 = Theme.BGCard
        Frame.Parent = TabPage

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 10)
        Corner.Parent = Frame

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Theme.Border
        Stroke.Thickness = 1
        Stroke.Transparency = 0.4
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
        ValueLabel.Position = UDim2.new(0.7, -6, 0, 6)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = tostring(value)
        ValueLabel.TextColor3 = Theme.Accent
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.TextSize = 12
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = Frame

        local TrackBg = Instance.new("Frame")
        TrackBg.Size = UDim2.new(1, -28, 0, 5)
        TrackBg.Position = UDim2.new(0, 14, 0, 36)
        TrackBg.BackgroundColor3 = Theme.ToggleOff
        TrackBg.BorderSizePixel = 0
        TrackBg.Parent = Frame
        Instance.new("UICorner", TrackBg).CornerRadius = UDim.new(1, 0)

        local fillPercent = (value - min) / (max - min)

        local TrackFill = Instance.new("Frame")
        TrackFill.Size = UDim2.new(fillPercent, 0, 1, 0)
        TrackFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TrackFill.BorderSizePixel = 0
        TrackFill.Parent = TrackBg
        Instance.new("UICorner", TrackFill).CornerRadius = UDim.new(1, 0)

        local FillGrad = Instance.new("UIGradient")
        FillGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.AccentSecondary),
        })
        FillGrad.Parent = TrackFill

        local Thumb = Instance.new("Frame")
        Thumb.Size = UDim2.new(0, 14, 0, 14)
        Thumb.Position = UDim2.new(fillPercent, -7, 0.5, -7)
        Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Thumb.ZIndex = 2
        Thumb.Parent = TrackBg
        Instance.new("UICorner", Thumb).CornerRadius = UDim.new(1, 0)

        local ThumbStroke = Instance.new("UIStroke")
        ThumbStroke.Color = Theme.Accent
        ThumbStroke.Thickness = 2
        ThumbStroke.Transparency = 0.3
        ThumbStroke.Parent = Thumb

        local sliding = false

        local function updateSlider(inputX)
            local absPos = TrackBg.AbsolutePosition.X
            local absSize = TrackBg.AbsoluteSize.X
            local relative = math.clamp((inputX - absPos) / absSize, 0, 1)
            value = math.floor(min + (max - min) * relative)
            local pct = (value - min) / (max - min)

            TrackFill.Size = UDim2.new(pct, 0, 1, 0)
            Thumb.Position = UDim2.new(pct, -7, 0.5, -7)
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

-- ╔══════════════════════════════════════════════════╗
-- ║              CREATE TABS                          ║
-- ╚══════════════════════════════════════════════════╝
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

-- ╔══════════════════════════════════════════════════╗
-- ║          FLOATING TOGGLE BUTTON                   ║
-- ╚══════════════════════════════════════════════════╝
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "TerehubFloat"
FloatBtn.Size = UDim2.new(0, 48, 0, 48)
FloatBtn.Position = UDim2.new(0, 16, 0.5, -24)
FloatBtn.BackgroundColor3 = Theme.BGMain
FloatBtn.Text = ""
FloatBtn.ZIndex = 10
FloatBtn.Parent = ScreenGui

Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Theme.Accent
FloatStroke.Thickness = 2
FloatStroke.Parent = FloatBtn

local FloatIcon = Instance.new("ImageLabel")
FloatIcon.Size = UDim2.new(0, 24, 0, 24)
FloatIcon.Position = UDim2.new(0.5, -12, 0.5, -12)
FloatIcon.BackgroundTransparency = 1
FloatIcon.Image = "rbxassetid://136360402262473"
FloatIcon.ImageColor3 = Theme.Accent
FloatIcon.ZIndex = 11
FloatIcon.Parent = FloatBtn

-- Outer glow ring
local FloatGlowRing = Instance.new("Frame")
FloatGlowRing.Size = UDim2.new(0, 56, 0, 56)
FloatGlowRing.Position = UDim2.new(0.5, -28, 0.5, -28)
FloatGlowRing.BackgroundColor3 = Theme.Accent
FloatGlowRing.BackgroundTransparency = 0.85
FloatGlowRing.ZIndex = 9
FloatGlowRing.Parent = FloatBtn
Instance.new("UICorner", FloatGlowRing).CornerRadius = UDim.new(1, 0)

-- Animated rainbow stroke on float button
task.spawn(function()
    local hue = 0
    while FloatBtn and FloatBtn.Parent do
        hue = (hue + 0.003) % 1
        local color = Color3.fromHSV(hue, 0.7, 1)
        FloatStroke.Color = color
        FloatIcon.ImageColor3 = color
        FloatGlowRing.BackgroundColor3 = color
        RunService.Heartbeat:Wait()
    end
end)

-- Pulse animation on glow ring
task.spawn(function()
    while FloatGlowRing and FloatGlowRing.Parent do
        TweenService:Create(FloatGlowRing, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            BackgroundTransparency = 0.6,
            Size = UDim2.new(0, 62, 0, 62),
            Position = UDim2.new(0.5, -31, 0.5, -31),
        }):Play()
        task.wait(1.2)
        TweenService:Create(FloatGlowRing, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            BackgroundTransparency = 0.85,
            Size = UDim2.new(0, 56, 0, 56),
            Position = UDim2.new(0.5, -28, 0.5, -28),
        }):Play()
        task.wait(1.2)
    end
end)

-- Draggable float button
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
        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
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
    TweenService:Create(FloatBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 52, 0, 52)}):Play()
end)
FloatBtn.MouseLeave:Connect(function()
    TweenService:Create(FloatBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 48, 0, 48)}):Play()
end)

-- ╔══════════════════════════════════════════════════╗
-- ║           SPLASH ANIMATION SEQUENCE               ║
-- ╚══════════════════════════════════════════════════╝
task.spawn(function()
    -- Icon fade in + scale
    TweenService:Create(SplashIcon, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
    task.wait(0.3)
    TweenService:Create(SplashTitle, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
    task.wait(0.2)
    TweenService:Create(SplashSub, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
    task.wait(0.15)

    -- Fill progress bar
    TweenService:Create(ProgressFill, TweenInfo.new(1.5, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(1.6)

    -- Fade out splash
    TweenService:Create(SplashIcon, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
    TweenService:Create(SplashTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(SplashSub, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    task.wait(0.2)

    local tw = TweenService:Create(SplashOverlay, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {BackgroundTransparency = 1})
    tw:Play()
    tw.Completed:Wait()
    SplashOverlay:Destroy()

    -- Show main window
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 620, 0, 420)
    TweenService:Create(MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 660, 0, 460),
    }):Play()

    task.wait(0.5)
    Notify({Title = "Welcome!", Description = "Terehub v2.0 berhasil dimuat!", Duration = 4, Icon = "🚀"})
end)

-- ╔══════════════════════════════════════════════════╗
-- ║            TAB FEATURES                           ║
-- ╚══════════════════════════════════════════════════╝

-- [[ MAIN TAB ]] --
MainTab:AddSection("Skill Check Automation")

local autoSkillCheck = false
MainTab:AddToggle("Auto Perfect Skill Check", false, function(state)
    autoSkillCheck = state
    Notify({Title = "Skill Check", Description = state and "Auto Skill Check diaktifkan!" or "Auto Skill Check dimatikan.", Duration = 2, Icon = "⚡"})
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

-- [[ CHARACTER TAB ]] --
CharTab:AddSection("Movement Modifiers")

local wsValue = 16
local wsToggle = false

CharTab:AddToggle("Enable Custom WalkSpeed", false, function(state)
    wsToggle = state
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = state and wsValue or 16 end
end)

CharTab:AddSlider("WalkSpeed", 16, 200, 100, function(val)
    wsValue = val
    if wsToggle then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = val end
    end
end)

local infJump = false
CharTab:AddToggle("Infinite Jump", false, function(state)
    infJump = state
    Notify({Title = "Movement", Description = state and "Infinite Jump ON" or "Infinite Jump OFF", Duration = 2, Icon = "🦘"})
end)

UserInputService.JumpRequest:Connect(function()
    if infJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- [[ COMBAT TAB ]] --
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

-- [[ SHOPS TAB ]] --
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
    Notify({Title = "Scanner", Description = count .. " remote ditemukan! Cek Console F9.", Duration = 3, Icon = "🔍"})
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
        Notify({Title = "Auto Buy", Description = "Pembelian semua item selesai!", Duration = 3, Icon = "💰"})
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
                RestockParagraph:Set({ Title = "⏱ Restock Countdown", Content = "Waktu: " .. tostring(timerLabel.Text) })
            else
                RestockParagraph:Set({ Title = "⏱ Restock Countdown", Content = "Memantau... (Buka GUI Shop)" })
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

print("Terehub v2.0 Modern: Successfully Loaded!")
