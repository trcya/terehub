-- Gunakan pcall agar jika ada error suara, script tidak mati total
pcall(function()
    local CoreGui = game:GetService("CoreGui")
    
    -- Pastikan UI lama dibersihkan agar tidak menumpuk error
    if CoreGui:FindFirstChild("RockHubDelta") then
        CoreGui.RockHubDelta:Destroy()
    end

    -- Jalankan script UI di sini (Gunakan kode yang saya berikan sebelumnya)
    -- ... (Copy paste bagian MainFrame dan seterusnya dari chat sebelumnya)
end)

print("RockHub: UI Attempted to Load")