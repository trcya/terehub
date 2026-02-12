-- Memastikan game ter-load sepenuhnya
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Menggunakan Rayfield UI karena WindUI sedang mengalami gangguan server
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Admin Tester Panel | David",
   LoadingTitle = "Menyiapkan Panel Testing...",
   LoadingSubtitle = "by David",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "DavidScripts",
      FileName = "TesterPanel"
   },
   KeySystem = false -- Set ke true jika ingin menambahkan sistem kunci
})

-- Membuat Tab
local MainTab = Window:CreateTab("Movement", 4483362458) -- Icon ID: Walking
local VisualTab = Window:CreateTab("Visuals", 4483345998) -- Icon ID: Eye
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- [ TAB MOVEMENT ] --

MainTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 300},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "SliderSpeed", 
   Callback = function(Value)
      if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
          game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

MainTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 500},
   Increment = 1,
   Suffix = "Power",
   CurrentValue = 50,
   Flag = "SliderJump",
   Callback = function(Value)
      if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
          game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
          game.Players.LocalPlayer.Character.Humanoid.UseJumpPower = true
      end
   end,
})

local noclipActive = false
MainTab:CreateToggle({
   Name = "Noclip Mode",
   CurrentValue = false,
   Flag = "ToggleNoclip",
   Callback = function(Value)
      noclipActive = Value
   end,
})

-- [ TAB VISUALS ] --

local espActive = false
VisualTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "ToggleESP",
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

-- [ TAB SETTINGS ] --

SettingsTab:CreateButton({
   Name = "Rejoin Server",
   Callback = function()
      game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
   end,
})

-- [ LOGIC RUNTIME ] --

game:GetService("RunService").RenderStepped:Connect(function()
    local char = game.Players.LocalPlayer.Character
    
    -- Logic Noclip
    if noclipActive and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- Logic ESP
    if espActive then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                if not p.Character:FindFirstChild("Highlight") then
                    local h = Instance.new("Highlight", p.Character)
                    h.FillColor = Color3.fromRGB(255, 0, 0)
                    h.OutlineColor = Color3.fromRGB(255, 255, 255)
                    h.FillTransparency = 0.5
                end
            end
        end
    end
end)

-- Notifikasi Berhasil
Rayfield:Notify({
   Title = "David's Panel",
   Content = "Script berhasil dimuat menggunakan Rayfield UI!",
   Duration = 5,
   Image = 4483345998,
})