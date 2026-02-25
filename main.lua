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

-- [[ MAIN TAB: MOVEMENT ]] --
MainTab:Slider({ Title = "Speed", Min = 16, Max = 250, Default = 16, Callback = function(v) walkSpeedValue = v end })
MainTab:Toggle({ Title = "Noclip", Callback = function(state) noclipActive = state end })

-- [[ COMBAT & AUTO ]] --
CombatTab:Toggle({ Title = "Auto Aim (Killer)", Callback = function(state) autoAim = state end })
AutoTab:Toggle({ Title = "Full Auto Gen", Callback = function(state) autoGen = state end })

-- [[ LOGIC: ESP PLAYER & KILLER ]] --
RunService.RenderStepped:Connect(function()
    if espActive then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                -- Logika Warna: Cek Team
                local isKiller = false
                if p.Team and (p.Team.Name:lower():find("killer") or p.Team.Name:find("murderer")) then
                    isKiller = true
                end
                
                local color = isKiller and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)
                
                -- Gunakan Highlight agar nembus tembok
                local highlight = p.Character:FindFirstChild("TereESP")
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "TereESP"
                    highlight.Parent = p.Character
                end
                
                highlight.FillColor = color
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
            end
        end
    end
end)

-- [[ LOGIC: MOVEMENT ]] --
RunService.Stepped:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = walkSpeedValue
        if noclipActive then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end
end)

-- [[ LOGIC: AUTO GENERATOR (SAMPING) ]] --
task.spawn(function()
    while true do
        if autoGen and player.Character then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name:lower():find("generator") then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    local target = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                    if hrp and target then
                        -- Teleport ke samping (X = 3)
                        hrp.CFrame = target.CFrame * CFrame.new(3, 0, 0)
                        hrp.CFrame = CFrame.lookAt(hrp.Position, target.Position)
                        
                        local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                        if prompt then fireproximityprompt(prompt) end
                        break
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

Window:Notify({ Title = "Terehub", Content = "ESP & All Features Loaded!", Duration = 5 })