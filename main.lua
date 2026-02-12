-- [[ terehub | Mega Update Anti-Cheat Tester ]] --
-- UI Library: Rayfield

if not game:IsLoaded() then game.Loaded:Wait() end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "terehub | Mega Tester",
   LoadingTitle = "Booting terehub v2.0",
   LoadingSubtitle = "by David",
   ConfigurationSaving = { Enabled = true, FolderName = "terehub_configs", FileName = "mega_config" }
})

-- [[ TABS ]] --
local MoveTab = Window:CreateTab("Movement", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483345998)
local WorldTab = Window:CreateTab("World & Render", 4483362458)
local AutomationTab = Window:CreateTab("Automation", 4483362458)

-- [[ MOVEMENT ]] --
MoveTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 500},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end,
})

local flyActive = false
MoveTab:CreateToggle({
   Name = "Fly Mode (CFrame)",
   CurrentValue = false,
   Callback = function(v)
      flyActive = v
      task.spawn(function()
          local char = game.Players.LocalPlayer.Character
          local hrp = char:FindFirstChild("HumanoidRootPart")
          local bv = Instance.new("BodyVelocity", hrp)
          bv.MaxForce = Vector3.new(1,1,1) * math.huge
          while flyActive do
              bv.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * 100
              task.wait()
          end
          bv:Destroy()
      end)
   end,
})

-- [[ VISUALS (TEMBUS PANDANG) ]] --
local espActive = false
VisualTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Callback = function(v) espActive = v end,
})

-- [[ WORLD & RENDER (Testing Environment AC) ]] --
WorldTab:CreateButton({
   Name = "Fullbright / No Fog",
   Callback = function()
       game:GetService("Lighting").Brightness = 2
       game:GetService("Lighting").ClockTime = 14
       game:GetService("Lighting").FogEnd = 100000
       game:GetService("Lighting").GlobalShadows = false
   end,
})

WorldTab:CreateSlider({
   Name = "Field of View (FOV)",
   Range = {70, 120},
   Increment = 1,
   CurrentValue = 70,
   Callback = function(v) game.Workspace.CurrentCamera.FieldOfView = v end,
})

-- [[ AUTOMATION (Testing Rate Limit) ]] --
local autoClick = false
AutomationTab:CreateToggle({
   Name = "Auto Clicker (Test Rate Limit)",
   CurrentValue = false,
   Callback = function(v)
       autoClick = v
       task.spawn(function()
           while autoClick do
               -- Simulasi klik kiri
               local VirtualUser = game:GetService("VirtualUser")
               VirtualUser:CaptureController()
               VirtualUser:ClickButton1(Vector2.new(0,0))
               task.wait(0.1)
           end
       end)
   end,
})

AutomationTab:CreateButton({
   Name = "Chat Spam 'terehub'",
   Callback = function()
       for i = 1, 5 do
           game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("terehub on top!", "All")
           task.wait(0.5)
       end
   end,
})

-- [[ RUNTIME LOGIC ]] --
game:GetService("RunService").RenderStepped:Connect(function()
    if espActive then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                if not p.Character:FindFirstChild("Highlight") then
                    local h = Instance.new("Highlight", p.Character)
                    h.FillColor = Color3.fromRGB(255, 0, 0)
                end
            end
        end
    end
end)

-- [[ terehub | Ultimate Control Edition ]] --
-- UI Library: Rayfield

if not game:IsLoaded() then game.Loaded:Wait() end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "terehub | Ultimate Tester",
   LoadingTitle = "Booting terehub v3.0",
   LoadingSubtitle = "by David",
   ConfigurationSaving = { Enabled = true, FolderName = "terehub_configs", FileName = "ultimate_config" }
})

-- [[ GLOBAL VARIABLES ]] --
local flyActive = false
local flySpeed = 50
local infJump = false
local noclipActive = false

-- [[ TABS ]] --
local MoveTab = Window:CreateTab("Movement", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483345998)

-- [[ MOVEMENT: FLY, INF JUMP, NOCLIP ]] --

MoveTab:CreateToggle({
   Name = "Fly (Analog/Camera Direction)",
   CurrentValue = false,
   Callback = function(v)
      flyActive = v
      local char = game.Players.LocalPlayer.Character
      local hrp = char:FindFirstChild("HumanoidRootPart")
      
      if v then
          local bv = Instance.new("BodyVelocity", hrp)
          bv.Name = "terehub_Fly"
          bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
          
          task.spawn(function()
              while flyActive do
                  -- Bergerak ke arah kamera (Support Analog/Keyboard)
                  bv.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * flySpeed
                  task.wait()
              end
              bv:Destroy()
          end)
      end
   end,
})

MoveTab:CreateSlider({
   Name = "Fly Speed",
   Range = {10, 300},
   Increment = 5,
   CurrentValue = 50,
   Callback = function(v) flySpeed = v end,
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

-- [[ VISUALS ]] --
local espActive = false
VisualTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Callback = function(v) espActive = v end,
})

-- [[ LOGIC RUNTIME ]] --

-- Infinite Jump Logic
game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJump and game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Noclip & ESP Logic
game:GetService("RunService").Stepped:Connect(function()
    local char = game.Players.LocalPlayer.Character
    
    -- Noclip Logic
    if noclipActive and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    -- ESP Logic
    if espActive then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                if not p.Character:FindFirstChild("Highlight") then
                    local h = Instance.new("Highlight", p.Character)
                    h.FillColor = Color3.fromRGB(255, 0, 0)
                end
            end
        end
    end
end)


