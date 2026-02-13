local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/Source.lua"))()

local Window = WindUI:CreateWindow({
    Title = "terehub | David",
    Icon = "rbxassetid://4483362458",
    Author = "David",
    Folder = "terehub_configs",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200
})

local MainTab = Window:Tab({ Title = "Main", Icon = "home" })

MainTab:Button({
    Title = "Test Button",
    Callback = function()
        print("UI Berhasil Muncul!")
    end
})