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


  -- [[ WAJIB: DEFINE SERVICES DI ATAS ]] --
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

-- [[ TABS ]] --
local AutoTab = Window:Tab({ Title = "Automation", Icon = "cpu" })
local VisualTab = Window:Tab({ Title = "Visuals", Icon = "eye" })

-- [[ FEATURE: FULL AUTO GENERATOR ]] --
local autoGen = false
local autoSkillCheck = false

-- 1. Toggle Skill Check (Area Putih)
AutoTab:Toggle({
    Title = "Auto Perfect Skill Check",
    Callback = function(state) autoSkillCheck = state end
})

-- 2. Toggle Teleport & Repair (Yang tadi kamu belum ada)
AutoTab:Toggle({
    Title = "Full Auto Repair Generator",
    Callback = function(state) autoGen = state end
})

-- [[ LOGIC: AUTO SKILL CHECK ]] --
task.spawn(function()
    while true do
        if autoSkillCheck then
            local pGui = player:FindFirstChild("PlayerGui")
            if pGui then
                -- Mencari UI Skill Check secara dinamis
                for _, v in pairs(pGui:GetDescendants()) do
                    if v.Name == "Pointer" or v.Name == "Needle" then 
                        local success = v.Parent:FindFirstChild("SuccessZone") or v.Parent:FindFirstChild("WhiteArea")
                        if success and math.abs(v.Rotation - success.Rotation) < 7 then
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                            task.wait(0.01)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                            task.wait(0.2)
                        end
                    end
                end
            end
        end
        task.wait() -- Minimal wait agar tidak crash
    end
end)

-- [[ LOGIC: TELEPORT & INTERACT GENERATOR ]] --
task.spawn(function()
    while true do
        if autoGen and player.Character then
            -- Cari Generator
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("generator") then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    local target = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                    
                    if hrp and target then
                        -- TELEPORT
                        hrp.CFrame = target.CFrame * CFrame.new(0, 3, 0)
                        
                        -- INTERAKSI (Ini yang bikin support PC & Mobile)
                        local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                        if prompt then
                            fireproximityprompt(prompt) -- Utama untuk Mobile & PC
                        else
                            -- Backup jika game pakai sistem tombol custom
                            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            task.wait(0.1)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        end
                        break
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- [[ VISUALS: ESP KILLER RED ]] --
local espActive = false
VisualTab:Toggle({ Title = "ESP Killer & Survivor", Callback = function(s) espActive = s end })

RunService.RenderStepped:Connect(function()
    if espActive then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local color = (p.Team and (p.Team.Name:find("Killer") or p.Team.Name:find("Murderer"))) and Color3.fromRGB(255,0,0) or Color3.fromRGB(255,255,255)
                local h = p.Character:FindFirstChild("Highlight") or Instance.new("Highlight", p.Character)
                h.FillColor = color
                h.OutlineColor = Color3.new(1,1,1)
            end
        end
    end
end)

Window:Notify({ Title = "Terehub V10", Content = "Auto Generator & Skill Check Ready!", Duration = 5 })