--[[
    TEREHUB - VIOLENCE DISTRICT
    MENGGUNAKAN LIBRARY KAVO UI (LEBIH STABIL)
    UI DIJAMIN MUNCUL!
]]

-- Load Kavo UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Terehub - Violence District", "DarkTheme")

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Tunggu player siap
repeat task.wait() until player and player.Character

-- Variables
local flyActive = false
local flyBV = nil
local flyConn = nil
local flySpeed = 50
local noclipActive = false
local noclipConn = nil
local espActive = false
local espConn = nil

-- ================ TAB MOVEMENT ================
local MovementTab = Window:NewTab("Movement")
local MovementSection = MovementTab:NewSection("Movement Controls")

-- WalkSpeed Slider
MovementSection:NewSlider("WalkSpeed", "Atur kecepatan jalan", 200, 16, function(v)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = v
    end
end)

-- JumpPower Slider
MovementSection:NewSlider("JumpPower", "Atur kekuatan lompat", 200, 50, function(v)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = v
    end
end)

-- Fly Toggle
MovementSection:NewToggle("Fly Mode", "Terbang dengan WASD + Space/Ctrl", function(state)
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
end)

-- Fly Speed Slider
MovementSection:NewSlider("Fly Speed", "Kecepatan terbang", 200, 50, function(v)
    flySpeed = v
end)

-- NoClip Toggle
MovementSection:NewToggle("NoClip", "Tembus tembok", function(state)
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
end)

-- Reset Button
MovementSection:NewButton("Reset Speed & Jump", "Kembali ke normal", function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 16
        player.Character.Humanoid.JumpPower = 50
    end
end)

-- ================ TAB AUTO GENERATOR ================
local GeneratorTab = Window:NewTab("Auto Generator")
local GenSection = GeneratorTab:NewSection("Generator Settings")

GenSection:NewToggle("Auto Generator", "Otomatis memperbaiki generator", function(state)
    print("Auto Generator:", state)
    -- Tambahkan logic auto generator di sini
end)

GenSection:NewSlider("Search Radius", "Radius pencarian generator", 100, 50, function(v)
    print("Radius:", v)
end)

GenSection:NewButton("Scan Generator", "Cari generator di sekitar", function()
    local count = 0
    for _, v in pairs(Workspace:GetDescendants()) do
        local name = v.Name:lower()
        if name:find("generator") or name:find("gen") or name:find("repair") then
            count = count + 1
        end
    end
    Library:Notify("Ditemukan " .. count .. " generator")
end)

-- ================ TAB AUTO AIM ================
local AimTab = Window:NewTab("Auto Aim")
local AimSection = AimTab:NewSection("Aim Settings")

AimSection:NewToggle("Auto Aim ke Killer", "Otomatis mengarah ke killer", function(state)
    print("Auto Aim:", state)
    -- Tambahkan logic auto aim di sini
end)

AimSection:NewSlider("FOV", "Field of View", 180, 120, function(v)
    print("FOV:", v)
end)

AimSection:NewSlider("Smoothness", "Kehalusan aim", 20, 5, function(v)
    print("Smooth:", v)
end)

AimSection:NewDropdown("Prioritas Target", "Pilih prioritas", {"Terdekat", "Health Terkecil", "Health Terbesar"}, function(v)
    print("Prioritas:", v)
end)

-- ================ TAB ESP ================
local ESPTab = Window:NewTab("ESP")
local ESPSection = ESPTab:NewSection("ESP Settings")

ESPSection:NewToggle("ESP Killer", "Lihat posisi killer", function(state)
    espActive = state
    if state then
        -- Logic ESP di sini
    end
end)

ESPSection:NewToggle("ESP Survivor", "Lihat posisi survivor lain", function(state)
    print("ESP Survivor:", state)
end)

ESPSection:NewToggle("ESP Generator", "Lihat posisi generator", function(state)
    print("ESP Generator:", state)
end)

ESPSection:NewColorPicker("Warna ESP", "Pilih warna", Color3.new(1,0,0), function(color)
    print("Warna:", color)
end)

-- ================ TAB TELEPORT ================
local TeleportTab = Window:NewTab("Teleport")
local TeleportSection = TeleportTab:NewSection("Teleport Options")

TeleportSection:NewButton("Teleport ke Spawn", "Kembali ke spawn", function()
    local spawn = Workspace:FindFirstChild("SpawnLocation")
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if spawn and root then
        root.CFrame = spawn.CFrame * CFrame.new(0, 5, 0)
        Library:Notify("Teleport ke Spawn")
    end
end)

TeleportSection:NewButton("Teleport ke 0,100,0", "Pergi ke tengah map", function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(0, 100, 0)
        Library:Notify("Teleport ke 0,100,0")
    end
end)

-- Dropdown Player
local playerList = {}
for _, p in pairs(Players:GetPlayers()) do
    if p ~= player then
        table.insert(playerList, p.Name)
    end
end

TeleportSection:NewDropdown("Pilih Player", "Target teleport", playerList, function(selected)
    local target = Players:FindFirstChild(selected)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
            Library:Notify("Teleport ke " .. selected)
        end
    end
end)

-- ================ TAB UTILITIES ================
local UtilTab = Window:NewTab("Utilities")
local UtilSection = UtilTab:NewSection("Tools")

UtilSection:NewButton("Reset Character", "Respawn karakter", function()
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Health = 0
    end
end)

UtilSection:NewButton("Anti AFK", "Cegah kick karena AFK", function()
    local vu = game:GetService("VirtualUser")
    player.Idled:Connect(function()
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
    Library:Notify("Anti AFK Diaktifkan")
end)

UtilSection:NewButton("Infinite Yield", "Load admin commands", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

UtilSection:NewButton("Get Map Info", "Informasi tentang map", function()
    local count = 0
    for _ in pairs(Workspace:GetDescendants()) do
        count = count + 1
    end
    Library:Notify("Total Objects: " .. count)
end)

-- ================ TAB SETTINGS ================
local SettingsTab = Window:NewTab("Settings")
local SettingsSection = SettingsTab:NewSection("UI Settings")

SettingsSection:NewKeybind("Toggle UI", "Buka/tutup UI", Enum.KeyCode.RightShift, function()
    Library:ToggleUI()
end)

SettingsSection:NewButton("Unload Script", "Hapus semua fitur", function()
    if flyConn then flyConn:Disconnect() end
    if flyBV then flyBV:Destroy() end
    if noclipConn then noclipConn:Disconnect() end
    Library:Unload()
    script:Destroy()
end)

-- Notifikasi
Library:Notify("✅ Terehub - Violence District Loaded!")

print("=== TEREHUB VIOLENCE DISTRICT LOADED ===")
print("Menggunakan Kavo UI Library")
print("Tekan RightShift untuk toggle UI")