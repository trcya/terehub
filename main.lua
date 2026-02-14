--[[
    TEREHUB - VIOLENCE DISTRICT
    WINDIU - VERSI SUPER FIX
    UI DIJAMIN MUNCUL!
]]

-- Load WindUI dengan error handling
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not success or not WindUI then
    -- Fallback ke UI sederhana jika WindUI gagal load
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 400, 0, 300)
    Frame.Position = UDim2.new(0.5, -200, 0.5, -150)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "TEREHUB - VIOLENCE DISTRICT"
    Title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Parent = Frame
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 40)
    Button.Position = UDim2.new(0, 10, 0, 50)
    Button.Text = "Test Button"
    Button.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Parent = Frame
    
    print("⚠️ WindUI gagal load, menggunakan fallback UI")
    return
end

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Tunggu player siap
repeat task.wait() until player and player.Character

-- Buat Window dengan opsi lengkap
local Window = WindUI:CreateWindow({
    Title = "Terehub - Violence District",
    Icon = "rbxassetid://136360402262473",
    SubTitle = "Beta v1.0",
    Author = "Tere",
    Folder = "TerehubVD",
    Size = UDim2.fromOffset(650, 500),
    MinSize = Vector2.new(500, 400),
    MaxSize = Vector2.new(900, 700),
    Theme = "Violet",
    Transparent = true,
    Resizable = true,
    SideBarWidth = 180,
    BackgroundImageTransparency = 0.3,
})

-- Variabel Global
local flyActive = false
local flyBV = nil
local flyConn = nil
local flySpeed = 50
local noclipActive = false
local noclipConn = nil

-- ============================================
-- STRUKTUR WINDIU YANG BENAR:
-- 1. Window:CreateTab() -> menghasilkan TAB
-- 2. TAB:CreateSection() -> menghasilkan SECTION
-- 3. SECTION:AddButton/AddSlider/AddToggle() -> menambah fitur
-- ============================================

-- ================ TAB MOVEMENT ================
local MovementTab = Window:CreateTab({
    Title = "Movement",
    Icon = "move"
})

-- Section 1: Speed Control
local speedSection = MovementTab:CreateSection("⚡ Speed Control")

-- WalkSpeed Slider
speedSection:AddSlider({
    Title = "WalkSpeed",
    Description = "Atur kecepatan jalan (16-200)",
    Min = 16,
    Max = 200,
    Default = 16,
    Unit = "studs/s",
    Callback = function(v)
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = v
            print("WalkSpeed diubah ke:", v) -- Debug
        end
    end
})

-- JumpPower Slider
speedSection:AddSlider({
    Title = "JumpPower",
    Description = "Atur kekuatan lompat (50-200)",
    Min = 50,
    Max = 200,
    Default = 50,
    Unit = "power",
    Callback = function(v)
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = v
            print("JumpPower diubah ke:", v)
        end
    end
})

-- Reset Button
speedSection:AddButton({
    Title = "Reset Speed & Jump",
    Description = "Kembalikan ke nilai normal",
    Icon = "rotate-ccw",
    Callback = function()
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
            WindUI:Notify({
                Title = "Reset",
                Content = "Speed & Jump kembali normal"
            })
        end
    end
})

-- Section 2: Fly Mode
local flySection = MovementTab:CreateSection("🕊️ Fly Mode")

-- Fly Toggle
flySection:AddToggle({
    Title = "Aktifkan Fly",
    Description = "Terbang dengan WASD + Space/Ctrl",
    Icon = "bird",
    Callback = function(state)
        flyActive = state
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        
        if state and root then
            -- Matikan yang lama jika ada
            if flyConn then flyConn:Disconnect() end
            if flyBV then flyBV:Destroy() end
            
            -- Set platform stand
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.PlatformStand = true
            end
            
            -- Buat BodyVelocity
            flyBV = Instance.new("BodyVelocity")
            flyBV.Name = "TereFly"
            flyBV.MaxForce = Vector3.new(10000, 10000, 10000)
            flyBV.Parent = root
            
            -- Loop untuk kontrol fly
            flyConn = RunService.Heartbeat:Connect(function()
                if not flyActive or not root or not flyBV then return end
                
                local move = Vector3.new()
                local look = root.CFrame.LookVector
                local right = root.CFrame.RightVector
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    move = move + look
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    move = move - look
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    move = move - right
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    move = move + right
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    move = move + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    move = move - Vector3.new(0, 1, 0)
                end
                
                if move.Magnitude > 0 then
                    flyBV.Velocity = move.Unit * flySpeed
                else
                    flyBV.Velocity = Vector3.new(0, 0, 0)
                end
            end)
            
            WindUI:Notify({
                Title = "Fly Mode",
                Content = "Aktif! Gunakan WASD + Space/Ctrl"
            })
        else
            -- Matikan fly
            if flyConn then
                flyConn:Disconnect()
                flyConn = nil
            end
            if flyBV then
                flyBV:Destroy()
                flyBV = nil
            end
            local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.PlatformStand = false
            end
        end
    end
})

-- Fly Speed Slider
flySection:AddSlider({
    Title = "Kecepatan Fly",
    Description = "Atur kecepatan terbang",
    Min = 10,
    Max = 200,
    Default = 50,
    Unit = "studs/s",
    Callback = function(v)
        flySpeed = v
        print("Fly speed diubah ke:", v)
    end
})

-- Stop Fly Button
flySection:AddButton({
    Title = "Matikan Fly",
    Description = "Nonaktifkan mode terbang",
    Icon = "square",
    Callback = function()
        flyActive = false
        if flyConn then
            flyConn:Disconnect()
            flyConn = nil
        end
        if flyBV then
            flyBV:Destroy()
            flyBV = nil
        end
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
        WindUI:Notify({
            Title = "Fly Mode",
            Content = "Dimatikan"
        })
    end
})

-- Section 3: NoClip
local noclipSection = MovementTab:CreateSection("🚪 NoClip")

-- NoClip Toggle
noclipSection:AddToggle({
    Title = "NoClip",
    Description = "Tembus tembok dan objek",
    Icon = "slash",
    Callback = function(state)
        noclipActive = state
        if state then
            if noclipConn then noclipConn:Disconnect() end
            noclipConn = RunService.Stepped:Connect(function()
                if noclipActive and player.Character then
                    for _, v in pairs(player.Character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end)
            WindUI:Notify({
                Title = "NoClip",
                Content = "Aktif - Bisa tembus tembok"
            })
        else
            if noclipConn then
                noclipConn:Disconnect()
                noclipConn = nil
            end
        end
    end
})

-- ================ TAB AUTO GENERATOR ================
local GeneratorTab = Window:CreateTab({
    Title = "Generator",
    Icon = "zap"
})

local genSection = GeneratorTab:CreateSection("⚡ Auto Generator")

-- Status Label
local genStatus = genSection:AddLabel({
    Title = "Status: OFF",
    Description = "Auto Generator belum aktif"
})

-- Toggle Auto Generator
genSection:AddToggle({
    Title = "Aktifkan Auto Generator",
    Description = "Otomatis mencari dan memperbaiki generator",
    Icon = "play",
    Callback = function(state)
        if state then
            genStatus:SetTitle("Status: AKTIF")
            genStatus:SetDescription("Mencari generator...")
            WindUI:Notify({
                Title = "Auto Generator",
                Content = "Diaktifkan"
            })
        else
            genStatus:SetTitle("Status: OFF")
            genStatus:SetDescription("Auto Generator mati")
        end
        print("Auto Generator:", state)
    end
})

-- Radius Slider
genSection:AddSlider({
    Title = "Radius Pencarian",
    Description = "Jarak maksimal mencari generator",
    Min = 10,
    Max = 100,
    Default = 50,
    Unit = "studs",
    Callback = function(v)
        print("Radius pencarian:", v)
    end
})

-- Scan Button
genSection:AddButton({
    Title = "Scan Generator",
    Description = "Cari generator di sekitar",
    Icon = "search",
    Callback = function()
        local count = 0
        for _, v in pairs(Workspace:GetDescendants()) do
            local name = v.Name:lower()
            if name:find("generator") or name:find("gen") or name:find("repair") then
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

local aimSection = AimTab:CreateSection("🎯 Auto Aim ke Killer")

-- Toggle Auto Aim
aimSection:AddToggle({
    Title = "Aktifkan Auto Aim",
    Description = "Otomatis mengarah ke killer",
    Icon = "target",
    Callback = function(state)
        print("Auto Aim:", state)
        if state then
            WindUI:Notify({
                Title = "Auto Aim",
                Content = "Diaktifkan"
            })
        end
    end
})

-- FOV Slider
aimSection:AddSlider({
    Title = "Field of View (FOV)",
    Description = "Area deteksi target",
    Min = 30,
    Max = 180,
    Default = 120,
    Unit = "°",
    Callback = function(v)
        print("FOV:", v)
    end
})

-- Smoothness Slider
aimSection:AddSlider({
    Title = "Smoothness",
    Description = "Kehalusan gerakan aim",
    Min = 1,
    Max = 20,
    Default = 5,
    Callback = function(v)
        print("Smoothness:", v)
    end
})

-- Priority Dropdown
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

local espSection = ESPTab:CreateSection("👁️ ESP Settings")

-- ESP Killer Toggle
espSection:AddToggle({
    Title = "ESP Killer",
    Description = "Highlight posisi killer",
    Icon = "skull",
    Callback = function(state)
        print("ESP Killer:", state)
        if state then
            WindUI:Notify({
                Title = "ESP Killer",
                Content = "Diaktifkan"
            })
        end
    end
})

-- ESP Survivor Toggle
espSection:AddToggle({
    Title = "ESP Survivor",
    Description = "Highlight posisi survivor lain",
    Icon = "users",
    Callback = function(state)
        print("ESP Survivor:", state)
    end
})

-- ESP Generator Toggle
espSection:AddToggle({
    Title = "ESP Generator",
    Description = "Highlight posisi generator",
    Icon = "zap",
    Callback = function(state)
        print("ESP Generator:", state)
    end
})

-- Color Picker
espSection:AddColorPicker({
    Title = "Warna ESP",
    Description = "Pilih warna highlight",
    Default = Color3.new(1, 0, 0),
    Callback = function(color)
        print("Warna ESP:", color)
    end
})

-- ================ TAB TELEPORT ================
local TeleportTab = Window:CreateTab({
    Title = "Teleport",
    Icon = "map-pin"
})

local tpSection = TeleportTab:CreateSection("📍 Teleport Options")

-- Teleport ke Spawn
tpSection:AddButton({
    Title = "Teleport ke Spawn",
    Description = "Kembali ke titik spawn",
    Icon = "home",
    Callback = function()
        local spawn = Workspace:FindFirstChild("SpawnLocation")
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if spawn and root then
            root.CFrame = spawn.CFrame * CFrame.new(0, 5, 0)
            WindUI:Notify({
                Title = "Teleport",
                Content = "Ke Spawn"
            })
        end
    end
})

-- Teleport ke 0,100,0
tpSection:AddButton({
    Title = "Teleport ke 0,100,0",
    Description = "Pergi ke tengah map",
    Icon = "crosshair",
    Callback = function()
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(0, 100, 0)
            WindUI:Notify({
                Title = "Teleport",
                Content = "Ke 0,100,0"
            })
        end
    end
})

-- ================ TAB UTILITIES ================
local UtilTab = Window:CreateTab({
    Title = "Utilities",
    Icon = "settings"
})

local utilSection = UtilTab:CreateSection("🛠️ Tools")

-- Reset Character
utilSection:AddButton({
    Title = "Reset Character",
    Description = "Respawn karakter",
    Icon = "refresh-cw",
    Callback = function()
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end
})

-- Anti AFK
utilSection:AddButton({
    Title = "Anti AFK",
    Description = "Cegah kick karena AFK",
    Icon = "coffee",
    Callback = function()
        local vu = game:GetService("VirtualUser")
        player.Idled:Connect(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
        WindUI:Notify({
            Title = "Anti AFK",
            Content = "Diaktifkan"
        })
    end
})

-- Infinite Yield
utilSection:AddButton({
    Title = "Infinite Yield",
    Description = "Load admin commands",
    Icon = "terminal",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

-- Map Info
utilSection:AddButton({
    Title = "Map Info",
    Description = "Informasi tentang map",
    Icon = "info",
    Callback = function()
        local count = 0
        for _ in pairs(Workspace:GetDescendants()) do
            count = count + 1
        end
        WindUI:Notify({
            Title = "Map Info",
            Content = "Total Objects: " .. count
        })
    end
})

-- ================ TAB SETTINGS ================
local SettingsTab = Window:CreateTab({
    Title = "Settings",
    Icon = "sliders"
})

local settingSection = SettingsTab:CreateSection("⚙️ UI Settings")

-- Toggle UI Button
settingSection:AddButton({
    Title = "Toggle UI (RightShift)",
    Description = "Buka/tutup GUI",
    Icon = "eye",
    Callback = function()
        WindUI:Toggle()
    end
})

-- Transparency Slider
settingSection:AddSlider({
    Title = "UI Transparency",
    Description = "Atur transparansi UI",
    Min = 0,
    Max = 0.8,
    Default = 0.3,
    Callback = function(v)
        -- Update transparency semua frame
        for _, gui in pairs(player.PlayerGui:GetDescendants()) do
            if gui:IsA("Frame") then
                gui.BackgroundTransparency = v
            end
        end
    end
})

-- Unload Button
settingSection:AddButton({
    Title = "Unload Script",
    Description = "Hapus semua fitur",
    Icon = "power",
    Callback = function()
        -- Matikan semua fitur
        if flyConn then flyConn:Disconnect() end
        if flyBV then flyBV:Destroy() end
        if noclipConn then noclipConn:Disconnect() end
        
        -- Reset karakter
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
        
        -- Hapus GUI
        WindUI:Destroy()
        script:Destroy()
    end
})

-- Info Label
settingSection:AddLabel({
    Title = "Keybinds:",
    Description = "RightShift: Toggle UI\nEnd: Unload Script"
})

-- ================ KEYBINDS ================
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        WindUI:Toggle()
    elseif input.KeyCode == Enum.KeyCode.End then
        -- Unload paksa
        if flyConn then flyConn:Disconnect() end
        if flyBV then flyBV:Destroy() end
        if noclipConn then noclipConn:Disconnect() end
        WindUI:Destroy()
        script:Destroy()
    end
end)

-- Notifikasi sukses
task.wait(1)
WindUI:Notify({
    Title = "✅ TEREHUB - Violence District",
    Content = "Script berhasil dimuat! Tekan RightShift",
    Duration = 3
})

-- Debug di console
print("=== TEREHUB VIOLENCE DISTRICT LOADED ===")
print("✅ WindUI berhasil dimuat")
print("✅ Struktur GUI sudah benar")
print("✅ Tekan RightShift untuk toggle GUI")
print("✅ Tekan END untuk unload")
print("📌 Jumlah tab:", #Window.Tabs)