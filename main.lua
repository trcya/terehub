-- [[ terehub | Anti-Cheat Tester Panel ]] --
-- UI Library: Rayfield

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "terehub | Anti-Cheat Tester",
   LoadingTitle = "Loading terehub...",
   LoadingSubtitle = "by David (Junior Web Dev)",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "terehub_configs",
      FileName = "tester_config"
   }
})

-- TAB 1: MOVEMENT (Testing Speed/Fly Detection)
local MoveTab = Window:CreateTab("Movement Test", 4483362458)

MoveTab:CreateSlider({
   Name = "WalkSpeed Bypass",
   Info = "Gunakan untuk cek apakah AC menendang pemain saat speed > 16",
   Range = {16, 500},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value)
      if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
          game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

MoveTab:CreateToggle({
   Name = "Noclip (Physics Check)",
   Info = "Cek apakah AC mendeteksi pemain di dalam part/tembok",
   CurrentValue = false,
   Callback = function(Value)
      _G.Noclip = Value
      game:GetService("RunService").Stepped:Connect(function()
          if _G.Noclip and game.Players.LocalPlayer.Character then
              for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                  if part:IsA("BasePart") then part.CanCollide = false end
              end
          end
      end)
   end,
})

-- TAB 2: TELEPORT (Testing Position/Region AC)
local TpTab = Window:CreateTab("Teleport Test", 4483345998)

TpTab:CreateButton({
   Name = "Get TP Tool (Click TP)",
   Info = "Cek apakah AC mendeteksi perubahan posisi instan (Magnitude check)",
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
      Rayfield:Notify({Title = "Tool Added", Content = "Gunakan tool di backpack untuk TP!", Duration = 3})
   end,
})

-- TAB 3: VISUALS (Testing Instance Detection)
local VisualTab = Window:CreateTab("Visuals", 4483345998)

VisualTab:CreateToggle({
   Name = "Player ESP",
   Info = "Cek apakah AC mendeteksi penambahan objek 'Highlight' pada karakter",
   CurrentValue = false,
   Callback = function(Value)
      _G.ESP = Value
      if not Value then
          for _, p in pairs(game.Players:GetPlayers()) do
              if p.Character and p.Character:FindFirstChild("Highlight") then
                  p.Character.Highlight:Destroy()
              end
          end
      end
   end,
})

-- LOGIC RUNTIME ESP
task.spawn(function()
    while true do
        if _G.ESP then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= game.Players.LocalPlayer and p.Character and not p.Character:FindFirstChild("Highlight") then
                    Instance.new("Highlight", p.Character)
                end
            end
        end
        task.wait(1)
    end
end)

Rayfield:Notify({
   Title = "terehub Loaded",
   Content = "Siap untuk testing anti-cheat map!",
   Duration = 5,
   Image = 4483345998,
})