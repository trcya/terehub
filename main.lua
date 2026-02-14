--[[
    Terehub Beta - Map Testing Script
    Warna: Biru Ungu Transparan
    Untuk Delta Executor
]]

-- Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/main_example.lua"))()

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

--[[ KUSTOMISASI WARNA ]]
-- Warna Biru Ungu Gradient
local PrimaryColor = Color3.fromRGB(98, 114, 255) -- Biru terang
local SecondaryColor = Color3.fromRGB(170, 100, 255) -- Ungu
local AccentColor = Color3.fromRGB(130, 87, 255) -- Biru Ungu campuran
local BackgroundColor = Color3.fromRGB(15, 10, 25) -- Dark purple background
local Transparency = 0.15 -- Transparan 15%

-- Apply warna ke WindUI
WindUI.Theme:SetPrimary(PrimaryColor)
WindUI.Theme:SetSecondary(SecondaryColor)
WindUI.Theme:SetAccent(AccentColor)
WindUI.Theme:SetBackground(BackgroundColor)
WindUI.Theme:SetTransparency(Transparency)

-- Main Window dengan judul Terehub Beta
local Window = WindUI:CreateWindow({
    Title = "Terehub ฅ^•ﻌ•^ฅ",
    SubTitle = "Beta Version v0.1",
    Icon = "cat", -- Ikon kucing
    Author = "Tere",
    Folder = "TerehubBeta",
    Size = UDim2.fromOffset(550, 450),
    Transparency = Transparency
})

-- Notifikasi Load dengan tema biru ungu
WindUI:Notify({
    Title = "Terehub Beta Loaded",
    Content = "Welcome to Terehub Beta! ฅ^•ﻌ•^ฅ",
    Duration = 3,
    Style = {
        Color = PrimaryColor,
        Secondary = SecondaryColor
    }
})

--[[ FUNGSI UTILITY ]]
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getRoot()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

--[[ TAB MOVEMENT - KOSONG ]]
local MovementTab = Window:CreateTab({
    Title = "Movement",
    Icon = "move",
    Description = "Movement features (soon)"
})

-- Section kosong dengan pesan
local MoveSection = MovementTab:CreateSection("Movement Controls")
MoveSection:AddBlank()

MovementTab:CreateLabel({
    Title = "✨ Coming Soon",
    Description = "Movement features will be added in next update",
    Icon = "clock"
})

MovementTab:CreateButton({
    Title = "Speed (Soon)",
    Description = "WalkSpeed slider coming soon",
    Icon = "zap",
    Callback = function()
        WindUI:Notify({
            Title = "Info",
            Content = "Fitur dalam pengembangan!",
            Duration = 2
        })
    end
})

MovementTab:CreateButton({
    Title = "Jump (Soon)",
    Description = "JumpPower slider coming soon",
    Icon = "chevrons-up",
    Callback = function()
        WindUI:Notify({
            Title = "Info",
            Content = "Fitur dalam pengembangan!",
            Duration = 2
        })
    end
})

--[[ TAB TELEPORT - KOSONG ]]
local TeleportTab = Window:CreateTab({
    Title = "Teleport",
    Icon = "map-pin",
    Description = "Teleport features (soon)"
})

local TeleSection = TeleportTab:CreateSection("Teleport Controls")
TeleSection:AddBlank()

TeleportTab:CreateLabel({
    Title = "🚀 In Development",
    Description = "Teleport tools will be available soon",
    Icon = "construction"
})

TeleportTab:CreateButton({
    Title = "Save Position (Soon)",
    Icon = "bookmark",
    Callback = function()
        WindUI:Notify({
            Title = "Development",
            Content = "Fitur teleport sedang dibuat",
            Duration = 2
        })
    end
})

TeleportTab:CreateButton({
    Title = "Load Position (Soon)",
    Icon = "book-open",
    Callback = function()
        WindUI:Notify({
            Title = "Development",
            Content = "Fitur teleport sedang dibuat",
            Duration = 2
        })
    end
})

--[[ TAB VISUAL - KOSONG ]]
local VisualTab = Window:CreateTab({
    Title = "Visual",
    Icon = "eye",
    Description = "Visual features (soon)"
})

local VisSection = VisualTab:CreateSection("Visual Settings")
VisSection:AddBlank()

VisualTab:CreateLabel({
    Title = "🎨 Coming Soon",
    Description = "ESP and X-Ray features in progress",
    Icon = "palette"
})

VisualTab:CreateButton({
    Title = "ESP (Soon)",
    Icon = "highlighter",
    Callback = function()
        WindUI:Notify({
            Title = "Info",
            Content = "ESP fitur akan segera hadir!",
            Duration = 2
        })
    end
})

VisualTab:CreateButton({
    Title = "X-Ray (Soon)",
    Icon = "eye-off",
    Callback = function()
        WindUI:Notify({
            Title = "Info",
            Content = "X-Ray fitur dalam pengembangan",
            Duration = 2
        })
    end
})

--[[ TAB UTILITIES - KOSONG ]]
local UtilityTab = Window:CreateTab({
    Title = "Utilities",
    Icon = "settings",
    Description = "Utility features (soon)"
})

local UtilSection = UtilityTab:CreateSection("Tools")
UtilSection:AddBlank()

UtilityTab:CreateLabel({
    Title = "🔧 Under Construction",
    Description = "Various tools coming in next update",
    Icon = "wrench"
})

UtilityTab:CreateButton({
    Title = "Anti AFK (Soon)",
    Icon = "coffee",
    Callback = function()
        WindUI:Notify({
            Title = "Info",
            Content = "Fitur Anti AFK sedang dibuat",
            Duration = 2
        })
    end
})

UtilityTab:CreateButton({
    Title = "Reset Character (Soon)",
    Icon = "refresh-cw",
    Callback = function()
        WindUI:Notify({
            Title = "Info",
            Content = "Fitur reset dalam pengembangan",
            Duration = 2
        })
    end
})

--[[ TAB INFO ]]
local InfoTab = Window:CreateTab({
    Title = "Info",
    Icon = "info",
    Description = "Information about Terehub"
})

local InfoSection = InfoTab:CreateSection("Terehub Beta Info")
InfoSection:AddBlank()

-- Info dengan style
InfoTab:CreateLabel({
    Title = "ฅ^•ﻌ•^ฅ Terehub Beta",
    Description = "Version: 0.1 Beta",
    Icon = "tag"
})

InfoTab:CreateLabel({
    Title = "Status",
    Description = "In Development - Features Coming Soon",
    Icon = "clock"
})

InfoTab:CreateLabel({
    Title = "Creator",
    Description = "Tere ฅ^•ﻌ•^ฅ",
    Icon = "heart"
})

InfoTab:CreateLabel({
    Title = "Color Theme",
    Description = "Blue Purple Transparent",
    Icon = "droplet"
})

-- Color preview
local ColorSection = InfoTab:CreateSection("Theme Colors")
local colorFrame = InfoTab:CreateToggle({
    Title = "Show Colors",
    Description = "Preview theme colors",
    Icon = "palette",
    Callback = function(state)
        if state then
            -- Tampilkan preview warna
            local colors = {
                {name = "Primary", color = PrimaryColor},
                {name = "Secondary", color = SecondaryColor},
                {name = "Accent", color = AccentColor},
                {name = "Background", color = BackgroundColor}
            }
            
            for _, col in pairs(colors) do
                WindUI:Notify({
                    Title = col.name .. " Color",
                    Content = "RGB: " .. math.floor(col.color.R * 255) .. ", " .. math.floor(col.color.G * 255) .. ", " .. math.floor(col.color.B * 255),
                    Duration = 2,
                    Style = {
                        Color = col.color
                    }
                })
                wait(0.5)
            end
        end
    end
})

--[[ TAB SETTINGS ]]
local SettingsTab = Window:CreateTab({
    Title = "Settings",
    Icon = "sliders",
    Description = "Hub settings"
})

local SetSection = SettingsTab:CreateSection("Settings")
SetSection:AddBlank()

-- UI Toggle
SettingsTab:CreateButton({
    Title = "Toggle UI",
    Description = "Hide/Show UI (RightShift)",
    Icon = "eye",
    Callback = function()
        WindUI:Toggle()
    end
})

-- Transparency Control
local transSlider = SettingsTab:CreateSlider({
    Title = "UI Transparency",
    Description = "Adjust UI transparency",
    Icon = "droplet",
    Min = 0,
    Max = 0.5,
    Default = Transparency,
    ValueName = "Opacity",
    Callback = function(value)
        WindUI.Theme:SetTransparency(value)
        -- Update frame transparency
        for _, v in pairs(player.PlayerGui:GetDescendants()) do
            if v:IsA("Frame") and v.Name ~= "TopBar" then
                v.BackgroundTransparency = value
            end
        end
    end
})

-- Color Theme Selector
SettingsTab:CreateDropdown({
    Title = "Theme Color",
    Description = "Pilih tema warna",
    Icon = "brush",
    Values = {"Biru Ungu", "Biru Tua", "Ungu Terang", "Hitam Biru", "Default"},
    Callback = function(selected)
        if selected == "Biru Ungu" then
            WindUI.Theme:SetPrimary(Color3.fromRGB(98, 114, 255))
            WindUI.Theme:SetSecondary(Color3.fromRGB(170, 100, 255))
        elseif selected == "Biru Tua" then
            WindUI.Theme:SetPrimary(Color3.fromRGB(0, 100, 255))
            WindUI.Theme:SetSecondary(Color3.fromRGB(0, 150, 255))
        elseif selected == "Ungu Terang" then
            WindUI.Theme:SetPrimary(Color3.fromRGB(200, 100, 255))
            WindUI.Theme:SetSecondary(Color3.fromRGB(150, 50, 255))
        elseif selected == "Hitam Biru" then
            WindUI.Theme:SetPrimary(Color3.fromRGB(0, 50, 150))
            WindUI.Theme:SetSecondary(Color3.fromRGB(0, 20, 100))
        end
        
        WindUI:Notify({
            Title = "Theme Updated",
            Content = "Color theme changed to " .. selected,
            Duration = 2
        })
    end
})

-- Reset Settings
SettingsTab:CreateButton({
    Title = "Reset Settings",
    Description = "Kembali ke default",
    Icon = "rotate-ccw",
    Callback = function()
        WindUI.Theme:SetPrimary(PrimaryColor)
        WindUI.Theme:SetSecondary(SecondaryColor)
        WindUI.Theme:SetTransparency(Transparency)
        transSlider:Set(Transparency)
        
        WindUI:Notify({
            Title = "Settings Reset",
            Content = "Kembali ke tema default",
            Duration = 2
        })
    end
})

-- Unload
SettingsTab:CreateButton({
    Title = "Unload Terehub",
    Description = "Close and remove all",
    Icon = "power",
    Callback = function()
        WindUI:Destroy()
        script:Destroy()
    end
})

--[[ KEYBINDS ]]
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        WindUI:Toggle()
    elseif input.KeyCode == Enum.KeyCode.End then
        -- Close GUI with End key
        WindUI:Destroy()
        script:Destroy()
    end
end)

--[[ WELCOME MESSAGE ]]
wait(1)
WindUI:Notify({
    Title = "ฅ^•ﻌ•^ฅ Welcome to Terehub Beta!",
    Content = "Fitur masih kosong, tunggu update selanjutnya!",
    Duration = 5,
    Style = {
        Color = SecondaryColor,
        Secondary = PrimaryColor
    }
})

-- Info di console
print([[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    TEREHUB BETA - LOADED
    Version: 0.1 Beta
    Theme: Blue Purple Transparent
    Press RightShift to toggle
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
]])

-- Update judul di bar
local function updateBar()
    local bar = player.PlayerGui:FindFirstChild("WindUI")
    if bar then
        for _, v in pairs(bar:GetDescendants()) do
            if v:IsA("TextLabel") and v.Text and v.Text:find("WindUI") then
                v.Text = "Terehub Beta ฅ^•ﻌ•^ฅ"
            end
        end
    end
end

wait(2)
updateBar()