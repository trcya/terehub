-- [[ terecya | Anti-Cheat Stress Test ]] --
-- Versi Publik: Tanpa Restriksi Developer

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ==================== KONFIGURASI ====================
local DURATION = 3 -- Lama setiap test berjalan

local function Notify(msg)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🧪 TEST: " .. Player.Name,
        Text = msg,
        Duration = 3
    })
    print("[TEST] " .. msg)
end

-- ==================== 1. SPEED TEST ====================
local function RunSpeed()
    Notify("Testing Speed (WalkSpeed = 150)")
    local oldSpeed = Humanoid.WalkSpeed
    Humanoid.WalkSpeed = 150
    task.wait(DURATION)
    Humanoid.WalkSpeed = oldSpeed
end

-- ==================== 2. FLY TEST ====================
local function RunFly()
    Notify("Testing Fly (BodyVelocity)")
    local bv = Instance.new("BodyVelocity")
    bv.Name = "Test_Fly"
    bv.Velocity = Vector3.new(0, 50, 0)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Parent = RootPart
    task.wait(DURATION)
    bv:Destroy()
end

-- ==================== 3. TELEPORT TEST ====================
local function RunTP()
    Notify("Testing Teleport (500 Studs Up)")
    local originalPos = RootPart.CFrame
    RootPart.CFrame = originalPos * CFrame.new(0, 500, 0)
    task.wait(1)
    RootPart.CFrame = originalPos
end

-- ==================== 4. NOCLIP TEST ====================
local function RunNoclip()
    Notify("Testing Noclip (Stepped Loop)")
    local startTime = tick()
    local connection
    connection = game:GetService("RunService").Stepped:Connect(function()
        if tick() - startTime > DURATION then
            connection:Disconnect()
            Notify("Noclip Selesai")
        else
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end

-- ==================== 5. REMOTE SPAM ====================
local function RunRemoteSpam()
    Notify("Testing Remote Spam...")
    -- Mencari Remote di ReplicatedStorage (yang biasanya ada di map)
    for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if v:IsA("RemoteEvent") then
            for i = 1, 50 do
                v:FireServer("STRESS_TEST", math.random(1, 1000))
            end
            break -- Spam satu remote saja sebagai sample
        end
    end
end

-- ==================== EKSEKUSI OTOMATIS ====================
task.spawn(function()
    Notify("MEMULAI STRESS TEST DALAM 3 DETIK")
    task.wait(3)
    
    RunSpeed()
    task.wait(2)
    
    RunFly()
    task.wait(2)
    
    RunTP()
    task.wait(2)
    
    RunNoclip()
    task.wait(2)
    
    RunRemoteSpam()
    
    Notify("SEMUA TEST SELESAI!")
    warn("Jika kamu TIDAK terdeteksi/kick, berarti Anti-Cheat bocor!")
end)