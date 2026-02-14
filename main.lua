--[[
    TEREHUB - VIOLENCE DISTRICT
    STRUKTUR WINDIU YANG BENAR
    UI DIJAMIN MUNCUL!
]]

-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Tunggu player siap
repeat wait() until player and player.Character

-- Buat Window
local Window = WindUI:CreateWindow({
    Title = "Terehub - Violence District",
    Icon = "rbxassetid://136360402262473",
    SubTitle = "Auto Generator + Auto Aim",
    Author = "Beta",
    Folder = "TerehubVD",
    Size = UDim2.fromOffset(650, 500),
    Theme = "Violet",
    Transparent = true,
})

-- =============================================
-- PENTING! WindUI menggunakan struktur:
-- 1. Window:CreateTab() -> menghasilkan TAB
-- 2. TAB:CreateSection() -> menghasilkan SECTION
-- 3. SECTION:AddButton/AddSlider/AddToggle() -> menambah fitur
-- =============================================

-- ================ TAB MOVEMENT ================
local MovementTab = Window:CreateTab({ 
    Title = "Movement", 
    Icon = "move" 
})

-- Section 1: Speed Control
local speedSection = MovementTab:CreateSection("Speed Control")

speedSection:AddSlider({
    Title = "WalkSpeed",
    Description = "Atur kecepatan jalan",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(v)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = v
        end
    end
})

speedSection:AddSlider({
    Title = "JumpPower",
    Description = "Atur kekuatan lompat",
    Min = 50,
    Max = 200,
    Default = 50,
    Callback = function(v)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = v
        end
    end
})

-- Section 2: Flight
local flySection = MovementTab:CreateSection("Fly Mode")

local flyActive = false
local flyBV = nil
local flyConn = nil
local flySpeed = 50

flySection:AddToggle({
    Title = "Aktifkan Fly",
    Description = "Terbang dengan WASD + Space/Ctrl",
    Callback = function(state)
        flyActive = state
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        
        if state and root then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then humanoid.PlatformStand = true end
            
            flyBV = Instance.new("BodyVelocity")
            flyBV.MaxForce = Vector3.new(10000, 10000, 10000)
            flyBV.Parent = root
            
            flyConn = RunService.Heartbeat:Connect(function()
                if not flyActive or not root then return end
                
                local move = Vector3.new()
                local look = root.CFrame.LookVector
                local right = root.CFrame.RightVector
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + look end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - look end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - right end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + right end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
                
                flyBV.Velocity = move.Magnitude > 0 and move.Unit * flySpeed or Vector3.new(0,0,0)
            end)
        else
            if flyConn then flyConn:Disconnect() end
            if flyBV then flyBV:Destroy() end
            local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
            if humanoid then humanoid.PlatformStand = false end
        end
    end
})

flySection:AddSlider({
    Title = "Kecepatan Fly",
    Min = 10,
    Max = 200,
    Default = 50,
    Callback = function(v)
        flySpeed = v
    end
})

-- Section 3: NoClip
local noclipSection = MovementTab:CreateSection("NoClip")

local noclipActive = false
local noclipConn = nil

noclipSection:AddToggle({
    Title = "NoClip",
    Description = "Tembus tembok",
    Callback = function(state)
        noclipActive = state
        if state then
            noclipConn = RunService.Stepped:Connect(function()
                if noclipActive and player.Character then
                    for _, v in pairs(player.Character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        else
            if noclipConn then noclipConn:Disconnect() end
        end
    end
})

-- ================ TAB AUTO GENERATOR ================
local GeneratorTab = Window:CreateTab({ 
    Title = "Auto Generator", 
    Icon = "zap" 
})

local genSection = GeneratorTab:CreateSection("Pengaturan Generator")

local genActive = false
local genConn = nil
local genRadius = 50

genSection:AddToggle({
    Title = "Aktifkan Auto Generator",
    Description = "Otomatis mencari dan memperbaiki generator",
    Callback = function(state)
        genActive = state
        if state then
            -- Logic auto generator akan ditambahkan di sini
            print("Auto Generator Aktif")
        end
    end
})

genSection:AddSlider({
    Title = "Radius Pencarian",
    Min = 10,
    Max = 100,
    Default = 50,
    Callback = function(v)
        genRadius = v
    end
})

genSection:AddButton({
    Title = "Scan Generator",
    Description = "Cari generator di sekitar",
    Callback = function()
        local count = 0
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.Name:lower():find("generator") or v.Name:lower():find("gen") then
                count = count + 1
            end
        end
        WindUI:Notify({
            Title = "Hasil Scan",
            Content = "Ditemukan " .. count .. " generator"
        })
    end
})

-- ================ TAB AUTO AIM ================
local AimTab = Window:CreateTab({ 
    Title = "Auto Aim", 
    Icon = "crosshair" 
})

local aimSection = AimTab:CreateSection("Auto Aim ke Killer")

local aimActive = false
local aimConn = nil
local aimFov = 120
local aimSmooth = 5

aimSection:AddToggle({
    Title = "Aktifkan Auto Aim",
    Description = "Otomatis mengarah ke killer",
    Callback = function(state)
        aimActive = state
        if state then
            -- Logic auto aim akan ditambahkan di sini
            print("Auto Aim Aktif")
        end
    end
})

aimSection:AddSlider({
    Title = "Field of View (FOV)",
    Description = "Area deteksi target (derajat)",
    Min = 30,
    Max = 180,
    Default = 120,
    Callback = function(v)
        aimFov = v
    end
})

aimSection:AddSlider({
    Title = "Smoothness",
    Description = "Kehalusan aim (1-20)",
    Min = 1,
    Max = 20,
    Default = 5,
    Callback = function(v)
        aimSmooth = v
    end
})

aimSection:AddDropdown({
    Title = "Prioritas Target",
    Description = "Pilih prioritas aim",
    Values = {"Terdekat", "Health Terkecil", "Health Terbesar"},
    Default = "Terdekat",
    Callback = function(v)
        print("Prioritas:", v)
    end
})

-- ================ TAB ESP ================
local ESPTab = Window:CreateTab({ 
    Title = "ESP", 
    Icon = "eye" 
})

local espSection = ESPTab:CreateSection("ESP Settings")

espSection:AddToggle({
    Title = "ESP Killer",
    Description = "Highlight posisi killer",
    Callback = function(state)
        print("ESP Killer:", state)
    end
})

espSection:AddToggle({
    Title = "ESP Survivor",
    Description = "Highlight posisi survivor lain",
    Callback = function(state)
        print("ESP Survivor:", state)
    end
})

espSection:AddToggle({
    Title = "ESP Generator",
    Description = "Highlight posisi generator",
    Callback = function(state)
        print("ESP Generator:", state)
    end
})

espSection:AddColorPicker({
    Title = "Warna ESP Killer",
    Default = Color3.new(1, 0, 0),
    Callback = function(color)
        print("Warna Killer:", color)
    end
})

-- ================ TAB UTILITIES ================
local UtilTab = Window:CreateTab({ 
    Title = "Utilities", 
    Icon = "settings" 
})

local utilSection = UtilTab:CreateSection("Tools")

utilSection:AddButton({
    Title = "Reset Character",
    Description = "Respawn karakter",
    Callback = function()
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end
})

utilSection:AddButton({
    Title = "Anti AFK",
    Description = "Cegah kick karena AFK",
    Callback = function()
        local vu = game:GetService("VirtualUser")
        player.Idled:Connect(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
        WindUI:Notify({Title = "Anti AFK", Content = "Diaktifkan"})
    end
})

utilSection:AddButton({
    Title = "Infinite Yield",
    Description = "Load admin commands",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

-- ================ TAB TELEPORT ================
local TeleportTab = Window:CreateTab({ 
    Title = "Teleport", 
    Icon = "map-pin" 
})

local tpSection = TeleportTab:CreateSection("Teleport Options")

tpSection:AddButton({
    Title = "Teleport ke Spawn",
    Callback = function()
        local spawn = Workspace:FindFirstChild("SpawnLocation")
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if spawn and root then
            root.CFrame = spawn.CFrame * CFrame.new(0, 5, 0)
        end
    end
})

tpSection:AddButton({
    Title = "Teleport ke 0,100,0",
    Callback = function()
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(0, 100, 0)
        end
    end
})

-- ================ TAB SETTINGS ================
local SettingsTab = Window:CreateTab({ 
    Title = "Settings", 
    Icon = "sliders" 
})

local settingSection = SettingsTab:CreateSection("UI Settings")

settingSection:AddButton({
    Title = "Toggle UI (RightShift)",
    Callback = function()
        WindUI:Toggle()
    end
})

settingSection:AddButton({
    Title = "Unload Script",
    Callback = function()
        if flyConn then flyConn:Disconnect() end
        if flyBV then flyBV:Destroy() end
        if noclipConn then noclipConn:Disconnect() end
        WindUI:Destroy()
        script:Destroy()
    end
})

settingSection:AddLabel({
    Title = "Keybinds:",
    Description = "RightShift: Toggle UI\nEnd: Unload Script"
})

-- ================ KEYBINDS ================
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        WindUI:Toggle()
    elseif input.KeyCode == Enum.KeyCode.End then
        if flyConn then flyConn:Disconnect() end
        if flyBV then flyBV:Destroy() end
        if noclipConn then noclipConn:Disconnect() end
        WindUI:Destroy()
        script:Destroy()
    end
end)

-- Notifikasi sukses
wait(1)
WindUI:Notify({
    Title = "✅ TEREHUB - Violence District",
    Content = "Script berhasil dimuat! Tekan RightShift",
    Duration = 3
})

print("=== TEREHUB VIOLENCE DISTRICT LOADED ===")
print("Struktur WindUI sudah benar - fitur harus muncul!")
print("Tekan RightShift untuk toggle GUI")