local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Player = Players.LocalPlayer

-- Menyimpan Nama Asli Roblox
local REAL_DISPLAY_NAME = Player.DisplayName
local REAL_USERNAME = Player.Name

-- State & Variables Fake Name
local fakeNameEnabled = false
local fakeDisplayName = "Anonymous"
local fakeUsername = "User123"

-- Koordinat Lokasi Static (Fallback / Main Shops)
local DICE_SHOP_POS = Vector3.new(180.87811279296875, 4.21789026260376, -144.01097106933594)
local POTION_SHOP_POS = Vector3.new(151.80166625976562, 3.6720831394195557, -137.97610473632812)
local GAMEPASS_BUY_POS = Vector3.new(166.76821899414062, 4.46852970123291, -148.235595703125)
local WHEEL_POS = Vector3.new(-161.6514434814453, 7.668628692626953, -127.3036117553711)

local customSavedCFrame = nil
local customPosName = "Posisi Kustom"

-- State Master Toggle
local autoBuyShopEnabled = false
local autoTPFoodCartEnabled = false
local autoTPMerchantEnabled = false
local autoTPWheelEnabled = false
local antiAFKEnabled = true

-- Lock Control Per-Shop
local diceRestockDone = false
local potionRestockDone = false
local foodCartRestockDone = false
local merchantSpawnDone = false
local wheelRestockDone = false

-- =========================================================================
-- HELPER LOCK TELEPORTASI (MUTEX / QUEUE SAFE)
-- =========================================================================
local isTeleporting = false

local function acquireLock(timeout)
    timeout = timeout or 4
    local start = tick()
    while isTeleporting do
        if tick() - start > timeout then
            return false
        end
        task.wait(0.1)
    end
    isTeleporting = true
    return true
end

local function releaseLock()
    isTeleporting = false
end

-- =========================================================================
-- HELPER TELEPORTASI AMAN (SAFE TELEPORT WITH RETRY & VELOCITY ZEROING)
-- =========================================================================
local function safeTeleport(targetPosOrCFrame, maxRetries)
    if not targetPosOrCFrame then return false end
    maxRetries = maxRetries or 3

    local targetCFrame
    if typeof(targetPosOrCFrame) == "Vector3" then
        targetCFrame = CFrame.new(targetPosOrCFrame)
    elseif typeof(targetPosOrCFrame) == "CFrame" then
        targetCFrame = targetPosOrCFrame
    else
        return false
    end

    local char = Player.Character
    if not char then return false end

    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid or humanoid.Health <= 0 then
        return false
    end

    -- Stand up if sitting
    if humanoid.Sit then
        humanoid.Sit = false
        task.wait(0.1)
    end

    local targetPos = targetCFrame.Position
    for i = 1, maxRetries do
        pcall(function()
            if root:IsA("BasePart") then
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                root.Anchored = true
            end
            
            char:PivotTo(targetCFrame)
            root.CFrame = targetCFrame
            task.wait(0.05)

            if root:IsA("BasePart") then
                root.Anchored = false
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end
        end)

        -- Distance verification (within 15 studs)
        if (root.Position - targetPos).Magnitude <= 15 then
            return true
        end
        task.wait(0.1)
    end

    return false
end

-- =========================================================================
-- HELPER PEMANGGILAN REMOTE AMAN (NON-BLOCKING TASK.SPAWN)
-- =========================================================================
local function safeCallRemote(remoteObj, ...)
    if not remoteObj then return end
    local args = {...}
    task.spawn(function()
        pcall(function()
            if remoteObj:IsA("RemoteFunction") then
                remoteObj:InvokeServer(unpack(args))
            elseif remoteObj:IsA("RemoteEvent") then
                remoteObj:FireServer(unpack(args))
            end
        end)
    end)
end

-- FIRE ALL WHEEL REMOTES
local function executeWheelRemotes()
    task.spawn(function()
        pcall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local wheelRemote = remotes and remotes:FindFirstChild("Wheel")
            
            if wheelRemote then
                safeCallRemote(wheelRemote, "GetState")
                task.wait(0.2)
                safeCallRemote(wheelRemote, "ClaimFree")
                task.wait(0.2)
                safeCallRemote(wheelRemote, "Spin")
            end
        end)
    end)
end

-- FIRE ALL FOOD CART REMOTES & PROMPTS
local function executeFoodCartRemotes(targetObj)
    task.spawn(function()
        pcall(function()
            if targetObj then
                for _, desc in ipairs(targetObj:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") then
                        fireproximityprompt(desc)
                    end
                end
            end
            
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local fcRemote = remotes and (remotes:FindFirstChild("FoodCart") or remotes:FindFirstChild("Food_Cart"))
            if fcRemote then
                safeCallRemote(fcRemote, "Request")
                safeCallRemote(fcRemote, "Buy")
                safeCallRemote(fcRemote, "Claim")
                safeCallRemote(fcRemote, "Open")
            end
        end)
    end)
end

-- FIRE ALL MERCHANT REMOTES & PROMPTS
local function executeMerchantRemotes(targetObj)
    task.spawn(function()
        pcall(function()
            if targetObj then
                for _, desc in ipairs(targetObj:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") then
                        fireproximityprompt(desc)
                    end
                end
            end
            
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local merchantRemote = remotes and (remotes:FindFirstChild("Merchant") or remotes:FindFirstChild("TravellingMerchant"))
            if merchantRemote then
                safeCallRemote(merchantRemote, "Request")
                safeCallRemote(merchantRemote, "RequestShop")
                safeCallRemote(merchantRemote, "BuyAll")
                safeCallRemote(merchantRemote, "Open")
            end
        end)
    end)
end

-- CEK KEPEMILIKAN GAMEPASS AUTO BUY
local function hasAutoBuyGamepass()
    local owned = false
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local gpCheck = remotes and remotes:FindFirstChild("GamepassOwnedCheck")
        if gpCheck and gpCheck:IsA("RemoteFunction") then
            owned = (gpCheck:InvokeServer("AutoBuy") == true or gpCheck:InvokeServer("Auto Buy All") == true)
        end
    end)
    return owned
end

-- LOGIKA TELEPORTASI SHOP (GAMEPASS & NON-GAMEPASS CHECK AUTOMATIC)
local function executeShopRestockSequence(doDice, doPotion)
    if not acquireLock(4) then return false end
    local success = false

    pcall(function()
        local char = Player.Character
        if not char then return end

        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local returnCFrame = customSavedCFrame or root.CFrame
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")

        if hasAutoBuyGamepass() then
            safeTeleport(GAMEPASS_BUY_POS)
            task.wait(1.5)
            success = true
        else
            if doDice then
                if safeTeleport(DICE_SHOP_POS) then
                    task.wait(0.4)
                    if remotes then
                        local buyDice = remotes:FindFirstChild("BuyDice")
                        if buyDice then
                            safeCallRemote(buyDice, "RequestShop")
                            task.wait(0.3)
                            safeCallRemote(buyDice, "BuyBestAvailable")
                        end
                    end
                    task.wait(0.4)
                    success = true
                end
            end

            if doDice and doPotion then task.wait(1.2) end

            if doPotion then
                if safeTeleport(POTION_SHOP_POS) then
                    task.wait(0.4)
                    if remotes then
                        local buyPotion = remotes:FindFirstChild("BuyPotion")
                        if buyPotion then
                            safeCallRemote(buyPotion, "RequestShop")
                            task.wait(0.3)
                            safeCallRemote(buyPotion, "BuyBestAvailable")
                        end
                    end
                    task.wait(0.4)
                    success = true
                end
            end
        end

        task.wait(0.2)
        safeTeleport(returnCFrame)
    end)

    releaseLock()
    return success
end

-- =========================================================================
-- ADVANCED WORKSPACE OBJECT SEARCH
-- =========================================================================
local function getObjectPosition(obj)
    if not obj then return nil end
    local pos = nil
    pcall(function()
        if obj:IsA("Model") then
            if obj.PrimaryPart then
                pos = obj.PrimaryPart.Position
            else
                pos = obj:GetPivot().Position
            end
        elseif obj:IsA("BasePart") then
            pos = obj.Position
        else
            for _, child in ipairs(obj:GetDescendants()) do
                if child:IsA("BasePart") then
                    pos = child.Position
                    break
                end
            end
        end
    end)
    return pos
end

local function findFoodCart()
    local fc = nil
    pcall(function()
        if workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("MapShop") then
            fc = workspace.Map.MapShop:FindFirstChild("FoodCart")
        end
        if not fc then
            fc = workspace:FindFirstChild("FoodCart", true) or workspace:FindFirstChild("Food_Cart", true)
        end
    end)

    if fc then
        local isActive = false
        pcall(function()
            if fc:IsA("Model") and #fc:GetChildren() > 0 then
                isActive = true
            elseif fc:IsA("BasePart") and fc.Transparency < 1 then
                isActive = true
            end
        end)
        if isActive then return fc end
    end
    return nil
end

local function findMerchantInWorkspace()
    local merchantObj = nil
    pcall(function()
        if workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("MapShop") then
            merchantObj = workspace.Map.MapShop:FindFirstChild("Merchant")
        end
        if not merchantObj then
            merchantObj = workspace:FindFirstChild("Merchant", true) or workspace:FindFirstChild("TravellingMerchant", true)
        end
    end)
    return merchantObj
end

local function findWheelInWorkspace()
    local wheelObj = nil
    pcall(function()
        if workspace:FindFirstChild("Map") then
            if workspace.Map:FindFirstChild("MapShop") and workspace.Map.MapShop:FindFirstChild("Wheel") then
                wheelObj = workspace.Map.MapShop.Wheel
            elseif workspace.Map:FindFirstChild("Wheel") then
                wheelObj = workspace.Map.Wheel
            end
        end
        if not wheelObj then
            wheelObj = workspace:FindFirstChild("Wheel", true) or workspace:FindFirstChild("SpinWheel", true)
        end
    end)
    return wheelObj
end

-- =========================================================================
-- HELPER TIMER WHEEL
-- =========================================================================
local function getWheelTimerText()
    local text = ""
    pcall(function()
        local pGui = Player:FindFirstChild("PlayerGui")
        if not pGui then return end
        
        local main = pGui:FindFirstChild("Main")
        local canvas = main and main:FindFirstChild("Canvas")
        local wheel = canvas and canvas:FindFirstChild("Wheel")
        local wheelMain = wheel and wheel:FindFirstChild("Main")
        local spin = wheelMain and wheelMain:FindFirstChild("Spin")
        local timer = spin and spin:FindFirstChild("Timer")
        
        if timer and (timer:IsA("TextLabel") or timer:IsA("TextButton")) then
            text = timer.Text
        end

        if text == "" and wheel then
            for _, desc in ipairs(wheel:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Visible and desc.Text ~= "" then
                    local t = desc.Text:upper()
                    if t:find(":") or t:find("FREE") or t:find("READY") or t:find("SPIN") or t:find("CLAIM") or t:find("%d+") then
                        text = desc.Text
                        break
                    end
                end
            end
        end
    end)
    return text
end

-- =========================================================================
-- ACTIONS TELEPORT & EXECUTE
-- =========================================================================

-- =========================================================================
-- ACTIONS TELEPORT & EXECUTE
-- =========================================================================

local function teleportToFoodCartAndRequest()
    if not acquireLock(4) then return false end
    local success = false

    pcall(function()
        local foodCartObj = findFoodCart()
        local tpTarget = foodCartObj and getObjectPosition(foodCartObj)

        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local returnCFrame = customSavedCFrame or root.CFrame
            if tpTarget and safeTeleport(tpTarget) then
                task.wait(0.4)
                executeFoodCartRemotes(foodCartObj)
                task.wait(0.6)
                safeTeleport(returnCFrame)
                success = true
            else
                executeFoodCartRemotes(foodCartObj)
                success = true
            end
        end
    end)

    releaseLock()
    return success
end

local function teleportToMerchantAndBack()
    if not acquireLock(4) then return false end
    local success = false

    pcall(function()
        local merchantObj = findMerchantInWorkspace()
        local tpTarget = merchantObj and getObjectPosition(merchantObj)

        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local returnCFrame = customSavedCFrame or root.CFrame
            if tpTarget and safeTeleport(tpTarget) then
                task.wait(0.4)
                executeMerchantRemotes(merchantObj)
                task.wait(0.6)
                safeTeleport(returnCFrame)
                success = true
            else
                executeMerchantRemotes(merchantObj)
                success = true
            end
        end
    end)

    releaseLock()
    return success
end

local function teleportToWheelAndSpin()
    if not acquireLock(4) then return false end
    local success = false

    pcall(function()
        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local returnCFrame = customSavedCFrame or root.CFrame
            local wheelModel = findWheelInWorkspace()
            local targetPos = getObjectPosition(wheelModel) or WHEEL_POS
            
            if safeTeleport(targetPos) then
                task.wait(0.4)
                executeWheelRemotes()
                task.wait(0.8)
                safeTeleport(returnCFrame)
                success = true
            end
        end
    end)

    releaseLock()
    return success
end

-- =========================================================================
-- SYSTEM ANTI-AFK & FAKE NAME
-- =========================================================================
Player.Idled:Connect(function()
    if antiAFKEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

local function escapePattern(str)
    return (str:gsub("([^%w])", "%%%1"))
end

local function applyFakeName()
    if not fakeNameEnabled then return end
    pcall(function() Player.DisplayName = fakeDisplayName end)

    local containers = {Player:FindFirstChild("PlayerGui"), Player.Character}

    for _, container in ipairs(containers) do
        if container then
            pcall(function()
                for _, guiObj in ipairs(container:GetDescendants()) do
                    if guiObj:IsA("TextLabel") or guiObj:IsA("TextButton") then
                        local text = guiObj.Text
                        if REAL_DISPLAY_NAME ~= "" and text:find(REAL_DISPLAY_NAME, 1, true) then
                            guiObj.Text = text:gsub(escapePattern(REAL_DISPLAY_NAME), fakeDisplayName)
                        end
                        if REAL_USERNAME ~= "" and text:find(REAL_USERNAME, 1, true) then
                            guiObj.Text = text:gsub(escapePattern(REAL_USERNAME), fakeUsername)
                        end
                    end
                end
            end)
        end
    end
end

local function restoreRealName()
    pcall(function() Player.DisplayName = REAL_DISPLAY_NAME end)

    local containers = {Player:FindFirstChild("PlayerGui"), Player.Character}

    for _, container in ipairs(containers) do
        if container then
            pcall(function()
                for _, guiObj in ipairs(container:GetDescendants()) do
                    if guiObj:IsA("TextLabel") or guiObj:IsA("TextButton") then
                        local text = guiObj.Text
                        if fakeDisplayName ~= "" and text:find(fakeDisplayName, 1, true) then
                            guiObj.Text = text:gsub(escapePattern(fakeDisplayName), REAL_DISPLAY_NAME)
                        end
                        if fakeUsername ~= "" and text:find(fakeUsername, 1, true) then
                            guiObj.Text = text:gsub(escapePattern(fakeUsername), REAL_USERNAME)
                        end
                    end
                end
            end)
        end
    end
end

task.spawn(function()
    while task.wait(1.5) do
        if fakeNameEnabled then applyFakeName() end
    end
end)

-- =========================================================================
-- 1. SETUP WINDOW & TAB UI
-- =========================================================================
local Window = WindUI:CreateWindow({
    Title = "Shop & Wheel Auto Tracker",
    Icon = "clock",
    Folder = "RestockTracker",
    Size = UDim2.fromOffset(420, 850),
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

local timerTab = Window:Tab({ Title = "Timer & Position", Icon = "timer", Locked = false })
local timerSec = timerTab:Section({ Title = "Live Restock Tracker & Automation", TextSize = 20 })

timerSec:Toggle({
    Title = "Anti-AFK (Anti Kick 20 Min)",
    Desc = "Cegah server meremove karakter karena diam/idle",
    Value = true,
    Callback = function(state) antiAFKEnabled = state end
})

timerSec:Toggle({
    Title = "Auto Buy & TP Shop (Auto Gamepass)",
    Desc = "Cek Gamepass otomatis & TP 1x saat diaktifkan untuk beli stock",
    Value = false,
    Callback = function(state)
        autoBuyShopEnabled = state
        if state then
            task.spawn(function()
                executeShopRestockSequence(true, true)
            end)
        end
    end
})

timerSec:Toggle({
    Title = "Auto TP Food Cart (Dynamic Search Fix)",
    Desc = "Teleport ke Food Cart & Trigger Prompt/Remote",
    Value = false,
    Callback = function(state) autoTPFoodCartEnabled = state end
})

timerSec:Toggle({
    Title = "Auto TP Merchant (Dynamic Search Fix)",
    Desc = "Teleport ke Merchant & Trigger Prompt/Remote",
    Value = false,
    Callback = function(state) autoTPMerchantEnabled = state end
})

timerSec:Toggle({
    Title = "Auto TP & Claim Wheel Spin",
    Desc = "Teleport ke Wheel, Trigger Remote, & Kembali",
    Value = false,
    Callback = function(state) autoTPWheelEnabled = state end
})

-- TOMBOL MANUAL DENGAN HYBRID INSTANT TP + REMOTE TRIGGER
timerSec:Button({
    Title = "🌭 Manual Request Food Cart Now",
    Desc = "TP ke Food Cart -> Trigger Remote & Prompt -> Kembali ke Spot",
    Callback = function()
        task.spawn(teleportToFoodCartAndRequest)
        WindUI:Notify({ Title = "Food Cart Executed!", Content = "Proses TP & Request Food Cart dijalankan.", Duration = 3 })
    end
})

timerSec:Button({
    Title = "🧙‍♂️ Manual Request Merchant Now",
    Desc = "TP ke Merchant -> Trigger Remote & Prompt -> Kembali ke Spot",
    Callback = function()
        task.spawn(teleportToMerchantAndBack)
        WindUI:Notify({ Title = "Merchant Executed!", Content = "Proses TP & Request Merchant dijalankan.", Duration = 3 })
    end
})

timerSec:Button({
    Title = "⚡ Manual Claim & Spin Wheel Now",
    Desc = "TP ke Wheel -> Spin Remote -> Kembali ke Spot",
    Callback = function()
        task.spawn(teleportToWheelAndSpin)
        WindUI:Notify({ Title = "Wheel Executed!", Content = "Proses TP & Spin Wheel dijalankan.", Duration = 3 })
    end
})

local RestockPara = timerSec:Paragraph({ Title = "🛒 Main Shop:", Desc = "--:--" })
local PotionPara = timerSec:Paragraph({ Title = "🧪 Potion Shop:", Desc = "--:--" })
local FoodCartPara = timerSec:Paragraph({ Title = "🌭 Food Cart Status:", Desc = "Mengecek..." })
local MerchantPara = timerSec:Paragraph({ Title = "🧙‍♂️ Merchant Status:", Desc = "Mengecek..." })
local WheelPara = timerSec:Paragraph({ Title = "🎡 Wheel Spin:", Desc = "--:--" })

local posSec = timerTab:Section({ Title = "Kontrol Posisi Karakter", TextSize = 20 })
local posStatusPara = posSec:Paragraph({ Title = "📍 Status Posisi Kembali:", Desc = "Menggunakan posisi otomatis." })

posSec:Input({
    Title = "✏️ Nama Posisi Kustom",
    Value = "Spot Saya",
    Placeholder = "Ketik nama lokasi...",
    Callback = function(text) customPosName = (text and text ~= "") and text or "Posisi Kustom" end
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
        posStatusPara:SetDesc("Menggunakan posisi otomatis.")
        WindUI:Notify({ Title = "Posisi Direset!", Content = "Kembali ke mode posisi otomatis.", Duration = 3 })
    end
})

local visualTab = Window:Tab({ Title = "Visual & Name", Icon = "user-check", Locked = false })
local nameSec = visualTab:Section({ Title = "Sensor / Visual Name Changer", TextSize = 20 })

nameSec:Toggle({
    Title = "Enable Fake Name (Sensor)",
    Value = false,
    Callback = function(state)
        fakeNameEnabled = state
        if not state then restoreRealName() else applyFakeName() end
    end
})

nameSec:Input({
    Title = "Fake Display Name", Value = "Anonymous",
    Callback = function(text) fakeDisplayName = (text and text ~= "") and text or "Anonymous" if fakeNameEnabled then applyFakeName() end end
})

nameSec:Input({
    Title = "Fake Username (@)", Value = "User123",
    Callback = function(text) fakeUsername = (text and text ~= "") and text or "User123" if fakeNameEnabled then applyFakeName() end end
})

-- =========================================================================
-- 2. HELPER FUNCTIONS & TELEPORTS
-- =========================================================================

local function isTimerReady(timeStr)
    if not timeStr or timeStr == "" then return false end
    local cleanStr = timeStr:gsub("<[^>]+>", ""):upper()
    
    if cleanStr:find("READY") or cleanStr:find("FREE") or cleanStr:find("CLAIM") or cleanStr:find("SPIN") or cleanStr:find("NOW") or cleanStr:find("RESTOCKED") or cleanStr == "00:00" or cleanStr == "0:00" or cleanStr == "0S" then
        return true
    end

    local numOnlyStr = cleanStr:gsub("RESTOCK", ""):gsub("IN", "")
    local numbers = {}
    for num in numOnlyStr:gmatch("%d+") do table.insert(numbers, tonumber(num)) end
    
    if #numbers > 0 then
        local totalSec = 0
        if #numbers == 3 then totalSec = (numbers[1] * 3600) + (numbers[2] * 60) + numbers[3]
        elseif #numbers == 2 then totalSec = (numbers[1] * 60) + numbers[2]
        elseif #numbers == 1 then totalSec = numbers[1] end
        
        return totalSec == 0
    end
    
    return false
end

-- =========================================================================
-- 3. MAIN LOOP
-- =========================================================================
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local pGui = Player:FindFirstChild("PlayerGui")
            local mainUI = pGui and pGui:FindFirstChild("Main")
            local canvas = mainUI and mainUI:FindFirstChild("Canvas")
            
            -- Map Shops
            local mapShops = canvas and canvas:FindFirstChild("MapShops")
            local shopMain = mapShops and mapShops:FindFirstChild("Main")
            local timerLabelMain = shopMain and shopMain:FindFirstChild("Timer") and shopMain.Timer:FindFirstChild("Timer")

            local shopPotion = mapShops and mapShops:FindFirstChild("Potion")
            local timerLabelPotion = shopPotion and shopPotion:FindFirstChild("Timer") and shopPotion.Timer:FindFirstChild("Timer")

            -- DETEKSI WHEEL SPIN TIMER
            local wheelText = getWheelTimerText()

            -- DETEKSI FOOD CART IN WORKSPACE
            local foodCartInstance = findFoodCart()
            local isFoodCartSpawned = (foodCartInstance ~= nil)

            -- DETEKSI MERCHANT IN WORKSPACE
            local merchantWorkspaceObj = findMerchantInWorkspace()
            local isMerchantSpawnedInWorkspace = (merchantWorkspaceObj ~= nil and (
                (merchantWorkspaceObj:IsA("Model") and #merchantWorkspaceObj:GetChildren() > 0) or 
                (merchantWorkspaceObj:IsA("BasePart") and merchantWorkspaceObj.Transparency < 1)
            ))

            -- Teks Timer GUI Merchant
            local merchantObjGUI = canvas and canvas:FindFirstChild("Merchant")
            local merchantText = ""
            if merchantObjGUI and merchantObjGUI:FindFirstChild("Main") and merchantObjGUI.Main:FindFirstChild("Timer") then
                local tLabel = merchantObjGUI.Main.Timer:FindFirstChild("Timer")
                if tLabel and tLabel:IsA("TextLabel") then merchantText = tLabel.Text end
            end

            -- Teks Timer Main & Potion Shop
            local mainText = (timerLabelMain and timerLabelMain:IsA("TextLabel")) and timerLabelMain.Text or ""
            local potionText = (timerLabelPotion and timerLabelPotion:IsA("TextLabel")) and timerLabelPotion.Text or ""

            -- Update UI Display
            if mainText ~= "" then RestockPara:SetDesc("<b><font size='24'>" .. mainText .. "</font></b>") else RestockPara:SetDesc("Tutup") end
            if potionText ~= "" then PotionPara:SetDesc("<b><font size='24'>" .. potionText .. "</font></b>") else PotionPara:SetDesc("Tutup") end

            -- UPDATE UI FOOD CART
            if isFoodCartSpawned then
                FoodCartPara:SetTitle("🌭 Food Cart Status:")
                FoodCartPara:SetDesc("<b><font color='#00FF00' size='22'>🟢 SPAWNED / BUKA</font></b>")
            else
                FoodCartPara:SetTitle("🌭 Food Cart Status:")
                FoodCartPara:SetDesc("<b><font color='#FF4500' size='22'>🔴 TUTUP / DESPAWNED</font></b>")
            end

            -- UPDATE UI MERCHANT
            if isMerchantSpawnedInWorkspace then
                MerchantPara:SetDesc("<b><font color='#00FF00' size='22'>🟢 MUNCUL DI WORKSPACE</font></b>")
            elseif merchantText ~= "" then
                MerchantPara:SetDesc("<b><font size='24'>" .. merchantText .. "</font></b>")
            else
                MerchantPara:SetDesc("<b><font color='#FF4500' size='22'>🔴 Despawn</font></b>")
            end

            if wheelText ~= "" then 
                WheelPara:SetDesc("<b><font size='24'>" .. wheelText .. "</font></b>") 
            else 
                WheelPara:SetDesc("<b><font color='#00FF00' size='22'>READY / SIAP SPIN</font></b>") 
            end

            -- LOGIKA TRIGGER AUTO TP RESTOCK SHOP
            local isDiceReady = isTimerReady(mainText)
            local isPotionReady = isTimerReady(potionText)

            if autoBuyShopEnabled then
                local shouldDoDice = isDiceReady and not diceRestockDone
                local shouldDoPotion = isPotionReady and not potionRestockDone

                if shouldDoDice or shouldDoPotion then
                    task.spawn(function()
                        if executeShopRestockSequence(shouldDoDice, shouldDoPotion) then
                            if shouldDoDice then diceRestockDone = true end
                            if shouldDoPotion then potionRestockDone = true end
                        end
                    end)
                end
            end

            if not isDiceReady then diceRestockDone = false end
            if not isPotionReady then potionRestockDone = false end

            -- AUTO TP FOOD CART
            if autoTPFoodCartEnabled then
                if isFoodCartSpawned and not foodCartRestockDone then
                    task.spawn(function()
                        if teleportToFoodCartAndRequest() then
                            foodCartRestockDone = true
                        end
                    end)
                elseif not isFoodCartSpawned then
                    foodCartRestockDone = false
                end
            end

            -- AUTO TP MERCHANT
            if autoTPMerchantEnabled then
                if isMerchantSpawnedInWorkspace and not merchantSpawnDone then
                    task.spawn(function()
                        if teleportToMerchantAndBack() then
                            merchantSpawnDone = true
                        end
                    end)
                elseif not isMerchantSpawnedInWorkspace then 
                    merchantSpawnDone = false 
                end
            end

            -- AUTO TP WHEEL SPIN
            local isWheelReady = isTimerReady(wheelText)
            if autoTPWheelEnabled then
                if isWheelReady and not wheelRestockDone then
                    task.spawn(function()
                        if teleportToWheelAndSpin() then
                            wheelRestockDone = true
                        end
                    end)
                elseif not isWheelReady then 
                    wheelRestockDone = false 
                end
            end
        end)
    end
end)