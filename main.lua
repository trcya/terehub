-- =====================================================
-- ROBLOX ANTI-CHEAT TESTING SUITE - DEVELOPER MODE
-- HANYA UNTUK GAME SENDIRI - JANGAN GUNAKAN DI GAME ORANG LAIN
-- =====================================================
-- Execute di executor (Wave, Krnl, Ronin, dll) - Dijamin work
-- =====================================================

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Konfirmasi Developer (GANTI DENGAN USERNAME ANDA!)
local DEVELOPER_USERNAME = "YourUsernameHere" -- <<< GANTI INI!
local IS_DEVELOPER = Player.Name == DEVELOPER_USERNAME or Player.DisplayName == DEVELOPER_USERNAME

if not IS_DEVELOPER then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "❌ ACCESS DENIED",
        Text = "Script ini HANYA untuk developer game.",
        Duration = 5
    })
    return
end

-- =====================================================
-- 1. HOOK DETECTION TEST (Anti-getrawmetatable / hookfunction)
-- =====================================================
local function Test_HookDetection()
    local success, result = pcall(function()
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local old_namecall = mt.__namecall
        mt.__namecall = function(...)
            return old_namecall(...)
        end
        return "✅ Berhasil hook metatable"
    end)
    
    warn("[TEST] Hook Detection:", success and result or "❌ Gagal")
end

-- =====================================================
-- 2. SPEED HACK TEST
-- =====================================================
local function Test_SpeedHack()
    local originalSpeed = Humanoid.WalkSpeed
    Humanoid.WalkSpeed = 120
    task.wait(2)
    Humanoid.WalkSpeed = originalSpeed
    warn("[TEST] Speed Hack: Set ke 120 selama 2 detik")
end

-- =====================================================
-- 3. FLY / BODY MOVER TEST
-- =====================================================
local function Test_FlyHack()
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 75, 0)
    bv.Parent = RootPart
    task.wait(2)
    bv:Destroy()
    warn("[TEST] Fly Hack: BodyVelocity ke atas")
end

-- =====================================================
-- 4. NOCLIP TEST
-- =====================================================
local function Test_Noclip()
    local noclip = true
    local steptime = 0
    game:GetService("RunService").Stepped:Connect(function()
        if noclip then
            steptime = steptime + 1
            if steptime < 100 then -- hanya 100 step (~2 detik)
                for _, v in pairs(Character:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then
                        v.CanCollide = false
                    end
                end
            else
                noclip = false
            end
        end
    end)
    warn("[TEST] Noclip: Active for ~2 seconds")
end

-- =====================================================
-- 5. REMOTE SPAM TEST (Honeypot)
-- =====================================================
local function Test_RemoteSpam()
    local remote = Instance.new("RemoteEvent")
    remote.Name = "TestHoneypot_" .. tostring(math.random(1000, 9999))
    remote.Parent = game:GetService("ReplicatedStorage")
    
    for i = 1, 50 do
        remote:FireServer("SPAM_TEST", i)
        task.wait(0.01)
    end
    warn("[TEST] Remote Spam: 50 events fired")
end

-- =====================================================
-- 6. TELEPORT DETECTION TEST
-- =====================================================
local function Test_Teleport()
    local originalPos = RootPart.CFrame
    RootPart.CFrame = CFrame.new(0, 500, 0)
    task.wait(0.5)
    RootPart.CFrame = originalPos
    warn("[TEST] Teleport: Pindah ke 0,500,0")
end

-- =====================================================
-- 7. INFINITE JUMP TEST
-- =====================================================
local function Test_InfiniteJump()
    local jumps = 0
    local connection = game:GetService("UserInputService").JumpRequest:Connect(function()
        jumps = jumps + 1
        if jumps <= 20 then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        else
            connection:Disconnect()
        end
    end)
    
    for i = 1, 20 do
        task.wait(0.05)
        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.01)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end
    warn("[TEST] Infinite Jump: 20x jump dalam 1 detik")
end

-- =====================================================
-- 8. DUMP SCRIPT / DECOMPILE TEST
-- =====================================================
local function Test_ScriptDump()
    local success, result = pcall(function()
        local acScript = game:GetService("ServerScriptService"):FindFirstChild("AntiCheat")
        if acScript and acScript:IsA("BaseScript") then
            local code = decompile(acScript)
            return "✅ Script ditemukan, panjang: " .. #code
        else
            return "❌ Script anti-cheat tidak ditemukan"
        end
    end)
    warn("[TEST] Script Dump:", success and result or "❌ decompile tidak tersedia")
end

-- =====================================================
-- EKSEKUSI MENU
-- =====================================================
local Notify = function(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 3
    })
end

Notify("🧪 ANTI-CHEAT TEST", "Memulai tes keamanan...")

task.wait(1)

-- Run semua test
Test_HookDetection()
task.wait(0.5)
Test_SpeedHack()
task.wait(2.5)
Test_FlyHack()
task.wait(2.5)
Test_Noclip()
task.wait(2.5)
Test_RemoteSpam()
task.wait(1)
Test_Teleport()
task.wait(1)
Test_InfiniteJump()
task.wait(2)
Test_ScriptDump()

Notify("✅ TEST SELESAI", "Cek output console (F9) untuk hasil")
warn("========== ANTI-CHEAT TEST COMPLETE ==========")
warn("Jika anti-cheat Anda bekerja dengan baik, Anda harus:")
warn("1. DIKICK atau DIBAN dari server")
warn("2. Atau violation points bertambah")
warn("3. Atau movement di-reset")
warn("==============================================")