local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "terehub | Admin Panel",
    Icon = "rbxassetid://128278170341835", -- ID Ikon pilihanmu
    Author = "David",
    Folder = "terehub_configs", -- Folder untuk menyimpan konfigurasi
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark", -- Tema default: "Dark" atau "Light"
    SideBarWidth = 200,
})

local MainTab = Window:Tab({
    Title = "Movement",
    Icon = "walking", -- Mendukung Lucide Icons
})

MainTab:Toggle({
    Title = "Infinite Jump",
    Callback = function(state)
        print("Infinite Jump: ", state)
        -- Masukkan logika terbang/lompat di sini
    end,
})

MainTab:Slider({
    Title = "WalkSpeed",
    Value = { Min = 16, Max = 500, Default = 16 },
    Callback = function(v)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
    end,
})