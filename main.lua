--[[
    TEREHUB - Simple Version
    Fitur: Movement, Teleport Player, Fly (Arah Karakter)
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
    Title = "Terehub",
    Icon = "rbxassetid://136360402262473",
    Author = "Beta",
    Folder = "Terehub",
    Size = UDim2.fromOffset(500, 350),
    Theme = "Indigo",
    Transparent = true,
})

-- Variables Global
local selectedTarget = nil
local flyActive = false
local flyBV = nil
local flyConnection = nil
local flySpeed = 50

-- Fungsi Utility
local function getRoot()
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

-- ================ MOVEMENT TAB ================
local MovementTab = Window:CreateTab({
    Title = "Movement",
    Icon = "move"
})

-- WalkSpeed
MovementTab:CreateSection("Kecepatan")
local speedSlider = MovementTab:CreateSlider({
    Title = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(v)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = v
        end
    end
})

-- JumpPower
MovementTab:CreateSection("Lompat")
local jumpSlider = MovementTab:CreateSlider({
    Title = "JumpPower",
    Min = 50,
    Max = 200,
    Default = 50,
    Callback = function(v)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = v
        end
    end
})

-- NoClip
MovementTab:CreateSection("Tembus Tembok")
local noclipActive = false
local noclipConn = nil

MovementTab:CreateToggle({
    Title = "NoClip",
    Description = "Tembus tembok",
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
        else
            if noclipConn then
                noclipConn:Disconnect()
                noclipConn = nil
            end
        end
    end
})

-- ================ FLY TAB ================
local FlyTab = Window:CreateTab({
    Title = "Fly",
    Icon = "bird"
})

FlyTab:CreateSection("Mode Terbang")

-- Tombol Aktifkan Fly
FlyTab:CreateButton({
    Title = "Aktifkan Fly Mode",
    Description = "Terbang dengan arah karakter",
    Icon = "play",
    Callback = function()
        local root = getRoot()
        if not root then 
            WindUI:Notify({Title="Error", Content="Tidak bisa terbang"})
            return 
        end
        
        if flyActive then
            -- Matikan fly dulu
            if flyConnection then flyConnection:Disconnect() end
            if flyBV then flyBV:Destroy() end
            flyActive = false
        end
        
        -- Aktifkan fly
        flyActive = true
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = true
        end
        
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(10000, 10000, 10000)
        flyBV.Velocity = Vector3.new(0,0,0)
        flyBV.Parent = root
        
        flyConnection = RunService.Heartbeat:Connect(function()
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
        
        WindUI:Notify({Title="Fly Mode", Content="Aktif! WASD + Space/Ctrl"})
    end
})

-- Tombol Matikan Fly
FlyTab:CreateButton({
    Title = "Matikan Fly Mode",
    Description = "Kembali ke mode normal",
    Icon = "stop",
    Callback = function()
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        if flyBV then
            flyBV:Destroy()
            flyBV = nil
        end
        flyActive = false
        
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
        
        WindUI:Notify({Title="Fly Mode", Content="Dimatikan"})
    end
})

-- Kecepatan Fly
FlyTab:CreateSection("Pengaturan")
FlyTab:CreateSlider({
    Title = "Kecepatan Terbang",
    Min = 10,
    Max = 200,
    Default = 50,
    Callback = function(v)
        flySpeed = v
    end
})

-- ================ TELEPORT TAB ================
local TeleportTab = Window:CreateTab({
    Title = "Teleport",
    Icon = "map-pin"
})

-- Teleport ke Player
TeleportTab:CreateSection("Teleport ke Player")

-- Function update daftar player
local function getPlayerList()
    local list = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(list, plr.Name)
        end
    end
    return list
end

-- Dropdown player
local playerDropdown = TeleportTab:CreateDropdown({
    Title = "Pilih Player",
    Values = getPlayerList(),
    Callback = function(selected)
        selectedTarget = Players:FindFirstChild(selected)
        if selectedTarget then
            WindUI:Notify({Title="Target", Content="Memilih " .. selected})
        end
    end
})

-- Tombol teleport
TeleportTab:CreateButton({
    Title = "Teleport ke Target",
    Icon = "user",
    Callback = function()
        if not selectedTarget then
            WindUI:Notify({Title="Error", Content="Pilih player dulu!"})
            return
        end
        
        local root = getRoot()
        if not root then return end
        
        if selectedTarget.Character and selectedTarget.Character:FindFirstChild("HumanoidRootPart") then
            root.CFrame = selectedTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0,3,0)
            WindUI:Notify({Title="Teleport", Content="Ke " .. selectedTarget.Name})
        end
    end
})

-- Tombol refresh
TeleportTab:CreateButton({
    Title = "Refresh Player List",
    Icon = "refresh-cw",
    Callback = function()
        playerDropdown:SetValues(getPlayerList())
        WindUI:Notify({Title="Refresh", Content="Daftar player diperbarui"})
    end
})

-- Bring all
TeleportTab:CreateButton({
    Title = "Bring All Players",
    Description = "Tarik semua player ke sini",
    Icon = "users",
    Callback = function()
        local root = getRoot()
        if not root then return end
        
        local count = 0
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                plr.Character.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(0,3,0)
                count = count + 1
            end
        end
        
        WindUI:Notify({Title="Bring All", Content=count.." player ditarik"})
    end
})

-- Teleport ke Spawn
TeleportTab:CreateSection("Teleport Lain")
TeleportTab:CreateButton({
    Title = "Ke Spawn",
    Icon = "home",
    Callback = function()
        local spawn = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
        local root = getRoot()
        if spawn and root then
            root.CFrame = spawn.CFrame * CFrame.new(0,5,0)
        elseif root then
            root.CFrame = CFrame.new(0,50,0)
        end
    end
})

-- ================ VISUAL TAB ================
local VisualTab = Window:CreateTab({
    Title = "Visual",
    Icon = "eye"
})

-- ESP
VisualTab:CreateSection("ESP")
local espActive = false

VisualTab:CreateToggle({
    Title = "ESP Map",
    Description = "Highlight semua part",
    Icon = "highlighter",
    Callback = function(state)
        espActive = state
        if state then
            -- Hapus ESP lama
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("Highlight") and v.Name == "TerehubESP" then
                    v:Destroy()
                end
            end
            
            -- Buat ESP baru
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsDescendantOf(player.Character) then
                    local hl = Instance.new("Highlight")
                    hl.Name = "TerehubESP"
                    hl.Adornee = v
                    hl.FillColor = Color3.new(0.5, 0, 1)
                    hl.FillTransparency = 0.5
                    hl.Parent = v
                end
            end
        else
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("Highlight") and v.Name == "TerehubESP" then
                    v:Destroy()
                end
            end
        end
    end
})

-- XRay
VisualTab:CreateSection("X-Ray")
VisualTab:CreateSlider({
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

-- ================ UTILITIES TAB ================
local UtilityTab = Window:CreateTab({
    Title = "Utilities",
    Icon = "settings"
})

UtilityTab:CreateSection("Tools")

-- Reset Character
UtilityTab:CreateButton({
    Title = "Reset Character",
    Icon = "refresh-cw",
    Callback = function()
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end
})

-- Anti AFK
UtilityTab:CreateToggle({
    Title = "Anti AFK",
    Icon = "coffee",
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

-- Map Info
UtilityTab:CreateButton({
    Title = "Info Map",
    Icon = "info",
    Callback = function()
        local count = 0
        for _ in pairs(Workspace:GetDescendants()) do
            count = count + 1
        end
        WindUI:Notify({Title="Map Info", Content="Total objects: "..count})
    end
})

-- Load IY
UtilityTab:CreateButton({
    Title = "Load Infinite Yield",
    Icon = "terminal",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

-- ================ SETTINGS TAB ================
local SettingsTab = Window:CreateTab({
    Title = "Settings",
    Icon = "sliders"
})

SettingsTab:CreateSection("UI Control")

-- Toggle UI
SettingsTab:CreateButton({
    Title = "Toggle UI (RightShift)",
    Icon = "eye",
    Callback = function()
        WindUI:Toggle()
    end
})

-- Transparency
SettingsTab:CreateSlider({
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
SettingsTab:CreateButton({
    Title = "Unload Script",
    Icon = "power",
    Callback = function()
        -- Matikan semua
        if noclipConn then noclipConn:Disconnect() end
        if flyConnection then flyConnection:Disconnect() end
        if flyBV then flyBV:Destroy() end
        
        -- Hapus ESP
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Highlight") and v.Name == "TerehubESP" then
                v:Destroy()
            end
        end
        
        -- Reset gravity
        Workspace.Gravity = 196.2
        
        -- Hapus UI
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
        if flyConnection then flyConnection:Disconnect() end
        if flyBV then flyBV:Destroy() end
        WindUI:Destroy()
        script:Destroy()
    end
end)

-- Notifikasi sukses
wait(1)
WindUI:Notify({
    Title = "✅ Terehub Siap",
    Content = "Tekan RightShift untuk buka/tutup GUI",
    Duration = 3
})

print("=== TEREHUB LOADED ===")
print("Tekan RightShift untuk buka/tutup GUI")
print("Tekan END untuk unload")