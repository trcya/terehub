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
    HideSearchBar = false, 
    ScrollBarEnabled = true,
    })

-- [[ TABS ]] --
local MainTab = Window:CreateTab({ Title = "Main", Icon = "zap" }) -- Diubah ke CreateTab sesuai WindUI terbaru
local CombatTab = Window:CreateTab({ Title = "Combat", Icon = "crosshair" })
local VisualTab = Window:CreateTab({ Title = "Visuals", Icon = "eye" })
local PlayerTab = Window:CreateTab({ Title = "Players", Icon = "users" })

-- [[ VARIABLES ]] --
local autoSkillCheck = false
local autoGen = false
local autoAim = false
local espActive = false
local espGenPallet = false

-- [[ MAIN: AUTO GENERATOR & SKILL CHECK ]] --
local mainSection = MainTab:CreateSection("Automation")

mainSection:AddToggle({
    Title = "Auto Perfect Skill Check",
    Default = true,
    Callback = function(state) autoSkillCheck = state end
})

mainSection:AddToggle({
    Title = "Full Auto Generator",
    Description = "Teleport & Repair Otomatis",
    Callback = function(state) autoGen = state end
})

-- Logic Auto Skill Check
task.spawn(function()
    while true do
        if autoSkillCheck then
            local pGui = player:FindFirstChild("PlayerGui")
            if pGui then
                for _, v in pairs(pGui:GetDescendants()) do
                    if v.Name == "Pointer" or v.Name == "Needle" then 
                        local successZone = v.Parent:FindFirstChild("SuccessZone") or v.Parent:FindFirstChild("WhiteArea")
                        if successZone and math.abs(v.Rotation - successZone.Rotation) < 6 then
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                            task.wait(0.01)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                            task.wait(0.2)
                        end
                    end
                end
            end
        end
        task.wait()
    end
end)

-- Logic Auto Generator Teleport
task.spawn(function()
    while true do
        if autoGen and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v.Name:lower():find("generator") then
                    local part = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
                    if part then
                        player.Character.HumanoidRootPart.CFrame = part.CFrame * CFrame.new(0, 3, 0)
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt then fireproximityprompt(prompt) end
                        break
                    end
                end
            end
        end
        task.wait(1)
    end
end)

-- [[ COMBAT: AUTO AIM KILLER ]] --
local combatSection = CombatTab:CreateSection("Targeting")

combatSection:AddToggle({
    Title = "Auto Aim (Target Killer)",
    Callback = function(state) autoAim = state end
})

RunService.RenderStepped:Connect(function()
    if autoAim then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                if p.Team and (p.Team.Name:find("Killer") or p.Team.Name:find("Murderer")) then
                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, p.Character.Head.Position)
                end
            end
        end
    end
end)

-- [[ VISUALS: ESP ]] --
local visualSection = VisualTab:CreateSection("ESP Settings")

visualSection:AddToggle({
    Title = "ESP Players (Team Color)",
    Callback = function(state) espActive = state end
})

visualSection:AddToggle({
    Title = "ESP Generator & Pallet",
    Callback = function(state) espGenPallet = state end
})

-- ESP Logic Loop
RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local h = p.Character:FindFirstChild("TereHighlight")
            if espActive then
                if not h then
                    h = Instance.new("Highlight", p.Character)
                    h.Name = "TereHighlight"
                end
                local isKiller = p.Team and (p.Team.Name:find("Killer") or p.Team.Name:find("Murderer"))
                h.FillColor = isKiller and Color3.new(1,0,0) or Color3.new(1,1,1)
            elseif h then h:Destroy() end
        end
    end
    
    if espGenPallet then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.Name:lower():find("generator") or v.Name:lower():find("pallet") then
                if not v:FindFirstChild("ObjectHighlight") then
                    local h = Instance.new("Highlight", v)
                    h.Name = "ObjectHighlight"
                    h.FillColor = v.Name:lower():find("generator") and Color3.new(1,1,0) or Color3.new(1,0,1)
                end
            end
        end
    end
end)

-- [[ PLAYERS: TELEPORT ]] --
local playerSection = PlayerTab:CreateSection("Player List")
local selectedPlayer = ""

local function getPlayers()
    local tbl = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then table.insert(tbl, p.Name) end
    end
    return tbl
end

local PlayerDrop = playerSection:AddDropdown({
    Title = "Select Player",
    Values = getPlayers(),
    Callback = function(v) selectedPlayer = v end
})

playerSection:AddButton({ Title = "Refresh List", Callback = function() PlayerDrop:SetValues(getPlayers()) end })
playerSection:AddButton({ Title = "Teleport", Callback = function()
    local target = Players:FindFirstChild(selectedPlayer)
    if target and target.Character then player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame end
end })

Window:Notify({ Title = "Terehub V10", Content = "Script Ready, David!", Duration = 5 })