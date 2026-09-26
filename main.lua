-- ĐỊNH VỊ QUÁI — Bắt mọi đối tượng kể cả không có Humanoid
local NgườiChơi = game.Players.LocalPlayer
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
    
    -- Từ khóa nhận diện quái — THÊM TÊN CON QUÁI Ở ĐÂY
    TừKhóa = {
        "quái", "monster", "enemy", "boss", "trùm", "bot",
        "kẻ thù", "dịch", "zombie", "skeleton", "goblin",
        "sói", "gấu", "rồng", "ma", "quỷ", "npc", "mob",
        "địch", "ke", "dich", "enemy_", "mon_", "mob_",
        "Trung", "Quai", "Con", "Vat", "Kẻ", "Thu"
    },
    
    -- Tìm theo thư mục chứa quái (thường game để tất cả quái vào 1 thư mục)
    ThưMụcChứaQuái = {"Quái", "Monsters", "Enemies", "Bosses", "Mobs", "NPCs", "Địch"},
    
    -- Tìm cả những Model có phần thân dù không có Humanoid
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
    -- Ưu tiên HumanoidRootPart
    if ĐốiTượng:FindFirstChild("HumanoidRootPart") then
        return ĐốiTượng.HumanoidRootPart
    end
    -- Tìm phần thân chính nếu không có Humanoid
    if ĐốiTượng:IsA("Model") then
        local PhầnChính = ĐốiTượng.PrimaryPart
        if PhầnChính then return PhầnChính end
        -- Tìm Part đầu tiên có kích thước lớn
        for _, v in ipairs(ĐốiTượng:GetChildren()) do
            if v:IsA("BasePart") and v.Size.Magnitude > 2 then
                return v
            end
        end
        -- Lấy Part bất kỳ
        for _, v in ipairs(ĐốiTượng:GetChildren()) do
            if v:IsA("BasePart") then return v end
        end
    end
    return nil
end

-- === KIỂM TRA CÓ PHẢI QUÁI ===
local function LàQuái(ĐốiTượng)
    -- Bỏ qua không phải Model
    if not ĐốiTượng:IsA("Model") then return false end
    -- Bỏ chính mình
    if CấuHình.BỏQuaChínhMình and ĐốiTượng == NhânVật then return false end
    -- Bỏ người chơi thật
    if CấuHình.BỏQuaNgườiChơi and DanhSáchNgườiChơi[ĐốiTượng] then return false end
    
    -- Kiểm tra theo tên
    local Tên = string.lower(ĐốiTượng.Name)
    for _, Từ in ipairs(CấuHình.TừKhóa) do
        if string.find(Tên, string.lower(Từ)) then return true end
    end
    
    -- Kiểm tra theo thư mục cha
    local Cha = ĐốiTượng.Parent
    while Cha and Cha ~= workspace do
        local TênCha = string.lower(Cha.Name)
        for _, Từ in ipairs(CấuHình.ThưMụcChứaQuái) do
            if string.find(TênCha, string.lower(Từ)) then return true end
        end
        Cha = Cha.Parent
    end
    
    -- Kiểm tra có dấu hiệu là nhân vật di chuyển được
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
        -- Có thân nhưng không phải người chơi → có thể là quái
        if CóPhầnThân and CóKíchThước and not ĐốiTượng:FindFirstChildWhichIsA("Humanoid") then
            -- Kiểm tra tên thư mục cha gần nhất
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
    Gui.Size = UDim2.new(0, 200, 0, 60)
    Gui.Parent = VịTrí
    
    local Chữ = Instance.new("TextLabel")
    Chữ.Size = UDim2.new(1,0,1,0)
    Chữ.BackgroundTransparency = 1
    Chữ.Font = Enum.Font.GothamBold
    Chữ.TextSize = 14
    Chữ.Parent = Gui
    
    DanhSáchĐánhDấu[ĐốiTượng] = {Gui = Gui, Chữ = Chữ, VịTríGốc = VịTrí}
end

-- === BỎ ĐÁNH DẤU ===
local function BỏĐánhDấu(ĐốiTượng)
    if DanhSáchĐánhDấu[ĐốiTượng] then
        DanhSáchĐánhDấu[ĐốiTượng].Gui:Destroy()
        DanhSáchĐánhDấu[ĐốiTượng] = nil
    end
end

-- === TẠO MENU ===
local Menu = Instance.new("ScreenGui")
Menu.Name = "DinhViKhongHumanoid"
Menu.Parent = NgườiChơi.PlayerGui

local Khung = Instance.new("Frame")
Khung.Size = UDim2.new(0, 260, 0, 320)
Khung.Position = UDim2.new(0.02, 0, 0.5, -160)
Khung.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Khung.CornerRadius = UDim.new(0, 12)
Khung.Parent = Menu

local TieuDe = Instance.new("TextLabel")
TieuDe.Size = UDim2.new(1, 0, 0, 50)
TieuDe.BackgroundColor3 = Color3.fromRGB(60, 40, 80)
TieuDe.Text = "🎯 ĐỊNH VỊ QUÁI — KHÔNG CẦN HUMANOID"
TieuDe.TextColor3 = Color3.new(1,1,1)
TieuDe.Font = Enum.Font.GothamBold
TieuDe.TextSize = 15
TieuDe.Parent = Khung

local NútBậtTắt = Instance.new("TextButton")
NútBậtTắt.Size = UDim2.new(0.9, 0, 0, 50)
NútBậtTắt.Position = UDim2.new(0.05, 0, 0, 60)
NútBậtTắt.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
NútBậtTắt.Text = "✅ ĐANG BẬT"
NútBậtTắt.TextColor3 = Color3.new(1,1,1)
NútBậtTắt.CornerRadius = UDim.new(0, 8)
NútBậtTắt.Parent = Khung

local ThôngTin = Instance.new("TextLabel")
ThôngTin.Size = UDim2.new(0.9, 0, 0, 190)
ThôngTin.Position = UDim2.new(0.05, 0, 0, 120)
ThôngTin.BackgroundTransparency = 1
ThôngTin.TextColor3 = Color3.fromRGB(200,200,200)
ThôngTin.Font = Enum.Font.Gotham
ThôngTin.TextSize = 12
ThôngTin.TextWrapped = true
ThôngTin.TextXAlignment = Enum.TextXAlignment.Left
ThôngTin.Parent = Khung

-- === NÚT BẬT/TẮT ===
NútBậtTắt.MouseButton1Click:Connect(function()
    CấuHình.BậtĐịnhVị = not CấuHình.BậtĐịnhVị
    NútBậtTắt.BackgroundColor3 = CấuHình.BậtĐịnhVị 
        and Color3.fromRGB(40, 180, 80) 
        or Color3.fromRGB(180, 40, 40)
    NútBậtTắt.Text = CấuHình.BậtĐịnhVị and "✅ ĐANG BẬT" or "❌ ĐANG TẮT"
    if not CấuHình.BậtĐịnhVị then
        for k in pairs(DanhSáchĐánhDấu) do BỏĐánhDấu(k) end
    end
end)

-- === CHẠY LIÊN TỤC ===
RS.Heartbeat:Connect(function()
    CậpNhậtNgườiChơi()
    
    -- Cập nhật nhân vật nếu đổi
    if not NhânVật or not NhânVật:FindFirstChild("HumanoidRootPart") then
        NhânVật = NgườiChơi.Character or NgườiChơi.CharacterAdded:Wait()
        VịTríNgười = NhânVật:FindFirstChild("HumanoidRootPart")
        return
    end
    if not CấuHình.BậtĐịnhVị or not VịTríNgười then return end

    local TìmThấy = {}
    local Đếm = 0
    local ĐếmBoss = 0
    local KhôngCóHumanoid = 0

    -- QUÉT TOÀN BỘ WORKSPACE
    for _, ĐốiTượng in ipairs(workspace:GetChildren()) do
        if LàQuái(ĐốiTượng) then
            table.insert(TìmThấy, ĐốiTượng)
            Đếm += 1
            if not ĐốiTượng:FindFirstChildWhichIsA("Humanoid") then
                KhôngCóHumanoid += 1
            end
        end
    end

    -- ĐÁNH DẤU
    for _, Quái in ipairs(TìmThấy) do
        local VịTrí = LấyVịTrí(Quái)
        if not VịTrí then continue end
        
        ĐánhDấu(Quái)
        local KC = math.floor((VịTríNgười.Position - VịTrí.Position).Magnitude)
        local LaBoss = LàBoss(Quái.Name)
        if LaBoss then ĐếmBoss += 1 end
        
        DanhSáchĐánhDấu[Quái].Chữ.Text = 
            (LaBoss and "👑 " or "🔴 ") .. Quái.Name .. "\n📏 " .. KC .. " studs" ..
            (not Quái:FindFirstChildWhichIsA("Humanoid") and " ⚡Không có Humanoid" or "")
        DanhSáchĐánhDấu[Quái].Chữ.TextColor3 = 
            LaBoss and CấuHình.MàuSắcBoss or CấuHình.MàuSắcQuái
    end

    -- XÓA NHỮNG CON KHÔNG CÒN
    for ĐốiTượng in pairs(DanhSáchĐánhDấu) do
        local Còn = false
        for _, Quái in ipairs(TìmThấy) do
            if Quái == ĐốiTượng then Còn = true end
        end
        if not Còn then BỏĐánhDấu(ĐốiTượng) end
    end

    -- HIỂN THỊ
    ThôngTin.Text = 
        "✅ Tổng: " .. Đếm .. " con quái\n" ..
        "⚡ Không có Humanoid: " .. KhôngCóHumanoid .. "\n" ..
        "👑 Boss: " .. ĐếmBoss .. "\n\n" ..
        "💡 Nếu còn thiếu: Mở Roblox Studio → tab Workspace →\n" ..
        "   Tìm con quái → ghi TÊN & TÊN THƯ MỤC CHA → gửi mình thêm"
end)

-- === ẨN/HIỆN MENU ===
UIS.InputBegan:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.B then
        Menu.Enabled = not Menu.Enabled
    end
end)

print("✅ Đã nạp! Bắt quái có & không có Humanoid")
