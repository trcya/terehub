local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/Source.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Terehub | Violence District V10",
    Icon = "rbxassetid://136360402262473",
    Author = "David",
    Folder = "Terehub",
    Size = UDim2.fromOffset(600, 420),
    Transparent = true,
    Theme = "Indigo",
})

-- [[ TABS ]] --
local MainTab = Window:Tab({ Title = "Main", Icon = "home" })
local CharTab = Window:Tab({ Title = "Character", Icon = "user" })
local CombatTab = Window:Tab({ Title = "Combat", Icon = "crosshair" })
local VisualTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local PlayerTab = Window:Tab({ Title = "Players", Icon = "users" })

-- [[ MAIN: AUTO PERFECT SKILL CHECK & COLLECTOR ]] --
local autoSkillCheck = false
MainTab:Toggle({
    Title = "Auto Perfect Skill Check",
    Callback = function(state) autoSkillCheck = state end
})

-- Logic Auto Skill Check (Tepat di Putih)
task.spawn(function()
    while true do
        if autoSkillCheck then
            local pGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
            -- Mencari UI Skill Check di Violence District
            for _, v in pairs(pGui:GetDescendants()) do
                if v.Name == "SkillCheck" or v.Name == "Pointer" then 
                    local needle = v -- Jarum
                    local successZone = v.Parent:FindFirstChild("SuccessZone") or v.Parent:FindFirstChild("WhiteArea")
                    
                    if needle and successZone then
                        -- Jika posisi jarum masuk ke area sukses, otomatis tekan
                        if math.abs(needle.Rotation - successZone.Rotation) < 5 then
                            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                            task.wait(0.01)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                        end
                    end
                end
            end
        end
        task.wait()
    end
end)

local autoGen = false
MainTab:Toggle({
    Title = "Auto Collect Items",
    Callback = function(state)
        autoGen = state
        task.spawn(function()
            while autoGen do
                for _, v in pairs(game.Workspace:GetChildren()) do
                    if v:IsA("Tool") or v.Name == "Scrap" or v.Name == "Item" then
                        local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local target = v:FindFirstChild("Handle") or v:FindFirstChildWhichIsA("BasePart")
                        if hrp and target then
                            hrp.CFrame = target.CFrame
                            task.wait(0.2)
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
})

local autoRepairGen = false
MainTab:Toggle({
    Title = "Auto Repair Generator",
    Callback = function(state)
        autoRepairGen = state
        task.spawn(function()
            while autoRepairGen do
                pcall(function()
                    for _, prompt in pairs(workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") then
                            local name = string.lower(prompt.Parent.Name)
                            local action = string.lower(prompt.ActionText)
                            
                            if string.find(name, "gen") or string.find(action, "repair") or string.find(action, "fix") then
                                local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                local targetPart = prompt.Parent
                                if targetPart and targetPart:IsA("BasePart") and hrp then
                                    -- Teleport near the generator
                                    hrp.CFrame = targetPart.CFrame * CFrame.new(0, 0, 3)
                                    task.wait(0.2)
                                    -- Otomatis trigger repair
                                    fireproximityprompt(prompt)
                                end
                            end
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end
})

-- [[ CHARACTER: MOVEMENT MODIFIERS ]] --
local wsToggle = false
local wsValue = 16
local jpToggle = false
local jpValue = 50
local infJump = false

CharTab:Toggle({ Title = "Enable WalkSpeed", Callback = function(s) wsToggle = s end })
CharTab:Slider({ Title = "WalkSpeed", Step = 1, Min = 16, Max = 150, Default = 16, Callback = function(v) wsValue = v end })

CharTab:Toggle({ Title = "Enable JumpPower", Callback = function(s) jpToggle = s end })
CharTab:Slider({ Title = "JumpPower", Step = 1, Min = 50, Max = 200, Default = 50, Callback = function(v) jpValue = v end })

CharTab:Toggle({ Title = "Infinite Jump", Callback = function(s) infJump = s end })

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJump and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

task.spawn(function()
    game:GetService("RunService").RenderStepped:Connect(function()
        if wsToggle and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = wsValue
        end
        if jpToggle and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.UseJumpPower = true
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = jpValue
        end
    end)
end)

-- [[ COMBAT: AUTO AIM KILLER ]] --
local autoAim = false
CombatTab:Toggle({
    Title = "Auto Aim (Target Killer)",
    Callback = function(state) autoAim = state end
})

task.spawn(function()
    game:GetService("RunService").RenderStepped:Connect(function()
        if autoAim then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    if p.Team and (string.find(p.Team.Name, "Killer") or string.find(p.Team.Name, "Murderer")) then
                        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, p.Character.Head.Position)
                    end
                end
            end
        end
    end)
end)

-- Hitbox Expander
local hitboxActive = false
local hitboxSize = 5
CombatTab:Toggle({ Title = "Hitbox Expander", Callback = function(state) hitboxActive = state end })
CombatTab:Slider({ Title = "Hitbox Size", Step = 1, Min = 2, Max = 25, Default = 5, Callback = function(v) hitboxSize = v end })

task.spawn(function()
    game:GetService("RunService").RenderStepped:Connect(function()
        if hitboxActive then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    p.Character.HumanoidRootPart.Transparency = 0.5
                    p.Character.HumanoidRootPart.CanCollide = false
                end
            end
        end
    end)
end)

-- [[ VISUALS: ESP TEAM COLOR ]] --
local espActive = false
VisualTab:Toggle({ Title = "ESP Team (Red Killer/White Surv)", Callback = function(s) espActive = s end })

game:GetService("RunService").RenderStepped:Connect(function()
    if espActive then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                -- Logika untuk menentukan Killer vs Survivor
                local isKiller = false
                if p.Team and (string.match(string.lower(p.Team.Name), "killer") or string.match(string.lower(p.Team.Name), "murderer")) then
                    isKiller = true
                elseif p.Character:FindFirstChildWhichIsA("Tool") and string.match(string.lower(p.Character:FindFirstChildWhichIsA("Tool").Name), "knife") then
                    -- Fallback: Kadang Killer tidak masuk tim, tapi memegang senjata tertentu
                    isKiller = true
                end

                local color = isKiller and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)
                
                local h = p.Character:FindFirstChild("Highlight") or Instance.new("Highlight", p.Character)
                h.FillColor = color

                local bb = p.Character:FindFirstChild("TereName") or Instance.new("BillboardGui", p.Character)
                if not p.Character:FindFirstChild("TereName") then
                    bb.Name = "TereName"; bb.AlwaysOnTop = true; bb.Size = UDim2.new(0, 100, 0, 25); bb.ExtentsOffset = Vector3.new(0, 3, 0)
                    local lbl = Instance.new("TextLabel", bb); lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1; lbl.TextStrokeTransparency = 0
                end
                bb.TextLabel.Text = p.Name; bb.TextLabel.TextColor3 = color
            end
        end
    end
end)

-- Fullbright
local fullbright = false
VisualTab:Toggle({ Title = "Fullbright", Callback = function(state) fullbright = state end })

task.spawn(function()
    local lighting = game:GetService("Lighting")
    game:GetService("RunService").RenderStepped:Connect(function()
        if fullbright then
            lighting.Ambient = Color3.new(1, 1, 1)
            lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
            lighting.ColorShift_Top = Color3.new(1, 1, 1)
            lighting.Brightness = 2
            lighting.GlobalShadows = false
        end
    end)
end)

-- [[ PLAYER LIST FIX ]] --
local selectedPlayer = ""
local function getPlayers()
    local tbl = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then table.insert(tbl, p.Name) end
    end
    return tbl
end

local PlayerDrop = PlayerTab:Dropdown({
    Title = "Select Player",
    Options = getPlayers(),
    Callback = function(v) selectedPlayer = v end
})

PlayerTab:Button({ Title = "Fix Player List", Callback = function() PlayerDrop:SetOptions(getPlayers()) end })
PlayerTab:Button({ Title = "Teleport", Callback = function()
    local target = game.Players:FindFirstChild(selectedPlayer)
    if target and target.Character then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame end
end })

PlayerTab:Button({ Title = "Spectate", Callback = function()
    local target = game.Players:FindFirstChild(selectedPlayer)
    if target and target.Character then
        workspace.CurrentCamera.CameraSubject = target.Character:FindFirstChild("Humanoid")
    end
end })

PlayerTab:Button({ Title = "Unspectate", Callback = function()
    if game.Players.LocalPlayer.Character then
        workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    end
end })

Window:Notify({ Title = "Terehub V10", Content = "Terehub + New Features Loaded!", Duration = 5 })
