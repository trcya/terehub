local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Tunggu player siap
repeat wait() until player and player.Character and player.Character:FindFirstChild("Humanoid")

-- Variables
local noclipConnection = nil
local infiniteJumpConnection = nil
local flyConnection = nil
local espConnections = {}
local waypoints = {}
local selectedPart = nil
local flySpeed = 50
local flyBodyVelocity = nil
local isFlying = false
local selectedTarget = nil

-- Buat Window
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

-- Notifikasi Load
WindUI:Notify({
    Title = "Terehub Loaded",
    Content = "Welcome to Terehub! Press RightShift to toggle GUI",
    Duration = 3
})

--[[ FUNGSI UTILITY ]]
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getRoot()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

--[[ ================ MOVEMENT TAB ================ ]]
local MovementTab = Window:CreateTab({
    Title = "Movement",
    Icon = "move"
})

-- Speed Control
local SpeedSection = MovementTab:CreateSection("Speed Control")

local speedSlider = MovementTab:CreateSlider({
    Title = "WalkSpeed",
    Description = "Atur kecepatan jalan (16-350)",
    Min = 16,
    Max = 350,
    Default = 16,
    Callback = function(value)
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
})

-- Jump Control
local jumpSlider = MovementTab:CreateSlider({
    Title = "Jump Power",
    Description = "Atur kekuatan lompat (50-350)",
    Min = 50,
    Max = 350,
    Default = 50,
    Callback = function(value)
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.JumpPower = value
        end
    end
})

-- Gravity Control
local gravityToggle = MovementTab:CreateToggle({
    Title = "Low Gravity",
    Description = "Mengurangi gravitasi menjadi 50",
    Icon = "moon",
    Callback = function(value)
        if value then
            Workspace.Gravity = 50
            WindUI:Notify({
                Title = "Low Gravity",
                Content = "Gravitasi dikurangi menjadi 50",
                Duration = 1
            })
        else
            Workspace.Gravity = 196.2
        end
    end
})

-- Infinite Jump
local infiniteJumpToggle = MovementTab:CreateToggle({
    Title = "Infinite Jump",
    Description = "Lompat berkali-kali di udara",
    Icon = "repeat",
    Callback = function(value)
        if value then
            if infiniteJumpConnection then
                infiniteJumpConnection:Disconnect()
            end
            infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                local humanoid = getHumanoid()
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
            WindUI:Notify({
                Title = "Infinite Jump",
                Content = "Aktif - Lompat terus di udara",
                Duration = 1
            })
        else
            if infiniteJumpConnection then
                infiniteJumpConnection:Disconnect()
                infiniteJumpConnection = nil
            end
        end
    end
})

-- NoClip
local noclipToggle = MovementTab:CreateToggle({
    Title = "NoClip",
    Description = "Tembus tembok",
    Icon = "slash",
    Callback = function(value)
        if value then
            if noclipConnection then
                noclipConnection:Disconnect()
            end
            noclipConnection = RunService.Stepped:Connect(function()
                local char = getCharacter()
                if char then
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end)
            WindUI:Notify({
                Title = "NoClip",
                Content = "Aktif - Bisa tembus tembok",
                Duration = 1
            })
        else
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
        end
    end
})

--[[ FLY MODE BARU - Menggunakan arah karakter (HumanoidRootPart) ]]
local flyToggle = MovementTab:CreateToggle({
    Title = "Fly Mode",
    Description = "Terbang berdasarkan arah karakter (WASD = maju sesuai arah hadap)",
    Icon = "bird",
    Callback = function(value)
        isFlying = value
        local root = getRoot()
        local humanoid = getHumanoid()
        
        if value and root and humanoid then
            humanoid.PlatformStand = true
            flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
            flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            flyBodyVelocity.Parent = root
            
            flyConnection = RunService.Heartbeat:Connect(function()
                if not isFlying or not root or not flyBodyVelocity then
                    return
                end
                
                -- Dapatkan arah karakter dari HumanoidRootPart
                local lookVector = root.CFrame.LookVector  -- Arah hadap karakter
                local rightVector = root.CFrame.RightVector -- Arah kanan karakter
                local upVector = Vector3.new(0, 1, 0) -- Arah atas global
                
                local moveDirection = Vector3.new()
                
                -- WASD berdasarkan arah karakter (bukan camera)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + lookVector -- Maju sesuai arah hadap
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - lookVector -- Mundur
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - rightVector -- Ke kiri (strafe)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + rightVector -- Ke kanan (strafe)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + upVector -- Naik
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    moveDirection = moveDirection - upVector -- Turun
                end
                
                -- Normalisasi dan aplikasikan kecepatan
                if moveDirection.Magnitude > 0 then
                    flyBodyVelocity.Velocity = moveDirection.Unit * flySpeed
                else
                    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end
            end)
            
            WindUI:Notify({
                Title = "Fly Mode",
                Content = "Aktif - Gunakan WASD (berdasarkan arah karakter)\nSpace/LCtrl untuk naik/turun",
                Duration = 3
            })
        else
            if flyConnection then
                flyConnection:Disconnect()
                flyConnection = nil
            end
            if flyBodyVelocity then
                flyBodyVelocity:Destroy()
                flyBodyVelocity = nil
            end
            if humanoid then
                humanoid.PlatformStand = false
            end
        end
    end
})

-- Fly Speed Slider
local flySpeedSlider = MovementTab:CreateSlider({
    Title = "Fly Speed",
    Description = "Kecepatan terbang (10-200)",
    Min = 10,
    Max = 200,
    Default = 50,
    Callback = function(value)
        flySpeed = value
    end
})

--[[ ================ TELEPORT TAB ================ ]]
local TeleportTab = Window:CreateTab({
    Title = "Teleport",
    Icon = "map-pin"
})

-- Quick Teleports
local QuickSection = TeleportTab:CreateSection("Quick Teleport")

TeleportTab:CreateButton({
    Title = "Teleport ke Spawn",
    Description = "Kembali ke spawn point",
    Icon = "home",
    Callback = function()
        local spawn = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
        local root = getRoot()
        if spawn and root then
            root.CFrame = spawn.CFrame * CFrame.new(0, 5, 0)
            WindUI:Notify({
                Title = "Teleported",
                Content = "Ke Spawn",
                Duration = 1
            })
        elseif root then
            root.CFrame = CFrame.new(0, 50, 0)
        end
    end
})

TeleportTab:CreateButton({
    Title = "Teleport ke 0,100,0",
    Description = "Pergi ke tengah map",
    Icon = "crosshair",
    Callback = function()
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(0, 100, 0)
            WindUI:Notify({
                Title = "Teleported",
                Content = "Ke 0,100,0",
                Duration = 1
            })
        end
    end
})

--[[ TELEPORT KE PLAYER - BARU ]]
local PlayerSection = TeleportTab:CreateSection("Teleport ke Player")

-- Function untuk update daftar player
local function updatePlayerList()
    local playerList = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(playerList, plr.Name)
        end
    end
    return playerList
end

-- Dropdown player
local playerDropdown = TeleportTab:CreateDropdown({
    Title = "Pilih Player",
    Description = "Pilih target player",
    Values = updatePlayerList(),
    Callback = function(selected)
        selectedTarget = Players:FindFirstChild(selected)
        if selectedTarget then
            WindUI:Notify({
                Title = "Target Dipilih",
                Content = "Target: " .. selected,
                Duration = 1
            })
        end
    end
})

-- Tombol Teleport ke Player
TeleportTab:CreateButton({
    Title = "Teleport ke Target",
    Description = "Pindah ke player yang dipilih",
    Icon = "user",
    Callback = function()
        if not selectedTarget then
            WindUI:Notify({
                Title = "Error",
                Content = "Pilih target player dulu!",
                Duration = 2
            })
            return
        end
        
        if selectedTarget.Character and selectedTarget.Character:FindFirstChild("HumanoidRootPart") then
            local root = getRoot()
            if root then
                root.CFrame = selectedTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                WindUI:Notify({
                    Title = "Teleported",
                    Content = "Ke " .. selectedTarget.Name,
                    Duration = 1
                })
            end
        else
            WindUI:Notify({
                Title = "Error",
                Content = "Target tidak memiliki karakter atau sedang respawn",
                Duration = 2
            })
        end
    end
})

-- Tombol Refresh Player List
TeleportTab:CreateButton({
    Title = "Refresh Player List",
    Description = "Perbarui daftar player",
    Icon = "refresh-cw",
    Callback = function()
        playerDropdown:SetValues(updatePlayerList())
        WindUI:Notify({
            Title = "Player List",
            Content = "Daftar player diperbarui",
            Duration = 1
        })
    end
})

-- Teleport Semua Player ke Saya
TeleportTab:CreateButton({
    Title = "Bring All Players",
    Description = "Tarik semua player ke posisi Anda",
    Icon = "users",
    Callback = function()
        local root = getRoot()
        if not root then return end
        
        local count = 0
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                plr.Character.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(0, 3, 0)
                count = count + 1
            end
        end
        
        WindUI:Notify({
            Title = "Bring All",
            Content = count .. " player ditarik ke posisi Anda",
            Duration = 2
        })
    end
})

-- Waypoints
local WaypointSection = TeleportTab:CreateSection("Waypoints")

TeleportTab:CreateButton({
    Title = "Save Waypoint",
    Description = "Simpan posisi sekarang",
    Icon = "bookmark",
    Callback = function()
        local root = getRoot()
        if root then
            table.insert(waypoints, {
                name = "Waypoint " .. #waypoints + 1,
                cframe = root.CFrame
            })
            WindUI:Notify({
                Title = "Waypoint Saved",
                Content = "Posisi disimpan sebagai Waypoint " .. #waypoints,
                Duration = 1
            })
        end
    end
})

TeleportTab:CreateButton({
    Title = "Load Waypoint",
    Description = "Pilih waypoint untuk teleport",
    Icon = "book-open",
    Callback = function()
        if #waypoints == 0 then
            WindUI:Notify({
                Title = "No Waypoints",
                Content = "Save waypoint dulu!",
                Duration = 2
            })
            return
        end
        
        local wpValues = {}
        for _, wp in pairs(waypoints) do
            table.insert(wpValues, wp.name)
        end
        
        local wpDropdown = TeleportTab:CreateDropdown({
            Title = "Select Waypoint",
            Values = wpValues,
            Callback = function(selected)
                for _, wp in pairs(waypoints) do
                    if wp.name == selected then
                        local root = getRoot()
                        if root then
                            root.CFrame = wp.cframe
                            WindUI:Notify({
                                Title = "Teleported",
                                Content = "Ke " .. selected,
                                Duration = 1
                            })
                        end
                        break
                    end
                end
            end
        })
    end
})

--[[ ================ VISUAL TAB ================ ]]
local VisualTab = Window:CreateTab({
    Title = "Visual",
    Icon = "eye"
})

-- ESP Functions
local function clearESP()
    for _, conn in pairs(espConnections) do
        conn:Disconnect()
    end
    espConnections = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Highlight") and v.Name == "TerehubESP" then
            v:Destroy()
        end
    end
end

-- ESP Toggle
local espToggle = VisualTab:CreateToggle({
    Title = "ESP Map Parts",
    Description = "Highlight semua part di map",
    Icon = "highlighter",
    Callback = function(value)
        clearESP()
        if value then
            local count = 0
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsDescendantOf(player.Character) then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "TerehubESP"
                    highlight.Adornee = v
                    highlight.FillColor = Color3.new(0.5, 0, 1)
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.FillTransparency = 0.5
                    highlight.Parent = v
                    count = count + 1
                end
            end
            WindUI:Notify({
                Title = "ESP Active",
                Content = count .. " parts di-highlight",
                Duration = 2
            })
        end
    end
})

-- X-Ray
local xraySlider = VisualTab:CreateSlider({
    Title = "X-Ray",
    Description = "Atur transparansi dinding",
    Min = 0,
    Max = 0.9,
    Default = 0,
    Callback = function(value)
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(player.Character) then
                v.Transparency = value
            end
        end
    end
})

-- Fullbright
local fullbrightToggle = VisualTab:CreateToggle({
    Title = "Fullbright",
    Description = "Terang seperti siang",
    Icon = "sun",
    Callback = function(value)
        if value then
            game:GetService("Lighting").Ambient = Color3.new(1, 1, 1)
            game:GetService("Lighting").Brightness = 2
            WindUI:Notify({
                Title = "Fullbright",
                Content = "Pencahayaan maksimal",
                Duration = 1
            })
        else
            game:GetService("Lighting").Ambient = Color3.new(0, 0, 0)
            game:GetService("Lighting").Brightness = 1
        end
    end
})

--[[ ================ UTILITIES TAB ================ ]]
local UtilityTab = Window:CreateTab({
    Title = "Utilities",
    Icon = "settings"
})

-- Character Tools
local CharSection = UtilityTab:CreateSection("Character")

UtilityTab:CreateButton({
    Title = "Reset Character",
    Description = "Respawn karakter",
    Icon = "refresh-cw",
    Callback = function()
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.Health = 0
        end
    end
})

-- Anti AFK
local antiAfkToggle = UtilityTab:CreateToggle({
    Title = "Anti AFK",
    Description = "Cegah kick karena AFK",
    Icon = "coffee",
    Callback = function(value)
        if value then
            player.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            WindUI:Notify({
                Title = "Anti AFK",
                Content = "Aktif - Tidak akan di-kick",
                Duration = 2
            })
        end
    end
})

-- Map Info
UtilityTab:CreateButton({
    Title = "Map Information",
    Description = "Info lengkap tentang map",
    Icon = "info",
    Callback = function()
        local partCount = 0
        local meshCount = 0
        local unionCount = 0
        local modelCount = 0
        
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then partCount = partCount + 1 end
            if v:IsA("MeshPart") then meshCount = meshCount + 1 end
            if v:IsA("UnionOperation") then unionCount = unionCount + 1 end
            if v:IsA("Model") and v ~= player.Character then modelCount = modelCount + 1 end
        end
        
        WindUI:Notify({
            Title = "📊 Map Statistics",
            Content = string.format("Parts: %d | Meshes: %d\nUnions: %d | Models: %d", 
                partCount, meshCount, unionCount, modelCount),
            Duration = 5
        })
    end
})

-- Infinite Yield
UtilityTab:CreateButton({
    Title = "Load Infinite Yield",
    Description = "Admin tools lengkap",
    Icon = "terminal",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

--[[ ================ SETTINGS TAB ================ ]]
local SettingsTab = Window:CreateTab({
    Title = "Settings",
    Icon = "sliders"
})

-- UI Settings
local UISection = SettingsTab:CreateSection("UI Settings")

SettingsTab:CreateButton({
    Title = "Toggle UI",
    Description = "Sembunyikan/tampilkan GUI (RightShift)",
    Icon = "eye",
    Callback = function()
        WindUI:Toggle()
    end
})

-- Transparency
SettingsTab:CreateSlider({
    Title = "Transparency",
    Description = "Atur transparansi UI",
    Min = 0,
    Max = 0.8,
    Default = 0.42,
    Callback = function(value)
        for _, v in pairs(player.PlayerGui:GetDescendants()) do
            if v:IsA("Frame") and v.Name ~= "TopBar" then
                v.BackgroundTransparency = value
            end
        end
    end
})

-- Keybinds Info
SettingsTab:CreateButton({
    Title = "Keybinds",
    Description = "Lihat daftar shortcut",
    Icon = "keyboard",
    Callback = function()
        WindUI:Notify({
            Title = "⌨️ Keybinds",
            Content = "RightShift: Toggle UI\nWASD + Space/Ctrl: Fly mode (arah karakter)\nEnd: Close GUI",
            Duration = 4
        })
    end
})

-- Unload
SettingsTab:CreateButton({
    Title = "Unload Terehub",
    Description = "Tutup semua fitur",
    Icon = "power",
    Callback = function()
        if noclipConnection then noclipConnection:Disconnect() end
        if infiniteJumpConnection then infiniteJumpConnection:Disconnect() end
        if flyConnection then flyConnection:Disconnect() end
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        clearESP()
        Workspace.Gravity = 196.2
        WindUI:Destroy()
        script:Destroy()
    end
})

--[[ KEYBINDS ]]
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightShift then
        WindUI:Toggle()
    elseif input.KeyCode == Enum.KeyCode.End then
        if noclipConnection then noclipConnection:Disconnect() end
        if infiniteJumpConnection then infiniteJumpConnection:Disconnect() end
        if flyConnection then flyConnection:Disconnect() end
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        clearESP()
        Workspace.Gravity = 196.2
        WindUI:Destroy()
        script:Destroy()
    end
end)

-- Auto refresh player list setiap 10 detik
spawn(function()
    while wait(10) do
        if playerDropdown then
            playerDropdown:SetValues(updatePlayerList())
        end
    end
end)

-- Set speed/jump on respawn
player.CharacterAdded:Connect(function(char)
    repeat wait() until char:FindFirstChild("Humanoid")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = speedSlider.Value or 16
        humanoid.JumpPower = jumpSlider.Value or 50
    end
end)

print("✅ Terehub Loaded - Theme: Indigo")
print("📌 Fitur Fly menggunakan arah karakter (bukan camera)")
print("📌 Teleport ke Player tersedia")
print("📌 Press RightShift to toggle GUI")