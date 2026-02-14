-- TereHub - OrionLib Version
-- Purple Blue Theme
-- UI Only (No Features)

local OrionLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/shlexware/Orion/main/source"
))()

local Window = OrionLib:MakeWindow({
    Name = "TereHub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "TereHubConfig",
    IntroEnabled = false
})

-- Main Tab (Kosong)
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddParagraph("UI Ready", "OrionLib Purple-Blue Theme Loaded")

-- Theme Tab
local ThemeTab = Window:MakeTab({
    Name = "Theme",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

ThemeTab:AddColorpicker({
    Name = "Accent Color",
    Default = Color3.fromRGB(120, 60, 255),
    Callback = function(color)
        OrionLib:SetTheme({
            Main = color
        })
    end
})

OrionLib:Init()
