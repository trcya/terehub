-- TereHub - OrionLib (Delta Safe)
-- UI Only - Minimal & Stable

local OrionLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/shlexware/Orion/main/source.lua"
))()

local Window = OrionLib:MakeWindow({
    Name = "TereHub",
    HidePremium = false,
    SaveConfig = false,
    IntroEnabled = false
})

-- Empty Tab
local Tab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

Tab:AddLabel("UI Loaded Successfully")
Tab:AddLabel("OrionLib is working")

OrionLib:Init()