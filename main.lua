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
    HideSearchBar = false, 
    ScrollBarEnabled = true,
})

-- [[ TABS ]] --
local MainTab = Window:Tab({ Title = "Main", Icon = "home" })
local CombatTab = Window:Tab({ Title = "Combat", Icon = "crosshair" })
local VisualTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local PlayerTab = Window:Tab({ Title = "Players", Icon = "users" })

-- [[ FEATURE: AUTO PERFECT GENERATOR ]] --
local autoSkillCheck = false
AutoTab:Toggle({
    Title = "Auto Perfect Skill Check",
    Callback = function(state)
        autoSkillCheck = state
        if state then
            task.spawn(function()
                while autoSkillCheck do
                    -- Mencari UI Generator/Skill Check di PlayerGui
                    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
                    -- Kita cari baris kode/UI yang menangani jarum (pointer) dan area putih
                    -- Logika: Jika jarum berada di posisi area putih, tekan tombol 'Space' atau 'Click'
                    for _, gui in pairs(playerGui:GetDescendants()) do
                        if gui.Name == "SkillCheck" or gui.Name == "GeneratorUI" then -- Sesuaikan nama UI game
                            local needle = gui:FindFirstChild("Pointer") -- Jarum
                            local whiteArea = gui:FindFirstChild("SuccessZone") -- Area Putih
                            
                            if needle and whiteArea then
                                -- Bandingkan posisi rotasi atau koordinat
                                if math.abs(needle.Rotation - whiteArea.Rotation) < 5 then
                                    -- Simulasi tekan tombol Space
                                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                                    task.wait(0.05)
                                    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                                end
                            end
                        end
                    end
                    task.wait()
                end
            end)
        end
    end
})

-- [[ COMBAT: AUTO AIM KILLER ]] --
local autoAim = false
CombatTab:Toggle({
    Title = "Auto Aim (Target Killer)",
    Callback = function(state) autoAim = state end
})

-- Logic Silent Aim sederhana
task.spawn(function()
    game:GetService("RunService").RenderStepped:Connect(function()
        if autoAim then
            for _, p in pairs(game.Players:GetPlayers()) do
                -- Hanya target yang timnya "Killer" atau "Murderer"
                if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    if p.Team and (string.find(p.Team.Name, "Killer") or string.find(p.Team.Name, "Murderer")) then
                        local cam = game.Workspace.CurrentCamera
                        cam.CFrame = CFrame.new(cam.CFrame.Position, p.Character.Head.Position)
                    end
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
                local color = Color3.fromRGB(255, 255, 255) -- Default Survivor (Putih)
                
                if p.Team and (string.find(p.Team.Name, "Killer") or string.find(p.Team.Name, "Murderer")) then
                    color = Color3.fromRGB(255, 0, 0) -- Killer (Merah)
                end

                -- Highlight
                local h = p.Character:FindFirstChild("Highlight") or Instance.new("Highlight", p.Character)
                h.FillColor = color

                -- ESP Title / Name Tag
                local bb = p.Character:FindFirstChild("TereName")
                if not bb then
                    bb = Instance.new("BillboardGui", p.Character)
                    bb.Name = "TereName"
                    bb.AlwaysOnTop = true
                    bb.Size = UDim2.new(0, 100, 0, 25)
                    bb.ExtentsOffset = Vector3.new(0, 3, 0)
                    local lbl = Instance.new("TextLabel", bb)
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextStrokeTransparency = 0
                end
                bb.TextLabel.Text = p.Name
                bb.TextLabel.TextColor3 = color -- Nama jadi MERAH jika Killer
            end
        end
    end
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

PlayerTab:Button({ 
    Title = "Fix Player List", 
    Callback = function() PlayerDrop:SetOptions(getPlayers()) end 
})

PlayerTab:Button({ 
    Title = "Teleport", 
    Callback = function()
        local target = game.Players:FindFirstChild(selectedPlayer)
        if target and target.Character then 
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame 
        end
    end 
})

Window:Notify({ Title = "Violence District Pro", Content = "David, V9 siap digunakan!", Duration = 5 })

