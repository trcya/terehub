-- =============================================
// ATOMIC HUB UI - FISHING STYLE
// Buat di ScreenGui → Frame
// Cocok untuk game fishing simulator
// =============================================

local Library = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- ============== THEME ==============
local Theme = {
    Background = Color3.fromRGB(20, 22, 27),
    Surface = Color3.fromRGB(30, 33, 40),
    Primary = Color3.fromRGB(45, 120, 255),
    Secondary = Color3.fromRGB(60, 70, 90),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 185, 190),
    Success = Color3.fromRGB(70, 200, 100),
    Warning = Color3.fromRGB(255, 170, 60),
    Danger = Color3.fromRGB(255, 80, 80),
    Border = Color3.fromRGB(40, 45, 55)
}

-- ============== MAIN WINDOW ==============
function Library:CreateWindow(title)
    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "AtomicHub"
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    
    -- Main Frame
    local main = Instance.new("Frame")
    main.Name = "MainWindow"
    main.Size = UDim2.new(0, 650, 0, 500)
    main.Position = UDim2.new(0.5, -325, 0.5, -250)
    main.BackgroundColor3 = Theme.Background
    main.BackgroundTransparency = 0.05
    main.BorderSizePixel = 0
    main.Parent = gui
    
    -- Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, -20)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = main
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = main
    
    -- Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Border
    stroke.Thickness = 1.5
    stroke.Parent = main
    
    -- ============== HEADER ==============
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Theme.Surface
    header.BorderSizePixel = 0
    header.Parent = main
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0, 200, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "  " .. title
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    -- Logo
    local logo = Instance.new("ImageLabel")
    logo.Name = "Logo"
    logo.Size = UDim2.new(0, 30, 0, 30)
    logo.Position = UDim2.new(0, 15, 0, 10)
    logo.BackgroundTransparency = 1
    logo.Image = "rbxassetid://4483345998" -- Fishing rod icon
    logo.ImageColor3 = Theme.Primary
    logo.Parent = header
    
    titleLabel.Position = UDim2.new(0, 55, 0, 0)
    
    -- Close Button
    local close = Instance.new("TextButton")
    close.Name = "CloseButton"
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -40, 0, 10)
    close.BackgroundColor3 = Color3.fromRGB(50, 55, 65)
    close.Text = "✕"
    close.TextColor3 = Theme.TextDim
    close.TextSize = 18
    close.Font = Enum.Font.Gotham
    close.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = close
    
    close.MouseEnter:Connect(function()
        close.BackgroundColor3 = Theme.Danger
        close.TextColor3 = Theme.Text
    end)
    
    close.MouseLeave:Connect(function()
        close.BackgroundColor3 = Color3.fromRGB(50, 55, 65)
        close.TextColor3 = Theme.TextDim
    end)
    
    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- ============== SIDEBAR ==============
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 180, 1, -50)
    sidebar.Position = UDim2.new(0, 0, 0, 50)
    sidebar.BackgroundColor3 = Theme.Surface
    sidebar.BackgroundTransparency = 0.3
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main
    
    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 8)
    sidebarCorner.Parent = sidebar
    
    -- User Profile
    local profile = Instance.new("Frame")
    profile.Name = "Profile"
    profile.Size = UDim2.new(1, -20, 0, 70)
    profile.Position = UDim2.new(0, 10, 0, 15)
    profile.BackgroundColor3 = Theme.Background
    profile.BackgroundTransparency = 0.5
    profile.BorderSizePixel = 0
    profile.Parent = sidebar
    
    local profileCorner = Instance.new("UICorner")
    profileCorner.CornerRadius = UDim.new(0, 6)
    profileCorner.Parent = profile
    
    -- Avatar
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Size = UDim2.new(0, 40, 0, 40)
    avatar.Position = UDim2.new(0, 10, 0, 15)
    avatar.BackgroundColor3 = Theme.Primary
    avatar.BackgroundTransparency = 0.8
    avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size60x60)
    avatar.Parent = profile
    
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatarCorner.Parent = avatar
    
    -- Username
    local username = Instance.new("TextLabel")
    username.Name = "Username"
    username.Size = UDim2.new(1, -60, 0, 20)
    username.Position = UDim2.new(0, 60, 0, 15)
    username.BackgroundTransparency = 1
    username.Text = LocalPlayer.DisplayName
    username.TextColor3 = Theme.Text
    username.TextSize = 14
    username.Font = Enum.Font.GothamBold
    username.TextXAlignment = Enum.TextXAlignment.Left
    username.Parent = profile
    
    -- Level
    local level = Instance.new("TextLabel")
    level.Name = "Level"
    level.Size = UDim2.new(1, -60, 0, 20)
    level.Position = UDim2.new(0, 60, 0, 35)
    level.BackgroundTransparency = 1
    level.Text = "Level 42 • Master Angler"
    level.TextColor3 = Theme.Primary
    level.TextSize = 12
    level.Font = Enum.Font.Gotham
    level.TextXAlignment = Enum.TextXAlignment.Left
    level.Parent = profile
    
    -- ============== NAVIGATION ==============
    local navigation = Instance.new("ScrollingFrame")
    navigation.Name = "Navigation"
    navigation.Size = UDim2.new(1, -20, 0, 300)
    navigation.Position = UDim2.new(0, 10, 0, 100)
    navigation.BackgroundTransparency = 1
    navigation.BorderSizePixel = 0
    navigation.ScrollBarThickness = 4
    navigation.ScrollBarImageColor3 = Theme.Primary
    navigation.AutomaticCanvasSize = Enum.AutomaticSize.Y
    navigation.CanvasSize = UDim2.new(0, 0, 0, 0)
    navigation.Parent = sidebar
    
    local navList = Instance.new("UIListLayout")
    navList.SortOrder = Enum.SortOrder.LayoutOrder
    navList.Padding = UDim.new(0, 5)
    navList.Parent = navigation
    
    -- Navigation Buttons
    local navItems = {
        {icon = "rbxassetid://4483345998", name = "Main", selected = true},
        {icon = "rbxassetid://6026568198", name = "Zone Fishing"},
        {icon = "rbxassetid://6023426587", name = "Auto Selling"},
        {icon = "rbxassetid://6023428198", name = "Backpack"},
        {icon = "rbxassetid://6026569198", name = "Selling Type"},
        {icon = "rbxassetid://6034508198", name = "Webhook"},
        {icon = "rbxassetid://6034509198", name = "Trading"}
    }
    
    local navButtons = {}
    
    for _, item in ipairs(navItems) do
        local btn = Instance.new("TextButton")
        btn.Name = item.name .. "Button"
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundColor3 = item.selected and Theme.Primary or Color3.fromRGB(40, 45, 55)
        btn.BackgroundTransparency = item.selected and 0.8 or 0
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.Parent = navigation
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        -- Icon
        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(0, 20, 0, 20)
        icon.Position = UDim2.new(0, 12, 0, 10)
        icon.BackgroundTransparency = 1
        icon.Image = item.icon
        icon.ImageColor3 = item.selected and Theme.Text or Theme.TextDim
        icon.Parent = btn
        
        -- Label
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -40, 1, 0)
        label.Position = UDim2.new(0, 40, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = item.name
        label.TextColor3 = item.selected and Theme.Text or Theme.TextDim
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = btn
        
        table.insert(navButtons, btn)
    end
    
    -- ============== CONTENT AREA ==============
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -190, 1, -60)
    content.Position = UDim2.new(0, 190, 0, 60)
    content.BackgroundColor3 = Theme.Surface
    content.BackgroundTransparency = 0.5
    content.BorderSizePixel = 0
    content.Parent = main
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 8)
    contentCorner.Parent = content
    
    -- Content Title
    local contentTitle = Instance.new("TextLabel")
    contentTitle.Name = "ContentTitle"
    contentTitle.Size = UDim2.new(1, -30, 0, 50)
    contentTitle.Position = UDim2.new(0, 15, 0, 0)
    contentTitle.BackgroundTransparency = 1
    contentTitle.Text = "Main"
    contentTitle.TextColor3 = Theme.Text
    contentTitle.TextSize = 20
    contentTitle.Font = Enum.Font.GothamBold
    contentTitle.TextXAlignment = Enum.TextXAlignment.Left
    contentTitle.Parent = content
    
    -- Content Frame (for tabs)
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -30, 1, -70)
    contentFrame.Position = UDim2.new(0, 15, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = content
    
    local contentList = Instance.new("UIListLayout")
    contentList.SortOrder = Enum.SortOrder.LayoutOrder
    contentList.Padding = UDim.new(0, 12)
    contentList.Parent = contentFrame
    
    -- ============== CREATE UI ELEMENTS ==============
    local UI = {}
    
    function UI:AddSection(name)
        local section = Instance.new("Frame")
        section.Name = name .. "Section"
        section.Size = UDim2.new(1, 0, 0, 0)
        section.BackgroundTransparency = 1
        section.Parent = contentFrame
        section.AutomaticSize = Enum.AutomaticSize.Y
        
        local sectionTitle = Instance.new("TextLabel")
        sectionTitle.Name = "Title"
        sectionTitle.Size = UDim2.new(1, 0, 0, 25)
        sectionTitle.BackgroundTransparency = 1
        sectionTitle.Text = name
        sectionTitle.TextColor3 = Theme.TextDim
        sectionTitle.TextSize = 14
        sectionTitle.Font = Enum.Font.GothamBold
        sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        sectionTitle.Parent = section
        
        local sectionLine = Instance.new("Frame")
        sectionLine.Name = "Line"
        sectionLine.Size = UDim2.new(1, 0, 0, 1)
        sectionLine.Position = UDim2.new(0, 0, 0, 25)
        sectionLine.BackgroundColor3 = Theme.Border
        sectionLine.BorderSizePixel = 0
        sectionLine.Parent = section
        
        return section
    end
    
    function UI:AddToggle(parent, title, default)
        local toggle = Instance.new("Frame")
        toggle.Name = title .. "Toggle"
        toggle.Size = UDim2.new(1, 0, 0, 35)
        toggle.BackgroundTransparency = 1
        toggle.Parent = parent
        toggle.AutomaticSize = Enum.AutomaticSize.Y
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(0, 200, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = title
        label.TextColor3 = Theme.Text
        label.TextSize = 15
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggle
        
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Name = "Button"
        toggleBtn.Size = UDim2.new(0, 50, 0, 25)
        toggleBtn.Position = UDim2.new(1, -60, 0, 5)
        toggleBtn.BackgroundColor3 = default and Theme.Success or Theme.Secondary
        toggleBtn.BorderSizePixel = 0
        toggleBtn.Text = ""
        toggleBtn.Parent = toggle
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(1, 0)
        toggleCorner.Parent = toggleBtn
        
        local toggleCircle = Instance.new("Frame")
        toggleCircle.Name = "Circle"
        toggleCircle.Size = UDim2.new(0, 21, 0, 21)
        toggleCircle.Position = default and UDim2.new(1, -26, 0, 2) or UDim2.new(0, 4, 0, 2)
        toggleCircle.BackgroundColor3 = Theme.Text
        toggleCircle.BorderSizePixel = 0
        toggleCircle.Parent = toggleBtn
        
        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(1, 0)
        circleCorner.Parent = toggleCircle
        
        local enabled = default or false
        
        toggleBtn.MouseButton1Click:Connect(function()
            enabled = not enabled
            toggleBtn.BackgroundColor3 = enabled and Theme.Success or Theme.Secondary
            toggleCircle:TweenPosition(
                enabled and UDim2.new(1, -26, 0, 2) or UDim2.new(0, 4, 0, 2),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.2,
                true
            )
        end)
        
        return toggle
    end
    
    function UI:AddSlider(parent, title, min, max, default)
        local slider = Instance.new("Frame")
        slider.Name = title .. "Slider"
        slider.Size = UDim2.new(1, 0, 0, 50)
        slider.BackgroundTransparency = 1
        slider.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(0, 200, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = title
        label.TextColor3 = Theme.Text
        label.TextSize = 15
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = slider
        
        local value = Instance.new("TextLabel")
        value.Name = "Value"
        value.Size = UDim2.new(0, 50, 0, 20)
        value.Position = UDim2.new(1, -60, 0, 0)
        value.BackgroundTransparency = 1
        value.Text = tostring(default)
        value.TextColor3 = Theme.Primary
        value.TextSize = 15
        value.Font = Enum.Font.GothamBold
        value.TextXAlignment = Enum.TextXAlignment.Right
        value.Parent = slider
        
        local barBg = Instance.new("Frame")
        barBg.Name = "BarBackground"
        barBg.Size = UDim2.new(1, 0, 0, 6)
        barBg.Position = UDim2.new(0, 0, 0, 30)
        barBg.BackgroundColor3 = Theme.Secondary
        barBg.BorderSizePixel = 0
        barBg.Parent = slider
        
        local barBgCorner = Instance.new("UICorner")
        barBgCorner.CornerRadius = UDim.new(1, 0)
        barBgCorner.Parent = barBg
        
        local bar = Instance.new("Frame")
        bar.Name = "Bar"
        bar.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        bar.BackgroundColor3 = Theme.Primary
        bar.BorderSizePixel = 0
        bar.Parent = barBg
        
        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(1, 0)
        barCorner.Parent = bar
        
        return slider
    end
    
    function UI:AddDropdown(parent, title, options)
        local dropdown = Instance.new("Frame")
        dropdown.Name = title .. "Dropdown"
        dropdown.Size = UDim2.new(1, 0, 0, 35)
        dropdown.BackgroundTransparency = 1
        dropdown.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(0, 200, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = title
        label.TextColor3 = Theme.Text
        label.TextSize = 15
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = dropdown
        
        local select = Instance.new("TextButton")
        select.Name = "Select"
        select.Size = UDim2.new(0, 140, 0, 30)
        select.Position = UDim2.new(1, -150, 0, 2.5)
        select.BackgroundColor3 = Theme.Background
        select.BorderSizePixel = 0
        select.Text = options[1] or "Select"
        select.TextColor3 = Theme.Text
        select.TextSize = 14
        select.Font = Enum.Font.Gotham
        select.Parent = dropdown
        
        local selectCorner = Instance.new("UICorner")
        selectCorner.CornerRadius = UDim.new(0, 6)
        selectCorner.Parent = select
        
        return dropdown
    end
    
    -- Add sample elements to demonstrate
    local mainSection = UI:AddSection("Fishing Settings")
    UI:AddToggle(mainSection, "Auto Cast", true)
    UI:AddToggle(mainSection, "Auto Reel", true)
    UI:AddToggle(mainSection, "Skip Animation", false)
    UI:AddSlider(mainSection, "Cast Power", 0, 100, 75)
    
    local zoneSection = UI:AddSection("Zone Selection")
    UI:AddDropdown(zoneSection, "Fishing Zone", {"Coral Reef", "Deep Ocean", "Mangrove", "Ice Waters"})
    UI:AddToggle(zoneSection, "Auto Move to Zone", false)
    
    return UI
end

-- Create the UI
local UI = Library:CreateWindow("Super Instant Fishing")

-- Make UI draggable
local gui = LocalPlayer.PlayerGui:FindFirstChild("AtomicHub")
if gui and gui:FindFirstChild("MainWindow") then
    local main = gui.MainWindow
    local dragging = false
    local dragInput, dragStart, startPos
    
    main.Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    main.Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end