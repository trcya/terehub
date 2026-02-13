local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "RockHub | Purple-Blue Edition",
   LoadingTitle = "RockHub v2.0",
   LoadingSubtitle = "by David",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "RockHubConfigs", 
      FileName = "DavidHub"
   },
   Discord = {
      Enabled = false,
      Invite = "", 
      RememberJoins = true 
   },
   KeySystem = false, -- Ubah ke true jika ingin pakai sistem key
})

-- Tab Utama
local MainTab = Window:CreateTab("🏠 Home", 4483362458) -- Icon ID
local Section = MainTab:CreateSection("Main Cheats")

-- Tombol Contoh: Speed
local SpeedSlider = MainTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 300},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "Slider1", 
   Callback = function(Value)
      game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
   end,
})

-- Tombol Contoh: Jump
local JumpSlider = MainTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 500},
   Increment = 1,
   Suffix = "Power",
   CurrentValue = 50,
   Flag = "Slider2", 
   Callback = function(Value)
      game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
   end,
})

-- Bagian Info (Sesuai gambar yang kamu mau)
local InfoTab = Window:CreateTab("📊 Network", 4483362458)
InfoTab:CreateLabel("Status: Connected")
InfoTab:CreateLabel("Current: 5.64 kB/s")
InfoTab:CreateLabel("Average: 7.75 kB/s")

Rayfield:Notify({
   Title = "RockHub Loaded!",
   Content = "Selamat datang, David! Script siap digunakan.",
   Duration = 5,
   Image = 4483362458,
   Actions = { 
      Ignore = {
         Name = "Okay!",
         Callback = function()
            print("User clicked Okay")
         end
      },
   },
})