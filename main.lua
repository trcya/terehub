-- =====================================================
// ANTI-CHEAT STRESS TEST - EXECUTOR VERSION
// TIDAK ADA RESTRIKSI DEVELOPER - BISA PAKAI AKUN APAPUN
// =====================================================

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ==================== KONFIGURASI TEST ====================
local CONFIG = {
    SPEED_ENABLED = true,
    FLY_ENABLED = true,
    NOCLIP_ENABLED = true,
    REMOTE_SPAM_ENABLED = true,
    TELEPORT_ENABLED = true,
    INFJUMP_ENABLED = true,
    HOOK_ENABLED = true,
    
    -- Durasi test (detik)
    DURATION = 3,
    
    -- Notifikasi
    SHOW_NOTIFICATION = true
}

-- ==================== UTILITY FUNCTIONS ====================
local function Notify(msg)
    if CONFIG.SHOW_NOTIFICATION then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🧪 ANTI-CHEAT TEST",
            Text = msg,
            Duration = 2
        })
    end
    warn("[TEST] " .. msg)
end

-- ==================== 1. SPEED HACK ====================
local function RunSpeedHack()
    if not CONFIG.SPEED_ENABLED then return end
    
    Notify("Speed Hack: 120 WalkSpeed")
    local original = Humanoid.WalkSpeed
    Humanoid.WalkSpeed = 120
    task.wait(CONFIG.DURATION)
    Humanoid.WalkSpeed = original
end

-- ==================== 2. FLY HACK ====================
local function RunFlyHack()
    if not CONFIG.FLY_ENABLED then return end
    
    Notify("Fly Hack: BodyVelocity")
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 70, 0)
    bv.Parent = RootPart
    task.wait(CONFIG.DURATION)
    bv:Destroy()
end

-- ==================== 3. NOCLIP ====================
local function RunNoclip()
    if not CONFIG.NOCLIP_ENABLED then return end
    
    Notify("Noclip: 3 detik")
    local connection
    connection = game:GetService("RunService").Stepped:Connect(function()
        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end)
    
    task.wait(CONFIG.DURATION)
    connection:Disconnect()
end

-- ==================== 4. REMOTE SPAM ====================
local function RunRemoteSpam()
    if not CONFIG.REMOTE_SPAM_ENABLED then return end
    
    Notify("Remote Spam: 100 events")
    
    -- Cari semua RemoteEvent/Function di ReplicatedStorage
    local remotes = {}
    for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            table.insert(remotes, v)
        end
    end
    
    -- Spam remote pertama yang ditemukan
    if #remotes > 0 then
        local remote = remotes[1]
        for i = 1, 100 do
            pcall(function()
                remote:FireServer("ANTICHEAT_TEST_" .. i, math.random(1, 9999))
            end)
            task.wait(0.01)
        end
    end
end

-- ==================== 5. TELEPORT ====================
local function RunTeleport()
    if not CONFIG.TELEPORT_ENABLED then return end
    
    Notify("Teleport: 500 stud ke atas")
    local original = RootPart.CFrame
    RootPart.CFrame = CFrame.new(original.X, original.Y + 500, original.Z)
    task.wait(0.5)
    RootPart.CFrame = original
end

-- ==================== 6. INFINITE JUMP ====================
local function RunInfiniteJump()
    if not CONFIG.INFJUMP_ENABLED then return end
    
    Notify("Infinite Jump: 30x jump")
    local jumps = 0
    local connection = game:GetService("UserInputService").JumpRequest:Connect(function()
        jumps = jumps + 1
        if jumps <= 30 then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        else
            connection:Disconnect()
        end
    end)
    
    -- Simulate spacebar spam
    for i = 1, 30 do
        task.wait(0.03)
        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.01)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end
end

-- ==================== 7. HOOK DETECTION ====================
local function RunHookTest()
    if not CONFIG.HOOK_ENABLED then return end
    
    Notify("Hook Test: getrawmetatable")
    local success = pcall(function()
        local mt = getrawmetatable(game)
        if mt then
            setreadonly(mt, false)
            local old = mt.__namecall
            mt.__namecall = function(...)
                return old(...)
            end
        end
    end)
    
    if success then
        warn("[HOOK] Berhasil - Anti-cheat harusnya deteksi")
    else
        warn("[HOOK] Gagal - Mungkin sudah di-protect")
    end
end

-- ==================== 8. TOOLS DETECTION ====================
local function RunToolCheck()
    Notify("Memeriksa anti-cheat...")
    
    -- Cek apakah ada anti-cheat script
    local acDetected = false
    local acNames = {"AntiCheat", "AC", "Security", "Moderator", "KickSystem", "BanSystem", "Admin", "Adonis"}
    
    for _, name in pairs(acNames) do
        local sc = game:GetService("ServerScriptService"):FindFirstChild(name)
        local sg = game:GetService("ServerStorage"):FindFirstChild(name)
        if sc or sg then
            acDetected = true
            warn("[ANTI-CHEAT] Terdeteksi: " .. name)
        end
    end
    
    if not acDetected then
        warn("[ANTI-CHEAT] TIDAK TERDETEKSI - Game ini mungkin tidak punya anti-cheat")
    end
end

-- ==================== EKSEKUSI ====================
Notify("MULAI TEST ANTI-CHEAT")
warn("========== ANTI-CHEAT STRESS TEST ==========")
warn("Player: " .. Player.Name)
warn("Server: " .. game.JobId)
warn("============================================")

task.wait(1)

-- JALANKAN SEMUA TEST
RunToolCheck()
task.wait(0.5)

-- Urutan: dari yang paling obvious ke stealthy
RunSpeedHack()
task.wait(1)

RunFlyHack()
task.wait(1)

RunNoclip()
task.wait(1)

RunTeleport()
task.wait(1)

RunInfiniteJump()
task.wait(1)

RunRemoteSpam()
task.wait(1)

RunHookTest()

-- Final report
task.wait(1)
warn("========== TEST SELESAI ==========")
warn("✓ Speed Hack: Selesai")
warn("✓ Fly Hack: Selesai") 
warn("✓ Noclip: Selesai")
warn("✓ Teleport: Selesai")
warn("✓ Infinite Jump: Selesai")
warn("✓ Remote Spam: Selesai")
warn("✓ Hook Test: Selesai")
warn("==================================")
warn("CEK SERVER LOG: Apakah Anda di-kick?")
warn("Jika TIDAK di-kick, anti-cheat Anda BOCOR")