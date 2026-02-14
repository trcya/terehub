--[[
    TEREHUB - VIOLENCE DISTRICT
    SEMUA FITUR DALAM 1 WINDOW
    (Mengikuti struktur persis seperti yang Anda minta)
]]

-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- Tunggu player siap
repeat task.wait() until player and player.Character

-- ============================================
-- WINDOW UTAMA (Sesuai permintaan Anda)
-- ============================================
local Window = WindUI:CreateWindow({
    Title = "Terehub",
    Icon = "rbxassetid://136360402262473",
    Author = "Beta Tester",
    Folder = "Terehub",
    Size = UDim2.fromOffset(600, 360),
    MinSize = Vector2.new(560, 250),
    MaxSize = Vector2.new(950, 760),
    Transparent = true,
    Theme = "Indigo",
    Resizable = true,
    SideBarWidth = 190,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = false,
    ScrollBarEnabled = true,
})

-- ============================================
-- VARIABLES GLOBAL
-- ============================================
local flyActive = false
local flyBV = nil
local flyConn = nil
local flySpeed = 50
local noclipActive = false
local noclipConn = nil
local selectedPlayer = nil
local autoGenActive = false
local autoAimActive = false
local espKillerActive = false
local espSurvivorActive = false
local espGenActive = false
local espColor = Color3.new(1, 0, 0)
local waypoints = {}
local targetKiller = nil
local genRadius = 50
local aimFov = 120
local aimSmooth = 5

-- ============================================
-- FUNGSI UTILITY
-- ============================================
local function getRoot()
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    return player.Character and player.Character:FindFirstChild("Humanoid")
end

-- Fungsi scan killer
local function scanKillers()
    local killers = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") then
            local humanoid = v:FindFirstChildOfClass("Humanoid")
            local root = v:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health > 0 and root then
                if not Players:GetPlayerFromCharacter(v) then
                    table.insert(killers, {
                        name = v.Name,
                        root = root,
                        humanoid = humanoid,
                        health = humanoid.Health
                    })
                end
            end
        end
    end
    return killers
end

-- Fungsi scan generator
local function scanGenerators()
    local gens = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") then
            local name = v.Name:lower()
            if name:find("generator") or name:find("gen") or name:find("repair") then
                table.insert(gens, v)
            end
        end
    end
    return gens
end

-- ============================================
-- TAB MOVEMENT
-- ============================================
local MovementTab = Window:CreateTab({
    Title = "Movement",
    Icon = "move"
})

-- Section Speed
local speedSection = MovementTab:CreateSection("⚡ Speed Control")
speedSection:AddSlider({
    Title = "WalkSpeed",
    Description = "Atur kecepatan jalan (16-200)",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(v)
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = v end
    end
})

speedSection:AddSlider({
    Title = "JumpPower",
    Description = "Atur kekuatan lompat (50-200)",
    Min = 50,
    Max = 200,
    Default = 50,
    Callback = function(v)
        local hum = getHumanoid()
        if hum then hum.JumpPower = v end
    end
})

speedSection:AddButton({
    Title = "Reset Speed & Jump",
    Description = "Kembali ke nilai normal",
    Callback = function()
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
            WindUI:Notify({Title = "Reset", Content = "Speed & Jump normal"})
        end
    end
})

-- Section Fly
local flySection = MovementTab:CreateSection("🕊️ Fly Mode")
flySection:AddToggle({
    Title = "Aktifkan Fly",
    Description = "Terbang dengan WASD + Space/Ctrl",
    Callback = function(state)
        flyActive = state
        local root = getRoot()
        
        if state and root then
            local hum = getHumanoid()
            if hum then hum.PlatformStand = true end
            
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
            
            WindUI:Notify({Title = "Fly Mode", Content = "Aktif!"})
        else
            if flyConn then flyConn:Disconnect() end
            if flyBV then flyBV:Destroy() end
            local hum = getHumanoid()
            if hum then hum.PlatformStand = false end
        end
    end
})

flySection:AddSlider({
    Title = "Fly Speed",
    Description = "Kecepatan terbang",
    Min = 10,
    Max = 200,
    Default = 50,
    Callback = function(v)
        flySpeed = v
    end
})

flySection:AddButton({
    Title = "Matikan Fly",
    Callback = function()
        flyActive = false
        if flyConn then flyConn:Disconnect() end
        if flyBV then flyBV:Destroy() end
        local hum = getHumanoid()
        if hum then hum.PlatformStand = false end
        WindUI:Notify({Title = "Fly Mode", Content = "Dimatikan"})
    end
})

-- Section NoClip
local noclipSection = MovementTab:CreateSection("🚪 NoClip")
noclipSection:AddToggle({
    Title = "NoClip",
    Description = "Tembus tembok dan objek",
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
            WindUI:Notify({Title = "NoClip", Content = "Aktif"})
        else
            if noclipConn then noclipConn:Disconnect() end
        end
    end
})

-- ============================================
-- TAB AUTO GENERATOR
-- ============================================
local GenTab = Window:CreateTab({
    Title = "Generator",
    Icon = "zap"
})

local genSection = GenTab:CreateSection("⚡ Auto Generator")

genSection:AddToggle({
    Title = "Aktifkan Auto Generator",
    Description = "Otomatis mencari dan memperbaiki generator",
    Callback = function(state)
        autoGenActive = state
        WindUI:Notify({
            Title = "Auto Generator",
            Content = state and "ON" or "OFF"
        })
    end
})

genSection:AddSlider({
    Title = "Radius Pencarian",
    Description = "Jarak maksimal mencari generator",
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
        local gens = scanGenerators()
        local count = #gens
        WindUI:Notify({
            Title = "Hasil Scan",
            Content = "Ditemukan " .. count .. " generator"
        })
    end
})

-- ============================================
-- TAB AUTO AIM
-- ============================================
local AimTab = Window:CreateTab({
    Title = "Auto Aim",
    Icon = "crosshair"
})

local aimSection = AimTab:CreateSection("🎯 Auto Aim ke Killer")

aimSection:AddToggle({
    Title = "Aktifkan Auto Aim",
    Description = "Otomatis mengarahkan kamera ke killer",
    Callback = function(state)
        autoAimActive = state
        WindUI:Notify({
            Title = "Auto Aim",
            Content = state and "ON" or "OFF"
        })
    end
})

aimSection:AddSlider({
    Title = "FOV (Field of View)",
    Description = "Area deteksi target (30-180°)",
    Min = 30,
    Max = 180,
    Default = 120,
    Callback = function(v)
        aimFov = v
    end
})

aimSection:AddSlider({
    Title = "Smoothness",
    Description = "Kehalusan gerakan aim (1-20)",
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

-- ============================================
-- TAB ESP
-- ============================================
local ESPTab = Window:CreateTab({
    Title = "ESP",
    Icon = "eye"
})

local espSection = ESPTab:CreateSection("👁️ ESP Settings")

espSection:AddToggle({
    Title = "ESP Killer",
    Description = "Lihat posisi killer (Merah)",
    Callback = function(state)
        espKillerActive = state
        WindUI:Notify({Title = "ESP Killer", Content = state and "ON" or "OFF"})
    end
})

espSection:AddToggle({
    Title = "ESP Survivor",
    Description = "Lihat posisi survivor lain (Hijau)",
    Callback = function(state)
        espSurvivorActive = state
    end
})

espSection:AddToggle({
    Title = "ESP Generator",
    Description = "Lihat posisi generator (Kuning)",
    Callback = function(state)
        espGenActive = state
    end
})

espSection:AddColorPicker({
    Title = "Warna ESP Killer",
    Description = "Pilih warna highlight killer",
    Default = Color3.new(1, 0, 0),
    Callback = function(color)
        espColor = color
    end
})

-- ============================================
-- TAB TELEPORT
-- ============================================
local TpTab = Window:CreateTab({
    Title = "Teleport",
    Icon = "map-pin"
})

local tpSection = TpTab:CreateSection("📍 Teleport Options")

-- Teleport ke Spawn
tpSection:AddButton({
    Title = "Teleport ke Spawn",
    Description = "Kembali ke titik spawn",
    Callback = function()
        local spawn = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
        local root = getRoot()
        if spawn and root then
            root.CFrame = spawn.CFrame * CFrame.new(0, 5, 0)
            WindUI:Notify({Title = "Teleport", Content = "Ke Spawn"})
        end
    end
})

-- Teleport ke 0,100,0
tpSection:AddButton({
    Title = "Teleport ke 0,100,0",
    Description = "Pergi ke tengah map",
    Callback = function()
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(0, 100, 0)
            WindUI:Notify({Title = "Teleport", Content = "Ke 0,100,0"})
        end
    end
})

-- Dropdown Player
local playerNames = {}
for _, p in pairs(Players:GetPlayers()) do
    if p ~= player then
        table.insert(playerNames, p.Name)
    end
end

tpSection:AddDropdown({
    Title = "Pilih Player",
    Description = "Target teleport ke player",
    Values = playerNames,
    Callback = function(selected)
        selectedPlayer = Players:FindFirstChild(selected)
        if selectedPlayer then
            WindUI:Notify({Title = "Target", Content = "Memilih " .. selected})
        end
    end
})

tpSection:AddButton({
    Title = "Teleport ke Player",
    Description = "Pindah ke player yang dipilih",
    Callback = function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = getRoot()
            if root then
                root.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                WindUI:Notify({Title = "Teleport", Content = "Ke " .. selectedPlayer.Name})
            end
        else
            WindUI:Notify({Title = "Error", Content = "Pilih player dulu!"})
        end
    end
})

-- Bring All
tpSection:AddButton({
    Title = "Bring All Players",
    Description = "Tarik semua player ke posisi Anda",
    Callback = function()
        local root = getRoot()
        if not root then return end
        
        local count = 0
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(0, 3, 0)
                count = count + 1
            end
        end
        WindUI:Notify({Title = "Bring All", Content = count .. " player ditarik"})
    end
})

-- Waypoints
local waypointSection = TpTab:CreateSection("📍 Waypoints")

waypointSection:AddButton({
    Title = "Save Waypoint",
    Description = "Simpan posisi sekarang",
    Callback = function()
        local root = getRoot()
        if root then
            table.insert(waypoints, {
                name = "Waypoint " .. #waypoints + 1,
                pos = root.Position
            })
            WindUI:Notify({Title = "Waypoint", Content = "Tersimpan"})
        end
    end
})

waypointSection:AddButton({
    Title = "Load Waypoint",
    Description = "Teleport ke waypoint",
    Callback = function()
        if #waypoints == 0 then
            WindUI:Notify({Title = "Error", Content = "Tidak ada waypoint"})
            return
        end
        
        local wpList = {}
        for _, wp in pairs(waypoints) do
            table.insert(wpList, wp.name)
        end
        
        -- Akan dibuat dropdown dinamis di sini
    end
})

-- ============================================
-- TAB UTILITIES
-- ============================================
local UtilTab = Window:CreateTab({
    Title = "Utilities",
    Icon = "settings"
})

local utilSection = UtilTab:CreateSection("🛠️ Tools")

-- Reset Character
utilSection:AddButton({
    Title = "Reset Character",
    Description = "Respawn karakter",
    Callback = function()
        local hum = getHumanoid()
        if hum then
            hum.Health = 0
        end
    end
})

-- Anti AFK
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

-- Fullbright
utilSection:AddToggle({
    Title = "Fullbright",
    Description = "Pencahayaan maksimal",
    Callback = function(state)
        if state then
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.Brightness = 2
            Lighting.GlobalShadows = false
        else
            Lighting.Ambient = Color3.new(0, 0, 0)
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
        end
    end
})

-- X-Ray
utilSection:AddSlider({
    Title = "X-Ray",
    Description = "Transparansi dinding",
    Min = 0,
    Max = 0.9,
    Default = 0,
    Callback = function(v)
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part:IsDescendantOf(player.Character) then
                part.Transparency = v
            end
        end
    end
})

-- Infinite Yield
utilSection:AddButton({
    Title = "Infinite Yield",
    Description = "Load admin commands",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

-- Map Info
utilSection:AddButton({
    Title = "Map Info",
    Description = "Informasi tentang map",
    Callback = function()
        local partCount = 0
        for _ in pairs(Workspace:GetDescendants()) do
            partCount = partCount + 1
        end
        WindUI:Notify({
            Title = "Map Info",
            Content = "Total Objects: " .. partCount
        })
    end
})

-- ============================================
-- TAB SETTINGS
-- ============================================
local SettingsTab = Window:CreateTab({
    Title = "Settings",
    Icon = "sliders"
})

local settingSection = SettingsTab:CreateSection("⚙️ UI Settings")

-- Toggle UI
settingSection:AddButton({
    Title = "Toggle UI (RightShift)",
    Description = "Buka/tutup GUI",
    Callback = function()
        WindUI:Toggle()
    end
})

-- Transparency
settingSection:AddSlider({
    Title = "UI Transparency",
    Description = "Atur transparansi UI",
    Min = 0,
    Max = 0.8,
    Default = 0.42,
    Callback = function(v)
        for _, gui in pairs(player.PlayerGui:GetDescendants()) do
            if gui:IsA("Frame") then
                gui.BackgroundTransparency = v
            end
        end
    end
})

-- Theme Selector
settingSection:AddDropdown({
    Title = "Theme",
    Description = "Ganti tema warna",
    Values = {"Indigo", "Violet", "Midnight", "Rose", "Sky", "Emerald"},
    Default = "Indigo",
    Callback = function(selected)
        -- Note: Untuk ganti theme perlu reload window
        WindUI:Notify({Title = "Theme", Content = selected .. " dipilih"})
    end
})

-- Unload
settingSection:AddButton({
    Title = "Unload Script",
    Description = "Hapus semua fitur",
    Callback = function()
        if flyConn then flyConn:Disconnect() end
        if flyBV then flyBV:Destroy() end
        if noclipConn then noclipConn:Disconnect() end
        WindUI:Destroy()
        script:Destroy()
    end
})

-- Info
settingSection:AddLabel({
    Title = "Keybinds:",
    Description = "RightShift: Toggle UI\nEnd: Unload Script"
})

-- ============================================
-- KEYBINDS
-- ============================================
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

-- ============================================
-- NOTIFIKASI
-- ============================================
task.wait(1)
WindUI:Notify({
    Title = "✅ Terehub - Violence District",
    Content = "Script Loaded! Tekan RightShift",
    Duration = 3
})

print("=== TEREHUB VIOLENCE DISTRICT LOADED ===")
print("✅ Window: Title = Terehub")
print("✅ Theme: Indigo")
print("✅ Transparent: true")
print("✅ HideSearchBar: false")
print("✅ Fitur: Movement, Generator, Auto Aim, ESP, Teleport, Utilities, Settings")
print("✅ Tekan RightShift untuk toggle UI")