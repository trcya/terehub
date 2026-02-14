-- TereHub - Rayfield UI
-- Purple Blue Theme
-- UI Only (Empty)

local Rayfield = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua"
))()

local Window = Rayfield:CreateWindow({
    Name = "TereHub",
    LoadingTitle = "TereHub",
    LoadingSubtitle = "Rayfield UI",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- Main Tab (Kosong)
local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateLabel("UI Loaded Successfully")
MainTab:CreateLabel("Rayfield is working")

-- Optional: Theme info
local ThemeTab = Window:CreateTab("Theme", 4483362458)

ThemeTab:CreateLabel("Default Rayfield theme active")