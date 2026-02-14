local MainTab = Window:Tab({ Title = "Movement", Icon = "walking" })
local PlayerTab = Window:Tab({ Title = "Players", Icon = "users" })

-- [[ FIX: ANALOG FLY (Move Direction Based) ]] --
local flyActive = false
local flySpeed = 50
MainTab:Toggle({
    Title = "True Analog Fly",
    Callback = function(state)
        flyActive = state
        local char = game.Players.LocalPlayer.Character
        local humanoid = char:WaitForChild("Humanoid")
        local hrp = char:WaitForChild("HumanoidRootPart")
        
        if state then
            local bv = Instance.new("BodyVelocity", hrp)
            bv.Name = "TereFlyForce"
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            
            task.spawn(function()
                while flyActive do
                    -- Menggunakan MoveDirection (Arah Analog/Keyboard) 
                    -- Jika tidak gerak, tetap melayang di tempat
                    if humanoid.MoveDirection.Magnitude > 0 then
                        bv.Velocity = humanoid.MoveDirection * flySpeed
                    else
                        bv.Velocity = Vector3.new(0, 0, 0)
                    end
                    task.wait()
                end
                bv:Destroy()
            end)
        end
    end
})

MainTab:Slider({
    Title = "Fly Speed",
    Value = { Min = 10, Max = 500, Default = 50 },
    Callback = function(v) flySpeed = v end
})

-- [[ FIX: PLAYER LIST DROPDOWN ]] --
local selectedPlayer = ""
local pList = {}

-- Fungsi untuk ambil data pemain terbaru
local function getPlayers()
    local tbl = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then
            table.insert(tbl, p.Name)
        end
    end
    return tbl
end

local PlayerDropdown = PlayerTab:Dropdown({
    Title = "Select Player",
    Options = getPlayers(), -- Langsung panggil fungsi
    Callback = function(v) selectedPlayer = v end
})

-- Tombol Refresh Manual jika ada yang baru masuk
PlayerTab:Button({
    Title = "Refresh Player List",
    Callback = function()
        local newTable = getPlayers()
        PlayerDropdown:SetOptions(newTable) -- Mengupdate isi dropdown WindUI
        Window:Notify({Title = "System", Content = "Daftar pemain diperbarui!"})
    end
})

PlayerTab:Button({
    Title = "Teleport to Player",
    Callback = function()
        local target = game.Players:FindFirstChild(selectedPlayer)
        if target and target.Character then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end
})

Window:Notify({ Title = "Terehub", Content = "V3 Loaded! Analog Fly & Player Fix.", Duration = 5 })