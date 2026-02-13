-- [[ terecya | Admin Tester ]] --
-- Nama File: main.lua
-- Repo: github.com/trcya/terehub

local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or Rayfield == nil then
    warn("terecya Error: Gagal memuat UI Library. Pastikan koneksi internet stabil.")
    return
end

local Window = Rayfield:CreateWindow({
   Name = "terecya | Admin Tester",
   LoadingTitle = "terecya Hub",
   LoadingSubtitle = "by David",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "terecya_configs",
      FileName = "tester_config"
   },
   Theme = "Ocean" -- Tema Biru
})

-- [[ TABS ]] --
local MainTab = Window:CreateTab("Movement", "walking") 
local VisualTab = Window:CreateTab("Visuals", "eye")
local WorldTab = Window:CreateTab("Exploits", "zap")

-- [[ MOVEMENT FEATURES ]] --
local flyActive = false
local flySpeed = 50

MainTab:CreateSlider({
   Name = "WalkSpeed Hack",
   Range = {16, 500},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Callback = function(Value)
      if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
         game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end
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
         local bv = hrp:FindFirstChild("terecya_Fly") or Instance.new("BodyVelocity")
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

MainTab:CreateSlider({
   Name = "Fly Speed",
   Range = {10, 300},
   Increment = 1,
   CurrentValue = 50,
   Callback = function(v) flySpeed = v end
})

-- [[ VISUALS: ESP ]] --
local espActive = false
VisualTab:CreateToggle({
   Name = "Player ESP",
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
local noclipActive = false
WorldTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Callback = function(Value)
      noclipActive = Value
   end,
})

-- [[ RUNTIME LOGIC ]] --
game:GetService("RunService").Stepped:Connect(function()
    if noclipActive and game.Players.LocalPlayer.Character then
        for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    if espActive then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                if not p.Character:FindFirstChild("terecya_ESP") then
                    local h = Instance.new("Highlight", p.Character)
                    h.Name = "terecya_ESP"
                    h.FillColor = Color3.fromRGB(0, 150, 255)
                end
            end
        end
    end
end)

Rayfield:Notify({
   Title = "terecya Hub Berhasil Dimuat",
   Content = "Halo David, selamat menguji anti-cheat!",
   Duration = 5,
   Image = 4483362458,
})