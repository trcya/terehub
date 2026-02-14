--[[
    Map Testing Script with WindUI
    Untuk Delta Executor & Executor Lainnya
    Fitur: Teleport, Speed, Jump, ESP, NoClip, Infinite Yield Tools
]]

-- Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/main_example.lua"))()

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

-- Variables
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local noclipConnection = nil
local infiniteJumpConnection = nil
local speedConnection = nil
local espConnections = {}
local selectedPart = nil

-- Player check
if not player then
    return
end

-- Main Window
local Window = WindUI:CreateWindow({
    Title = "Map Tester",
    Icon = "map-pin",
    Author = "Tester",
    Folder = "MapTester",
    Size = UDim2.fromOffset(600, 500)
})

-- Notifikasi Load
WindUI:Notify({
    Title = "Map Tester Loaded",
    Content = "Tekan RightShift untuk buka/tutup GUI",
    Duration = 3
})

--[[ FUNGSI UTAMA ]]

-- Get Character
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

-- Get HumanoidRootPart
local function getRoot()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Get Humanoid
local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

--[[ TAB UTAMA - MOVEMENT ]]
local MovementTab = Window:CreateTab({
    Title = "Movement",
    Icon = "move"
})

-- Speed Slider
local SpeedSection = MovementTab:CreateSection("Movement Settings")

local speedSlider = MovementTab:CreateSlider({
    Title = "WalkSpeed",
    Description = "Atur kecepatan jalan",
    Icon = "footprints",
    Min = 16,
    Max = 250,
    Default = 16,
    ValueName = "Speed",
    Callback = function(value)
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
})

local jumpSlider = MovementTab:CreateSlider({
    Title = "JumpPower",
    Description = "Atur kekuatan lompat",
    Icon = "chevrons-up",
    Min = 50,
    Max = 350,
    Default = 50,
    ValueName = "Power",
    Callback = function(value)
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.JumpPower = value
        end
    end
})

-- Gravity Toggle
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
    Description = "Tembus tembok (pake shift lock)",
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

--[[ TAB TELEPORT ]]
local TeleportTab = Window:CreateTab({
    Title = "Teleport",
    Icon = "map"
})

-- Scan Map Section
local ScanSection = TeleportTab:CreateSection("Map Scanner")

-- Scan Button
TeleportTab:CreateButton({
    Title = "Scan Map Parts",
    Description = "Cari semua part di map",
    Icon = "scan",
    Callback = function()
        local parts = {}
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" and v.Name ~= "Handle" then
                if #parts < 50 then -- Limit to 50 parts
                    table.insert(parts, v.Name .. " - " .. string.sub(v.ClassName, 1, 10))
                end
            end
        end
        
        -- Buat dropdown dinamis
        local partDropdown = TeleportTab:CreateDropdown({
            Title = "Select Part",
            Description = "Pilih part untuk teleport",
            Icon = "list",
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

-- Teleport to Selected
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
                    Duration = 1.5
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

-- Teleport to Spawn
TeleportTab:CreateButton({
    Title = "Teleport ke Spawn",
    Description = "Kembali ke spawn point",
    Icon = "home",
    Callback = function()
        local spawns = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
        if spawns then
            local root = getRoot()
            if root then
                root.CFrame = spawns.CFrame * CFrame.new(0, 5, 0)
            end
        else
            -- Fallback ke posisi 0
            local root = getRoot()
            if root then
                root.CFrame = CFrame.new(0, 50, 0)
            end
        end
    end
})

-- Waypoints
local waypoints = {}
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
                Title = "Saved",
                Content = "Posisi disimpan",
                Duration = 1
            })
        end
    end
})

-- Load Waypoints (Dynamic)
TeleportTab:CreateButton({
    Title = "Load Waypoints",
    Description = "Teleport ke waypoint tersimpan",
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
                        end
                        break
                    end
                end
            end
        })
    end
})

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
    -- Hapus existing highlights
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Highlight") and v.Name == "MapESP" then
            v:Destroy()
        end
    end
end

local function createESP(part)
    if not part or not part:IsA("BasePart") then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "MapESP"
    highlight.Adornee = part
    highlight.FillColor = Color3.new(0, 1, 0)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    highlight.Parent = part
end

-- ESP Toggle
local espToggle = VisualTab:CreateToggle({
    Title = "ESP Parts",
    Description = "Highlight semua part di map",
    Icon = "highlighter",
    Callback = function(value)
        clearESP()
        if value then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsDescendantOf(player.Character) then
                    createESP(v)
                    -- Tambah connection untuk part baru
                    local conn = v.ChildAdded:Connect(function(child)
                        if child:IsA("BasePart") and value then
                            createESP(child)
                        end
                    end)
                    table.insert(espConnections, conn)
                end
            end
        end
    end
})

-- X-Ray (Transparansi)
local xraySlider = VisualTab:CreateSlider({
    Title = "X-Ray Intensity",
    Description = "Atur transparansi dinding",
    Icon = "eye-off",
    Min = 0,
    Max = 0.9,
    Default = 0,
    ValueName = "Transparansi",
    Callback = function(value)
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(player.Character) then
                if value > 0 then
                    v.Transparency = value
                else
                    v.Transparency = 0
                end
            end
        end
    end
})

--[[ TAB UTILITIES ]]
local UtilityTab = Window:CreateTab({
    Title = "Utilities",
    Icon = "settings"
})

-- Infinite Yield Tools (Basic)
UtilityTab:CreateButton({
    Title = "Infinite Yield (F3X)",
    Description = "Load Infinite Yield tools",
    Icon = "terminal",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

-- F3X (Build Tools)
UtilityTab:CreateButton({
    Title = "F3X Build Tools",
    Description = "Tools untuk build/mengedit",
    Icon = "box",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/8bP0LrQs"))()
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
                Title = "Anti AFK Active",
                Content = "Kamu tidak akan di-kick karena AFK",
                Duration = 2
            })
        end
    end
})

-- Reset Character
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

-- Get Map Info
UtilityTab:CreateButton({
    Title = "Map Information",
    Description = "Info tentang map",
    Icon = "info",
    Callback = function()
        local partCount = 0
        local meshCount = 0
        local unionCount = 0
        
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then partCount = partCount + 1 end
            if v:IsA("MeshPart") then meshCount = meshCount + 1 end
            if v:IsA("UnionOperation") then unionCount = unionCount + 1 end
        end
        
        WindUI:Notify({
            Title = "Map Info",
            Content = string.format("Parts: %d | Meshes: %d | Unions: %d", partCount, meshCount, unionCount),
            Duration = 5
        })
    end
})

--[[ TAB ADMIN ]]
local AdminTab = Window:CreateTab({
    Title = "Admin",
    Icon = "shield"
})

-- Admin Commands
AdminTab:CreateButton({
    Title = "CMD-X (Admin)",
    Description = "Load CMD-X admin panel",
    Icon = "command",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source"))()
    end
})

AdminTab:CreateButton({
    Title = "Nameless Admin",
    Description = "Load Nameless admin",
    Icon = "users",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/FilteringEnabled/NamelessAdmin/main/Source"))()
    end
})

--[[ SETTINGS TAB ]]
local SettingsTab = Window:CreateTab({
    Title = "Settings",
    Icon = "sliders"
})

-- UI Settings
SettingsTab:CreateButton({
    Title = "Toggle UI",
    Description = "Sembunyikan/tampilkan UI",
    Icon = "eye",
    Callback = function()
        WindUI:Toggle()
    end
})

-- Keybind Info
SettingsTab:CreateButton({
    Title = "Keybinds",
    Description = "RightShift = Buka/Tutup UI",
    Icon = "keyboard",
    Callback = function()
        WindUI:Notify({
            Title = "Keybinds",
            Content = "RightShift: Toggle UI\nEnd: Close GUI",
            Duration = 3
        })
    end
})

-- Unload Script
SettingsTab:CreateButton({
    Title = "Unload Script",
    Description = "Hapus semua fitur",
    Icon = "power",
    Callback = function()
        -- Cleanup
        if noclipConnection then
            noclipConnection:Disconnect()
        end
        if infiniteJumpConnection then
            infiniteJumpConnection:Disconnect()
        end
        clearESP()
        Workspace.Gravity = 196.2
        WindUI:Destroy()
        script:Destroy()
    end
})

--[[ AUTO EXECUTE ]]
-- Reset speed/jump on respawn
player.CharacterAdded:Connect(function()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = speedSlider.Value or 16
        humanoid.JumpPower = jumpSlider.Value or 50
    end
end)

print("✅ Map Tester Script Loaded - Tekan RightShift untuk buka GUI")