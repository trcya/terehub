local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()

print("Terehub: Initializing...")

-- [[ UI LOADING ]] --
local function LoadUI()
    local source = "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
    local success, content = pcall(game.HttpGet, game, source)
    
    if not success then
        warn("Terehub: Failed to fetch UI source. Check your internet connection.")
        return nil
    end
    
    local library, err = loadstring(content)
    if not library then
        warn("Terehub: Failed to compile UI library. Error: " .. tostring(err))
        return nil
    end
    
    local ok, result = pcall(library)
    if ok then
        return result
    else
        warn("Terehub: Failed to initialize UI library. Error: " .. tostring(result))
        return nil
    end
end

local WindUI = LoadUI()
if not WindUI then 
    warn("Terehub: CRITICAL - UI Library not found, script stopped.")
    return 
end
print("Terehub: UI Library loaded, creating window...")

local Window = WindUI:CreateWindow({
    Title = "Terehub | Violence District V10",
    Icon = "rbxassetid://136360402262473",
    Author = "David",
    Folder = "Terehub",
    Size = UDim2.fromOffset(600, 420),
    Transparent = false, -- Changed to false for better visibility
    Theme = "Indigo",
})

-- [[ FLOATING OPEN BUTTON (MUTLAK MUNCUL DI PC & MOBILE) ]] --
pcall(function()
    Window:EditOpenButton({
        Title = "Terehub",
        Icon = "rbxassetid://136360402262473",
        Enabled = true,
        Draggable = true,
        OnlyMobile = false, -- PENTING: Harus false agar tetap muncul di PC/Laptop
    })
end)

-- [[ TABS ]] --
local MainTab = Window:Tab({ Title = "Main", Icon = "home" })
local CharTab = Window:Tab({ Title = "Character", Icon = "user" })
local CombatTab = Window:Tab({ Title = "Combat", Icon = "crosshair" })
local VisualTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local ShopTab = Window:Tab({ Title = "Shops", Icon = "shopping-cart" })
local PlayerTab = Window:Tab({ Title = "Players", Icon = "users" })

-- [[ SHOPS: REMOTE MAPSHOPS OPENER & BUY ALL ]] --
ShopTab:Section({ Title = "Developer Tools & Remote Scanner (Alternatif SimpleSpy)" })

ShopTab:Button({
    Title = "Scan All Shop Remotes (Lihat di Console F9)",
    Desc = "Mencari semua RemoteEvent/Function bertema Shop/Buy/Dice di game dan menampilkannya di F9 Console",
    Callback = function()
        print("=== [TEREHUB REMOTE SCANNER] ===")
        local count = 0
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local name = string.lower(obj.Name)
                if string.find(name, "buy") or string.find(name, "shop") or string.find(name, "purchase") or string.find(name, "dice") or string.find(name, "potion") or string.find(name, "restock") or string.find(name, "roll") then
                    count = count + 1
                    print(string.format("[%d] %s (%s) -> Path: %s", count, obj.Name, obj.ClassName, obj:GetFullName()))
                end
            end
        end
        print("================================")
        Window:Notify({ Title = "Remote Scanner", Content = "Berhasil menemukan " .. tostring(count) .. " Remote! Buka F9 Console untuk melihatnya.", Duration = 4 })
    end
})

local hookActive = false
ShopTab:Toggle({
    Title = "Log Remote Event (F9 Console)",
    Desc = "Mencetak setiap RemoteEvent yang dipanggil oleh game saat Anda membeli barang ke F9 Console",
    Callback = function(state)
        hookActive = state
        if state then
            Window:Notify({ Title = "Remote Logger", Content = "Logger Aktif! Beli item di game lalu buka Console F9.", Duration = 4 })
            task.spawn(function()
                if hookmetamethod then
                    local oldNamecall
                    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                        local method = getnamecallmethod()
                        if hookActive and (method == "FireServer" or method == "InvokeServer") then
                            print(string.format("[REMOTE CALLED] %s:%s() | Args: ", self:GetFullName(), method), ...)
                        end
                        return oldNamecall(self, ...)
                    end)
                else
                    print("[REMOTE LOGGER ERROR] Executor Anda tidak mendukung hookmetamethod!")
                end
            end)
        end
    end
})

ShopTab:Section({ Title = "MapShops (Khusus Dex GUI)" })

ShopTab:Button({
    Title = "Buka MapShops GUI (Bypass Jarak)",
    Desc = "Langsung memunculkan PlayerGui.MapShops.Main dari mana saja",
    Callback = function()
        pcall(function()
            local pGui = LocalPlayer:FindFirstChild("PlayerGui")
            local mapShops = pGui and pGui:FindFirstChild("MapShops")
            
            if mapShops then
                mapShops.Enabled = true
                if mapShops:FindFirstChild("Main") then
                    mapShops.Main.Visible = true
                end
                Window:Notify({ Title = "MapShops", Content = "MapShops GUI Berhasil Dibuka!", Duration = 3 })
            else
                Window:Notify({ Title = "MapShops", Content = "MapShops GUI tidak ditemukan di PlayerGui!", Duration = 3 })
            end
        end)
    end
})

ShopTab:Button({
    Title = "Buy All Items (Beli Semua Dice/Item)",
    Desc = "Membeli otomatis semua item (Abyssal, Arcane, Bronze, Celestial, Crystal, Demonic, dll)",
    Callback = function()
        pcall(function()
            local pGui = LocalPlayer:FindFirstChild("PlayerGui")
            local mapShops = pGui and pGui:FindFirstChild("MapShops")
            local holder = mapShops and mapShops:FindFirstChild("Main") and mapShops.Main:FindFirstChild("Holder")
            
            if holder then
                local count = 0
                for _, itemFrame in pairs(holder:GetChildren()) do
                    if itemFrame:IsA("GuiObject") then
                        -- 1. Klik tombol beli di dalam itemFrame jika ada
                        local buyBtn = itemFrame:FindFirstChild("Buy") or itemFrame:FindFirstChild("Purchase") or itemFrame:FindFirstChildWhichIsA("TextButton") or itemFrame:FindFirstChildWhichIsA("ImageButton")
                        local targetClick = buyBtn or itemFrame
                        
                        if firesignal and targetClick then
                            pcall(function() firesignal(targetClick.MouseButton1Click) end)
                            pcall(function() firesignal(targetClick.Activated) end)
                        end
                        
                        if getconnections and targetClick then
                            for _, conn in pairs(getconnections(targetClick.MouseButton1Click) or {}) do
                                pcall(function() conn:Fire() end)
                            end
                        end
                        
                        -- 2. Panggil RemoteEvent jika game menggunakan Remote
                        for _, remote in pairs(game.ReplicatedStorage:GetDescendants()) do
                            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                                local rName = string.lower(remote.Name)
                                if string.find(rName, "buy") or string.find(rName, "purchase") or string.find(rName, "shop") or string.find(rName, "dice") then
                                    pcall(function()
                                        if remote:IsA("RemoteEvent") then
                                            remote:FireServer(itemFrame.Name)
                                        elseif remote:IsA("RemoteFunction") then
                                            remote:InvokeServer(itemFrame.Name)
                                        end
                                    end)
                                end
                            end
                        end
                        count = count + 1
                    end
                end
                Window:Notify({ Title = "Buy All", Content = "Mencoba membeli " .. tostring(count) .. " jenis item di MapShops!", Duration = 3 })
            else
                Window:Notify({ Title = "Buy All", Content = "Holder MapShops tidak ditemukan!", Duration = 3 })
            end
        end)
    end
})

local autoBuyAllShops = false
ShopTab:Toggle({
    Title = "Auto Buy All (Loop)",
    Desc = "Membeli semua item di MapShops secara terus menerus",
    Callback = function(state)
        autoBuyAllShops = state
    end
})

local catchRestockToggle = false
local restockConn = nil

ShopTab:Toggle({
    Title = "Catch Restock Time & Auto Buy",
    Desc = "Mendeteksi waktu Restock di UI MapShops dan otomatis beli saat 00:00 / Restock",
    Callback = function(state)
        catchRestockToggle = state
        if state then
            Window:Notify({ Title = "Restock Tracker", Content = "Memantau waktu Restock...", Duration = 3 })
            pcall(function()
                local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                local mapShops = pGui and pGui:FindFirstChild("MapShops")
                local timerLabel = mapShops and mapShops:FindFirstChild("Main") and (mapShops.Main:FindFirstChild("Timer") or mapShops.Main:FindFirstChild("RestockTime") or mapShops.Main:FindFirstChildWhichIsA("TextLabel", true))
                
                if timerLabel and timerLabel:IsA("TextLabel") then
                    restockConn = timerLabel:GetPropertyChangedSignal("Text"):Connect(function()
                        if not catchRestockToggle then return end
                        local tText = string.lower(timerLabel.Text)
                        if string.find(tText, "00:00") or string.find(tText, "restock") or string.find(tText, "0s") then
                            Window:Notify({ Title = "RESTOCK!", Content = "Shop Restock terdeteksi! Membeli semua item...", Duration = 3 })
                            local holder = mapShops.Main:FindFirstChild("Holder")
                            if holder then
                                for _, itemFrame in pairs(holder:GetChildren()) do
                                    if itemFrame:IsA("GuiObject") then
                                        local buyBtn = itemFrame:FindFirstChild("Buy") or itemFrame:FindFirstChildWhichIsA("TextButton") or itemFrame
                                        if firesignal and buyBtn then
                                            pcall(function() firesignal(buyBtn.MouseButton1Click) end)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end
            end)
        else
            if restockConn then
                restockConn:Disconnect()
                restockConn = nil
            end
        end
    end
})

task.spawn(function()
    while true do
        if autoBuyAllShops then
            pcall(function()
                local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                local mapShops = pGui and pGui:FindFirstChild("MapShops")
                local holder = mapShops and mapShops:FindFirstChild("Main") and mapShops.Main:FindFirstChild("Holder")
                
                if holder then
                    for _, itemFrame in pairs(holder:GetChildren()) do
                        if itemFrame:IsA("GuiObject") then
                            local buyBtn = itemFrame:FindFirstChild("Buy") or itemFrame:FindFirstChild("Purchase") or itemFrame:FindFirstChildWhichIsA("TextButton") or itemFrame:FindFirstChildWhichIsA("ImageButton")
                            local targetClick = buyBtn or itemFrame
                            
                            if firesignal and targetClick then
                                pcall(function() firesignal(targetClick.MouseButton1Click) end)
                                pcall(function() firesignal(targetClick.Activated) end)
                            end
                            
                            for _, remote in pairs(game.ReplicatedStorage:GetDescendants()) do
                                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                                    local rName = string.lower(remote.Name)
                                    if string.find(rName, "buy") or string.find(rName, "purchase") or string.find(rName, "shop") or string.find(rName, "dice") then
                                        pcall(function()
                                            if remote:IsA("RemoteEvent") then
                                                remote:FireServer(itemFrame.Name)
                                            end
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if infShopDistance then
            pcall(function()
                for _, prompt in pairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        local pName = string.lower(prompt.Parent.Name)
                        local actText = string.lower(prompt.ActionText)
                        local objText = string.lower(prompt.ObjectText)
                        
                        if string.find(pName, "mapshop") or string.find(pName, "shop") or string.find(pName, "merchant") or string.find(actText, "shop") or string.find(objText, "shop") then
                            prompt.MaxActivationDistance = 999999
                            prompt.RequiresLineOfSight = false
                        end
                    end
                end
            end)
        end
        task.wait(2)
    end
end)

ShopTab:Button({
    Title = "Teleport ke MapShops Terdekat",
    Desc = "Teleportasi karakter langsung ke lokasi MapShops",
    Callback = function()
        pcall(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            for _, v in pairs(workspace:GetDescendants()) do
                local n = string.lower(v.Name)
                if string.find(n, "mapshop") or string.find(n, "shop") then
                    local part = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
                    if part then
                        hrp.CFrame = part.CFrame * CFrame.new(0, 0, 3)
                        Window:Notify({ Title = "Teleport", Content = "Berhasil teleport ke " .. v.Name, Duration = 3 })
                        break
                    end
                end
            end
        end)
    end
})


-- [[ MAIN: AUTO PERFECT SKILL CHECK & COLLECTOR ]] --
local autoSkillCheck = false
MainTab:Toggle({
    Title = "Auto Perfect Skill Check",
    Callback = function(state) autoSkillCheck = state end
})

task.spawn(function()
    while true do
        if autoSkillCheck then
            pcall(function()
                local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                if pGui then
                    for _, v in pairs(pGui:GetDescendants()) do
                        if v.Name == "SkillCheck" or v.Name == "Pointer" then 
                            local needle = v
                            local successZone = v.Parent:FindFirstChild("SuccessZone") or v.Parent:FindFirstChild("WhiteArea")
                            
                            if needle and successZone and needle:IsA("GuiObject") and successZone:IsA("GuiObject") then
                                -- Check rotation or position for match
                                if math.abs(needle.Rotation - successZone.Rotation) < 8 then
                                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                                    task.wait(0.01)
                                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                                    task.wait(0.5) -- Debounce to prevent multiple presses
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait()
    end
end)

local autoCollect = false
MainTab:Toggle({
    Title = "Auto Collect Items",
    Callback = function(state)
        autoCollect = state
    end
})

task.spawn(function()
    while true do
        if autoCollect then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, v in pairs(workspace:GetChildren()) do
                        if v:IsA("Tool") or v.Name == "Scrap" or v.Name == "Item" then
                            local target = v:FindFirstChild("Handle") or v:FindFirstChildWhichIsA("BasePart")
                            if target then
                                hrp.CFrame = target.CFrame
                                task.wait(0.3)
                            end
                        end
                        if not autoCollect then break end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

local autoRepairGen = false
MainTab:Toggle({
    Title = "Auto Repair Generator",
    Callback = function(state)
        autoRepairGen = state
    end
})

task.spawn(function()
    while true do
        if autoRepairGen then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, prompt in pairs(workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") then
                            local name = string.lower(prompt.Parent.Name)
                            local action = string.lower(prompt.ActionText)
                            
                            if string.find(name, "gen") or string.find(action, "repair") or string.find(action, "fix") then
                                local targetPart = prompt.Parent
                                if targetPart and targetPart:IsA("BasePart") then
                                    hrp.CFrame = targetPart.CFrame * CFrame.new(0, 0, 3)
                                    task.wait(0.2)
                                    if fireproximityprompt then
                                        fireproximityprompt(prompt)
                                    else
                                        prompt:InputHoldBegin()
                                        task.wait(prompt.HoldDuration + 0.1)
                                        prompt:InputHoldEnd()
                                    end
                                end
                            end
                        end
                        if not autoRepairGen then break end
                    end
                end
            end)
        end
        task.wait(1)
    end
end)

-- [[ CHARACTER: MOVEMENT MODIFIERS ]] --
local wsToggle = false
local wsValue = 16
local jpToggle = false
local jpValue = 50
local infJump = false
local noclip = false
local flying = false
local flySpeed = 50

CharTab:Toggle({ Title = "Enable WalkSpeed", Callback = function(s) wsToggle = s end })
CharTab:Slider({ Title = "WalkSpeed", Step = 1, Min = 16, Max = 150, Default = 16, Callback = function(v) wsValue = v end })

CharTab:Toggle({ Title = "Enable JumpPower", Callback = function(s) jpToggle = s end })
CharTab:Slider({ Title = "JumpPower", Step = 1, Min = 50, Max = 200, Default = 50, Callback = function(v) jpValue = v end })

CharTab:Toggle({ Title = "Infinite Jump", Callback = function(s) infJump = s end })
CharTab:Toggle({ Title = "Noclip (Tembus)", Callback = function(s) noclip = s end })

local flyVelocity, flyGyro
CharTab:Toggle({ Title = "Fly (Terbang)", Callback = function(s) 
    flying = s 
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if flying then
        flyVelocity = Instance.new("BodyVelocity")
        flyVelocity.Name = "TereFlyVel"
        flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyVelocity.Parent = hrp
        
        flyGyro = Instance.new("BodyGyro")
        flyGyro.Name = "TereFlyGyro"
        flyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyGyro.CFrame = hrp.CFrame
        flyGyro.Parent = hrp
        
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = true end
    else
        if flyVelocity then flyVelocity:Destroy() end
        if flyGyro then flyGyro:Destroy() end
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end })
CharTab:Slider({ Title = "Fly Speed", Step = 1, Min = 10, Max = 300, Default = 50, Callback = function(v) flySpeed = v end })

UserInputService.JumpRequest:Connect(function()
    if infJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then
        if wsToggle then hum.WalkSpeed = wsValue end
        if jpToggle then 
            hum.UseJumpPower = true
            hum.JumpPower = jpValue 
        end
    end
    
    if noclip and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    if flying and flyVelocity and flyGyro then
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        flyVelocity.Velocity = moveDir * flySpeed
        flyGyro.CFrame = cam.CFrame
    end
end)

-- [[ COMBAT: AUTO AIM KILLER ]] --
local autoAim = false
CombatTab:Toggle({
    Title = "Auto Aim (Target Killer)",
    Callback = function(state) autoAim = state end
})

RunService.RenderStepped:Connect(function()
    if autoAim then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local isKiller = false
                if p.Team and (string.find(p.Team.Name, "Killer") or string.find(p.Team.Name, "Murderer")) then
                    isKiller = true
                end
                
                if isKiller then
                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, p.Character.Head.Position)
                    break
                end
            end
        end
    end
end)

-- Hitbox Expander
local hitboxActive = false
local hitboxSize = 5
CombatTab:Toggle({ Title = "Hitbox Expander", Callback = function(state) hitboxActive = state end })
CombatTab:Slider({ Title = "Hitbox Size", Step = 1, Min = 2, Max = 25, Default = 5, Callback = function(v) hitboxSize = v end })

task.spawn(function()
    while true do
        if hitboxActive then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    p.Character.HumanoidRootPart.Transparency = 0.5
                    p.Character.HumanoidRootPart.CanCollide = false
                end
            end
        end
        task.wait(1)
    end
end)

-- [[ VISUALS: ESP TEAM COLOR ]] --
local espActive = false
VisualTab:Toggle({ Title = "ESP Team", Callback = function(s) espActive = s end })

RunService.Heartbeat:Connect(function()
    if espActive then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local isKiller = false
                if p.Team and (string.match(string.lower(p.Team.Name), "killer") or string.match(string.lower(p.Team.Name), "murderer")) then
                    isKiller = true
                elseif p.Character:FindFirstChildWhichIsA("Tool") and string.match(string.lower(p.Character:FindFirstChildWhichIsA("Tool").Name), "knife") then
                    isKiller = true
                end

                local color = isKiller and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)
                
                -- Highlight
                local h = p.Character:FindFirstChild("TereHighlight")
                if not h then
                    h = Instance.new("Highlight")
                    h.Name = "TereHighlight"
                    h.Parent = p.Character
                end
                h.FillColor = color
                h.Enabled = true

                -- Name Tag
                local bb = p.Character:FindFirstChild("TereName")
                local lbl
                if not bb then
                    bb = Instance.new("BillboardGui")
                    bb.Name = "TereName"
                    bb.AlwaysOnTop = true
                    bb.Size = UDim2.new(0, 100, 0, 25)
                    bb.ExtentsOffset = Vector3.new(0, 3, 0)
                    bb.Parent = p.Character
                    
                    lbl = Instance.new("TextLabel")
                    lbl.Name = "Tag"
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextStrokeTransparency = 0
                    lbl.Parent = bb
                else
                    lbl = bb:FindFirstChild("Tag")
                end
                
                if lbl then
                    lbl.Text = p.Name
                    lbl.TextColor3 = color
                end
            end
        end
    else
        -- Clean up ESP
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                local h = p.Character:FindFirstChild("TereHighlight")
                if h then h.Enabled = false end
                local bb = p.Character:FindFirstChild("TereName")
                if bb then bb.Enabled = false end
            end
        end
    end
end)

-- Fullbright
local fullbright = false
VisualTab:Toggle({ Title = "Fullbright", Callback = function(state) fullbright = state end })

local originalAmbient = Lighting.Ambient
local originalBrightness = Lighting.Brightness

RunService.Heartbeat:Connect(function()
    if fullbright then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
    end
end)

-- [[ PLAYER LIST ]] --
local selectedPlayer = ""
local function getPlayers()
    local tbl = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(tbl, p.Name) end
    end
    return tbl
end

local PlayerDrop = PlayerTab:Dropdown({
    Title = "Select Player",
    Options = getPlayers(),
    Callback = function(v) selectedPlayer = v end
})

PlayerTab:Button({ Title = "Refresh Player List", Callback = function() PlayerDrop:SetOptions(getPlayers()) end })
PlayerTab:Button({ Title = "Teleport", Callback = function()
    local target = Players:FindFirstChild(selectedPlayer)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then 
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame 
        end
    end
end })

PlayerTab:Button({ Title = "Spectate", Callback = function()
    local target = Players:FindFirstChild(selectedPlayer)
    if target and target.Character and target.Character:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
    end
end })

PlayerTab:Button({ Title = "Unspectate", Callback = function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = char.Humanoid
    end
end })

Window:Notify({ Title = "Terehub V10", Content = "Script Loaded Successfully!", Duration = 5 })

-- [[ UI TOGGLE SYSTEM ]] --
pcall(function()
    local toggleKey = Enum.KeyCode.Minus
    local toggleGuiName = "TereToggle"
    local oldGui = game:GetService("CoreGui"):FindFirstChild(toggleGuiName)
    if oldGui then oldGui:Destroy() end

    local toggleGui = Instance.new("ScreenGui")
    toggleGui.Name = toggleGuiName
    toggleGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
    toggleGui.ResetOnSpawn = false

    local toggleBtn = Instance.new("ImageButton")
    toggleBtn.Name = "OpenButton"
    toggleBtn.Parent = toggleGui
    toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    toggleBtn.Position = UDim2.new(0, 15, 0.5, -20)
    toggleBtn.Size = UDim2.new(0, 40, 0, 40)
    toggleBtn.Image = "rbxassetid://136360402262473"
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Draggable = true
    toggleBtn.Active = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = toggleBtn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 100, 255)
    stroke.Thickness = 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = toggleBtn

    local function toggleUI()
        if WindUI and WindUI.ScreenGui then
            WindUI.ScreenGui.Enabled = not WindUI.ScreenGui.Enabled
        end
    end

    toggleBtn.MouseButton1Click:Connect(toggleUI)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == toggleKey then
            toggleUI()
        end
    end)
end)

