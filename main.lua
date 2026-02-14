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


   local AutoTab = Window:Tab({ Title = "Automation", Icon = "cpu" })
local VisualTab = Window:Tab({ Title = "Visuals", Icon = "eye" })

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

-- [[ VISUALS: ESP KILLER RED ]] --
local espActive = false
VisualTab:Toggle({ Title = "ESP Killer & Survivor", Callback = function(s) espActive = s end })

game:GetService("RunService").RenderStepped:Connect(function()
    if espActive then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                local color = (p.Team and (p.Team.Name:find("Killer") or p.Team.Name:find("Murderer"))) and Color3.fromRGB(255,0,0) or Color3.fromRGB(255,255,255)
                local h = p.Character:FindFirstChild("Highlight") or Instance.new("Highlight", p.Character)
                h.FillColor = color
            end
        end
    end
end)

Window:Notify({ Title = "Terehub V10", Content = "Auto Skill Check Aktif!", Duration = 5 })