-- [[ terehub | Anti-Cheat Tester Panel ]] --
-- Menggunakan Rayfield agar stabil dan tidak terkena 'Deployment Paused'

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "terehub | Anti-Cheat Tester", -- Nama sudah diubah
   LoadingTitle = "Menyiapkan terehub...",
   LoadingSubtitle = "by David",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "terehub_configs",
      FileName = "tester_config"
   }
})

-- TAB 1: MOVEMENT
local MoveTab = Window:CreateTab("Movement Testing", 4483362458)

MoveTab:CreateSlider({
   Name = "WalkSpeed Bypass",
   Range = {16, 500},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end,
})

local infJump = false
MoveTab:CreateToggle({
   Name = "Infinite Jump (Fly Test)",
   CurrentValue = false,
   Callback = function(v) infJump = v end,
})

-- TAB 2: EXPLOIT (Testing AC Physics)
local ExploitTab = Window:CreateTab("Exploits", 4483362458)

ExploitTab:CreateButton({
   Name = "Click TP Tool",
   Callback = function()
      local mouse = game.Players.LocalPlayer:GetMouse()
      local tool = Instance.new("Tool")
      tool.RequiresHandle = false
      tool.Name = "terehub TP"
      tool.Activated:Connect(function()
          game.Players.LocalPlayer.Character:MoveTo(mouse.Hit.p + Vector3.new(0, 3, 0))
      end)
      tool.Parent = game.Players.LocalPlayer.Backpack
   end,
})

-- Logic Runtime
game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJump then game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
end)

Rayfield:Notify({Title = "terehub Loaded", Content = "Siap untuk testing!", Duration = 5})