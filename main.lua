local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()

local Window = WindUI:CreateWindow({
    Title = "Admin Tester Panel",
    Icon = "rbxassetid://10734934585",
    Author = "David",
    Folder = "DavidTestConfig"
})

local MainTab = Window:CreateTab("Main", "home")
local VisualTab = Window:CreateTab("Visuals", "eye") -- Tab baru untuk ESP
local SettingsTab = Window:CreateTab("Settings", "settings")

-- [ MAIN TAB: MOVEMENT ] --

MainTab:CreateSlider({
    Title = "WalkSpeed",
    Desc = "Kecepatan jalan karakter",
    Min = 16, Max = 300, Default = 16,
    Callback = function(v)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    end
})

local noclipActive = false
MainTab:CreateToggle({
    Title = "Noclip Mode",
    Desc = "Tembus objek/dinding",
    Value = false,
    Callback = function(state) noclipActive = state end
})

-- [ VISUAL TAB: ESP ] --
-- Berguna untuk melihat apakah ada pemain/objek yang tersangkut di map
local espActive = false
VisualTab:CreateToggle({
    Title = "Player ESP",
    Desc = "Lihat pemain lain menembus dinding",
    Value = false,
    Callback = function(state)
        espActive = state
        if not state then
            for _, v in pairs(game.Players:GetPlayers()) do
                if v.Character and v.Character:FindFirstChild("Highlight") then
                    v.Character.Highlight:Destroy()
                end
            end
        end
    end
})

-- [ SETTINGS TAB: UTILITIES ] --

SettingsTab:CreateButton({
    Title = "Rejoin Server",
    Desc = "Segarkan koneksi ke server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end
})

SettingsTab:CreateButton({
    Title = "Destroy UI",
    Desc = "Menutup dan menghapus panel ini",
    Callback = function()
        Window:Close()
    end
})

-- [ BACKGROUND LOGICS ] --

-- Loop Noclip & ESP
game:GetService("RunService").RenderStepped:Connect(function()
    local char = game.Players.LocalPlayer.Character
    -- Logic Noclip
    if noclipActive and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    -- Logic ESP (Highlighting)
    if espActive then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                if not p.Character:FindFirstChild("Highlight") then
                    local h = Instance.new("Highlight", p.Character)
                    h.FillColor = Color3.fromRGB(255, 0, 0)
                    h.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            end
        end
    end
end)

-- Notifikasi Awal
WindUI:Notify({
    Title = "System Ready",
    Content = "Halo David, mode testing aktif.",
    Duration = 5,
    Type = "Info"
})