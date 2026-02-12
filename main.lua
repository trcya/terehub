-- TEST MINIMALIS
local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()
local Window = WindUI:CreateWindow({
    Title = "Test Koneksi",
    Icon = "rbxassetid://10734934585",
    Author = "David",
    Folder = "Test"
})
local Tab = Window:CreateTab("Home", "home")
Tab:CreateButton({
    Title = "Berhasil!",
    Callback = function() print("UI Muncul!") end
})