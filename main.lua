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
    HideSearchBar = false,  -- Ubah ke false biar bisa search fitur
    ScrollBarEnabled = true,
})

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

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

--[[ TAB MOVEMENT ]]
local MovementTab = Window:CreateTab({
    Title = "Movement",
    Icon = "move"
})

-- Speed Control
local SpeedSection = MovementTab:CreateSection("Speed Control")
local speedSlider = MovementTab:CreateSlider({
    Title = "WalkSpeed",
    Description = "Atur kecepatan jalan",
    Min = 16,
    Max = 350,
    Default = 16,
    Unit = "studs/s",
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
    Description = "Atur kekuatan lompat",
    Min = 50,
    Max = 350,
    Default = 50,
    Unit = "power",
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
    Description = "Mengurangi gravitasi",
    Icon = "moon",
    Callback = function(value)
        if value then
            Workspace.Gravity = 50
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
                    humanoid:ChangeState("Jumping")
                end
            end)
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
        else
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            -- Reset collision
            local char = getCharacter()
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = true
                    end
                end
            end
        end
    end
})

-- Fly Mode
local flyToggle = MovementTab:CreateToggle({
    Title = "Fly Mode",
    Description = "Terbang bebas",
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
                
                local moveDirection = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end
                
                if moveDirection.Magnitude > 0 then
                    flyBodyVelocity.Velocity = moveDirection.Unit * flySpeed
                else
                    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end
            end)
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
    Description = "Kecepatan terbang",
    Min = 10,
    Max = 200,
    Default = 50,
    Unit = "studs/s",
    Callback = function(value)
        flySpeed = value
    end
})

--[[ TAB TELEPORT ]]
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
            WindUI:Notify({Title = "Teleported", Content = "Ke Spawn", Duration = 1})
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
        end
    end
})

-- Map Scanner
local ScanSection = TeleportTab:CreateSection("Map Scanner")

TeleportTab:CreateButton({
    Title = "Scan Map Parts",
    Description = "Cari semua part di map",
    Icon = "scan",
    Callback = function()
        local parts = {}
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" and not v:IsDescendantOf(player.Character) then
                if #parts < 100 then
                    table.insert(parts, v.Name .. " - " .. string.sub(v.ClassName, 1, 10))
                end
            end
        end
        
        local partDropdown = TeleportTab:CreateDropdown({
            Title = "Select Part",
            Description = "Pilih part untuk teleport",
            Values = parts,
            Callback = function(selected)
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") and (v.Name .. " - " .. string.sub(v.ClassName, 1, 10)) == selected then
                        selectedPart = v
                        break
                    end
                end
            end
        })
        
        WindUI:Notify({
            Title = "Scan Complete",
            Content = "Ditemukan " .. #parts .. " parts",
            Duration = 2
        })
    end
})

TeleportTab:CreateButton({
    Title = "Teleport ke Selected",
    Description = "Pindah ke part yang dipilih",
    Icon = "target",
    Callback = function()
        if selectedPart then
            local root = getRoot()
            if root and selectedPart then
                root.CFrame = CFrame.new(selectedPart.Position + Vector3.new(0, 5, 0))
                WindUI:Notify({
                    Title = "Teleported",
                    Content = "Ke: " .. selectedPart.Name,
                    Duration = 1
                })
            end
        else
            WindUI:Notify({
                Title = "Error",
                Content = "Pilih part dulu!",
                Duration = 2
            })
        end
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
                Content = "Posisi disimpan",
                Duration = 1
            })
        end
    end
})

TeleportTab:CreateButton({
    Title = "Load Waypoints",
    Description = "Teleport ke waypoint",
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

TeleportTab:CreateButton({
    Title = "Clear Waypoints",
    Description = "Hapus semua waypoint",
    Icon = "trash",
    Callback = function()
        waypoints = {}
        WindUI:Notify({
            Title = "Waypoints Cleared",
            Content = "Semua waypoint dihapus",
            Duration = 1
        })
    end
})

-- Player Teleport
local PlayerSection = TeleportTab:CreateSection("Player Teleport")

local playerList = {}
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= player then
        table.insert(playerList, plr.Name)
    end
end

local playerDropdown = TeleportTab:CreateDropdown({
    Title = "Select Player",
    Description = "Pilih player untuk teleport",
    Values = playerList,
    Callback = function(selected)
        local target = Players:FindFirstChild(selected)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local root = getRoot()
            if root then
                root.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                WindUI:Notify({
                    Title = "Teleported",
                    Content = "Ke " .. selected,
                    Duration = 1
                })
            end
        end
    end
})

-- Update player list periodically
spawn(function()
    while wait(10) do
        local newList = {}
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player then
                table.insert(newList, plr.Name)
            end
        end
        if playerDropdown then
            playerDropdown:SetValues(newList)
        end
    end
end)

--[[ TAB VISUAL/ESP ]]
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

local function createESP(part, color)
    if not part or not part:IsA("BasePart") then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "TerehubESP"
    highlight.Adornee = part
    highlight.FillColor = color or Color3.new(0.5, 0, 1) -- Ungu
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    highlight.Parent = part
    return highlight
end

-- ESP Toggle
local espToggle = VisualTab:CreateToggle({
    Title = "ESP Map Parts",
    Description = "Highlight semua part di map",
    Icon = "highlighter",
    Callback = function(value)
        clearESP()
        if value then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsDescendantOf(player.Character) then
                    createESP(v, Color3.new(0.5, 0, 1)) -- Ungu
                    local conn = v.ChildAdded:Connect(function(child)
                        if child:IsA("BasePart") and value then
                            createESP(child, Color3.new(0.5, 0, 1))
                        end
                    end)
                    table.insert(espConnections, conn)
                end
            end
        end
    end
})

-- Player ESP
local playerESP = VisualTab:CreateToggle({
    Title = "Player ESP",
    Description = "Lihat player lain",
    Icon = "users",
    Callback = function(value)
        if value then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    for _, v in pairs(plr.Character:GetDescendants()) do
                        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                            createESP(v, Color3.new(1, 0, 0)) -- Merah
                        end
                    end
                end
            end
        else
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("Highlight") and v.FillColor == Color3.new(1, 0, 0) then
                    v:Destroy()
                end
            end
        end
    end
})

-- X-Ray
local xraySlider = VisualTab:CreateSlider({
    Title = "X-Ray Intensity",
    Description = "Atur transparansi dinding",
    Min = 0,
    Max = 0.9,
    Default = 0,
    Unit = "%",
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
        else
            game:GetService("Lighting").Ambient = Color3.new(0, 0, 0)
            game:GetService("Lighting").Brightness = 1
        end
    end
})

--[[ TAB UTILITIES ]]
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

UtilityTab:CreateButton({
    Title = "God Mode (Server-Sided)",
    Description = "Mencoba membuat karakter kebal",
    Icon = "shield",
    Callback = function()
        local char = getCharacter()
        if char then
            local humanoid = getHumanoid()
            if humanoid then
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
            end
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanTouch = false
                end
            end
            WindUI:Notify({
                Title = "God Mode",
                Content = "Mode kebal diaktifkan (sementara)",
                Duration = 2
            })
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

-- F3X
UtilityTab:CreateButton({
    Title = "F3X Build Tools",
    Description = "Tools untuk building",
    Icon = "box",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/8bP0LrQs"))()
    end
})

--[[ TAB SETTINGS ]]
local SettingsTab = Window:CreateTab({
    Title = "Settings",
    Icon = "sliders"
})

-- UI Settings
local UISection = SettingsTab:CreateSection("UI Settings")

SettingsTab:CreateButton({
    Title = "Toggle UI",
    Description = "Sembunyikan/tampilkan GUI",
    Icon = "eye",
    Callback = function()
        WindUI:Toggle()
    end
})

-- Theme Selector
SettingsTab:CreateDropdown({
    Title = "Theme Color",
    Description = "Ganti tema warna",
    Values = {"Indigo", "Violet", "Midnight", "Rose", "Sky", "Emerald", "Monokai Pro"},
    Callback = function(selected)
        -- Ganti tema
        WindUI:Destroy()
        local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
        Window = WindUI:CreateWindow({
            Title = "Terehub",
            Icon = "rbxassetid://136360402262473",
            Author = "Beta Tester",
            Folder = "Terehub",
            Size = UDim2.fromOffset(600, 360),
            MinSize = Vector2.new(560, 250),
            MaxSize = Vector2.new(950, 760),
            Transparent = true,
            Theme = selected,
            Resizable = true,
            SideBarWidth = 190,
            BackgroundImageTransparency = 0.42,
            HideSearchBar = false,
            ScrollBarEnabled = true,
        })
        WindUI:Notify({
            Title = "Theme Changed",
            Content = "Sekarang menggunakan tema " .. selected,
            Duration = 2
        })
    end
})

-- Transparency
SettingsTab:CreateSlider({
    Title = "Background Transparency",
    Description = "Atur transparansi background",
    Min = 0,
    Max = 0.8,
    Default = 0.42,
    Unit = "%",
    Callback = function(value)
        WindUI.Theme:SetTransparency(value)
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
            Content = "RightShift: Toggle UI\nWASD: Fly mode\nSpace/LCtrl: Naik/Turun",
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
        -- Cleanup semua connection
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

--[[ AUTO EXECUTE ]]
player.CharacterAdded:Connect(function()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = speedSlider.Value or 16
        humanoid.JumpPower = jumpSlider.Value or 50
    end
end)

print("✅ Terehub Loaded - Theme: Indigo")
WindUI:Notify({
    Title = "Terehub Ready!",
    Content = "Semua fitur siap digunakan",
    Duration = 3
})