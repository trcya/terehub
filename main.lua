--[[
    TEREHUB - TEST SEDERHANA
    HANYA 1 TAB DULU UNTUK TEST
]]

print("🚀 Mulai load script...")

-- Load WindUI
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not success then
    print("❌ Gagal load WindUI:", WindUI)
    return
end

print("✅ WindUI berhasil di-load")

-- Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Tunggu player
repeat task.wait() until player and player.Character
print("✅ Player siap")

-- Buat Window SEDERHANA
local Window = WindUI:CreateWindow({
    Title = "TEREHUB TEST",
    SubTitle = "v1.0",
    Theme = "Violet",
    Size = UDim2.fromOffset(400, 300),
    Transparent = true,
})

print("✅ Window dibuat")

-- Buat 1 TAB
local MainTab = Window:CreateTab({
    Title = "TEST",
    Icon = "home"
})

print("✅ Tab dibuat")

-- Buat 1 SECTION
local testSection = MainTab:CreateSection("TEST SECTION")
print("✅ Section dibuat")

-- Buat 1 BUTTON
testSection:AddButton({
    Title = "TEST BUTTON",
    Description = "Klik untuk test",
    Callback = function()
        print("✅ Tombol ditekan!")
        -- Notifikasi
        WindUI:Notify({
            Title = "TEST",
            Content = "Tombol bekerja!",
            Duration = 2
        })
    end
})

print("✅ Button dibuat")

-- Buat 1 SLIDER
testSection:AddSlider({
    Title = "TEST SLIDER",
    Min = 1,
    Max = 10,
    Default = 5,
    Callback = function(v)
        print("Slider value:", v)
    end
})

print("✅ Slider dibuat")

-- Buat 1 TOGGLE
testSection:AddToggle({
    Title = "TEST TOGGLE",
    Callback = function(state)
        print("Toggle state:", state)
    end
})

print("✅ Toggle dibuat")

-- Notifikasi
task.wait(1)
WindUI:Notify({
    Title = "TEREHUB TEST",
    Content = "Script berhasil di-load!",
    Duration = 3
})

print("=== SCRIPT SELESAI ===")
print("Tekan RightShift untuk toggle UI")