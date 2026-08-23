local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Player = Players.LocalPlayer

-- Menyimpan Nama Asli Roblox
local REAL_DISPLAY_NAME = Player.DisplayName
local REAL_USERNAME = Player.Name

-- State & Variables Fake Name
local fakeNameEnabled = false
local fakeDisplayName = "Anonymous"
local fakeUsername = "User123"

-- Koordinat Teleport
local DEFAULT_RESTOCK_POS = Vector3.new(166.10043334960938, 4.488986968994141, -147.11224365234375)
local WHEEL_POS = Vector3.new(-161.6514434814453, 7.668628692626953, -127.3036117553711)

local customSavedCFrame = nil
local customPosName = "Posisi Kustom"

-- State Auto TP DIPISAH
local autoTPShopEnabled = false
local autoTPWheelEnabled = false

local isTeleporting = false
local lastShopTP = 0
local lastWheelTP = 0
local COOLDOWN_TIME = 10

-- =========================================================================
-- 1. SETUP WINDOW & TAB UI
-- =========================================================================
local Window = WindUI:CreateWindow({
    Title = "Shop & Wheel Auto Tracker",
    Icon = "clock",
    Folder = "RestockTracker",
    Size = UDim2.fromOffset(420, 720),
    Transparent = true,
    Theme = "Dark"
})

Window:EditOpenButton({
    Title = "Restock UI [-]",
    Icon = "clock",
    CornerRadius = UDim.new(0, 30),
    StrokeThickness = 1.5,
    Color = ColorSequence.new(Color3.fromHex("87CEFA"), Color3.fromHex("191970")),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Minus then
        Window:Toggle()
    end
end)

-- TAB 1: RESTOCK & POSITION
local timerTab = Window:Tab({ Title = "Timer & Position", Icon = "timer", Locked = false })

local timerSec = timerTab:Section({ Title = "Live Restock Tracker", TextSize = 20 })

-- Toggle 1: Khusus Restock Shop (Main, Potion, & Merchant)
timerSec:Toggle({
    Title = "Auto TP Shop Restock",
    Desc = "Teleport ke Main / Potion / Merchant Shop saat restock",
    Value = false,
    Callback = function(state)
        autoTPShopEnabled = state
    end
})

-- Toggle 2: Khusus Wheel Spin
timerSec:Toggle({
    Title = "Auto TP & Claim Wheel Spin",
    Desc = "Teleport ke Wheel, Auto Claim, Spin, & Kembali",
    Value = false,
    Callback = function(state)
        autoTPWheelEnabled = state
    end
})

local RestockPara = timerSec:Paragraph({ Title = "🛒 Main Shop:", Desc = "--:--" })
local PotionPara = timerSec:Paragraph({ Title = "🧪 Potion Shop:", Desc = "--:--" })
local MerchantPara = timerSec:Paragraph({ Title = "🧙‍♂️ Merchant Shop:", Desc = "--:--" })
local WheelPara = timerSec:Paragraph({ Title = "🎡 Wheel Spin:", Desc = "--:--" })

local posSec = timerTab:Section({ Title = "Kontrol Posisi Karakter", TextSize = 20 })

local posStatusPara = posSec:Paragraph({
    Title = "📍 Status Posisi Kembali:",
    Desc = "Menggunakan posisi otomatis."
})

posSec:Input({
    Title = "✏️ Nama Posisi Kustom",
    Desc = "Ketik nama/label titik posisi",
    Value = "Spot Saya",
    Placeholder = "Ketik nama lokasi...",
    Callback = function(text)
        customPosName = (text and text ~= "") and text or "Posisi Kustom"
    end
})

posSec:Button({
    Title = "💾 Save Posisi Saat Ini",
    Callback = function()
        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            customSavedCFrame = root.CFrame
            local pos = root.Position
            posStatusPara:SetTitle("📍 Status Posisi Kembali: [" .. string.upper(customPosName) .. "]")
            posStatusPara:SetDesc(string.format("Tersimpan (%s): X: %.1f, Y: %.1f, Z: %.1f", customPosName, pos.X, pos.Y, pos.Z))
            
            WindUI:Notify({ Title = "Posisi Disimpan!", Content = "Lokasi '" .. customPosName .. "' berhasil disimpan.", Duration = 3 })
        end
    end
})

posSec:Button({
    Title = "🔄 Reset Posisi",
    Callback = function()
        customSavedCFrame = nil
        posStatusPara:SetTitle("📍 Status Posisi Kembali: [DEFAULT]")
        posStatusPara:SetDesc("Menggunakan posisi otomatis (posisi saat TP dipicu).")
        WindUI:Notify({ Title = "Posisi Direset!", Content = "Kembali ke mode posisi otomatis.", Duration = 3 })
    end
})

-- TAB 2: VISUAL & STREAMER MODE (FAKE NAME)
local visualTab = Window:Tab({ Title = "Visual & Name", Icon = "user-check", Locked = false })
local nameSec = visualTab:Section({ Title = "Sensor / Visual Name Changer", TextSize = 20 })

nameSec:Toggle({
    Title = "Enable Fake Name (Sensor)",
    Desc = "Ubah tampilan nama Anda secara visual di client/layar Anda",
    Value = false,
    Callback = function(state)
        fakeNameEnabled = state
        if not state then
            pcall(function() Player.DisplayName = REAL_DISPLAY_NAME end)
            WindUI:Notify({ Title = "Visual Name Off", Content = "Nama kembali ke tampilan asli.", Duration = 2 })
        else
            WindUI:Notify({ Title = "Visual Name Active", Content = "Nama berhasil disensor/diubah.", Duration = 2 })
        end
    end
})

nameSec:Input({
    Title = "Fake Display Name",
    Value = "Anonymous",
    Placeholder = "Ketik Display Name...",
    Callback = function(text)
        fakeDisplayName = (text and text ~= "") and text or "Anonymous"
    end
})

nameSec:Input({
    Title = "Fake Username (@)",
    Value = "User123",
    Placeholder = "Ketik Username...",
    Callback = function(text)
        fakeUsername = (text and text ~= "") and text or "User123"
    end
})

-- =========================================================================
-- 2. HELPER FUNCTIONS & TELEPORT LOGIC
-- =========================================================================
local function applyFakeName()
    if not fakeNameEnabled then return end

    pcall(function() Player.DisplayName = fakeDisplayName end)

    local pGui = Player:FindFirstChild("PlayerGui")
    if pGui then
        for _, guiObj in ipairs(pGui:GetDescendants()) do
            if guiObj:IsA("TextLabel") or guiObj:IsA("TextButton") then
                if guiObj.Text:find(REAL_DISPLAY_NAME) then
                    guiObj.Text = guiObj.Text:gsub(REAL_DISPLAY_NAME, fakeDisplayName)
                end
                if guiObj.Text:find(REAL_USERNAME) then
                    guiObj.Text = guiObj.Text:gsub(REAL_USERNAME, fakeUsername)
                end
            end
        end
    end

    local char = Player.Character
    if char then
        for _, guiObj in ipairs(char:GetDescendants()) do
            if guiObj:IsA("TextLabel") then
                if guiObj.Text:find(REAL_DISPLAY_NAME) then
                    guiObj.Text = guiObj.Text:gsub(REAL_DISPLAY_NAME, fakeDisplayName)
                end
                if guiObj.Text:find(REAL_USERNAME) then
                    guiObj.Text = guiObj.Text:gsub(REAL_USERNAME, fakeUsername)
                end
            end
        end
    end
end

-- Deteksi pintar apakah waktu sudah ready / 0
local function isTimerReady(timeStr)
    if not timeStr or timeStr == "" then return false end
    
    local cleanStr = timeStr:gsub("<[^>]+>", ""):upper()
    
    -- Cek kata kunci umum jika timer siap
    if cleanStr:find("READY") or cleanStr:find("FREE") or cleanStr:find("CLAIM") or cleanStr:find("SPIN") or cleanStr:find("RESTOCK") then
        return true
    end
    
    -- Cek durasi angka
    local numbers = {}
    for num in cleanStr:gmatch("%d+") do 
        table.insert(numbers, tonumber(num)) 
    end
    
    if #numbers > 0 then
        local totalSec = 0
        if #numbers == 3 then totalSec = (numbers[1] * 3600) + (numbers[2] * 60) + numbers[3]
        elseif #numbers == 2 then totalSec = (numbers[1] * 60) + numbers[2]
        elseif #numbers == 1 then totalSec = numbers[1] end
        
        return totalSec == 0
    end
    
    return false
end

-- Teleport untuk Main Shop, Potion Shop, & Merchant Restock
local function teleportToRestockAndBack()
    if isTeleporting or (os.time() - lastShopTP) < COOLDOWN_TIME then return end

    isTeleporting = true
    lastShopTP = os.time()

    local char = Player.Character
    if not char then isTeleporting = false return end

    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    if root and humanoid and humanoid.Health > 0 then
        local targetReturnCFrame = customSavedCFrame or root.CFrame

        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero

        char:PivotTo(CFrame.new(DEFAULT_RESTOCK_POS))
        
        task.wait(1.5)

        local updatedChar = Player.Character
        if updatedChar then
            local updatedRoot = updatedChar:FindFirstChild("HumanoidRootPart")
            local updatedHumanoid = updatedChar:FindFirstChildOfClass("Humanoid")

            if updatedRoot and updatedHumanoid and updatedHumanoid.Health > 0 then
                updatedRoot.AssemblyLinearVelocity = Vector3.zero
                updatedRoot.AssemblyAngularVelocity = Vector3.zero
                updatedChar:PivotTo(targetReturnCFrame)
            end
        end
    end

    isTeleporting = false
end

-- Teleport Khusus Wheel Spin & Eksekusi Remotes
local function teleportToWheelAndSpin()
    if isTeleporting or (os.time() - lastWheelTP) < COOLDOWN_TIME then return end

    isTeleporting = true
    lastWheelTP = os.time()

    local char = Player.Character
    if not char then isTeleporting = false return end

    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    if root and humanoid and humanoid.Health > 0 then
        local targetReturnCFrame = customSavedCFrame or root.CFrame

        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero

        -- 1. TP ke Koordinat Wheel
        char:PivotTo(CFrame.new(WHEEL_POS))
        task.wait(1)

        -- 2. Eksekusi Remote Events Wheel (Claim -> Spin -> Finish)
        pcall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local wheelRemote = remotes and remotes:FindFirstChild("Wheel")
            
            if wheelRemote then
                wheelRemote:InvokeServer("ClaimFree")
                task.wait(0.5)

                wheelRemote:InvokeServer("Spin")
                task.wait(1)

                wheelRemote:InvokeServer("FinishSpin")
                task.wait(0.5)
            end
        end)

        task.wait(0.5)

        -- 3. Teleport Kembali ke Posisi Awal/Saved
        local updatedChar = Player.Character
        if updatedChar then
            local updatedRoot = updatedChar:FindFirstChild("HumanoidRootPart")
            local updatedHumanoid = updatedChar:FindFirstChildOfClass("Humanoid")

            if updatedRoot and updatedHumanoid and updatedHumanoid.Health > 0 then
                updatedRoot.AssemblyLinearVelocity = Vector3.zero
                updatedRoot.AssemblyAngularVelocity = Vector3.zero
                updatedChar:PivotTo(targetReturnCFrame)
            end
        end
    end

    isTeleporting = false
end

-- =========================================================================
-- 3. MAIN LOOP (TIMER & VISUAL UPDATER)
-- =========================================================================
task.spawn(function()
    while task.wait(0.2) do
        applyFakeName()

        pcall(function()
            local pGui = Player:FindFirstChild("PlayerGui")
            local mainUI = pGui and pGui:FindFirstChild("Main")
            local canvas = mainUI and mainUI:FindFirstChild("Canvas")
            
            -- Map Shops (Main & Potion)
            local mapShops = canvas and canvas:FindFirstChild("MapShops")
            local shopMain = mapShops and mapShops:FindFirstChild("Main")
            local timerLabelMain = shopMain and shopMain:FindFirstChild("Timer") and shopMain.Timer:FindFirstChild("Timer")

            local shopPotion = mapShops and mapShops:FindFirstChild("Potion")
            local timerLabelPotion = shopPotion and shopPotion:FindFirstChild("Timer") and shopPotion.Timer:FindFirstChild("Timer")

            -- Merchant Shop (Disesuaikan dengan Path Baru)
            local shopMerchant = canvas and canvas:FindFirstChild("Merchant")
            local timerLabelMerchant = shopMerchant and shopMerchant:FindFirstChild("Main") and shopMerchant.Main:FindFirstChild("Timer") and shopMerchant.Main.Timer:FindFirstChild("Timer")

            -- Wheel Spin
            local wheelObj = canvas and canvas:FindFirstChild("Wheel")
            local wheelSpin = wheelObj and wheelObj:FindFirstChild("Main") and wheelObj.Main:FindFirstChild("Spin")
            local wheelTimerObj = wheelSpin and wheelSpin:FindFirstChild("Timer")

            -- Ambil Teks Timer
            local mainText = (timerLabelMain and timerLabelMain:IsA("TextLabel")) and timerLabelMain.Text or ""
            local potionText = (timerLabelPotion and timerLabelPotion:IsA("TextLabel")) and timerLabelPotion.Text or ""
            local merchantText = (timerLabelMerchant and timerLabelMerchant:IsA("TextLabel")) and timerLabelMerchant.Text or ""
            
            local wheelText = ""
            if wheelTimerObj then
                if wheelTimerObj:IsA("TextLabel") then
                    wheelText = wheelTimerObj.Text
                elseif wheelTimerObj:FindFirstChild("Timer") and wheelTimerObj.Timer:IsA("TextLabel") then
                    wheelText = wheelTimerObj.Timer.Text
                end
            end

            -- Update UI Status Paragraphs
            if mainText ~= "" then
                RestockPara:SetTitle("🛒 Main Shop Restock In:")
                RestockPara:SetDesc("<b><font size='24'>" .. mainText .. "</font></b>")
            else
                RestockPara:SetTitle("⚠️ Main Shop:")
                RestockPara:SetDesc("Menu Tutup / Nonaktif")
            end

            if potionText ~= "" then
                PotionPara:SetTitle("🧪 Potion Shop Restock In:")
                PotionPara:SetDesc("<b><font size='24'>" .. potionText .. "</font></b>")
            else
                PotionPara:SetTitle("⚠️ Potion Shop:")
                PotionPara:SetDesc("Menu Tutup / Nonaktif")
            end

            if merchantText ~= "" then
                MerchantPara:SetTitle("🧙‍♂️ Merchant Shop Restock In:")
                MerchantPara:SetDesc("<b><font size='24'>" .. merchantText .. "</font></b>")
            else
                MerchantPara:SetTitle("⚠️ Merchant Shop:")
                MerchantPara:SetDesc("Menu Tutup / Nonaktif")
            end

            if wheelText ~= "" then
                WheelPara:SetTitle("🎡 Wheel Spin Ready In:")
                WheelPara:SetDesc("<b><font size='24'>" .. wheelText .. "</font></b>")
            else
                WheelPara:SetTitle("⚠️ Wheel Spin:")
                WheelPara:SetDesc("Menu Tutup / Nonaktif")
            end

            -- Trigger Auto TP Shop Restock (Main, Potion, & Merchant)
            if autoTPShopEnabled then
                if isTimerReady(mainText) or isTimerReady(potionText) or isTimerReady(merchantText) then
                    task.spawn(teleportToRestockAndBack)
                end
            end

            -- Trigger Auto TP Wheel Spin
            if autoTPWheelEnabled then
                if isTimerReady(wheelText) then
                    task.spawn(teleportToWheelAndSpin)
                end
            end
        end)
    end
end)