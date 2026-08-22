local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()

print("Terehub Custom UI: Initializing...")

-- [[ CLEANUP OLD UI ]] --
if CoreGui:FindFirstChild("TerehubCustomUI") then
    CoreGui.TerehubCustomUI:Destroy()
end

-- [[ CREATE CUSTOM SCREEN GUI ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TerehubCustomUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Main Window Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 620, 0, 420)
MainFrame.Position = UDim2.new(0.5, -310, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(85, 95, 225)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Top Bar (Header)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Terehub | Custom UI"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(235, 60, 60)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Make Window Draggable
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Sidebar for Tabs
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 140, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 5)
TabListLayout.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.PaddingLeft = UDim.new(0, 8)
SidebarPadding.PaddingRight = UDim.new(0, 8)
SidebarPadding.Parent = Sidebar

-- Content Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -140, 1, -40)
ContentContainer.Position = UDim2.new(0, 140, 0, 40)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- [[ TAB SYSTEM BUILDER ]] --
local Tabs = {}
local TabButtons = {}

local function CreateTab(tabName)
    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Name = tabName .. "Page"
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.ScrollBarThickness = 4
    TabPage.ScrollBarImageColor3 = Color3.fromRGB(85, 95, 225)
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
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
    TabBtn.Text = tabName
    TabBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextSize = 13
    TabBtn.Parent = Sidebar

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = TabBtn

    TabBtn.MouseButton1Click:Connect(function()
        for name, page in pairs(Tabs) do
            page.Visible = (name == tabName)
        end
        for name, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = (name == tabName) and Color3.fromRGB(85, 95, 225) or Color3.fromRGB(25, 28, 38)
            btn.TextColor3 = (name == tabName) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 185, 200)
        end
    end)

    Tabs[tabName] = TabPage
    TabButtons[tabName] = TabBtn

    -- Elements Helper for Pages
    local Elements = {}

    function Elements:AddButton(text, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 38)
        Btn.BackgroundColor3 = Color3.fromRGB(30, 34, 46)
        Btn.Text = text
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.GothamMedium
        Btn.TextSize = 13
        Btn.Parent = TabPage

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Btn

        Btn.MouseButton1Click:Connect(function()
            pcall(callback)
        end)
    end

    function Elements:AddToggle(text, default, callback)
        local state = default or false

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 38)
        Frame.BackgroundColor3 = Color3.fromRGB(30, 34, 46)
        Frame.Parent = TabPage

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Frame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(230, 230, 240)
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame

        local ToggleBox = Instance.new("TextButton")
        ToggleBox.Size = UDim2.new(0, 44, 0, 22)
        ToggleBox.Position = UDim2.new(1, -54, 0.5, -11)
        ToggleBox.BackgroundColor3 = state and Color3.fromRGB(85, 95, 225) or Color3.fromRGB(50, 55, 70)
        ToggleBox.Text = state and "ON" or "OFF"
        ToggleBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleBox.Font = Enum.Font.GothamBold
        ToggleBox.TextSize = 11
        ToggleBox.Parent = Frame

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 11)
        ToggleCorner.Parent = ToggleBox

        ToggleBox.MouseButton1Click:Connect(function()
            state = not state
            ToggleBox.BackgroundColor3 = state and Color3.fromRGB(85, 95, 225) or Color3.fromRGB(50, 55, 70)
            ToggleBox.Text = state and "ON" or "OFF"
            pcall(callback, state)
        end)
    end

    function Elements:AddParagraph(title, content)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 55)
        Frame.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
        Frame.Parent = TabPage

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Frame

        local TitleL = Instance.new("TextLabel")
        TitleL.Size = UDim2.new(1, -20, 0, 20)
        TitleL.Position = UDim2.new(0, 10, 0, 5)
        TitleL.BackgroundTransparency = 1
        TitleL.Text = title
        TitleL.TextColor3 = Color3.fromRGB(85, 95, 225)
        TitleL.Font = Enum.Font.GothamBold
        TitleL.TextSize = 13
        TitleL.TextXAlignment = Enum.TextXAlignment.Left
        TitleL.Parent = Frame

        local ContentL = Instance.new("TextLabel")
        ContentL.Size = UDim2.new(1, -20, 0, 25)
        ContentL.Position = UDim2.new(0, 10, 0, 25)
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
local MainTab = CreateTab("Main")
local CharTab = CreateTab("Character")
local CombatTab = CreateTab("Combat")
local VisualTab = CreateTab("Visuals")
local ShopTab = CreateTab("Shops")
local PlayerTab = CreateTab("Players")

-- Set Default Active Tab
TabButtons["Shops"].BackgroundColor3 = Color3.fromRGB(85, 95, 225)
TabButtons["Shops"].TextColor3 = Color3.fromRGB(255, 255, 255)
Tabs["Shops"].Visible = true

-- [[ FLOATING TOGGLE BUTTON (MOBILE & PC) ]] --
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "TerehubFloatingBtn"
FloatBtn.Size = UDim2.new(0, 50, 0, 50)
FloatBtn.Position = UDim2.new(0, 15, 0.5, -25)
FloatBtn.BackgroundColor3 = Color3.fromRGB(85, 95, 225)
FloatBtn.Text = "HUB"
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 14
FloatBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 25)
FloatCorner.Parent = FloatBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(255, 255, 255)
FloatStroke.Thickness = 2
FloatStroke.Parent = FloatBtn

FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- [[ SHOPS TAB FEATURES ]] --
ShopTab:AddButton("Scan All Remotes (F9 Console)", function()
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

print("Terehub Custom UI: Successfully Loaded!")
