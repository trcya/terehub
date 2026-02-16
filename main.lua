local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "Terehub - Violence District",
    Icon = "rbxassetid://136360402262473",
    Author = "Violence District",
    Folder = "Terehub",
    Size = UDim2.fromOffset(600, 360),
    MinSize = Vector2.new(560, 250),
    MaxSize = Vector2.new(950, 760),
    Transparent = true,
    Theme = "Indigo",
    Resizable = true,
    SideBarWidth = 190,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true, 
    ScrollBarEnabled = true,
    })

-- [[ SERVICES ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

-- [[ VARIABLES ]] --
local autoAim = false
local autoGen = false
local walkSpeedValue = 16
local noclipActive = false
local espActive = false
local autoSkillCheck = true 
local auraRange = 15 -- Jarak serang (studs)

-- [[ TABS SETUP ]] --
local MainTab = Window:Tab({ Title = "Main", Icon = "home" })
local VisualTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local CombatTab = Window:Tab({ Title = "Combat", Icon = "crosshair" })
local AutoTab = Window:Tab({ Title = "Automation", Icon = "cpu" })

-- [[ MAIN TAB: MOVEMENT ]] --
MainTab:Slider({
    Title = "Speedwalk",
    Min = 16,
    Max = 250,
    Default = 16,
    Callback = function(v) walkSpeedValue = v end
})

MainTab:Toggle({
    Title = "Noclip (Nembus Tembok)",
    Description = "Membuat karakter bisa menembus objek",
    Callback = function(state) noclipActive = state end
})

-- [[ COMBAT TAB ]] --
CombatTab:Toggle({
    Title = "Auto Aim (Killer)",
    Callback = function(state) autoAim = state end
})

-- [[ COMBAT: KILL AURA ]] --
CombatTab:Toggle({
    Title = "Kill Aura",
    Description = "Otomatis menyerang survivor di sekitar",
    Callback = function(state) killAuraActive = state end
})

CombatTab:Slider({
    Title = "Aura Range",
    Min = 5,
    Max = 25,
    Default = 15,
    Callback = function(v) auraRange = v end
})

-- [[ LOGIC: KILL AURA (Desktop & Mobile) ]] --
task.spawn(function()
    while true do
        if killAuraActive and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            for _, target in pairs(Players:GetPlayers()) do
                -- Pastikan target adalah orang lain dan punya karakter
                if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (player.Character.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude
                    
                    -- Jika survivor berada dalam jangkauan
                    if distance <= auraRange then
                        -- 1. Simulasi Klik Kiri (Mouse Button 1) untuk PC
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.01)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                        
                        -- 2. Backup: Simulasi Tap untuk Mobile
                        -- Kita kirim input 'Click' ke sistem game
                        local tool = player.Character:FindFirstChildOfClass("Tool")
                        if tool then
                            tool:Activate()
                        end
                    end
                end
            end
        end
        task.wait(0.1) -- Kecepatan pukul (Attack Speed)
    end
end)

-- [[ AUTO TAB ]] --
AutoTab:Toggle({
    Title = "Full Auto Gen (Hybrid)",
    Callback = function(state) autoGen = state end
})

-- [[ LOGIC: MOVEMENT & NOCLIP ]] --
-- Menggunakan Stepped agar Noclip stabil dan tidak mental
RunService.Stepped:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        -- Update Speed
        player.Character.Humanoid.WalkSpeed = walkSpeedValue
        
        -- Update Noclip
        if noclipActive then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- [[ LOGIC: AUTO AIM ]] --
RunService.RenderStepped:Connect(function()
    if autoAim and player.Character then
        local closestKiller = nil
        local shortestDistance = math.huge

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                local teamName = p.Team and p.Team.Name:lower() or ""
                if teamName:find("killer") or teamName:find("murderer") then
                    local distance = (player.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestKiller = p.Character.Head
                    end
                end
            end
        end

        if closestKiller then
            local cam = Workspace.CurrentCamera
            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, closestKiller.Position)
        end
    end
end)



-- [[ AUTO TAB: GENERATOR MOBILE FIX ]] --
AutoTab:Toggle({
    Title = "Full Auto Gen (Mobile Fix)",
    Callback = function(state) autoGen = state end
})

--- [[ 1. VISUALS TAB ]] ---
VisualTab:Toggle({
    Title = "ESP Player & Killer",
    Description = "Melihat posisi pemain menembus tembok",
    Callback = function(state) 
        espActive = state 
        if not state then
            -- Bersihkan highlight jika dimatikan
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("TereESP") then
                    p.Character.TereESP:Destroy()
                end
            end
        end
    end
})

-- [[ LOGIC: AUTO GEN  ]] --
task.spawn(function()
    while true do
        if autoGen and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name:lower():find("generator") then
                    local target = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                    
                    if target then
                        -- SOLUSI: Menggunakan posisi World agar tidak terpengaruh rotasi generator
                        -- Kita ambil posisi generator, lalu geser 3 stud ke samping (X) secara global
                        hrp.CFrame = CFrame.new(target.Position + Vector3.new(3, 0, 0))
                        
                        -- Membuat karakter menoleh ke arah generator
                        hrp.CFrame = CFrame.lookAt(hrp.Position, target.Position)
                        
                        -- Jalankan Interaksi
                        local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then
                            fireproximityprompt(prompt)
                        end
                        
                        -- Backup input E untuk Desktop/Mobile
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        
                        break
                    end
                end
            end
        end
        task.wait(0.4)
    end
end)
-- [[ LOGIC: SKILL CHECK (Sesuai Video) ]] --
task.spawn(function()
    while true do
        if autoGen or autoSkillCheck then
            local pGui = player:FindFirstChild("PlayerGui")
            if pGui then
                -- Mencari UI melingkar seperti di video kamu
                for _, v in pairs(pGui:GetDescendants()) do
                    if v.Name == "Pointer" or v.Name == "Needle" then
                        local success = v.Parent:FindFirstChild("SuccessZone") or v.Parent:FindFirstChild("WhiteArea")
                        -- Toleransi rotasi diperbesar sedikit (10) agar tidak luput di mobile
                        if success and math.abs(v.Rotation - success.Rotation) < 10 then
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                            task.wait(0.01)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                            task.wait(0.3)
                        end
                    end
                end
            end
        end
        task.wait()
    end
end)

Window:Notify({ Title = "Terehub V10", Content = "Movement & Noclip Ready!", Duration = 5 })