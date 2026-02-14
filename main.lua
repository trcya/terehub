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
        if autoGen and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- Mencari Generator terdekat di Workspace
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name:lower():find("generator") then
                    local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                    
                    if targetPart then
                        -- Teleport ke Generator
                        player.Character.HumanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, 3, 0)
                        
                        -- Otomatis tekan 'E' atau ProximityPrompt
                        local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then
                            fireproximityprompt(prompt)
                        end
                        break -- Berhenti di satu generator saja sampai selesai
                    end
                end
            end
        end
        task.wait(1) -- Scan generator setiap 1 detik
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