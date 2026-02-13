-- [[ terecya | Admin Tester Fixed ]] --
-- Powered by David | Theme: Blue Ocean

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "terecya | Admin Tester",
   LoadingTitle = "Loading terecya Hub...",
   LoadingSubtitle = "by David",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "terecya_configs",
      FileName = "tester_config"
   },
   Theme = "Ocean" -- Tema Otomatis Berwarna Biru
})

-- [[ TABS ]] --
local MainTab = Window:CreateTab("Movement", "walking") 
local VisualTab = Window:CreateTab("Visuals", "eye")
local WorldTab = Window:CreateTab("Exploits", "zap")

-- [[ VARIABLES ]] --
local flyActive = false
local flySpeed = 50
local noclipActive = false
local espActive = false

-- [[ MOVEMENT: SPEED & JUMP ]] --
MainTab:CreateSlider({
   Name = "WalkSpeed Hack",
   Range = {16, 500},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Callback = function(Value)
      game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
   end,
})

MainTab:CreateSlider({
   Name = "JumpPower Hack",
   Range = {50, 500},
   Increment = 1,
   Suffix = "Power",
   CurrentValue = 50,
   Callback = function(Value)
      game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
      game.Players.LocalPlayer.Character.Humanoid.UseJumpPower = true
   end,
})

MainTab:CreateToggle({
   Name = "Analog Fly (Camera)",
   CurrentValue = false,
   Callback = function(Value)
      flyActive = Value
      local char = game.Players.LocalPlayer.Character
      local hrp = char and char:FindFirstChild("HumanoidRootPart")
      
      if Value and hrp then
         local bv = Instance.new("BodyVelocity")
         bv.Name = "terecya_Fly"
         bv.Parent = hrp
         bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
         
         task.spawn(function()
            while flyActive and hrp.Parent do
               bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * flySpeed
               task.wait()
            end
            if bv then bv:Destroy() end
         end)
      end
   end,
})

-- [[ VISUALS: ESP ]] --
VisualTab:CreateToggle({
   Name = "Player ESP (Box & Highlight)",
   CurrentValue = false,
   Callback = function(Value)
      espActive = Value
      if not Value then
         for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("terecya_ESP") then
               p.Character.terecya_ESP:Destroy()
            end
         end
      end
   end,
})

-- [[ EXPLOITS: NOCLIP ]] --
WorldTab:CreateToggle({
   Name = "Noclip (Tembus Tembok)",
   CurrentValue = false,
   Callback = function(Value)
      noclipActive = Value
   end,
})

-- [[ RUNTIME LOGIC ]] --

-- Loop Noclip & ESP
game:GetService("RunService").Stepped:Connect(function()
    -- Noclip Logic
    if noclipActive and game.Players.LocalPlayer.Character then
        for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then 
                part.CanCollide = false 
            end
        end
    end
    
    -- ESP Logic
    if espActive then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                if not p.Character:FindFirstChild("terecya_ESP") then
                    local h = Instance.new("Highlight")
                    h.Name = "terecya_ESP"
                    h.FillColor = Color3.fromRGB(0, 150, 255) --