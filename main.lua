local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
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

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- Tunggu player siap
repeat wait() until player and player.Character

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "Terehub",
    Icon = "rbxassetid://136360402262473",
    Author = "Beta",
    Folder = "Terehub",
    Size = UDim2.fromOffset(550, 400),
    Theme = "Indigo",
    Transparent = true,
})

-- [[ TABS ]] --
local MainTab = Window:CreateTab({ Title = "Movement", Icon = "walking" })
local WorldTab = Window:CreateTab({ Title = "World", Icon = "globe" })
local PlayerTab = Window:CreateTab({ Title = "Players", Icon = "users" })

-- ================ MOVEMENT TAB ================
local moveSection = MainTab:CreateSection("Pengaturan Gerak")

-- Speed Slider
moveSection:AddSlider({
    Title = "WalkSpeed",
    Min = 16,
    Max = 350,
    Default = 16,
    Callback = function(v)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = v
        end
    end
})

-- Jump Slider
moveSection:AddSlider({
    Title = "JumpPower",
    Min = 50,
    Max = 350,
    Default = 50,
    Callback = function(v)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = v
        end
    end
})

-- Reset Button
moveSection:AddButton({
    Title = "Reset Speed & Jump",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 16
            player.Character.Humanoid.JumpPower = 50
            WindUI:Notify({Title="Reset", Content="Speed & Jump kembali normal"})
        end
    end
})

-- ================ FLY SECTION (WASD ANALOG - ARAH KARAKTER) ================
local flySection = MainTab:CreateSection("Mode Terbang (WASD Analog)")

-- Variabel fly
local flyActive = false
local flySpeed = 50
local flyBV = nil
local flyConn = nil

-- Fungsi untuk mendapatkan root part
local function getRoot()
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

-- Toggle Fly
flySection:AddToggle({
    Title = "Aktifkan Fly (WASD)",
    Description = "Terbang dengan arah karakter, bukan kamera",
    Callback = function(state)
        local root = getRoot()
        if not root then 
            WindUI:Notify({Title="Error", Content="Tidak bisa terbang"})
            return 
        end
        
        if state then
            -- Matikan yang lama jika ada
            if flyConn then flyConn:Disconnect() end
            if flyBV then flyBV:Destroy() end
            
            flyActive = true
            
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
            
            -- Loop untuk mengontrol kecepatan berdasarkan input WASD
            flyConn = RunService.Heartbeat:Connect(function()
                if not flyActive or not root or not flyBV then return end
                
                -- Dapatkan arah berdasarkan karakter (bukan kamera)
                local moveDirection = Vector3.new()
                local lookVector = root.CFrame.LookVector  -- Arah hadap karakter
                local rightVector = root.CFrame.RightVector -- Arah kanan karakter
                
                -- Input WASD
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + lookVector  -- Maju sesuai arah hadap
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - lookVector  -- Mundur
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - rightVector  -- Ke kiri (strafe)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + rightVector  -- Ke kanan (strafe)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)  -- Naik
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)  -- Turun
                end
                
                -- Terapkan kecepatan
                if moveDirection.Magnitude > 0 then
                    flyBV.Velocity = moveDirection.Unit * flySpeed
                else
                    flyBV.Velocity = Vector3.new(0, 0, 0)
                end
            end)
            
            WindUI:Notify({
                Title = "Fly Mode", 
                Content = "Aktif! Gunakan WASD + Space/Ctrl\nTerbang berdasarkan arah karakter"
            })
        else
            -- Matikan fly
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
            
            WindUI:Notify({Title="Fly Mode", Content="Dimatikan"})
        end
    end
})

-- Slider kecepatan fly
flySection:AddSlider({
    Title = "Fly Speed",
    Min = 10,
    Max = 500,
    Default = 50,
    Callback = function(v)
        flySpeed = v
    end
})

-- Tombol matikan fly
flySection:AddButton({
    Title = "Matikan Fly",
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
        WindUI:Notify({Title="Fly Mode", Content="Dimatikan"})
    end
})

-- ================ WORLD TAB ================
local worldSection = WorldTab:CreateSection("Visual")

-- Fullbright
local fullBright = false
worldSection:AddToggle({
    Title = "Full Bright (No Dark)",
    Callback = function(state)
        fullBright = state
        if state then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.new(1, 1, 1)
            WindUI:Notify({Title="Full Bright", Content="Diaktifkan"})
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.new(0, 0, 0)
        end
    end
})

-- X-Ray
worldSection:AddSlider({
    Title = "X-Ray (Transparansi)",
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

local antiAFKSection = WorldTab:CreateSection("Anti AFK")

-- Anti AFK
worldSection:AddButton({
    Title = "Anti-AFK (Stay Active)",
    Callback = function()
        local vu = game:GetService("VirtualUser")
        player.Idled:Connect(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
            WindUI:Notify({Title = "Anti-AFK", Content = "Karakter tetap aktif!"})
        end)
        WindUI:Notify({Title="Anti-AFK", Content="Diaktifkan"})
    end
})

-- ================ PLAYERS TAB ================
local playerSection = PlayerTab:CreateSection("Teleport ke Player")

-- Variabel untuk menyimpan player terpilih
local selectedPlayer = ""

-- Fungsi untuk mendapatkan daftar player (selain diri sendiri)
local function getPlayerList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(list, p.Name)
        end
    end
    return list
end

-- Dropdown untuk memilih player (dengan options awal)
local playerDropdown = playerSection:AddDropdown({
    Title = "Pilih Player",
    Description = "Pilih target teleport",
    Values = getPlayerList(),  -- Langsung diisi saat pertama load
    Callback = function(value)
        selectedPlayer = value
        if value then
            WindUI:Notify({Title="Target", Content="Memilih: " .. value})
        end
    end
})

-- Tombol refresh daftar player
playerSection:AddButton({
    Title = "Refresh Player List",
    Description = "Perbarui daftar player",
    Callback = function()
        playerDropdown:SetValues(getPlayerList())
        WindUI:Notify({Title="Refresh", Content="Daftar player diperbarui"})
    end
})

-- Tombol teleport
playerSection:AddButton({
    Title = "Teleport to Player",
    Description = "Pindah ke player yang dipilih",
    Callback = function()
        if selectedPlayer == "" or not selectedPlayer then
            WindUI:Notify({Title = "Error", Content = "Pilih player dulu!"})
            return
        end
        
        local target = Players:FindFirstChild(selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local root = getRoot()
            if root then
                root.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                WindUI:Notify({Title = "Teleport", Content = "Ke " .. target.Name})
            end
        else
            WindUI:Notify({Title = "Error", Content = "Target tidak valid atau sedang respawn"})
        end
    end
})

-- Bring all players
playerSection:AddButton({
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

-- ================ ESP SECTION ================
local espSection = PlayerTab:CreateSection("ESP Player")

-- Variabel ESP
local espActive = false
local espConnections = {}

-- Fungsi untuk membersihkan ESP
local function clearESP()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Highlight") and v.Name == "TerehubESP" then
            v:Destroy()
        end
    end
end

-- Toggle ESP
espSection:AddToggle({
    Title = "ESP Player",
    Description = "Highlight semua player",
    Callback = function(state)
        espActive = state
        clearESP()
        
        if state then
            WindUI:Notify({Title="ESP", Content="Player ESP diaktifkan"})
        end
    end
})

-- Loop untuk ESP (berjalan terus)
RunService.RenderStepped:Connect(function()
    if espActive then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                -- Cek apakah sudah punya highlight
                local existing = p.Character:FindFirstChildOfClass("Highlight")
                if not existing then
                    local hl = Instance.new("Highlight")
                    hl.Name = "TerehubESP"
                    hl.FillColor = Color3.new(1, 0, 0) -- Merah untuk player
                    hl.OutlineColor = Color3.new(1, 1, 1)
                    hl.FillTransparency = 0.5
                    hl.Parent = p.Character
                end
            end
        end
    else
        -- Hapus ESP jika dimatikan
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                local hl = p.Character:FindFirstChildOfClass("Highlight")
                if hl and hl.Name == "TerehubESP" then
                    hl:Destroy()
                end
            end
        end
    end
end)

-- ================ SETTINGS TAB ================
local SettingsTab = Window:CreateTab({ Title = "Settings", Icon = "sliders" })
local settingSection = SettingsTab:CreateSection("Pengaturan UI")

-- Toggle UI
settingSection:AddButton({
    Title = "Toggle UI (RightShift)",
    Callback = function()
        WindUI:Toggle()
    end
})

-- Transparency
settingSection:AddSlider({
    Title = "UI Transparency",
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

-- Unload
settingSection:AddButton({
    Title = "Unload Script",
    Callback = function()
        -- Matikan fly
        flyActive = false
        if flyConn then flyConn:Disconnect() end
        if flyBV then flyBV:Destroy() end
        
        -- Reset karakter
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
        
        -- Hapus ESP
        clearESP()
        
        -- Reset lighting
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.new(0, 0, 0)
        
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
        if flyConn then flyConn:Disconnect() end
        if flyBV then flyBV:Destroy() end
        clearESP()
        WindUI:Destroy()
        script:Destroy()
    end
end)

-- Auto-refresh player list setiap 10 detik
task.spawn(function()
    while wait(10) do
        if playerDropdown then
            playerDropdown:SetValues(getPlayerList())
        end
    end
end)

-- Notifikasi sukses
wait(1)
WindUI:Notify({
    Title = "✅ TEREHUB SIAP",
    Content = "Tekan RightShift untuk buka/tutup\nFly menggunakan WASD (arah karakter)",
    Duration = 4
})

print("=== TEREHUB LOADED ===")
print("Fly menggunakan WASD berdasarkan arah karakter")
print("Dropdown player otomatis terisi")
print("Tekan RightShift untuk toggle UI")