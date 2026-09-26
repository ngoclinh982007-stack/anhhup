-- ĐỊNH VỊ QUÁI — PHIÊN BẢN TỐI ƯU CHO MOBILE
local NgườiChơi = game:GetService("Players").LocalPlayer

-- CHỜ GIAO DIỆN SẴN SÀNG TRƯỚC
local PlayerGui = NgườiChơi:WaitForChild("PlayerGui", 10)
if not PlayerGui then
    warn("❌ Không tìm thấy PlayerGui!")
    return
end

-- CHỜ NHÂN VẬT
local NhânVật = NgườiChơi.Character or NgườiChơi.CharacterAdded:Wait()
local VịTríNgười = NhânVật:FindFirstChild("HumanoidRootPart")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

-- === CÀI ĐẶT ===
local CấuHình = {
    BậtĐịnhVị = true,
    MàuSắcQuái = Color3.fromRGB(255, 0, 0),
    MàuSắcBoss = Color3.fromRGB(255, 215, 0),
    BỏQuaNgườiChơi = true,
    BỏQuaChínhMình = true,
    
    TừKhóa = {
        "quái", "monster", "enemy", "boss", "trùm", "bot",
        "kẻ thù", "dịch", "zombie", "skeleton", "goblin",
        "sói", "gấu", "rồng", "ma", "quỷ", "npc", "mob",
        "địch", "ke", "dich", "enemy_", "mon_", "mob_",
        "Trung", "Quai", "Con", "Vat", "Kẻ", "Thu"
    },
    
    ThưMụcChứaQuái = {"Quái", "Monsters", "Enemies", "Bosses", "Mobs", "NPCs", "Địch"},
    TìmTheoThânThể = true
}

local DanhSáchĐánhDấu = {}
local DanhSáchNgườiChơi = {}

-- === CẬP NHẬT DANH SÁCH NGƯỜI CHƠI ===
local function CậpNhậtNgườiChơi()
    table.clear(DanhSáchNgườiChơi)
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p.Character then
            DanhSáchNgườiChơi[p.Character] = true
        end
    end
end

-- === LẤY VỊ TRÍ ĐỐI TƯỢNG ===
local function LấyVịTrí(ĐốiTượng)
    if ĐốiTượng:FindFirstChild("HumanoidRootPart") then
        return ĐốiTượng.HumanoidRootPart
    end
    if ĐốiTượng:IsA("Model") then
        local PhầnChính = ĐốiTượng.PrimaryPart
        if PhầnChính then return PhầnChính end
        for _, v in ipairs(ĐốiTượng:GetChildren()) do
            if v:IsA("BasePart") and v.Size.Magnitude > 2 then
                return v
            end
        end
        for _, v in ipairs(ĐốiTượng:GetChildren()) do
            if v:IsA("BasePart") then return v end
        end
    end
    return nil
end

-- === KIỂM TRA QUÁI ===
local function LàQuái(ĐốiTượng)
    if not ĐốiTượng:IsA("Model") then return false end
    if CấuHình.BỏQuaChínhMình and ĐốiTượng == NhânVật then return false end
    if CấuHình.BỏQuaNgườiChơi and DanhSáchNgườiChơi[ĐốiTượng] then return false end
    
    local Tên = string.lower(ĐốiTượng.Name)
    for _, Từ in ipairs(CấuHình.TừKhóa) do
        if string.find(Tên, string.lower(Từ)) then return true end
    end
    
    local Cha = ĐốiTượng.Parent
    while Cha and Cha ~= workspace do
        local TênCha = string.lower(Cha.Name)
        for _, Từ in ipairs(CấuHình.ThưMụcChứaQuái) do
            if string.find(TênCha, string.lower(Từ)) then return true end
        end
        Cha = Cha.Parent
    end
    
    if CấuHình.TìmTheoThânThể then
        local CóPhầnThân = false
        local CóKíchThước = false
        for _, v in ipairs(ĐốiTượng:GetChildren()) do
            if v:IsA("BasePart") then
                CóPhầnThân = true
                if v.Size.X > 0.5 and v.Size.Y > 0.5 then
                    CóKíchThước = true
                end
            end
        end
        if CóPhầnThân and CóKíchThước and not ĐốiTượng:FindFirstChildWhichIsA("Humanoid") then
            local ChaGần = ĐốiTượng.Parent
            if ChaGần then
                local TênCG = string.lower(ChaGần.Name)
                for _, Từ in ipairs(CấuHình.TừKhóa) do
                    if string.find(TênCG, string.lower(Từ)) then return true end
                end
            end
        end
    end
    return false
end

-- === KIỂM TRA BOSS ===
local function LàBoss(Tên)
    local t = string.lower(Tên)
    return string.find(t, "boss") or string.find(t, "trùm") or string.find(t, "vua") or string.find(t, "chủ")
end

-- === ĐÁNH DẤU ===
local function ĐánhDấu(ĐốiTượng)
    if DanhSáchĐánhDấu[ĐốiTượng] then return end
    local VịTrí = LấyVịTrí(ĐốiTượng)
    if not VịTrí then return end
    
    local Gui = Instance.new("BillboardGui")
    Gui.AlwaysOnTop = true
    Gui.Size = UDim2.new(0, 220, 0, 70)
    Gui.Parent = VịTrí
    
    local Chữ = Instance.new("TextLabel")
    Chữ.Size = UDim2.new(1, 0, 1, 0)
    Chữ.BackgroundTransparency = 1
    Chữ.Font = Enum.Font.GothamBold
    Chữ.TextSize = 15
    Chữ.Parent = Gui
    
    DanhSáchĐánhDấu[ĐốiTượng] = {Gui = Gui, Chữ = Chữ}
end

-- === BỎ ĐÁNH DẤU ===
local function BỏĐánhDấu(ĐốiTượng)
    if DanhSáchĐánhDấu[ĐốiTượng] then
        DanhSáchĐánhDấu[ĐốiTượng].Gui:Destroy()
        DanhSáchĐánhDấu[ĐốiTượng] = nil
    end
end

-- === TẠO MENU — NÚT TO, DỄ BẤN CHO ĐIỆN THOẠI ===
local Menu = Instance.new("ScreenGui")
Menu.Name = "DinhViMobile"
Menu.ResetOnSpawn = false -- KHÔNG MẤT MENU KHI CHẾT
Menu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Menu.Parent = PlayerGui

-- NÚT BẬT/TẮT LỚN Ở GÓC MÀN HÌNH — DỄ BẤN
local NútChính = Instance.new("TextButton")
NútChính.Name = "NutChinh"
NútChính.Size = UDim2.new(0, 140, 0, 60)
NútChính.Position = UDim2.new(0.02, 0, 0.02, 0)
NútChính.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
NútChính.Text = "🎯 BẬT ĐỊNH VỊ"
NútChính.TextColor3 = Color3.new(1, 1, 1)
NútChính.Font = Enum.Font.GothamBold
NútChính.TextSize = 16
NútChính.CornerRadius = UDim.new(0, 12)
NútChính.AutoLocalize = false
NútChính.Parent = Menu

-- KHUNG THÔNG TIN
local KhungThôngTin = Instance.new("Frame")
KhungThôngTin.Size = UDim2.new(0, 280, 0, 200)
KhungThôngTin.Position = UDim2.new(0.02, 0, 0.12, 0)
KhungThôngTin.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
KhungThôngTin.CornerRadius = UDim.new(0, 12)
KhungThôngTin.Visible = true
KhungThôngTin.Parent = Menu

local ChữThôngTin = Instance.new("TextLabel")
ChữThôngTin.Size = UDim2.new(0.92, 0, 0.92, 0)
ChữThôngTin.Position = UDim2.new(0.04, 0, 0.04, 0)
ChữThôngTin.BackgroundTransparency = 1
ChữThôngTin.TextColor3 = Color3.fromRGB(220, 220, 220)
ChữThôngTin.Font = Enum.Font.Gotham
ChữThôngTin.TextSize = 14
ChữThôngTin.TextWrapped = true
ChữThôngTin.TextXAlignment = Enum.TextXAlignment.Left
ChữThôngTin.TextYAlignment = Enum.TextYAlignment.Top
ChữThôngTin.Parent = KhungThôngTin

-- === NÚT BẤN ===
NútChính.MouseButton1Click:Connect(function()
    CấuHình.BậtĐịnhVị = not CấuHình.BậtĐịnhVị
    if CấuHình.BậtĐịnhVị then
        NútChính.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        NútChính.Text = "✅ ĐANG BẬT"
    else
        NútChính.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        NútChính.Text = "❌ ĐANG TẮT"
        for k in pairs(DanhSáchĐánhDấu) do BỏĐánhDấu(k) end
    end
end)

-- === CHẠY ===
RS.Heartbeat:Connect(function()
    CậpNhậtNgườiChơi()
    
    if not NhânVật or not NhânVật:FindFirstChild("HumanoidRootPart") then
        NhânVật = NgườiChơi.Character or NgườiChơi.CharacterAdded:Wait()
        VịTríNgười = NhânVật:FindFirstChild("HumanoidRootPart")
        return
    end
    if not CấuHình.BậtĐịnhVị or not VịTríNgười then
        ChữThôngTin.Text = "⏸ Đang tắt"
        return
    end

    local TìmThấy = {}
    local Đếm = 0
    local ĐếmBoss = 0
    local KhôngHumanoid = 0

    for _, ĐốiTượng in ipairs(workspace:GetChildren()) do
        if LàQuái(ĐốiTượng) then
            table.insert(TìmThấy, ĐốiTượng)
            Đếm = Đếm + 1
            if not ĐốiTượng:FindFirstChildWhichIsA("Humanoid") then
                KhôngHumanoid = KhôngHumanoid + 1
            end
        end
    end

    for _, Quái in ipairs(TìmThấy) do
        local VịTrí = LấyVịTrí(Quái)
        if not VịTrí then continue end
        
        ĐánhDấu(Quái)
        local KC = math.floor((VịTríNgười.Position - VịTrí.Position).Magnitude)
        local LaBoss = LàBoss(Quái.Name)
        if LaBoss then ĐếmBoss = ĐếmBoss + 1 end
        
        DanhSáchĐánhDấu[Quái].Chữ.Text =
            (LaBoss and "👑 " or "🔴 ") .. Quái.Name .. "\n📏 " .. KC .. " studs" ..
            (not Quái:FindFirstChildWhichIsA("Humanoid") and " ⚡Không Humanoid" or "")
        DanhSáchĐánhDấu[Quái].Chữ.TextColor3 =
            LaBoss and CấuHình.MàuSắcBoss or CấuHình.MàuSắcQuái
    end

    for ĐốiTượng in pairs(DanhSáchĐánhDấu) do
        local Còn = false
        for _, Quái in ipairs(TìmThấy) do
            if Quái == ĐốiTượng then Còn = true end
        end
        if not Còn then BỏĐánhDấu(ĐốiTượng) end
    end

    ChữThôngTin.Text =
        "✅ TỔNG: " .. Đếm .. " con quái\n" ..
        "⚡ Không Humanoid: " .. KhôngHumanoid .. "\n" ..
        "👑 Boss: " .. ĐếmBoss .. "\n\n" ..
        "💡 Nút trên cùng = Bật/Tắt\n" ..
        "   Nếu thiếu: gửi TÊN + THƯ MỤC quái"
end)

print("✅ Đã nạp phiên bản MOBILE! Nút góc trên bên trái")
