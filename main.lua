-- TereHub - WindUI Version
-- Purple Blue Theme
-- UI Only (Empty)

local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/source.lua"
))()

local Window = WindUI:CreateWindow({
    Title = "TereHub",
    Icon = "shield",
    Folder = "TereHub",
    Size = UDim2.fromOffset(500, 400),
    Theme = {
        Accent = Color3.fromRGB(120, 60, 255), -- Ungu Biru
        Background = Color3.fromRGB(25,20,45),
        Outline = Color3.fromRGB(40,35,70),
        Text = Color3.fromRGB(255,255,255)
    }
})

-- Empty Main Tab
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "sparkles"
})

MainTab:CreateLabel({
    Name = "UI Loaded Successfully"
})

-- Theme Tab
local ThemeTab = Window:CreateTab({
    Name = "Theme",
    Icon = "palette"
})

ThemeTab:CreateColorPicker({
    Name = "Accent Color",
    Default = Color3.fromRGB(120,60,255),
    Callback = function(color)
        WindUI:SetTheme("Accent", color)
    end
})