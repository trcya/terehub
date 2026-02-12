-- [[ terehub | GOD MODE EDITION v4.0 ]] --
-- UI Library: Rayfield

if not game:IsLoaded() then game.Loaded:Wait() end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "terehub | Mega Exploit Panel",
   LoadingTitle = "Booting terehub v4.0",
   LoadingSubtitle = "by David",
   ConfigurationSaving = { Enabled = true, FolderName = "terehub_configs", FileName = "god_config" }
})

-- [[ GLOBAL VARIABLES ]] --
local flyActive, infJump, noclipActive = false, false, false
local flySpeed, walkSpeed, jumpPower = 50, 16, 50
local autoClick, espActive, fullBright = false, false, false

-- [[ TABS ]] --
local MoveTab = Window:CreateTab("Movement", 4483362458)
local VisualTab = Window:CreateTab("Visuals Pro", 4483345998)
local CombatTab = Window:CreateTab("Combat & Hitbox", 4483362458)
local WorldTab = Window:CreateTab("World & Server", 4483362458)

-- [[ 1. MOVEMENT TAB ]] --
MoveTab:CreateSlider({
   Name = "Speed Hack",
   Range = {16, 1000},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) walkSpeed = v end,
})

MoveTab:CreateToggle({
   Name = "Analog Fly (Camera Mode)",
   CurrentValue = false,
   Callback = function(v)
      flyActive = v
      if v then
          local bv = Instance.new("BodyVelocity", game.Players.LocalPlayer.Character.HumanoidRootPart)
          bv.Name = "terehub_Fly"
          bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
          task.spawn(function()
              while flyActive do
                  bv.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * flySpeed
                  task.wait()
              end
              bv:Destroy()
          end)
      end
   end,
})

MoveTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Callback = function(v) infJump = v end,
})

MoveTab:CreateToggle({
   Name = "Noclip (Tembus Tembok)",
   CurrentValue = false,
   Callback = function(v) noclipActive = v end,
})

-- [[ 2. VISUALS PRO ]] --
VisualTab:CreateToggle({
   Name = "Player ESP (Highlighter)",
   CurrentValue = false,
   Callback = function(v) espActive = v end,
})

VisualTab:CreateButton({
   Name = "Fullbright (No Shadows)",
   Callback = function()
       game:GetService("Lighting").Brightness = 2
       game:GetService("Lighting").GlobalShadows = false
       game:GetService("Lighting").ClockTime = 14
   end,
})

VisualTab:CreateButton({
   Name = "Remove Fog",
   Callback = function()
       game:GetService("Lighting").FogEnd = 9e9
   end,
})

-- [[ 3. COMBAT & HITBOX ]] --
CombatTab:CreateSlider({
   Name = "Hitbox Expander (Head Size)",
   Range = {1, 50},
   Increment = 1,
   CurrentValue = 1,
   Callback = function(v)
       for _, p in pairs(game.Players:GetPlayers()) do
           if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
               p.Character.Head.Size = Vector3.new(v, v, v)
               p.Character.Head.Transparency = 0.5
           end
       end
   end,
})

CombatTab:CreateToggle({
   Name = "Fast Clicker (0.01s)",
   CurrentValue = false,
   Callback = function(v) autoClick = v end,
})

-- [[ 4. WORLD & SERVER ]] --
WorldTab:CreateButton({
   Name = "TP to Random Player",
   Callback = function()
       local players = game.Players:GetPlayers()
       local randomPlayer = players[math.random(1, #players)]
       if randomPlayer and randomPlayer ~= game.Players.LocalPlayer then
           game.Players.LocalPlayer.Character:MoveTo(randomPlayer.Character.HumanoidRootPart.Position)
       end
   end,
})

WorldTab:CreateButton({
   Name = "Server Lag Test (Chat Spam)",
   Callback = function()
       for i = 1, 10 do
           game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("terehub v4.0 dominates", "All")
           task.wait(0.1)
       end
   end,
})

-- [[ RUNTIME CORE ]] --
game:GetService("RunService").RenderStepped:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = walkSpeed
    end
    if noclipActive and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    if espActive then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character and not p.Character:FindFirstChild("Highlight") then
                Instance.new("Highlight", p.Character)
            end
        end
    end
    if autoClick then
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
    end
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJump then game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
end)

Rayfield:Notify({ Title = "terehub v4.0", Content = "Semua fitur berhasil dimuat!", Duration = 5 })