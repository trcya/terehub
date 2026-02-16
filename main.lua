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
local espActive = false
local autoAim = false
local autoGen = false
local walkSpeedValue = 16
local noclipActive = false

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

-- [[ VISUAL TAB: ESP ]] --
VisualTab:Toggle({
    Title = "ESP Players & Killer",
    Description = "Merah = Killer, Putih = Survivor",
    Callback = function(state) 
        espActive = state 
        -- Jika dimatikan, hapus semua highlight
        if not state then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("TereESP") then
                    p.Character.TereESP:Destroy()
                end
            end
        end
    end
})

-- [[ COMBAT TAB ]] --
CombatTab:Toggle({
    Title = "Auto Aim (Killer)",
    Callback = function(state) autoAim = state end
})

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

-- [[ LOGIC: AUTO GENERATOR ]] --
task.spawn(function()
    while true do
        if autoGen and player.Character then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name:lower():find("generator") then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    local target = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                    
                    if hrp and target then
                        -- KODE LAMA: CFrame.new(0, 3, 0) -> Ini ke atas
                        -- KODE BARU: CFrame.new(3, 0, 0) -> Ini ke samping (jarak 3 stud)
                        hrp.CFrame = target.CFrame * CFrame.new(3, 0, 0)
                        
                        -- Membuat karakter otomatis menghadap ke arah generator
                        hrp.CFrame = CFrame.lookAt(hrp.Position, target.Position)
                        
                        -- Interaksi
                        local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                        if prompt then
                            fireproximityprompt(prompt)
                        else
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            task.wait(0.1)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        end
                        break
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

Window:Notify({ Title = "Terehub V10", Content = "Movement & Noclip Ready!", Duration = 5 })