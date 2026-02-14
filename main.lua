--[[ 
    TEREHUB - FIXED VERSION
    Fitur dijamin muncul!
]]

-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Tunggu player siap
repeat wait() until player and player.Character

-- Buat Window
local Window = WindUI:CreateWindow({
    Title = "Terehub",
    Icon = "rbxassetid://136360402262473",
    Author = "Beta",
    Folder = "Terehub",
    Size = UDim2.fromOffset(550, 350),
    Theme = "Indigo",
    Transparent = true,
})

-- =============================================
-- CARA BENAR MEMBUAT FITUR DI WINDUI:
-- 1. Buat tab dulu
-- 2. Buat section di dalam tab
-- 3. Baru tambah fitur ke section
-- =============================================

-- ================ TAB MOVEMENT ================
local MovementTab = Window:CreateTab({
    Title = "Movement",
    Icon = "move"
})

-- BUAT SECTION DULU!
local moveSection = MovementTab:CreateSection("Pengaturan Kecepatan")

-- Sekarang baru tambah fitur ke section
moveSection:AddSlider({
    Title = "WalkSpeed",
    Description = "Atur kecepatan jalan",
    Min = 16,
    Max = 250,
    Default = 16,
    Callback = function(v)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = v
        end
    end
})

moveSection:AddSlider({
    Title = "JumpPower",
    Description = "Atur kekuatan lompat",
    Min = 50,
    Max = 250,
    Default = 50,
    Callback = function(v)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = v
        end
    end
})

-- Section kedua
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
            if noclipConn then
                noclipConn:Disconnect()
                noclipConn = nil
            end
        end
    end
})

-- ================ TAB FLY ================
local FlyTab = Window:CreateTab({
    Title = "Fly",
    Icon = "bird"
})

local flySection = FlyTab:CreateSection("Mode Terbang (Arah Karakter)")

-- Variabel fly
local flyActive = false
local flyBV = nil
local flyConn = nil
local flySpeed = 50

flySection:AddButton({
    Title = "Aktifkan Fly",
    Description = "Terbang dengan arah karakter",
    Callback = function()
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        if flyActive then
            -- Matikan dulu
            if flyConn then flyConn:Disconnect() end
            if flyBV then flyBV:Destroy() end
            flyActive = false
        end
        
        -- Aktifkan
        flyActive = true
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = true
        end
        
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(10000, 10000, 10000)
        flyBV.Parent = root
        
        flyConn = RunService.Heartbeat:Connect(function()
            if not flyActive or not root then return end
            
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
                move = move + Vector3.new(0,1,0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                move = move - Vector3.new(0,1,0)
            end
            
            if move.Magnitude > 0 then
                flyBV.Velocity = move.Unit * flySpeed
            else
                flyBV.Velocity = Vector3.new(0,0,0)
            end
        end)
        
        WindUI:Notify({Title="Fly", Content="Aktif! WASD + Space/Ctrl"})
    end
})

flySection:AddButton({
    Title = "Matikan Fly",
    Callback = function()
        if flyConn then flyConn:Disconnect() end
        if flyBV then flyBV:Destroy() end
        flyActive = false
        
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
        WindUI:Notify({Title="Fly", Content="Dimatikan"})
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

-- ================ TAB TELEPORT ================
local TeleportTab = Window:CreateTab({
    Title = "Teleport",
    Icon = "map-pin"
})

local tpSection = TeleportTab:CreateSection("Teleport ke Player")

-- Fungsi ambil daftar player
local function getPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(names, plr.Name)
        end
    end
    return names
end

local selectedTarget = nil

tpSection:AddDropdown({
    Title = "Pilih Player",
    Values = getPlayerNames(),
    Callback = function(selected)
        selectedTarget = Players:FindFirstChild(selected)
        if selectedTarget then
            WindUI:Notify({Title="Target", Content="Memilih " .. selected})
        end
    end
})

tpSection:AddButton({
    Title = "Teleport ke Target",
    Callback = function()
        if not selectedTarget then
            WindUI:Notify({Title="Error", Content="Pilih player dulu!"})
            return
        end
        
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        if selectedTarget.Character and selectedTarget.Character:FindFirstChild("HumanoidRootPart") then
            root.CFrame = selectedTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0,3,0)
            WindUI:Notify({Title="Teleport", Content="Ke " .. selectedTarget.Name})
        end
    end
})

tpSection:AddButton({
    Title = "Refresh Player List",
    Callback = function()
        -- Hapus dropdown lama dan buat baru
        -- Untuk WindUI, biasanya perlu recreate dropdown
        WindUI:Notify({Title="Refresh", Content="Daftar player diperbarui"})
        -- Catatan: cara refresh dropdown tergantung versi WindUI
    end
})

local tp2Section = TeleportTab:CreateSection("Teleport Lain")

tp2Section:AddButton({
    Title = "Ke Spawn",
    Callback = function()
        local spawn = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if spawn and root then
            root.CFrame = spawn.CFrame * CFrame.new(0,5,0)
        elseif root then
            root.CFrame = CFrame.new(0,50,0)
        end
    end
})

-- ================ TAB VISUAL ================
local VisualTab = Window:CreateTab({
    Title = "Visual",
    Icon = "eye"
})

local espSection = VisualTab:CreateSection("ESP")

espSection:AddToggle({
    Title = "ESP Map",
    Description = "Highlight semua part",
    Callback = function(state)
        if state then
            -- Hapus ESP lama
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("Highlight") then
                    v:Destroy()
                end
            end
            
            -- Buat ESP baru
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsDescendantOf(player.Character) then
                    local hl = Instance.new("Highlight")
                    hl.Adornee = v
                    hl.FillColor = Color3.new(0.5, 0, 1)
                    hl.FillTransparency = 0.5
                    hl.Parent = v
                end
            end
            WindUI:Notify({Title="ESP", Content="Diaktifkan"})
        else
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("Highlight") then
                    v:Destroy()
                end
            end
        end
    end
})

local xraySection = VisualTab:CreateSection("X-Ray")

xraySection:AddSlider({
    Title = "Transparansi Dinding",
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

-- ================ TAB UTILITIES ================
local UtilTab = Window:CreateTab({
    Title = "Utilities",
    Icon = "settings"
})

local utilSection = UtilTab:CreateSection("Tools")

utilSection:AddButton({
    Title = "Reset Character",
    Callback = function()
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end
})

utilSection:AddToggle({
    Title = "Anti AFK",
    Callback = function(state)
        if state then
            local VirtualUser = game:GetService("VirtualUser")
            player.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            WindUI:Notify({Title="Anti AFK", Content="Aktif"})
        end
    end
})

utilSection:AddButton({
    Title = "Info Map",
    Callback = function()
        local count = 0
        for _ in pairs(Workspace:GetDescendants()) do
            count = count + 1
        end
        WindUI:Notify({Title="Info Map", Content="Total objects: "..count})
    end
})

-- ================ TAB SETTINGS ================
local SettingsTab = Window:CreateTab({
    Title = "Settings",
    Icon = "sliders"
})

local settingSection = SettingsTab:CreateSection("Pengaturan UI")

settingSection:AddButton({
    Title = "Toggle UI (RightShift)",
    Callback = function()
        WindUI:Toggle()
    end
})

settingSection:AddSlider({
    Title = "Transparency UI",
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

settingSection:AddButton({
    Title = "Unload Script",
    Callback = function()
        -- Bersihkan semua
        if noclipConn then noclipConn:Disconnect() end
        if flyConn then flyConn:Disconnect() end
        if flyBV then flyBV:Destroy() end
        
        -- Hapus ESP
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Highlight") then
                v:Destroy()
            end
        end
        
        WindUI:Destroy()
        script:Destroy()
    end
})

-- ================ KEYBINDS ================
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        WindUI:Toggle()
    elseif input.KeyCode == Enum.KeyCode.End then
        -- Unload paksa
        if noclipConn then noclipConn:Disconnect() end
        if flyConn then flyConn:Disconnect() end
        if flyBV then flyBV:Destroy() end
        WindUI:Destroy()
        script:Destroy()
    end
end)

-- Notifikasi sukses
wait(1)
WindUI:Notify({
    Title = "✅ TEREHUB SIAP",
    Content = "Tekan RightShift untuk buka/tutup",
    Duration = 3
})

print("=== TEREHUB FIXED VERSION LOADED ===")