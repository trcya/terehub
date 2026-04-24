local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()

print("Terehub: Initializing...")

-- [[ UI LOADING ]] --
local function LoadUI()
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/Source.lua"))()
    end)
    if success and result then
        return result
    else
        warn("Terehub: Failed to load WindUI. Error: " .. tostring(result))
        return nil
    end
end

local WindUI = LoadUI()
if not WindUI then 
    print("Terehub: CRITICAL - UI Library failed to load!")
    return 
end
print("Terehub: UI Library loaded, creating window...")

local Window = WindUI:CreateWindow({
    Title = "Terehub | Violence District V10",
    Icon = "rbxassetid://136360402262473",
    Author = "David",
    Folder = "Terehub",
    Size = UDim2.fromOffset(600, 420),
    Transparent = false, -- Changed to false for better visibility
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

task.spawn(function()
    while true do
        if autoSkillCheck then
            pcall(function()
                local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                if pGui then
                    for _, v in pairs(pGui:GetDescendants()) do
                        if v.Name == "SkillCheck" or v.Name == "Pointer" then 
                            local needle = v
                            local successZone = v.Parent:FindFirstChild("SuccessZone") or v.Parent:FindFirstChild("WhiteArea")
                            
                            if needle and successZone and needle:IsA("GuiObject") and successZone:IsA("GuiObject") then
                                -- Check rotation or position for match
                                if math.abs(needle.Rotation - successZone.Rotation) < 8 then
                                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                                    task.wait(0.01)
                                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                                    task.wait(0.5) -- Debounce to prevent multiple presses
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait()
    end
end)

local autoCollect = false
MainTab:Toggle({
    Title = "Auto Collect Items",
    Callback = function(state)
        autoCollect = state
    end
})

task.spawn(function()
    while true do
        if autoCollect then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, v in pairs(workspace:GetChildren()) do
                        if v:IsA("Tool") or v.Name == "Scrap" or v.Name == "Item" then
                            local target = v:FindFirstChild("Handle") or v:FindFirstChildWhichIsA("BasePart")
                            if target then
                                hrp.CFrame = target.CFrame
                                task.wait(0.3)
                            end
                        end
                        if not autoCollect then break end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

local autoRepairGen = false
MainTab:Toggle({
    Title = "Auto Repair Generator",
    Callback = function(state)
        autoRepairGen = state
    end
})

task.spawn(function()
    while true do
        if autoRepairGen then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, prompt in pairs(workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") then
                            local name = string.lower(prompt.Parent.Name)
                            local action = string.lower(prompt.ActionText)
                            
                            if string.find(name, "gen") or string.find(action, "repair") or string.find(action, "fix") then
                                local targetPart = prompt.Parent
                                if targetPart and targetPart:IsA("BasePart") then
                                    hrp.CFrame = targetPart.CFrame * CFrame.new(0, 0, 3)
                                    task.wait(0.2)
                                    if fireproximityprompt then
                                        fireproximityprompt(prompt)
                                    else
                                        prompt:InputHoldBegin()
                                        task.wait(prompt.HoldDuration + 0.1)
                                        prompt:InputHoldEnd()
                                    end
                                end
                            end
                        end
                        if not autoRepairGen then break end
                    end
                end
            end)
        end
        task.wait(1)
    end
end)

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

UserInputService.JumpRequest:Connect(function()
    if infJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then
        if wsToggle then hum.WalkSpeed = wsValue end
        if jpToggle then 
            hum.UseJumpPower = true
            hum.JumpPower = jpValue 
        end
    end
end)

-- [[ COMBAT: AUTO AIM KILLER ]] --
local autoAim = false
CombatTab:Toggle({
    Title = "Auto Aim (Target Killer)",
    Callback = function(state) autoAim = state end
})

RunService.RenderStepped:Connect(function()
    if autoAim then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local isKiller = false
                if p.Team and (string.find(p.Team.Name, "Killer") or string.find(p.Team.Name, "Murderer")) then
                    isKiller = true
                end
                
                if isKiller then
                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, p.Character.Head.Position)
                    break
                end
            end
        end
    end
end)

-- Hitbox Expander
local hitboxActive = false
local hitboxSize = 5
CombatTab:Toggle({ Title = "Hitbox Expander", Callback = function(state) hitboxActive = state end })
CombatTab:Slider({ Title = "Hitbox Size", Step = 1, Min = 2, Max = 25, Default = 5, Callback = function(v) hitboxSize = v end })

task.spawn(function()
    while true do
        if hitboxActive then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    p.Character.HumanoidRootPart.Transparency = 0.5
                    p.Character.HumanoidRootPart.CanCollide = false
                end
            end
        end
        task.wait(1)
    end
end)

-- [[ VISUALS: ESP TEAM COLOR ]] --
local espActive = false
VisualTab:Toggle({ Title = "ESP Team", Callback = function(s) espActive = s end })

RunService.Heartbeat:Connect(function()
    if espActive then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local isKiller = false
                if p.Team and (string.match(string.lower(p.Team.Name), "killer") or string.match(string.lower(p.Team.Name), "murderer")) then
                    isKiller = true
                elseif p.Character:FindFirstChildWhichIsA("Tool") and string.match(string.lower(p.Character:FindFirstChildWhichIsA("Tool").Name), "knife") then
                    isKiller = true
                end

                local color = isKiller and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)
                
                -- Highlight
                local h = p.Character:FindFirstChild("TereHighlight")
                if not h then
                    h = Instance.new("Highlight")
                    h.Name = "TereHighlight"
                    h.Parent = p.Character
                end
                h.FillColor = color
                h.Enabled = true

                -- Name Tag
                local bb = p.Character:FindFirstChild("TereName")
                local lbl
                if not bb then
                    bb = Instance.new("BillboardGui")
                    bb.Name = "TereName"
                    bb.AlwaysOnTop = true
                    bb.Size = UDim2.new(0, 100, 0, 25)
                    bb.ExtentsOffset = Vector3.new(0, 3, 0)
                    bb.Parent = p.Character
                    
                    lbl = Instance.new("TextLabel")
                    lbl.Name = "Tag"
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextStrokeTransparency = 0
                    lbl.Parent = bb
                else
                    lbl = bb:FindFirstChild("Tag")
                end
                
                if lbl then
                    lbl.Text = p.Name
                    lbl.TextColor3 = color
                end
            end
        end
    else
        -- Clean up ESP
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                local h = p.Character:FindFirstChild("TereHighlight")
                if h then h.Enabled = false end
                local bb = p.Character:FindFirstChild("TereName")
                if bb then bb.Enabled = false end
            end
        end
    end
end)

-- Fullbright
local fullbright = false
VisualTab:Toggle({ Title = "Fullbright", Callback = function(state) fullbright = state end })

local originalAmbient = Lighting.Ambient
local originalBrightness = Lighting.Brightness

RunService.Heartbeat:Connect(function()
    if fullbright then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
    end
end)

-- [[ PLAYER LIST ]] --
local selectedPlayer = ""
local function getPlayers()
    local tbl = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(tbl, p.Name) end
    end
    return tbl
end

local PlayerDrop = PlayerTab:Dropdown({
    Title = "Select Player",
    Options = getPlayers(),
    Callback = function(v) selectedPlayer = v end
})

PlayerTab:Button({ Title = "Refresh Player List", Callback = function() PlayerDrop:SetOptions(getPlayers()) end })
PlayerTab:Button({ Title = "Teleport", Callback = function()
    local target = Players:FindFirstChild(selectedPlayer)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then 
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame 
        end
    end
end })

PlayerTab:Button({ Title = "Spectate", Callback = function()
    local target = Players:FindFirstChild(selectedPlayer)
    if target and target.Character and target.Character:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
    end
end })

PlayerTab:Button({ Title = "Unspectate", Callback = function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = char.Humanoid
    end
end })

Window:Notify({ Title = "Terehub V10", Content = "Script Loaded Successfully!", Duration = 5 })

