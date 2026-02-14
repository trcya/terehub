--[[
    TEREHUB - VIOLENCE DISTRICT SCRIPT
    Game: Violence District (Asymmetrical Horror)
    Fitur: Auto Generator, Auto Aim (Killer), ESP, Teleport, NoClip, dll
    Update: 2026
]]

-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Tunggu player siap
repeat wait() until player and player.Character

-- Buat Window
local Window = WindUI:CreateWindow({
    Title = "Terehub - Violence District",
    Icon = "rbxassetid://136360402262473",
    SubTitle = "Auto Generator + Auto Aim",
    Author = "Beta",
    Folder = "TerehubVD",
    Size = UDim2.fromOffset(700, 550),
    Theme = "Violet",
    Transparent = true,
})

-- Variabel Global
local autoGenActive = false
local autoAimActive = false
local espActive = false
local noclipActive = false
local genConnection = nil
local aimConnection = nil
local noclipConnection = nil
local targetKiller = nil
local generators = {}
local killers = {}
local survivors = {}
local aimFov = 120
local aimSmoothness = 5
local isSurvivor = true -- Akan dideteksi otomatis

-- ================ FUNGSI DETEKSI ROLE ================
local function detectRole()
    -- Coba deteksi apakah player sebagai survivor atau killer
    -- Berdasarkan deskripsi game: 5 survivors vs 1 killer [citation:4]
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") then
            local humanoid = v:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if v == player.Character then
                    -- Player sendiri
                elseif not Players:GetPlayerFromCharacter(v) then
                    -- Ini kemungkinan killer (NPC)
                    if #killers == 0 then
                        isSurvivor = true
                        return "Survivor"
                    end
                end
            end
        end
    end
    
    -- Fallback
    return "Survivor (default)"
end

-- ================ FUNGSI DETEKSI GENERATOR ================
local function scanGenerators()
    local newGens = {}
    
    -- Cari objek yang mirip generator [citation:5]
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") then
            local name = v.Name:lower()
            -- Keyword umum untuk generator
            if name:find("generator") or name:find("gen") or 
               name:find("repair") or name:find("fix") or
               name:find("power") or name:find("box") or
               v:FindFirstChild("ProximityPrompt") or
               v:FindFirstChild("ClickDetector") then
                
                local rootPart = v
                if v:IsA("Model") then
                    rootPart = v:FindFirstChild("Part") or v:FindFirstChild("Handle") or v.PrimaryPart
                end
                
                if rootPart then
                    table.insert(newGens, {
                        name = v.Name,
                        part = rootPart,
                        position = rootPart.Position,
                        model = v
                    })
                end
            end
        end
    end
    
    generators = newGens
    return newGens
end

-- ================ FUNGSI DETEKSI KILLER ================
local function scanKillers()
    local newKillers = {}
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") then
            local humanoid = v:FindFirstChildOfClass("Humanoid")
            local root = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Torso") or v.PrimaryPart
            
            if humanoid and humanoid.Health > 0 and root then
                -- Cek apakah ini killer (bukan player)
                if not Players:GetPlayerFromCharacter(v) then
                    local name = v.Name:lower()
                    -- Keyword umum killer
                    if name:find("killer") or name:find("hunter") or 
                       name:find("monster") or name:find("zombie") or
                       name:find("enemy") or name:find("boss") or
                       v:FindFirstChild("Killer") then
                        
                        local distance = player.Character and 
                                        player.Character:FindFirstChild("HumanoidRootPart") and
                                        (root.Position - player.Character.HumanoidRootPart.Position).Magnitude or 9999
                        
                        table.insert(newKillers, {
                            name = v.Name,
                            character = v,
                            root = root,
                            humanoid = humanoid,
                            health = humanoid.Health,
                            maxHealth = humanoid.MaxHealth,
                            distance = distance,
                            position = root.Position
                        })
                    end
                end
            end
        end
    end
    
    killers = newKillers
    return newKillers
end

-- ================ FUNGSI DETEKSI SURVIVOR ================
local function scanSurvivors()
    local newSurvivors = {}
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and root then
                local distance = player.Character and 
                                player.Character:FindFirstChild("HumanoidRootPart") and
                                (root.Position - player.Character.HumanoidRootPart.Position).Magnitude or 9999
                
                table.insert(newSurvivors, {
                    name = plr.Name,
                    character = plr.Character,
                    root = root,
                    humanoid = humanoid,
                    health = humanoid.Health,
                    maxHealth = humanoid.MaxHealth,
                    distance = distance,
                    position = root.Position
                })
            end
        end
    end
    
    survivors = newSurvivors
    return newSurvivors
end

-- ================ TAB UTAMA - AUTO GENERATOR ================
local MainTab = Window:CreateTab({ Title = "Auto Generator", Icon = "zap" })
local mainSection = MainTab:CreateSection("Pengaturan Generator")

-- Status
local statusLabel = mainSection:AddLabel({
    Title = "Status Generator: OFF",
    Description = "Auto Generator mati"
})

-- Tombol Start/Stop
local genBtn = mainSection:AddButton({
    Title = "▶️ Start Auto Generator",
    Callback = function()
        autoGenActive = not autoGenActive
        
        if autoGenActive then
            genBtn:SetTitle("⏸️ Stop Auto Generator")
            statusLabel:SetTitle("Status Generator: AKTIF")
            statusLabel:SetDescription("Mencari generator untuk diperbaiki...")
            startAutoGenerator()
        else
            genBtn:SetTitle("▶️ Start Auto Generator")
            statusLabel:SetTitle("Status Generator: OFF")
            statusLabel:SetDescription("Auto Generator mati")
            stopAutoGenerator()
        end
    end
})

-- Kecepatan Generator
mainSection:AddSlider({
    Title = "Kecepatan Repair",
    Min = 0.1,
    Max = 5,
    Default = 1,
    Decimals = 1,
    Callback = function(v)
        -- Kecepatan loop generator
    end
})

-- Radius Pencarian Generator
mainSection:AddSlider({
    Title = "Radius Pencarian",
    Min = 10,
    Max = 100,
    Default = 50,
    Callback = function(v)
        genRadius = v
    end
})

-- Tombol Scan Generator
mainSection:AddButton({
    Title = "🔍 Scan Generator Sekarang",
    Callback = function()
        local gens = scanGenerators()
        WindUI:Notify({
            Title = "Scan Selesai",
            Content = "Ditemukan " .. #gens .. " generator"
        })
        
        -- Update dropdown
        local options = {}
        for i, gen in pairs(gens) do
            table.insert(options, gen.name .. " #" .. i)
        end
        genDropdown:SetValues(options)
    end
})

-- Dropdown Generator
local genDropdown = mainSection:AddDropdown({
    Title = "Pilih Generator",
    Description = "Target generator spesifik",
    Values = {},
    Callback = function(selected)
        for i, gen in pairs(generators) do
            if gen.name .. " #" .. i == selected then
                targetGenerator = gen
                WindUI:Notify({Title = "Target", Content = "Memilih " .. gen.name})
                break
            end
        end
    end
})

-- ================ TAB AUTO AIM KE KILLER ================
local AimTab = Window:CreateTab({ Title = "Auto Aim (Killer)", Icon = "crosshair" })
local aimSection = AimTab:CreateSection("Auto Aim ke Killer")

-- Informasi Role
local roleLabel = aimSection:AddLabel({
    Title = "Role Terdeteksi: " .. detectRole(),
    Description = "Mode aim akan menarget killer"
})

-- Status Auto Aim
local aimStatusLabel = aimSection:AddLabel({
    Title = "Status Auto Aim: OFF",
    Description = "Auto Aim mati"
})

-- Tombol Start/Stop Auto Aim
local aimBtn = aimSection:AddButton({
    Title = "🎯 Aktifkan Auto Aim",
    Callback = function()
        autoAimActive = not autoAimActive
        
        if autoAimActive then
            aimBtn:SetTitle("⏸️ Matikan Auto Aim")
            aimStatusLabel:SetTitle("Status Auto Aim: AKTIF")
            aimStatusLabel:SetDescription("Mencari killer terdekat...")
            startAutoAim()
        else
            aimBtn:SetTitle("🎯 Aktifkan Auto Aim")
            aimStatusLabel:SetTitle("Status Auto Aim: OFF")
            aimStatusLabel:SetDescription("Auto Aim mati")
            stopAutoAim()
        end
    end
})

-- FOV Setting
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

-- Smoothness
aimSection:AddSlider({
    Title = "Smoothness",
    Description = "Kehalusan aim (1-20)",
    Min = 1,
    Max = 20,
    Default = 5,
    Callback = function(v)
        aimSmoothness = v
    end
})

-- Prioritas Target
aimSection:AddDropdown({
    Title = "Prioritas Target",
    Values = {"Killer Terdekat", "Killer dengan Health Terkecil", "Killer dengan Health Terbesar"},
    Default = "Killer Terdekat",
    Callback = function(selected)
        aimPriority = selected
    end
})

-- Tombol Force Target
aimSection:AddButton({
    Title = "🎯 Pilih Target Manual",
    Callback = function()
        scanKillers()
        local options = {}
        for _, k in pairs(killers) do
            table.insert(options, k.name .. " (❤️ " .. math.floor(k.health) .. " | " .. math.floor(k.distance) .. "m)")
        end
        killerDropdown:SetValues(options)
    end
})

-- Dropdown Killer
local killerDropdown = aimSection:AddDropdown({
    Title = "Target Manual",
    Values = {},
    Callback = function(selected)
        for _, k in pairs(killers) do
            if k.name .. " (❤️ " .. math.floor(k.health) .. " | " .. math.floor(k.distance) .. "m)" == selected then
                targetKiller = k
                WindUI:Notify({Title = "Target Manual", Content = k.name})
                break
            end
        end
    end
})

-- ================ TAB ESP ================
local ESPTab = Window:CreateTab({ Title = "ESP", Icon = "eye" })
local espSection = ESPTab:CreateSection("ESP Settings")

-- ESP Killer
espSection:AddToggle({
    Title = "ESP Killer",
    Description = "Highlight posisi killer",
    Callback = function(state)
        espKillerActive = state
    end
})

-- ESP Survivor
espSection:AddToggle({
    Title = "ESP Survivor",
    Description = "Highlight posisi survivor lain",
    Callback = function(state)
        espSurvivorActive = state
    end
})

-- ESP Generator
espSection:AddToggle({
    Title = "ESP Generator",
    Description = "Highlight posisi generator",
    Callback = function(state)
        espGenActive = state
    end
})

-- Warna ESP
espSection:AddColorPicker({
    Title = "Warna ESP Killer",
    Default = Color3.new(1, 0, 0), -- Merah
    Callback = function(color)
        killerESPColor = color
    end
})

espSection:AddColorPicker({
    Title = "Warna ESP Survivor",
    Default = Color3.new(0, 1, 0), -- Hijau
    Callback = function(color)
        survivorESPColor = color
    end
})

-- ================ TAB UTILITIES ================
local UtilTab = Window:CreateTab({ Title = "Utilities", Icon = "settings" })
local utilSection = UtilTab:CreateSection("Tools")

-- NoClip
utilSection:AddToggle({
    Title = "NoClip (Tembus Tembok)",
    Description = "Berjalan menembus dinding",
    Callback = function(state)
        noclipActive = state
        if state then
            if noclipConnection then noclipConnection:Disconnect() end
            noclipConnection = RunService.Stepped:Connect(function()
                if noclipActive and player.Character then
                    for _, v in pairs(player.Character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end)
            WindUI:Notify({Title = "NoClip", Content = "Aktif - Bisa tembus tembok"})
        else
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
        end
    end
})

-- Speed Boost
utilSection:AddSlider({
    Title = "Speed Boost",
    Min = 16,
    Max = 100,
    Default = 16,
    Callback = function(v)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = v
        end
    end
})

-- Anti Stun [citation:5]
utilSection:AddToggle({
    Title = "Anti Stun",
    Description = "Tidak terpengaruh stun effect",
    Callback = function(state)
        antiStunActive = state
    end
})

-- Auto Parry [citation:5]
utilSection:AddToggle({
    Title = "Auto Parry",
    Description = "Otomatis menangkis serangan",
    Callback = function(state)
        autoParryActive = state
    end
})

-- ================ TAB TELEPORT ================
local TeleportTab = Window:CreateTab({ Title = "Teleport", Icon = "map-pin" })
local tpSection = TeleportTab:CreateSection("Teleport")

-- Teleport ke Killer Terdekat
tpSection:AddButton({
    Title = "📍 Teleport ke Killer Terdekat",
    Callback = function()
        scanKillers()
        if #killers == 0 then
            WindUI:Notify({Title = "Error", Content = "Tidak ada killer!"})
            return
        end
        
        local nearest = killers[1]
        for _, k in pairs(killers) do
            if k.distance < nearest.distance then
                nearest = k
            end
        end
        
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root and nearest and nearest.root then
            root.CFrame = nearest.root.CFrame * CFrame.new(0, 3, 5)
            WindUI:Notify({Title = "Teleport", Content = "Ke " .. nearest.name})
        end
    end
})

-- Teleport ke Generator
tpSection:AddButton({
    Title = "⚡ Teleport ke Generator",
    Callback = function()
        scanGenerators()
        if #generators == 0 then
            WindUI:Notify({Title = "Error", Content = "Tidak ada generator!"})
            return
        end
        
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root and generators[1] and generators[1].part then
            root.CFrame = CFrame.new(generators[1].part.Position + Vector3.new(0, 3, 0))
            WindUI:Notify({Title = "Teleport", Content = "Ke generator"})
        end
    end
})

-- Gate TP [citation:5]
tpSection:AddButton({
    Title = "🚪 Teleport ke Gate",
    Description = "Langsung ke pintu keluar",
    Callback = function()
        -- Cari objek gate/exit
        for _, v in pairs(Workspace:GetDescendants()) do
            local name = v.Name:lower()
            if name:find("gate") or name:find("exit") or name:find("door") or name:find("escape") then
                local pos = v:IsA("BasePart") and v.Position or (v.PrimaryPart and v.PrimaryPart.Position)
                if pos then
                    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                        WindUI:Notify({Title = "Teleport", Content = "Ke gate"})
                        return
                    end
                end
            end
        end
    end
})

-- ================ FUNGSI AUTO GENERATOR ================
function startAutoGenerator()
    if genConnection then genConnection:Disconnect() end
    
    genConnection = RunService.Heartbeat:Connect(function()
        if not autoGenActive then return end
        
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        -- Scan generator secara berkala
        scanGenerators()
        
        if #generators > 0 then
            -- Cari generator terdekat
            local nearest = generators[1]
            local nearestDist = (nearest.part.Position - root.Position).Magnitude
            
            for _, gen in pairs(generators) do
                local dist = (gen.part.Position - root.Position).Magnitude
                if dist < nearestDist then
                    nearest = gen
                    nearestDist = dist
                end
            end
            
            -- Gerak ke generator
            if nearestDist > 5 then
                root.CFrame = CFrame.new(nearest.part.Position + Vector3.new(0, 3, 0))
            else
                -- Interaksi dengan generator
                if nearest.model then
                    -- Coba cari ClickDetector atau ProximityPrompt
                    local detector = nearest.model:FindFirstChildOfClass("ClickDetector")
                    if detector then
                        fireclickdetector(detector)
                    end
                    
                    local prompt = nearest.model:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then
                        -- Simulasi interaksi
                        prompt:InputHoldBegin()
                        task.wait(0.1)
                        prompt:InputHoldEnd()
                    end
                end
            end
        end
        
        task.wait(1)
    end)
end

function stopAutoGenerator()
    if genConnection then
        genConnection:Disconnect()
        genConnection = nil
    end
end

-- ================ FUNGSI AUTO AIM ================
function startAutoAim()
    if aimConnection then aimConnection:Disconnect() end
    
    aimConnection = RunService.RenderStepped:Connect(function()
        if not autoAimActive then return end
        
        scanKillers()
        if #killers == 0 then return end
        
        -- Pilih target berdasarkan prioritas
        local target = targetKiller
        if not target then
            if aimPriority == "Killer Terdekat" then
                target = killers[1]
                for _, k in pairs(killers) do
                    if k.distance < target.distance then
                        target = k
                    end
                end
            elseif aimPriority == "Killer dengan Health Terkecil" then
                target = killers[1]
                for _, k in pairs(killers) do
                    if k.health < target.health then
                        target = k
                    end
                end
            else -- Health terbesar
                target = killers[1]
                for _, k in pairs(killers) do
                    if k.health > target.health then
                        target = k
                    end
                end
            end
        end
        
        if target and target.root then
            -- Hitung arah ke target
            local targetPos = target.root.Position
            local cameraPos = camera.CFrame.Position
            local direction = (targetPos - cameraPos).Unit
            
            -- Hitung angle ke target
            local lookVector = camera.CFrame.LookVector
            local dot = lookVector:Dot(direction)
            local angle = math.acos(dot) * (180 / math.pi)
            
            -- Jika dalam FOV
            if angle <= aimFov then
                -- Smooth aim
                local newLook = lookVector:Lerp(direction, 1/aimSmoothness)
                camera.CFrame = CFrame.new(cameraPos, cameraPos + newLook)
            end
        end
    end)
end

function stopAutoAim()
    if aimConnection then
        aimConnection:Disconnect()
        aimConnection = nil
    end
end

-- ================ LOOP ESP ================
RunService.RenderStepped:Connect(function()
    -- Hapus semua ESP lama
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Highlight") and v.Name == "TerehubESP" then
            v:Destroy()
        end
    end
    
    -- ESP Killer
    if espKillerActive then
        for _, k in pairs(killers) do
            if k.character then
                local hl = Instance.new("Highlight")
                hl.Name = "TerehubESP"
                hl.Adornee = k.character
                hl.FillColor = killerESPColor or Color3.new(1, 0, 0)
                hl.FillTransparency = 0.5
                hl.OutlineColor = Color3.new(1, 1, 1)
                hl.Parent = k.character
            end
        end
    end
    
    -- ESP Survivor
    if espSurvivorActive then
        scanSurvivors()
        for _, s in pairs(survivors) do
            if s.character then
                local hl = Instance.new("Highlight")
                hl.Name = "TerehubESP"
                hl.Adornee = s.character
                hl.FillColor = survivorESPColor or Color3.new(0, 1, 0)
                hl.FillTransparency = 0.5
                hl.OutlineColor = Color3.new(1, 1, 1)
                hl.Parent = s.character
            end
        end
    end
    
    -- ESP Generator
    if espGenActive then
        for _, g in pairs(generators) do
            if g.part then
                local hl = Instance.new("Highlight")
                hl.Name = "TerehubESP"
                hl.Adornee = g.part
                hl.FillColor = Color3.new(1, 1, 0) -- Kuning
                hl.FillTransparency = 0.5
                hl.OutlineColor = Color3.new(1, 1, 1)
                hl.Parent = g.part
            end
        end
    end
end)

-- ================ AUTO UPDATE ================
task.spawn(function()
    while wait(3) do
        scanGenerators()
        scanKillers()
        scanSurvivors()
    end
end)

-- ================ KEYBINDS ================
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        WindUI:Toggle()
    elseif input.KeyCode == Enum.KeyCode.End then
        -- Unload
        if genConnection then genConnection:Disconnect() end
        if aimConnection then aimConnection:Disconnect() end
        if noclipConnection then noclipConnection:Disconnect() end
        WindUI:Destroy()
        script:Destroy()
    end
end)

-- Notifikasi sukses
wait(1)
WindUI:Notify({
    Title = "✅ TEREHUB - Violence District",
    Content = "Auto Generator | Auto Aim | ESP | Teleport\nTekan RightShift untuk toggle",
    Duration = 5
})

print("=== TEREHUB VIOLENCE DISTRICT LOADED ===")
print("Game: Violence District (Asymmetrical Horror)")
print("Fitur: Auto Generator, Auto Aim ke Killer, ESP, Teleport, NoClip")
print("Tekan RightShift untuk buka/tutup GUI")