-- [[ terehub | Admin Tester Panel ]] --
-- UI Library: Rayfield

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "terehub | Anti-Cheat Tester",
   LoadingTitle = "Loading terehub...",
   LoadingSubtitle = "by David",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "terehub_configs",
      FileName = "tester_config"
   },
   KeySystem = false 
})

-- [[ TABS ]] --
local MoveTab = Window:CreateTab("Movement", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483345998)
local WorldTab = Window:CreateTab("World/Exploit", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- [[ TAB MOVEMENT ]] --

MoveTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 500},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value)
      if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
          game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

MoveTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 500},
   Increment = 1,
   CurrentValue = 50,
   Callback = function(Value)
      if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
          game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
          game.Players.LocalPlayer.Character.Humanoid.UseJumpPower = true
      end
   end,
})

local infJumpActive = false
MoveTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Callback = function(Value)
      infJumpActive = Value
   end,
})

-- Logic Infinite Jump
game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJumpActive then
        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- [[ TAB VISUALS ]] --

local espActive = false
VisualTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Callback = function(Value)
      espActive = Value
      if not Value then
          for _, p in pairs(game.Players:GetPlayers()) do
              if p.Character and p.Character:FindFirstChild("Highlight") then
                  p.Character.Highlight:Destroy()
              end
          end
      end
   end,
})

-- [[ TAB WORLD/EXPLOIT ]] --

local noclipActive = false
WorldTab:CreateToggle({
   Name = "Noclip Mode",
   CurrentValue = false,
   Callback = function(Value)
      noclipActive = Value
   end,
})

WorldTab:CreateButton({
   Name = "Click Teleport Tool",
   Callback = function()
      local mouse = game.Players.LocalPlayer:GetMouse()
      local tool = Instance.new("Tool")
      tool.RequiresHandle = false
      tool.Name = "terehub TP Tool"
      tool.Activated:Connect(function()
          local pos = mouse.Hit.p + Vector3.new(0, 3, 0)
          game.Players.LocalPlayer.Character:MoveTo(pos)
      end)
      tool.Parent = game.Players.LocalPlayer.Backpack
      Rayfield:Notify({Title = "Tool Added", Content = "Cek Backpack kamu!", Duration = 3})
   end,
})

WorldTab:CreateSlider({
   Name = "Gravity",
   Range = {0, 196},
   Increment = 1,
   CurrentValue = 196,
   Callback = function(Value)
      game.Workspace.Gravity = Value
   end,
})

-- [[ TAB SETTINGS ]] --

SettingsTab:CreateButton({
   Name = "Rejoin Server",
   Callback = function()
      game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
   end,
})

-- [[ LOGIC RUNTIME ]] --

game:GetService("RunService").RenderStepped:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if noclipActive and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
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

Rayfield:Notify({
   Title = "terehub Loaded",
   Content = "Selamat melakukan testing, David!",
   Duration = 5,
   Image = 4483345998,
})