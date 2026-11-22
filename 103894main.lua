-- ngôn ngữ: Lua, tệp: anon_hub_hop_nhat.lua, nền tảng: trình chạy Roblox (Synapse/Delta/Solara/Fluxus/Codex)
-- *BẢN HỢP NHẤT — toàn bộ chức năng trong 1 tệp duy nhất. Toàn Việt.*
-- *18 tab, ~300 chức năng. Chạy 1 lần, dùng ngay.*

local DichVuNguoiChoi = game:GetService("Players")
local DichVuVongLap = game:GetService("RunService")
local DichVuNhapLieu = game:GetService("UserInputService")
local DichVuChuyenDong = game:GetService("TweenService")
local DichVuAnhSang = game:GetService("Lighting")
local KhongGianLamViec = game:GetService("Workspace")
local DichVuNguoiDungAo = game:GetService("VirtualUser")
local DichVuGiaoDienGoc = game:GetService("StarterGui")
local DichVuThe = game:GetService("CollectionService")
local DichVuHttp = game:GetService("HttpService")
local DichVuDichChuyen = game:GetService("TeleportService")
local KhoLuuTruChung = game:GetService("ReplicatedStorage")
local DichVuAmThanh = game:GetService("SoundService")
local DichVuGoiY = game:GetService("ProximityPromptService")
local DichVuThiTruong = game:GetService("MarketplaceService")
local DichVuThongKe = game:GetService("Stats")

local NguoiChoi = DichVuNguoiChoi.LocalPlayer
local MayAnh = KhongGianLamViec.CurrentCamera
local TEP_LUAT = "anon_luat_esp.json"
local TEP_CAIDAT = "anon_caidat.json"

-- ============================================================
-- TIỆN DỤNG
-- ============================================================
local function thongBao(t, n, d)
    pcall(function()
        DichVuGiaoDienGoc:SetCore("SendNotification", { Title = t or "ANON HUB", Text = n or "", Duration = d or 2 })
    end)
end
local function layNhanVat() return NguoiChoi.Character or NguoiChoi.CharacterAdded:Wait() end
local function layNguoi() return layNhanVat():FindFirstChildOfClass("Humanoid") end
local function layThanNguoi() return layNhanVat():FindFirstChild("HumanoidRootPart") end

local tapNguoiChoi = {}
local function capNhatTapNguoiChoi()
    tapNguoiChoi = {}
    for _, p in pairs(DichVuNguoiChoi:GetPlayers()) do
        if p.Character then tapNguoiChoi[p.Character] = true end
    end
end

-- ============================================================
-- TRẠNG THÁI TOÀN BỘ
-- ============================================================
local TrangThai = {
    -- nhân vật
    chayNhanh = false, giaTriChay = 60,
    nhayCao = false, giaTriNhay = 100,
    bayLuon = false, tocDoBay = 80,
    xuyenVatThe = false, nhayVoHan = false,
    chongAfk = true, chongRoiMap = false,
    xoayNguoi = false, tocDoXoay = 8,
    nhayLienTuc = false,
    diTrenNuoc = false, loLung = false, doCaoLoLung = 5,
    nhapNhayTele = false,
    theoDoi = nil, khoangCachTheoDoi = 10,
    xoayQuanh = nil, banKinhXoay = 15, tocDoXoayQuanh = 3,
    -- chống
    chongDay = false, chongRagdoll = false, chongLamCham = false,
    chongTrongLuc = false, giaTriTrongLuc = 196.2,
    -- thế giới
    sangToiDa = false, troiToi = false, suongMu = false,
    -- esp
    espNguoiChoi = false, espQuai = false, espVatPham = false,
    espDuongNoi = false, espTen = false, espMau = false, espKhoangCach = false,
    espXuong = false,
    mauNguoiChoi = Color3.fromRGB(255, 80, 80),
    mauQuai = Color3.fromRGB(255, 180, 60),
    mauVatPham = Color3.fromRGB(100, 255, 160),
    mauDuongNoi = Color3.fromRGB(255, 100, 255),
    mauXuong = Color3.fromRGB(255, 100, 255),
    -- chiến đấu
    tuDongBam = false, tuDongDungTool = false,
    danhGan = false, phamViDanh = 15,
    ngamTuDong = false, doMuotNgam = 0.15, phamViNgam = 150,
    phanNgam = "Head",
    tuDongBan = false, doTreBan = 0.05,
    silentAim = false, phamViSilent = 200,
    -- nông trại
    tuDongHut = false, phamViHut = 50,
    tuDongGoiY = false,
    -- chat
    tuDongTraLoi = false, noiDungTraLoi = "Bot đang chơi",
    spamChat = false, noiDungSpam = "", chuKySpam = 2,
    -- nâng cao
    moRongHitbox = false, kichThuocHitbox = 2,
    ghiRemote = false,
    cameraTuDo = false, khoangCachCam = 20,
    banNhanh = false, doTreBanNhanh = 0.05,
    danVoHan = false,
    tuHoiSinh = false, tuTrangBi = false,
    -- giải trí
    cauVong = false,
    xoayCamera = false, tocDoXoayCamera = 5,
    khongDau = false,
    khongLo = false, tyLeKhongLo = 3,
    tiHon = false, tyLeTiHon = 0.3,
    -- server
    tuDongVaoLai = false,
    -- quét
    khoangQuet = 0.15,
}

local Luat = { quai = {}, vatPham = {} }

-- ============================================================
-- LƯU / ĐỌC
-- ============================================================
local function luuTatCa()
    if not writefile then return end
    pcall(function()
        writefile(TEP_LUAT, DichVuHttp:JSONEncode(Luat))
        writefile(TEP_CAIDAT, DichVuHttp:JSONEncode({
            giaTriChay = TrangThai.giaTriChay, giaTriNhay = TrangThai.giaTriNhay,
            tocDoBay = TrangThai.tocDoBay, phamViDanh = TrangThai.phamViDanh,
            doMuotNgam = TrangThai.doMuotNgam, phamViNgam = TrangThai.phamViNgam,
            phanNgam = TrangThai.phanNgam, phamViHut = TrangThai.phamViHut,
            khoangQuet = TrangThai.khoangQuet,
        }))
    end)
end
local function docTatCa()
    if not isfile or not readfile then return end
    pcall(function()
        if isfile(TEP_LUAT) then
            local d = DichVuHttp:JSONDecode(readfile(TEP_LUAT))
            if d.quai then Luat.quai = d.quai end
            if d.vatPham then Luat.vatPham = d.vatPham end
        end
        if isfile(TEP_CAIDAT) then
            local c = DichVuHttp:JSONDecode(readfile(TEP_CAIDAT))
            for k, v in pairs(c) do if TrangThai[k] ~= nil then TrangThai[k] = v end end
        end
    end)
end
docTatCa()

-- ============================================================
-- KHỚP DẤU HIỆU
-- ============================================================
local function dauHieuKhop(doiTuong, dau)
    if not doiTuong or not doiTuong.Parent then return false end
    if dau.lop and doiTuong.ClassName ~= dau.lop then
        local toTien = doiTuong:FindFirstAncestorOfClass(dau.lop)
        if not toTien then return false end
    end
    if dau.mauTen and dau.mauTen ~= "" then
        if not string.find(string.lower(doiTuong.Name), string.lower(dau.mauTen), 1, true) then
            local toTien = dau.lop and doiTuong:FindFirstAncestorOfClass(dau.lop)
            if not (toTien and string.find(string.lower(toTien.Name), string.lower(dau.mauTen), 1, true)) then return false end
        end
    end
    if dau.the and #dau.the > 0 then
        local co = false
        for _, t in ipairs(dau.the) do
            if DichVuThe:HasTag(doiTuong, t) then co = true; break end
        end
        if not co then return false end
    end
    if dau.thuocTinh then
        for k, v in pairs(dau.thuocTinh) do
            if doiTuong:GetAttribute(k) ~= v then return false end
        end
    end
    if dau.thuMucCha and dau.thuMucCha ~= "" then
        local p, tim = doiTuong.Parent, false
        for _ = 1, 6 do
            if not p or p == KhongGianLamViec or p == game then break end
            if string.lower(p.Name) == string.lower(dau.thuMucCha) then tim = true; break end
            p = p.Parent
        end
        if not tim then return false end
    end
    if dau.coNguoi ~= nil then
        if (doiTuong:FindFirstChildOfClass("Humanoid") ~= nil) ~= dau.coNguoi then return false end
    end
    if dau.phamViKichThuoc then
        local kt
        if doiTuong:IsA("BasePart") then kt = doiTuong.Size
        elseif doiTuong:IsA("Model") then
            local pp = doiTuong:FindFirstChildWhichIsA("BasePart"); if pp then kt = pp.Size end
        end
        if kt and (kt.Magnitude < dau.phamViKichThuoc.nho or kt.Magnitude > dau.phamViKichThuoc.lon) then return false end
    end
    return true
end
local function khopBatKy(doiTuong, ds)
    for _, d in ipairs(ds) do if dauHieuKhop(doiTuong, d) then return true end end
    return false
end
local function taoDauHieu(doiTuong)
    local moHinh = doiTuong:FindFirstAncestorOfClass("Model") or doiTuong
    local dau = {}
    if doiTuong:IsA("Tool") then dau.lop = "Tool"
    elseif moHinh:IsA("Model") then dau.lop = "Model"
    elseif doiTuong:IsA("BasePart") then dau.lop = "BasePart" end
    local ten = (dau.lop == "Model") and moHinh.Name or doiTuong.Name
    local tenSach = string.gsub(string.gsub(ten, "%d+", ""), "^%s*(.-)%s*$", "%1")
    if #tenSach >= 2 then dau.mauTen = tenSach end
    local the = {}
    for _, t in ipairs(DichVuThe:GetTags(doiTuong)) do table.insert(the, t) end
    if #the > 0 then dau.the = the end
    local tt = {}
    for k, v in pairs(doiTuong:GetAttributes()) do
        if type(v) == "string" or type(v) == "number" or type(v) == "boolean" then tt[k] = v end
    end
    if next(tt) then dau.thuocTinh = tt end
    local dich = (dau.lop == "Model") and moHinh or doiTuong
    if dich.Parent and dich.Parent ~= KhongGianLamViec and dich.Parent:IsA("Folder") then
        dau.thuMucCha = dich.Parent.Name
    end
    if dau.lop == "Model" then dau.coNguoi = (moHinh:FindFirstChildOfClass("Humanoid") ~= nil) end
    if doiTuong:IsA("BasePart") then
        local kt = doiTuong.Size.Magnitude
        dau.phamViKichThuoc = { nho = kt * 0.7, lon = kt * 1.4 }
    end
    return dau
end

-- ============================================================
-- GIAO DIỆN
-- ============================================================
local gocGiaoDien = (gethui and gethui()) or game:GetService("CoreGui")
local ManHinh = Instance.new("ScreenGui")
ManHinh.Name = "ANON_Hub_HopNhat"
ManHinh.ResetOnSpawn = false
ManHinh.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ManHinh.IgnoreGuiInset = true
ManHinh.Parent = gocGiaoDien

local Khung = Instance.new("Frame")
Khung.Size = UDim2.new(0, 280, 0, 460)
Khung.Position = UDim2.new(0, 40, 0, 80)
Khung.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
Khung.BorderSizePixel = 0
Khung.Active = true
Khung.Parent = ManHinh
Instance.new("UICorner", Khung).CornerRadius = UDim.new(0, 8)
local vien = Instance.new("UIStroke", Khung)
vien.Color = Color3.fromRGB(60, 60, 75); vien.Thickness = 1

local ThanhTieuDe = Instance.new("Frame")
ThanhTieuDe.Size = UDim2.new(1, 0, 0, 30)
ThanhTieuDe.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
ThanhTieuDe.Parent = Khung
Instance.new("UICorner", ThanhTieuDe).CornerRadius = UDim.new(0, 8)
local matNa = Instance.new("Frame")
matNa.Size = UDim2.new(1, 0, 0, 10); matNa.Position = UDim2.new(0, 0, 1, -10)
matNa.BackgroundColor3 = Color3.fromRGB(26, 26, 34); matNa.Parent = ThanhTieuDe

local TieuDe = Instance.new("TextLabel")
TieuDe.Size = UDim2.new(1, -60, 1, 0)
TieuDe.Position = UDim2.new(0, 12, 0, 0)
TieuDe.BackgroundTransparency = 1
TieuDe.Text = "ANON HUB — HỢP NHẤT"
TieuDe.TextColor3 = Color3.fromRGB(230, 230, 240)
TieuDe.Font = Enum.Font.GothamBold; TieuDe.TextSize = 12
TieuDe.TextXAlignment = Enum.TextXAlignment.Left
TieuDe.Parent = ThanhTieuDe

local NutThuNho = Instance.new("TextButton")
NutThuNho.Size = UDim2.new(0, 22, 0, 22)
NutThuNho.Position = UDim2.new(1, -28, 0, 4)
NutThuNho.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
NutThuNho.Text = "–"
NutThuNho.TextColor3 = Color3.fromRGB(220, 220, 230)
NutThuNho.Font = Enum.Font.GothamBold; NutThuNho.TextSize = 14
NutThuNho.Parent = ThanhTieuDe
Instance.new("UICorner", NutThuNho).CornerRadius = UDim.new(0, 4)

local ThanhTab = Instance.new("ScrollingFrame")
ThanhTab.Size = UDim2.new(1, 0, 0, 24)
ThanhTab.Position = UDim2.new(0, 0, 0, 30)
ThanhTab.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
ThanhTab.BorderSizePixel = 0
ThanhTab.ScrollBarThickness = 0
ThanhTab.CanvasSize = UDim2.new(0, 0, 0, 0)
ThanhTab.AutomaticCanvasSize = Enum.AutomaticSize.X
ThanhTab.ScrollingDirection = Enum.ScrollingDirection.X
ThanhTab.Parent = Khung
local boCucTab = Instance.new("UIListLayout", ThanhTab)
boCucTab.FillDirection = Enum.FillDirection.Horizontal
boCucTab.Padding = UDim.new(0, 2); boCucTab.SortOrder = Enum.SortOrder.LayoutOrder
local demTab = Instance.new("UIPadding", ThanhTab)
demTab.PaddingLeft = UDim.new(0, 4); demTab.PaddingTop = UDim.new(0, 2)

local NoiDung = Instance.new("ScrollingFrame")
NoiDung.Size = UDim2.new(1, -12, 1, -70)
NoiDung.Position = UDim2.new(0, 6, 0, 58)
NoiDung.BackgroundTransparency = 1; NoiDung.BorderSizePixel = 0
NoiDung.ScrollBarThickness = 4; NoiDung.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 95)
NoiDung.CanvasSize = UDim2.new(0, 0, 0, 0)
NoiDung.AutomaticCanvasSize = Enum.AutomaticSize.Y
NoiDung.Parent = Khung
local boCucNoiDung = Instance.new("UIListLayout", NoiDung)
boCucNoiDung.Padding = UDim.new(0, 5); boCucNoiDung.SortOrder = Enum.SortOrder.LayoutOrder

-- kéo thả
local dangKeo, diemBatDau, viTriBatDau
ThanhTieuDe.InputBegan:Connect(function(nhap)
    if nhap.UserInputType == Enum.UserInputType.MouseButton1
    or nhap.UserInputType == Enum.UserInputType.Touch then
        dangKeo = true; diemBatDau = nhap.Position; viTriBatDau = Khung.Position
        nhap.Changed:Connect(function()
            if nhap.UserInputState == Enum.UserInputState.End then dangKeo = false end
        end)
    end
end)
DichVuNhapLieu.InputChanged:Connect(function(nhap)
    if dangKeo and (nhap.UserInputType == Enum.UserInputType.MouseMovement
    or nhap.UserInputType == Enum.UserInputType.Touch) then
        local chenh = nhap.Position - diemBatDau
        Khung.Position = UDim2.new(viTriBatDau.X.Scale, viTriBatDau.X.Offset + chenh.X,
                                   viTriBatDau.Y.Scale, viTriBatDau.Y.Offset + chenh.Y)
    end
end)

local daThuNho = false
NutThuNho.MouseButton1Click:Connect(function()
    daThuNho = not daThuNho
    DichVuChuyenDong:Create(Khung, TweenInfo.new(0.2),
        { Size = daThuNho and UDim2.new(0, 280, 0, 30) or UDim2.new(0, 280, 0, 460) }):Play()
    NoiDung.Visible = not daThuNho; ThanhTab.Visible = not daThuNho
    NutThuNho.Text = daThuNho and "+" or "–"
end)

-- ============================================================
-- HÀM GIAO DIỆN
-- ============================================================
local danhSachTab = {}
local function taoTab(ten, bieuTuong)
    local nut = Instance.new("TextButton")
    nut.Size = UDim2.new(0, 60, 0, 18)
    nut.BackgroundColor3 = Color3.fromRGB(35, 35, 44)
    nut.Text = (bieuTuong and bieuTuong .. " " or "") .. ten
    nut.TextColor3 = Color3.fromRGB(180, 180, 190)
    nut.Font = Enum.Font.Gotham; nut.TextSize = 9
    nut.AutoButtonColor = false; nut.Parent = ThanhTab
    Instance.new("UICorner", nut).CornerRadius = UDim.new(0, 4)
    local khungCon = Instance.new("Frame")
    khungCon.Size = UDim2.new(1, 0, 1, 0)
    khungCon.BackgroundTransparency = 1; khungCon.Visible = false; khungCon.Parent = NoiDung
    local boCuc = Instance.new("UIListLayout", khungCon)
    boCuc.Padding = UDim.new(0, 4); boCuc.SortOrder = Enum.SortOrder.LayoutOrder
    danhSachTab[ten] = { nut = nut, khung = khungCon }
    nut.MouseButton1Click:Connect(function()
        for _, t in pairs(danhSachTab) do
            t.khung.Visible = false
            t.nut.BackgroundColor3 = Color3.fromRGB(35, 35, 44)
        end
        khungCon.Visible = true
        nut.BackgroundColor3 = Color3.fromRGB(60, 90, 140)
    end)
    return { nut = nut, khung = khungCon }
end

local function taoMuc(p, t)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 16)
    l.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    l.Text = "  " .. t
    l.TextColor3 = Color3.fromRGB(120, 200, 255)
    l.Font = Enum.Font.GothamBold; l.TextSize = 9
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = p
    Instance.new("UICorner", l).CornerRadius = UDim.new(0, 4)
end
local function taoNut(p, t, goi)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 24)
    b.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    b.Text = t; b.TextColor3 = Color3.fromRGB(210, 210, 220)
    b.Font = Enum.Font.Gotham; b.TextSize = 10; b.AutoButtonColor = false
    b.Parent = p
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(38, 38, 48) end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(28, 28, 36) end)
    b.MouseButton1Click:Connect(goi)
    return b
end
local function taoCongTac(p, t, macDinh, goi)
    local s = macDinh or false
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 24)
    b.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    b.Text = ""; b.AutoButtonColor = false; b.Parent = p
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local l = Instance.new("TextLabel", b)
    l.Size = UDim2.new(1, -50, 1, 0); l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = t; l.TextColor3 = Color3.fromRGB(210, 210, 220)
    l.Font = Enum.Font.Gotham; l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    local i = Instance.new("Frame", b)
    i.Size = UDim2.new(0, 26, 0, 12); i.Position = UDim2.new(1, -34, 0.5, -6)
    i.BackgroundColor3 = s and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(50, 50, 60)
    Instance.new("UICorner", i).CornerRadius = UDim.new(1, 0)
    local k = Instance.new("Frame", i)
    k.Size = UDim2.new(0, 10, 0, 10); k.Position = UDim2.new(0, s and 15 or 1, 0, 1)
    k.BackgroundColor3 = Color3.fromRGB(230, 230, 240)
    Instance.new("UICorner", k).CornerRadius = UDim.new(1, 0)
    b.MouseButton1Click:Connect(function()
        s = not s
        DichVuChuyenDong:Create(i, TweenInfo.new(0.15), {
            BackgroundColor3 = s and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(50, 50, 60) }):Play()
        DichVuChuyenDong:Create(k, TweenInfo.new(0.15), {
            Position = UDim2.new(0, s and 15 or 1, 0, 1) }):Play()
        if goi then goi(s) end
    end)
    return b
end
local function taoThanhTruot(p, t, nho, lon, macDinh, goi)
    local h = Instance.new("Frame", p)
    h.Size = UDim2.new(1, 0, 0, 38)
    h.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    Instance.new("UICorner", h).CornerRadius = UDim.new(0, 4)
    local l = Instance.new("TextLabel", h)
    l.Size = UDim2.new(1, -12, 0, 16); l.Position = UDim2.new(0, 8, 0, 2)
    l.BackgroundTransparency = 1
    l.Text = t .. ": " .. tostring(macDinh); l.TextColor3 = Color3.fromRGB(210, 210, 220)
    l.Font = Enum.Font.Gotham; l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    local thanh = Instance.new("Frame", h)
    thanh.Size = UDim2.new(1, -16, 0, 6); thanh.Position = UDim2.new(0, 8, 0, 26)
    thanh.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Instance.new("UICorner", thanh).CornerRadius = UDim.new(1, 0)
    local day = Instance.new("Frame", thanh)
    day.Size = UDim2.new((macDinh - nho) / (lon - nho), 0, 1, 0)
    day.BackgroundColor3 = Color3.fromRGB(120, 200, 255)
    Instance.new("UICorner", day).CornerRadius = UDim.new(1, 0)
    local dangKeo = false
    thanh.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then dangKeo = true end
    end)
    DichVuNhapLieu.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then dangKeo = false end
    end)
    DichVuNhapLieu.InputChanged:Connect(function(i)
        if dangKeo and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            local ty = math.clamp((i.Position.X - thanh.AbsolutePosition.X) / thanh.AbsoluteSize.X, 0, 1)
            day.Size = UDim2.new(ty, 0, 1, 0)
            local gt = nho + (lon - nho) * ty
            l.Text = t .. ": " .. string.format("%.2f", gt)
            if goi then goi(gt) end
        end
    end)
end
local function taoODien(p, goiY, goi)
    local b = Instance.new("Frame", p)
    b.Size = UDim2.new(1, 0, 0, 26)
    b.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local t = Instance.new("TextBox", b)
    t.Size = UDim2.new(1, -12, 1, -4); t.Position = UDim2.new(0, 6, 0, 2)
    t.BackgroundTransparency = 1; t.Text = ""; t.PlaceholderText = goiY
    t.TextColor3 = Color3.fromRGB(210, 210, 220)
    t.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
    t.Font = Enum.Font.Gotham; t.TextSize = 10
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ClearTextOnFocus = false
    t.FocusLost:Connect(function() if goi then goi(t.Text) end end)
    return t
end
local function taoChonMau(p, t, macDinh, goi)
    local h = Instance.new("Frame", p)
    h.Size = UDim2.new(1, 0, 0, 24)
    h.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    Instance.new("UICorner", h).CornerRadius = UDim.new(0, 4)
    local l = Instance.new("TextLabel", h)
    l.Size = UDim2.new(1, -50, 1, 0); l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = t; l.TextColor3 = Color3.fromRGB(210, 210, 220)
    l.Font = Enum.Font.Gotham; l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    local o = Instance.new("Frame", h)
    o.Size = UDim2.new(0, 20, 0, 12); o.Position = UDim2.new(1, -28, 0.5, -6)
    o.BackgroundColor3 = macDinh
    Instance.new("UICorner", o).CornerRadius = UDim.new(0, 3)
    local bang = { Color3.fromRGB(255, 80, 80), Color3.fromRGB(80, 200, 255),
                   Color3.fromRGB(100, 255, 160), Color3.fromRGB(255, 200, 60),
                   Color3.fromRGB(200, 100, 255), Color3.fromRGB(255, 255, 255) }
    local chiSo = 1
    for i, c in ipairs(bang) do if c == macDinh then chiSo = i end end
    h.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            chiSo = (chiSo % #bang) + 1
            o.BackgroundColor3 = bang[chiSo]
            if goi then goi(bang[chiSo]) end
        end
    end)
end

-- ============================================================
-- ESP ENGINE
-- ============================================================
local function datNoi(doiTuong, mau, ten)
    if not doiTuong or not doiTuong.Parent then return end
    if doiTuong:FindFirstChild(ten) then return end
    local hl = Instance.new("Highlight")
    hl.Name = ten; hl.Adornee = doiTuong
    hl.FillColor = mau; hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5; hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = doiTuong
end
local function xoaNoi(doiTuong, ten)
    if doiTuong and doiTuong:FindFirstChild(ten) then doiTuong[ten]:Destroy() end
end

-- tracer
local khungDuongNoi = Instance.new("ScreenGui")
khungDuongNoi.Name = "ANON_DuongNoi"; khungDuongNoi.ResetOnSpawn = false
khungDuongNoi.IgnoreGuiInset = true; khungDuongNoi.Parent = gocGiaoDien
local duongNoi = {}
local function capNhatDuongNoi()
    if not TrangThai.espDuongNoi then
        for _, t in pairs(duongNoi) do
            if typeof(t) == "Instance" then t:Destroy()
            elseif t.Remove then pcall(function() t:Remove() end) end
        end
        duongNoi = {}; return
    end
    for _, p in pairs(DichVuNguoiChoi:GetPlayers()) do
        if p ~= NguoiChoi and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local sp = MayAnh:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if sp.Z > 0 then
                local d = duongNoi[p]
                if not d then
                    if Drawing then
                        d = Drawing.new("Line")
                        d.Thickness = 1.5; d.Color = TrangThai.mauDuongNoi; d.Transparency = 1
                    else
                        d = Instance.new("Frame", khungDuongNoi)
                        d.BorderSizePixel = 0; d.BackgroundColor3 = TrangThai.mauDuongNoi
                    end
                    duongNoi[p] = d
                end
                local gx = MayAnh.ViewportSize.X / 2
                local gy = MayAnh.ViewportSize.Y
                if Drawing then
                    d.From = Vector2.new(gx, gy); d.To = Vector2.new(sp.X, sp.Y)
                    d.Color = TrangThai.mauDuongNoi; d.Visible = true
                else
                    local dx = sp.X - gx; local dy = sp.Y - gy
                    local dai = math.sqrt(dx*dx + dy*dy); local goc = math.atan2(dy, dx)
                    d.Position = UDim2.new(0, gx, 0, gy)
                    d.Size = UDim2.new(0, dai, 0, 1); d.Rotation = math.deg(goc)
                end
            else
                local d = duongNoi[p]
                if d and Drawing then d.Visible = false end
            end
        end
    end
end

-- xương
local khungXuong = Instance.new("ScreenGui")
khungXuong.Name = "ANON_Xuong"; khungXuong.ResetOnSpawn = false
khungXuong.IgnoreGuiInset = true; khungXuong.Parent = gocGiaoDien
local xuong = {}
local function capNhatXuong()
    if not TrangThai.espXuong then
        for _, ds in pairs(xuong) do
            for _, l in pairs(ds) do
                if typeof(l) == "Instance" then l:Destroy()
                elseif l.Remove then pcall(function() l:Remove() end) end
            end
        end
        xuong = {}; return
    end
    for _, p in pairs(DichVuNguoiChoi:GetPlayers()) do
        if p ~= NguoiChoi and p.Character then
            local c = p.Character
            local hrp = c:FindFirstChild("HumanoidRootPart")
            local dau = c:FindFirstChild("Head")
            local tayT = c:FindFirstChild("RightUpperArm") or c:FindFirstChild("Right Arm")
            local tayP = c:FindFirstChild("LeftUpperArm") or c:FindFirstChild("Left Arm")
            local chanT = c:FindFirstChild("RightUpperLeg") or c:FindFirstChild("Right Leg")
            local chanP = c:FindFirstChild("LeftUpperLeg") or c:FindFirstChild("Left Leg")
            if hrp and dau then
                local ds = xuong[p] or {}
                local khuc = { {hrp, dau}, {dau, tayT}, {dau, tayP}, {hrp, chanT}, {hrp, chanP} }
                for i, cap in ipairs(khuc) do
                    local a, b = cap[1], cap[2]
                    if a and b then
                        local sa = MayAnh:WorldToViewportPoint(a.Position)
                        local sb = MayAnh:WorldToViewportPoint(b.Position)
                        if sa.Z > 0 and sb.Z > 0 then
                            local l = ds[i]
                            if not l then
                                if Drawing then
                                    l = Drawing.new("Line")
                                    l.Thickness = 1.5; l.Color = TrangThai.mauXuong; l.Transparency = 1
                                else
                                    l = Instance.new("Frame", khungXuong)
                                    l.BorderSizePixel = 0; l.BackgroundColor3 = TrangThai.mauXuong
                                end
                                ds[i] = l
                            end
                            if Drawing then
                                l.From = Vector2.new(sa.X, sa.Y); l.To = Vector2.new(sb.X, sb.Y)
                                l.Color = TrangThai.mauXuong; l.Visible = true
                            else
                                local dx = sb.X - sa.X; local dy = sb.Y - sa.Y
                                local dai = math.sqrt(dx*dx + dy*dy); local goc = math.atan2(dy, dx)
                                l.Position = UDim2.new(0, sa.X, 0, sa.Y)
                                l.Size = UDim2.new(0, dai, 0, 1.5); l.Rotation = math.deg(goc)
                            end
                        end
                    end
                end
                xuong[p] = ds
            end
        end
    end
end

-- nhãn
local khungNhan = Instance.new("ScreenGui")
khungNhan.Name = "ANON_Nhan"; khungNhan.ResetOnSpawn = false
khungNhan.IgnoreGuiInset = true; khungNhan.Parent = gocGiaoDien
local nhan = {}
local function capNhatNhan()
    local bat = TrangThai.espTen or TrangThai.espMau or TrangThai.espKhoangCach
    if not bat then
        for _, l in pairs(nhan) do l:Destroy() end
        nhan = {}; return
    end
    for _, p in pairs(DichVuNguoiChoi:GetPlayers()) do
        if p ~= NguoiChoi and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local sp = MayAnh:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if sp.Z > 0 then
                local l = nhan[p]
                if not l then
                    l = Instance.new("TextLabel", khungNhan)
                    l.BackgroundTransparency = 1
                    l.Font = Enum.Font.GothamBold; l.TextSize = 10
                    l.TextColor3 = Color3.fromRGB(255, 255, 255)
                    l.TextStrokeTransparency = 0
                    l.Size = UDim2.new(0, 200, 0, 40)
                    l.TextXAlignment = Enum.TextXAlignment.Center
                    nhan[p] = l
                end
                local dong = {}
                if TrangThai.espTen then table.insert(dong, p.Name) end
                if TrangThai.espMau then
                    local n = p.Character:FindFirstChildOfClass("Humanoid")
                    if n then table.insert(dong, string.format("Máu: %d/%d", n.Health, n.MaxHealth)) end
                end
                if TrangThai.espKhoangCach then
                    local hrp = layThanNguoi()
                    if hrp then
                        local kc = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        table.insert(dong, string.format("%.0fm", kc))
                    end
                end
                l.Text = table.concat(dong, "\n")
                l.Position = UDim2.new(0, sp.X - 100, 0, sp.Y - 50)
                l.Visible = true
            else
                local l = nhan[p]; if l then l.Visible = false end
            end
        end
    end
end

local vongEsp, dangEsp, lanQuetTruoc = nil, false, 0
local function batDauEsp()
    if dangEsp then return end
    dangEsp = true
    vongEsp = DichVuVongLap.RenderStepped:Connect(function()
        local bh = tick()
        if bh - lanQuetTruoc >= TrangThai.khoangQuet then
            lanQuetTruoc = bh
            capNhatTapNguoiChoi()
            if TrangThai.espNguoiChoi then
                for _, p in pairs(DichVuNguoiChoi:GetPlayers()) do
                    if p ~= NguoiChoi and p.Character then datNoi(p.Character, TrangThai.mauNguoiChoi, "ANON_NC") end
                end
            else
                for _, p in pairs(DichVuNguoiChoi:GetPlayers()) do
                    if p.Character then xoaNoi(p.Character, "ANON_NC") end
                end
            end
            for _, o in pairs(KhongGianLamViec:GetDescendants()) do
                if (o:IsA("Model") or o:IsA("BasePart")) and not tapNguoiChoi[o] then
                    if TrangThai.espQuai and khopBatKy(o, Luat.quai) then datNoi(o, TrangThai.mauQuai, "ANON_Q")
                    elseif not TrangThai.espQuai then xoaNoi(o, "ANON_Q") end
                end
            end
            for _, o in pairs(KhongGianLamViec:GetDescendants()) do
                if o:IsA("Model") or o:IsA("BasePart") or o:IsA("Tool") then
                    if TrangThai.espVatPham and khopBatKy(o, Luat.vatPham) then datNoi(o, TrangThai.mauVatPham, "ANON_VP")
                    elseif not TrangThai.espVatPham then xoaNoi(o, "ANON_VP") end
                end
            end
        end
        capNhatDuongNoi(); capNhatXuong(); capNhatNhan()
    end)
end
local function dungEspNeuKhongDung()
    if not TrangThai.espNguoiChoi and not TrangThai.espQuai and not TrangThai.espVatPham
    and not TrangThai.espDuongNoi and not TrangThai.espTen and not TrangThai.espMau
    and not TrangThai.espKhoangCach and not TrangThai.espXuong then
        if vongEsp then vongEsp:Disconnect() end
        dangEsp = false
    end
end

-- học
local cheDoHoc, vongHoc = nil, nil
local goiY = Instance.new("TextLabel")
goiY.Size = UDim2.new(0, 400, 0, 36)
goiY.Position = UDim2.new(0.5, -200, 0, 60)
goiY.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
goiY.TextColor3 = Color3.fromRGB(120, 255, 160)
goiY.Font = Enum.Font.GothamBold; goiY.TextSize = 13
goiY.Visible = false; goiY.Parent = ManHinh
Instance.new("UICorner", goiY).CornerRadius = UDim.new(0, 6)
local vienGoiY = Instance.new("UIStroke", goiY)
vienGoiY.Color = Color3.fromRGB(80, 200, 120); vienGoiY.Thickness = 2

local function dungHoc()
    cheDoHoc = nil; goiY.Visible = false
    if vongHoc then vongHoc:Disconnect(); vongHoc = nil end
end
local function batDauHoc(loai)
    dungHoc(); cheDoHoc = loai
    goiY.Text = (loai == "quai") and "🎯 Nhấp vào QUÁI (ESC dừng)" or "🎯 Nhấp vào VẬT PHẨM (ESC dừng)"
    goiY.Visible = true
    vongHoc = DichVuNhapLieu.InputBegan:Connect(function(i, xl)
        if xl then return end
        if i.KeyCode == Enum.KeyCode.Escape then dungHoc(); return end
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local m = DichVuNhapLieu:GetMouseLocation()
        local tia = MayAnh:ViewportPointToRay(m.X, m.Y)
        local ts = RaycastParams.new()
        ts.FilterType = Enum.RaycastFilterType.Exclude
        ts.FilterDescendantsInstances = { layNhanVat(), ManHinh }
        local kq = KhongGianLamViec:Raycast(tia.Origin, tia.Direction * 1000, ts)
        if not kq or not kq.Instance then return end
        local nhap = kq.Instance
        local dich = nhap:IsA("Tool") and nhap or nhap:FindFirstAncestorOfClass("Model") or nhap
        local dau = taoDauHieu(dich)
        local chuoi = DichVuHttp:JSONEncode(dau)
        local ds = (loai == "quai") and Luat.quai or Luat.vatPham
        for _, e in ipairs(ds) do
            if DichVuHttp:JSONEncode(e) == chuoi then thongBao("ANON HUB", "Đã có luật này"); return end
        end
        table.insert(ds, dau)
        luuTatCa()
        if loai == "quai" then TrangThai.espQuai = true else TrangThai.espVatPham = true end
        batDauEsp()
        thongBao("ANON HUB", "✅ Đã học: " .. dich.Name, 2)
    end)
end

-- ============================================================
-- VÒNG LẶP
-- ============================================================
local vongHoatDong = {}
local function datVong(ten, fn)
    if vongHoatDong[ten] then vongHoatDong[ten]:Disconnect(); vongHoatDong[ten] = nil end
    if fn then vongHoatDong[ten] = fn() end
end

local function apChayNhanh()
    if TrangThai.chayNhanh then
        datVong("chay", function() return DichVuVongLap.Heartbeat:Connect(function()
            local n = layNguoi(); if n then n.WalkSpeed = TrangThai.giaTriChay end
        end) end)
    else datVong("chay", nil); local n = layNguoi(); if n then n.WalkSpeed = 16 end end
end
local function apNhayCao()
    if TrangThai.nhayCao then
        datVong("nhay", function() return DichVuVongLap.Heartbeat:Connect(function()
            local n = layNguoi(); if n then n.UseJumpPower = true; n.JumpPower = TrangThai.giaTriNhay end
        end) end)
    else datVong("nhay", nil); local n = layNguoi(); if n then n.JumpPower = 50 end end
end
local function apBay()
    if TrangThai.bayLuon then
        local hrp = layThanNguoi(); if not hrp then return end
        local bv = Instance.new("BodyVelocity", hrp)
        bv.Name = "ANON_Bay"; bv.MaxForce = Vector3.new(9e9, 9e9, 9e9); bv.Velocity = Vector3.zero
        datVong("bay", function() return DichVuVongLap.RenderStepped:Connect(function()
            local huong = Vector3.zero
            if DichVuNhapLieu:IsKeyDown(Enum.KeyCode.W) then huong += MayAnh.CFrame.LookVector end
            if DichVuNhapLieu:IsKeyDown(Enum.KeyCode.S) then huong -= MayAnh.CFrame.LookVector end
            if DichVuNhapLieu:IsKeyDown(Enum.KeyCode.A) then huong -= MayAnh.CFrame.RightVector end
            if DichVuNhapLieu:IsKeyDown(Enum.KeyCode.D) then huong += MayAnh.CFrame.RightVector end
            if DichVuNhapLieu:IsKeyDown(Enum.KeyCode.Space) then huong += Vector3.new(0, 1, 0) end
            if DichVuNhapLieu:IsKeyDown(Enum.KeyCode.LeftControl) then huong -= Vector3.new(0, 1, 0) end
            bv.Velocity = huong.Magnitude > 0 and huong.Unit * TrangThai.tocDoBay or Vector3.zero
        end) end)
    else
        datVong("bay", nil)
        local hrp = layThanNguoi()
        if hrp then local o = hrp:FindFirstChild("ANON_Bay"); if o then o:Destroy() end end
    end
end
local function apXuyenVat()
    if TrangThai.xuyenVatThe then
        datVong("xuyen", function() return DichVuVongLap.Stepped:Connect(function()
            local c = NguoiChoi.Character
            if c then for _, p in pairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end end
        end) end)
    else datVong("xuyen", nil) end
end
local function apNhayVoHan()
    if TrangThai.nhayVoHan then
        datVong("nhayvh", function() return DichVuNhapLieu.JumpRequest:Connect(function()
            local n = layNguoi(); if n then n:ChangeState(Enum.HumanoidStateType.Jumping) end
        end) end)
    else datVong("nhayvh", nil) end
end
local function apXoayNguoi()
    if TrangThai.xoayNguoi then
        datVong("xoay", function() return DichVuVongLap.Heartbeat:Connect(function()
            local hrp = layThanNguoi()
            if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(TrangThai.tocDoXoay), 0) end
        end) end)
    else datVong("xoay", nil) end
end
local function apNhayLienTuc()
    if TrangThai.nhayLienTuc then
        datVong("nhaylt", function() return DichVuVongLap.Heartbeat:Connect(function()
            local n = layNguoi()
            if n and n.FloorMaterial ~= Enum.Material.Air then n.Jump = true end
        end) end)
    else datVong("nhaylt", nil) end
end
local function apChongAfk()
    if TrangThai.chongAfk then
        local nva = NguoiChoi:FindFirstChildOfClass("VirtualUser") or Instance.new("VirtualUser", NguoiChoi)
        datVong("afk", function() return nva.Idled:Connect(function()
            nva:CaptureController(); nva:ClickButton2(Vector2.new())
        end) end)
    else datVong("afk", nil) end
end
local function apChongRoi()
    if TrangThai.chongRoiMap then
        datVong("roi", function() return DichVuVongLap.Heartbeat:Connect(function()
            local hrp = layThanNguoi()
            if hrp and hrp.Position.Y < -50 then hrp.CFrame = CFrame.new(0, 50, 0) end
        end) end)
    else datVong("roi", nil) end
end
local function apTuBam()
    if TrangThai.tuDongBam then
        datVong("bam", function() return DichVuVongLap.RenderStepped:Connect(function()
            DichVuNguoiDungAo:CaptureController(); DichVuNguoiDungAo:ClickButton1(Vector2.new())
        end) end)
    else datVong("bam", nil) end
end
local function apTuTool()
    if TrangThai.tuDongDungTool then
        datVong("tool", function() return DichVuVongLap.Heartbeat:Connect(function()
            local c = layNhanVat()
            if c then
                local t = c:FindFirstChildOfClass("Tool")
                if t then pcall(function() t:Activate() end) end
            end
        end) end)
    else datVong("tool", nil) end
end
local function apDanhGan()
    if TrangThai.danhGan then
        datVong("danhgan", function() return DichVuVongLap.Heartbeat:Connect(function()
            local c = layNhanVat(); local hrp = layThanNguoi()
            if not (c and hrp) then return end
            for _, p in pairs(DichVuNguoiChoi:GetPlayers()) do
                if p ~= NguoiChoi and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local thrp = p.Character.HumanoidRootPart
                    if (hrp.Position - thrp.Position).Magnitude <= TrangThai.phamViDanh then
                        local t = c:FindFirstChildOfClass("Tool")
                        if t then pcall(function() t:Activate() end) end
                    end
                end
            end
        end) end)
    else datVong("danhgan", nil) end
end
local function apNgamTuDong()
    if TrangThai.ngamTuDong then
        datVong("ngam", function() return DichVuVongLap.RenderStepped:Connect(function()
            local gan, khoang = nil, math.huge
            for _, p in pairs(DichVuNguoiChoi:GetPlayers()) do
                if p ~= NguoiChoi and p.Character then
                    local t = p.Character:FindFirstChild(TrangThai.phanNgam) or p.Character:FindFirstChild("HumanoidRootPart")
                    if t then
                        local sp = MayAnh:WorldToViewportPoint(t.Position)
                        if sp.Z > 0 then
                            local m = DichVuNhapLieu:GetMouseLocation()
                            local d = math.sqrt((sp.X - m.X)^2 + (sp.Y - m.Y)^2)
                            if d < TrangThai.phamViNgam and d < khoang then gan, khoang = t, d end
                        end
                    end
                end
            end
            if gan then MayAnh.CFrame = MayAnh.CFrame:Lerp(
                CFrame.new(MayAnh.CFrame.Position, gan.Position), TrangThai.doMuotNgam) end
        end) end)
    else datVong("ngam", nil) end
end
local function apTuBan()
    if TrangThai.tuDongBan then
        datVong("tuban", function() return DichVuVongLap.Heartbeat:Connect(function()
            local m = DichVuNhapLieu:GetMouseLocation()
            local tia = MayAnh:ViewportPointToRay(m.X, m.Y)
            local ts = RaycastParams.new()
            ts.FilterType = Enum.RaycastFilterType.Exclude
            ts.FilterDescendantsInstances = { layNhanVat() }
            local kq = KhongGianLamViec:Raycast(tia.Origin, tia.Direction * 1000, ts)
            if kq and kq.Instance then
                local c = kq.Instance:FindFirstAncestorOfClass("Model")
                local nguoi = c and DichVuNguoiChoi:GetPlayerFromCharacter(c)
                if nguoi and nguoi ~= NguoiChoi then
                    DichVuNguoiDungAo:CaptureController(); DichVuNguoiDungAo:ClickButton1(Vector2.new())
                    task.wait(TrangThai.doTreBan)
                end
            end
        end) end)
    else datVong("tuban", nil) end
end
local function apTuHut()
    if TrangThai.tuDongHut then
        datVong("hut", function() return DichVuVongLap.Heartbeat:Connect(function()
            local hrp = layThanNguoi(); if not hrp then return end
            for _, o in pairs(KhongGianLamViec:GetDescendants()) do
                if (o:IsA("Model") or o:IsA("BasePart")) and khopBatKy(o, Luat.vatPham) then
                    local vt
                    if o:IsA("BasePart") then vt = o.Position
                    else local pp = o:FindFirstChildWhichIsA("BasePart"); if pp then vt = pp.Position end end
                    if vt then
                        local kc = (hrp.Position - vt).Magnitude
                        if kc <= TrangThai.phamViHut and kc > 1 then
                            hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(vt + Vector3.new(0, 2, 0)), 0.15)
                        end
                    end
                end
            end
        end) end)
    else datVong("hut", nil) end
end
local function apTuGoiY()
    if TrangThai.tuDongGoiY then
        datVong("goiy", function() return DichVuGoiY.PromptShown:Connect(function(g)
            if g.Enabled then
                task.wait(0.1); pcall(function() g:InputHoldBegin() end)
                task.wait(g.HoldDuration + 0.05); pcall(function() g:InputHoldEnd() end)
            end
        end) end)
    else datVong("goiy", nil) end
end
local function apTuTraLoi()
    if TrangThai.tuDongTraLoi then
        datVong("traloi", function() return NguoiChoi.Chatted:Connect(function(_)
            pcall(function()
                if KhoLuuTruChung:FindFirstChild("DefaultChatSystemChatEvents") then
                    KhoLuuTruChung.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(TrangThai.noiDungTraLoi, "All")
                end
            end)
        end) end)
    else datVong("traloi", nil) end
end
local function apSpam()
    if TrangThai.spamChat and TrangThai.noiDungSpam ~= "" then
        datVong("spam", function() return task.spawn(function()
            while TrangThai.spamChat and TrangThai.noiDungSpam ~= "" do
                pcall(function()
                    if KhoLuuTruChung:FindFirstChild("DefaultChatSystemChatEvents") then
                        KhoLuuTruChung.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(TrangThai.noiDungSpam, "All")
                    end
                end)
                task.wait(TrangThai.chuKySpam)
            end
        end) end)
    else datVong("spam", nil) end
end
local function apMoRongHitbox()
    if TrangThai.moRongHitbox then
        datVong("hitbox", function() return DichVuVongLap.Heartbeat:Connect(function()
            for _, p in pairs(DichVuNguoiChoi:GetPlayers()) do
                if p ~= NguoiChoi and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.Size = Vector3.new(
                        TrangThai.kichThuocHitbox * 2, TrangThai.kichThuocHitbox * 2, TrangThai.kichThuocHitbox * 2) end
                end
            end
        end) end)
    else
        datVong("hitbox", nil)
        for _, p in pairs(DichVuNguoiChoi:GetPlayers()) do
            if p ~= NguoiChoi and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Size = Vector3.new(2, 2, 1) end
            end
        end
    end
end
local function apSilentAim()
    if TrangThai.silentAim then
        datVong("silent", function() return DichVuVongLap.RenderStepped:Connect(function()
            local gan, khoang = nil, math.huge
            for _, p in pairs(DichVuNguoiChoi:GetPlayers()) do
                if p ~= NguoiChoi and p.Character then
                    local t = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
                    if t then
                        local sp = MayAnh:WorldToViewportPoint(t.Position)
                        if sp.Z > 0 then
                            local m = DichVuNhapLieu:GetMouseLocation()
                            local d = math.sqrt((sp.X - m.X)^2 + (sp.Y - m.Y)^2)
                            if d < TrangThai.phamViSilent and d < khoang then gan, khoang = t, d end
                        end
                    end
                end
            end
            if gan then MayAnh.CFrame = CFrame.new(MayAnh.CFrame.Position, gan.Position) end
        end) end)
    else datVong("silent", nil) end
end
local function apCameraTuDo()
    if TrangThai.cameraTuDo then
        datVong("camtudo", function() return DichVuVongLap.RenderStepped:Connect(function()
            local hrp = layThanNguoi()
            if hrp then
                local huong = MayAnh.CFrame.LookVector
                MayAnh.CFrame = CFrame.new(hrp.Position - huong * TrangThai.khoangCachCam) * MayAnh.CFrame.Rotation
            end
        end) end)
    else datVong("camtudo", nil) end
end
local function apCauVong()
    if TrangThai.cauVong then
        datVong("cauvong", function()
            local sac = 0
            return DichVuVongLap.Heartbeat:Connect(function()
                sac = (sac + 0.005) % 1
                local mau = Color3.fromHSV(sac, 1, 1)
                local c = NguoiChoi.Character
                if c then for _, p in pairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.Color = mau end
                end end
            end)
        end)
    else datVong("cauvong", nil) end
end
local function apXoayCamera()
    if TrangThai.xoayCamera then
        datVong("xoaycam", function() return DichVuVongLap.RenderStepped:Connect(function()
            MayAnh.CFrame = MayAnh.CFrame * CFrame.Angles(0, math.rad(TrangThai.tocDoXoayCamera), 0)
        end) end)
    else datVong("xoaycam", nil) end
end
local function apDiTrenNuoc()
    if TrangThai.diTrenNuoc then
        datVong("nuoc", function() return DichVuVongLap.Heartbeat:Connect(function()
            local ch = NguoiChoi.Character
            if ch then for _, p in pairs(ch:GetDescendants()) do
                if p:IsA("BasePart") then p.CustomPhysicalProperties = PhysicalProperties.new(0.001, 0.3, 0.5, 1, 1) end
            end end
        end) end)
    else datVong("nuoc", nil) end
end
local function apLoLung()
    if TrangThai.loLung then
        local hrp = layThanNguoi(); if not hrp then return end
        local bp = Instance.new("BodyPosition", hrp)
        bp.Name = "ANON_LoLung"; bp.MaxForce = Vector3.new(9e9, 9e9, 9e9); bp.D = 500; bp.P = 3000
        datVong("lolung", function() return DichVuVongLap.Heartbeat:Connect(function()
            local h = layThanNguoi()
            if h and h:FindFirstChild("ANON_LoLung") then
                local tia = Ray.new(h.Position, Vector3.new(0, -1000, 0))
                local vat = KhongGianLamViec:FindPartOnRay(tia, NguoiChoi.Character)
                if vat then h.ANON_LoLung.Position = vat.Position + Vector3.new(0, TrangThai.doCaoLoLung, 0) end
            end
        end) end)
    else
        datVong("lolung", nil)
        local hrp = layThanNguoi()
        if hrp then local o = hrp:FindFirstChild("ANON_LoLung"); if o then o:Destroy() end end
    end
end
local function apChongDay()
    if TrangThai.chongDay then
        datVong("chongday", function() return DichVuVongLap.Heartbeat:Connect(function()
            local ch = NguoiChoi.Character
            if ch then
                local hrp = ch:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local vt = hrp.AssemblyLinearVelocity
                    if vt.Magnitude > 200 then hrp.AssemblyLinearVelocity = vt.Unit * 50 end
                end
            end
        end) end)
    else datVong("chongday", nil) end
end
local function apChongRagdoll()
    if TrangThai.chongRagdoll then
        datVong("chongrag", function() return DichVuVongLap.Heartbeat:Connect(function()
            local n = layNguoi()
            if n and n:GetState() == Enum.HumanoidStateType.Physics then
                n:ChangeState(Enum.HumanoidStateType.Running)
            end
        end) end)
    else datVong("chongrag", nil) end
end
local function apChongLamCham()
    if TrangThai.chongLamCham then
        datVong("chongcham", function() return DichVuVongLap.Heartbeat:Connect(function()
            local n = layNguoi()
            if n then for _, e in pairs(n:GetChildren()) do
                if e:IsA("StatusEffect") or e.Name == "Slow" then e:Destroy() end
            end end
        end) end)
    else datVong("chongcham", nil) end
end
local function apTuHoiSinh()
    if TrangThai.tuHoiSinh then
        datVong("tuhoisinh", function() return NguoiChoi.CharacterAdded:Connect(function()
            task.wait(1); thongBao("ANON HUB", "Đã hồi sinh", 1)
        end) end)
    else datVong("tuhoisinh", nil) end
end
local function apTuTrangBi()
    if TrangThai.tuTrangBi then
        datVong("tutrangbi", function() return DichVuVongLap.Heartbeat:Connect(function()
            local ch = NguoiChoi.Character
            local bp = NguoiChoi:FindFirstChildOfClass("Backpack")
            if ch and bp and not ch:FindFirstChildOfClass("Tool") then
                local t = bp:FindFirstChildOfClass("Tool")
                if t then pcall(function() ch.Humanoid:EquipTool(t) end) end
            end
        end) end)
    else datVong("tutrangbi", nil) end
end
local function apBanNhanh()
    if TrangThai.banNhanh then
        datVong("bannhanh", function() return DichVuVongLap.Heartbeat:Connect(function()
            local ch = NguoiChoi.Character
            if ch then
                local t = ch:FindFirstChildOfClass("Tool")
                if t then pcall(function() t:Activate() end); task.wait(TrangThai.doTreBanNhanh) end
            end
        end) end)
    else datVong("bannhanh", nil) end
end
local function apDanVoHan()
    if TrangThai.danVoHan then
        datVong("danvohan", function() return DichVuVongLap.Heartbeat:Connect(function()
            local ch = NguoiChoi.Character
            if ch then for _, o in pairs(ch:GetDescendants()) do
                if o:IsA("IntValue") and (o.Name:lower():find("ammo") or o.Name:lower():find("clip")) then o.Value = 9999 end
            end end
        end) end)
    else datVong("danvohan", nil) end
end

-- ============================================================
-- CÁC TAB
-- ============================================================

--/// 1. MẮT THẦN ///
local tabESP = taoTab("Mắt Thần", "👁️")
local c = tabESP.khung
taoMuc(c, "👁️ BẬT ESP")
taoCongTac(c, "ESP người chơi", false, function(v) TrangThai.espNguoiChoi = v; if v then batDauEsp() else dungEspNeuKhongDung() end end)
taoCongTac(c, "ESP quái", false, function(v) TrangThai.espQuai = v; if v then batDauEsp() else dungEspNeuKhongDung() end end)
taoCongTac(c, "ESP vật phẩm", false, function(v) TrangThai.espVatPham = v; if v then batDauEsp() else dungEspNeuKhongDung() end end)
taoMuc(c, "🎨 ESP NÂNG CAO")
taoCongTac(c, "Đường nối", false, function(v) TrangThai.espDuongNoi = v; if v then batDauEsp() else dungEspNeuKhongDung() end end)
taoCongTac(c, "Hiện tên", false, function(v) TrangThai.espTen = v; if v then batDauEsp() else dungEspNeuKhongDung() end end)
taoCongTac(c, "Hiện máu", false, function(v) TrangThai.espMau = v; if v then batDauEsp() else dungEspNeuKhongDung() end end)
taoCongTac(c, "Hiện khoảng cách", false, function(v) TrangThai.espKhoangCach = v; if v then batDauEsp() else dungEspNeuKhongDung() end end)
taoCongTac(c, "ESP xương", false, function(v) TrangThai.espXuong = v; if v then batDauEsp() else dungEspNeuKhongDung() end end)
taoMuc(c, "🎓 HỌC TỰ ĐỘNG")
taoNut(c, "🎯 Học QUÁI", function() batDauHoc("quai") end)
taoNut(c, "🎯 Học VẬT PHẨM", function() batDauHoc("vatPham") end)
taoMuc(c, "🎨 Màu sắc")
taoChonMau(c, "Màu người chơi", TrangThai.mauNguoiChoi, function(x) TrangThai.mauNguoiChoi = x end)
taoChonMau(c, "Màu quái", TrangThai.mauQuai, function(x) TrangThai.mauQuai = x end)
taoChonMau(c, "Màu vật phẩm", TrangThai.mauVatPham, function(x) TrangThai.mauVatPham = x end)
taoChonMau(c, "Màu đường nối", TrangThai.mauDuongNoi, function(x) TrangThai.mauDuongNoi = x end)
taoChonMau(c, "Màu xương", TrangThai.mauXuong, function(x) TrangThai.mauXuong = x end)
taoMuc(c, "📋 QUẢN LÝ LUẬT")
local nhanLuat = Instance.new("TextLabel", c)
nhanLuat.Size = UDim2.new(1, 0, 0, 26); nhanLuat.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
nhanLuat.TextColor3 = Color3.fromRGB(160, 220, 160); nhanLuat.Font = Enum.Font.Code; nhanLuat.TextSize = 9
nhanLuat.TextWrapped = true; nhanLuat.Parent = c
Instance.new("UICorner", nhanLuat).CornerRadius = UDim.new(0, 4)
local function capNhatLuat() nhanLuat.Text = "Quái: " .. #Luat.quai .. " | Vật phẩm: " .. #Luat.vatPham end
capNhatLuat()
taoNut(c, "📋 Xem luật (F9)", function()
    print("QUÁI:")
    for i, r in ipairs(Luat.quai) do print(i, DichVuHttp:JSONEncode(r)) end
    print("VẬT PHẨM:")
    for i, r in ipairs(Luat.vatPham) do print(i, DichVuHttp:JSONEncode(r)) end
end)
taoNut(c, "🗑️ Xóa luật quái cuối", function() if #Luat.quai > 0 then table.remove(Luat.quai); luuTatCa(); capNhatLuat() end end)
taoNut(c, "🗑️ Xóa luật vật phẩm cuối", function() if #Luat.vatPham > 0 then table.remove(Luat.vatPham); luuTatCa(); capNhatLuat() end end)
taoNut(c, "🧹 Xóa tất cả luật", function() Luat.quai = {}; Luat.vatPham = {}; luuTatCa(); capNhatLuat() end)
taoNut(c, "🧹 Xóa đánh dấu ESP", function()
    for _, o in pairs(KhongGianLamViec:GetDescendants()) do
        for _, n in ipairs({"ANON_NC","ANON_Q","ANON_VP"}) do
            if o:FindFirstChild(n) then o[n]:Destroy() end
        end
    end
end)

--/// 2. NHÂN VẬT ///
local tabNV = taoTab("Nhân Vật", "🏃")
local c = tabNV.khung
taoMuc(c, "🏃 Di chuyển")
taoCongTac(c, "Chạy nhanh", TrangThai.chayNhanh, function(v) TrangThai.chayNhanh = v; apChayNhanh() end)
taoThanhTruot(c, "Tốc độ chạy", 16, 500, TrangThai.giaTriChay, function(v) TrangThai.giaTriChay = v end)
taoCongTac(c, "Nhảy cao", TrangThai.nhayCao, function(v) TrangThai.nhayCao = v; apNhayCao() end)
taoThanhTruot(c, "Lực nhảy", 50, 1000, TrangThai.giaTriNhay, function(v) TrangThai.giaTriNhay = v end)
taoCongTac(c, "Nhảy vô hạn", false, function(v) TrangThai.nhayVoHan = v; apNhayVoHan() end)
taoCongTac(c, "Nhảy liên tục", false, function(v) TrangThai.nhayLienTuc = v; apNhayLienTuc() end)
taoMuc(c, "✈️ Bay")
taoCongTac(c, "Bay lượn", TrangThai.bayLuon, function(v) TrangThai.bayLuon = v; apBay() end)
taoThanhTruot(c, "Tốc độ bay", 10, 500, TrangThai.tocDoBay, function(v) TrangThai.tocDoBay = v end)
taoMuc(c, "🎯 Khác")
taoCongTac(c, "Xoay người", false, function(v) TrangThai.xoayNguoi = v; apXoayNguoi() end)
taoThanhTruot(c, "Tốc độ xoay", 1, 50, TrangThai.tocDoXoay, function(v) TrangThai.tocDoXoay = v end)
taoCongTac(c, "Xuyên vật thể", false, function(v) TrangThai.xuyenVatThe = v; apXuyenVat() end)
taoCongTac(c, "Chống rơi map", false, function(v) TrangThai.chongRoiMap = v; apChongRoi() end)
taoCongTac(c, "Chống AFK", TrangThai.chongAfk, function(v) TrangThai.chongAfk = v; apChongAfk() end)
taoNut(c, "🔄 Hồi sinh", function() local ch = layNhanVat(); if ch then ch:BreakJoints() end end)

--/// 3. THẾ GIỚI ///
local tabTG = taoTab("Thế Giới", "🌍")
local c = tabTG.khung
taoMuc(c, "🌍 Ánh sáng")
taoCongTac(c, "Sáng tối đa", false, function(v)
    if v then
        DichVuAnhSang.Brightness = 2; DichVuAnhSang.ClockTime = 14
        DichVuAnhSang.GlobalShadows = false
        DichVuAnhSang.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
    else
        DichVuAnhSang.GlobalShadows = true
        DichVuAnhSang.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
end)
taoCongTac(c, "Trời tối", false, function(v)
    DichVuAnhSang.Brightness = v and 0.3 or 2
    DichVuAnhSang.ClockTime = v and 0 or 14
end)
taoCongTac(c, "Sương mù dày", false, function(v) DichVuAnhSang.FogEnd = v and 100 or 100000 end)
taoMuc(c, "⏰ Thời gian")
taoNut(c, "☀️ Bình minh (6h)", function() DichVuAnhSang.ClockTime = 6 end)
taoNut(c, "🌇 Hoàng hôn (18h)", function() DichVuAnhSang.ClockTime = 18 end)
taoNut(c, "🌙 Nửa đêm (0h)", function() DichVuAnhSang.ClockTime = 0 end)
taoMuc(c, "🔊 Âm thanh")
taoNut(c, "🔇 Tắt âm thanh", function() pcall(function() DichVuAmThanh.Volume = 0 end) end)
taoNut(c, "🔊 Bật âm thanh", function() pcall(function() DichVuAmThanh.Volume = 1 end) end)

--/// 4. TIỆN ÍCH ///
local tabTI = taoTab("Tiện Ích", "🛠️")
local c = tabTI.khung
taoMuc(c, "📍 Dịch chuyển")
local viTriDaLuu = nil
taoNut(c, "💾 Lưu vị trí hiện tại", function() local hrp = layThanNguoi(); if hrp then viTriDaLuu = hrp.CFrame; thongBao("ANON HUB", "Đã lưu") end end)
taoNut(c, "⏪ Quay lại vị trí đã lưu", function() local hrp = layThanNguoi(); if hrp and viTriDaLuu then hrp.CFrame = viTriDaLuu end end)
local tenDich = ""
taoODien(c, "Nhập tên người chơi...", function(v) tenDich = v end)
taoNut(c, "🚀 Bay tới người chơi", function()
    local t = DichVuNguoiChoi:FindFirstChild(tenDich)
    if t and t.Character then
        local hrp = layThanNguoi(); local thrp = t.Character:FindFirstChild("HumanoidRootPart")
        if hrp and thrp then hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, 5) end
    else thongBao("ANON HUB", "Không tìm thấy") end
end)
taoNut(c, "👥 Kéo mọi người chơi tới đây", function()
    local hrp = layThanNguoi(); if not hrp then return end
    for _, p in pairs(DichVuNguoiChoi:GetPlayers()) do
        if p ~= NguoiChoi and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, -3)
        end
    end
end)
taoMuc(c, "💬 Trò chuyện")
local oChat = taoODien(c, "Tin nhắn...", function(v) end)
taoNut(c, "📤 Gửi tin nhắn", function()
    local tn = oChat.Text
    if tn and tn ~= "" then pcall(function()
        if KhoLuuTruChung:FindFirstChild("DefaultChatSystemChatEvents") then
            KhoLuuTruChung.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(tn, "All")
        end
    end) end
end)
taoCongTac(c, "Tự động trả lời", false, function(v) TrangThai.tuDongTraLoi = v; apTuTraLoi() end)
taoODien(c, "Nội dung trả lời", function(v) TrangThai.noiDungTraLoi = v end)
taoCongTac(c, "Spam chat", false, function(v) TrangThai.spamChat = v; apSpam() end)
taoODien(c, "Nội dung spam", function(v) TrangThai.noiDungSpam = v; if TrangThai.spamChat then apSpam() end end)
taoThanhTruot(c, "Chu kỳ spam (giây)", 1, 10, 2, function(v) TrangThai.chuKySpam = v; if TrangThai.spamChat then apSpam() end end)
taoMuc(c, "📋 Sao chép")
taoNut(c, "📋 Sao chép tên nhân vật", function() if setclipboard then setclipboard(NguoiChoi.Name) end end)
taoNut(c, "📋 Sao chép mã máy chủ", function() if setclipboard then setclipboard(game.JobId) end end)
taoNut(c, "📋 Sao chép mã địa điểm", function() if setclipboard then setclipboard(tostring(game.PlaceId)) end end)

--/// 5. CHIẾN ĐẤU ///
local tabCD = taoTab("Chiến Đấu", "⚔️")
local c = tabCD.khung
taoMuc(c, "⚔️ TỰ ĐỘNG")
taoCongTac(c, "Tự động bấm chuột", false, function(v) TrangThai.tuDongBam = v; apTuBam() end)
taoCongTac(c, "Tự động dùng tool", false, function(v) TrangThai.tuDongDungTool = v; apTuTool() end)
taoCongTac(c, "Đánh gần", false, function(v) TrangThai.danhGan = v; apDanhGan() end)
taoThanhTruot(c, "Phạm vi đánh", 5, 50, TrangThai.phamViDanh, function(v) TrangThai.phamViDanh = v end)
taoMuc(c, "🎯 NGẮM TỰ ĐỘNG")
taoCongTac(c, "Ngắm tự động", false, function(v) TrangThai.ngamTuDong = v; apNgamTuDong() end)
taoThanhTruot(c, "Độ mượt ngắm", 0.01, 1, TrangThai.doMuotNgam, function(v) TrangThai.doMuotNgam = v end)
taoThanhTruot(c, "Phạm vi ngắm", 10, 500, TrangThai.phamViNgam, function(v) TrangThai.phamViNgam = v end)
taoNut(c, "🎯 Nhắm đầu", function() TrangThai.phanNgam = "Head"; thongBao("ANON HUB", "Nhắm: Đầu") end)
taoNut(c, "🎯 Nhắm thân", function() TrangThai.phanNgam = "HumanoidRootPart"; thongBao("ANON HUB", "Nhắm: Thân") end)
taoMuc(c, "⚡ TỰ ĐỘNG BẮN")
taoCongTac(c, "Tự động bắn", false, function(v) TrangThai.tuDongBan = v; apTuBan() end)
taoThanhTruot(c, "Độ trễ bắn (giây)", 0.01, 1, TrangThai.doTreBan, function(v) TrangThai.doTreBan = v end)

--/// 6. NÔNG TRẠI ///
local tabFarm = taoTab("Nông Trại", "🌾")
local c = tabFarm.khung
taoMuc(c, "🌾 TỰ ĐỘNG")
taoCongTac(c, "Tự động hút vật phẩm", false, function(v) TrangThai.tuDongHut = v; apTuHut() end)
taoThanhTruot(c, "Phạm vi hút", 10, 200, TrangThai.phamViHut, function(v) TrangThai.phamViHut = v end)
taoCongTac(c, "Tự động tương tác (gợi ý)", false, function(v) TrangThai.tuDongGoiY = v; apTuGoiY() end)

--/// 7. NÂNG CAO ///
local tabNC = taoTab("Nâng Cao", "⚙️")
local c = tabNC.khung
taoMuc(c, "⚙️ HITBOX")
taoCongTac(c, "Mở rộng hitbox", false, function(v) TrangThai.moRongHitbox = v; apMoRongHitbox() end)
taoThanhTruot(c, "Kích thước hitbox", 1, 10, TrangThai.kichThuocHitbox, function(v) TrangThai.kichThuocHitbox = v end)
taoMuc(c, "🎯 SILENT AIM")
taoCongTac(c, "Silent aim", false, function(v) TrangThai.silentAim = v; apSilentAim() end)
taoThanhTruot(c, "Phạm vi silent", 50, 500, TrangThai.phamViSilent, function(v) TrangThai.phamViSilent = v end)
taoMuc(c, "📡 MẠNG")
taoCongTac(c, "Ghi log remote (F9)", false, function(v)
    TrangThai.ghiRemote = v
    if v and hookmetamethod and getnamecallmethod then
        local cu
        cu = hookmetamethod(game, "__namecall", function(tu, ...)
            local pt = getnamecallmethod()
            if not checkcaller() and (pt == "FireServer" or pt == "InvokeServer") then
                if tu:IsA("RemoteEvent") or tu:IsA("RemoteFunction") then
                    print("[REMOTE]", os.date("%H:%M:%S"), tu:GetFullName(), pt)
                end
            end
            return cu(tu, ...)
        end)
        thongBao("ANON HUB", "Đã bật ghi log remote", 2)
    elseif v then thongBao("ANON HUB", "Trình chạy không hỗ trợ hook", 3) end
end)
taoMuc(c, "🎥 CAMERA")
taoCongTac(c, "Camera tự do", false, function(v) TrangThai.cameraTuDo = v; apCameraTuDo() end)
taoThanhTruot(c, "Khoảng cách camera", 5, 100, TrangThai.khoangCachCam, function(v) TrangThai.khoangCachCam = v end)
taoMuc(c, "🔧 TOOL")
taoCongTac(c, "Bắn nhanh", false, function(v) TrangThai.banNhanh = v; apBanNhanh() end)
taoThanhTruot(c, "Độ trễ bắn nhanh", 0.01, 0.5, TrangThai.doTreBanNhanh, function(v) TrangThai.doTreBanNhanh = v end)
taoCongTac(c, "Đạn vô hạn", false, function(v) TrangThai.danVoHan = v; apDanVoHan() end)
taoMuc(c, "⚙️ TỰ ĐỘNG KHÁC")
taoCongTac(c, "Tự động hồi sinh", false, function(v) TrangThai.tuHoiSinh = v; apTuHoiSinh() end)
taoCongTac(c, "Tự động trang bị tool", false, function(v) TrangThai.tuTrangBi = v; apTuTrangBi() end)

--/// 8. MÁY CHỦ ///
local tabSV = taoTab("Máy Chủ", "🌐")
local c = tabSV.khung
taoMuc(c, "🌐")
taoNut(c, "🔄 Vào lại máy chủ", function() DichVuDichChuyen:Teleport(game.PlaceId, NguoiChoi) end)
taoNut(c, "🎲 Chuyển máy chủ khác", function()
    local ds = {}
    pcall(function() ds = DichVuHttp:JSONDecode(game:HttpGet(
        "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100")) end)
    if ds and ds.data then
        for _, s in pairs(ds.data) do
            if s.id ~= game.JobId and s.playing < s.maxPlayers then
                DichVuDichChuyen:TeleportToPlaceInstance(game.PlaceId, s.id, NguoiChoi); return
            end
        end
    end
    thongBao("ANON HUB", "Không tìm thấy máy chủ")
end)
taoNut(c, "📋 Liệt kê máy chủ (F9)", function()
    local ds = {}
    pcall(function() ds = DichVuHttp:JSONDecode(game:HttpGet(
        "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100")) end)
    if ds and ds.data then
        for i, s in ipairs(ds.data) do print(i, s.id, s.playing .. "/" .. s.maxPlayers, s.ping .. "ms") end
    end
end)
taoCongTac(c, "Tự động vào lại khi bị đá", false, function(v) TrangThai.tuDongVaoLai = v end)
taoMuc(c, "📊 Trạng thái")
local nhanTrangThai = Instance.new("TextLabel", c)
nhanTrangThai.Size = UDim2.new(1, 0, 0, 48); nhanTrangThai.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
nhanTrangThai.TextColor3 = Color3.fromRGB(160, 220, 160); nhanTrangThai.Font = Enum.Font.Code
nhanTrangThai.TextSize = 9; nhanTrangThai.TextWrapped = true; nhanTrangThai.Parent = c
Instance.new("UICorner", nhanTrangThai).CornerRadius = UDim.new(0, 4)
task.spawn(function()
    while nhanTrangThai.Parent do
        local ping = "Không rõ"
        pcall(function() ping = math.floor(DichVuThongKe.Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms" end)
        local fps = 0
        pcall(function() fps = math.floor(1 / DichVuVongLap.RenderStepped:Wait()) end)
        nhanTrangThai.Text = string.format("Người: %d | Ping: %s | FPS: %d\nGame: %s\nMáy chủ: %s",
            #DichVuNguoiChoi:GetPlayers(), ping, fps, tostring(game.PlaceId),
            string.sub(game.JobId, 1, 12) .. "...")
        task.wait(1)
    end
end)

--/// 9. GIAO DIỆN ///
local tabGUI = taoTab("Giao Diện", "🎨")
local c = tabGUI.khung
taoMuc(c, "🎨")
taoNut(c, "🎯 Ẩn/Hiện", function() Khung.Visible = not Khung.Visible end)
taoNut(c, "📌 Trái trên", function() Khung.Position = UDim2.new(0, 20, 0, 20) end)
taoNut(c, "📌 Phải trên", function() Khung.Position = UDim2.new(1, -300, 0, 20) end)
taoNut(c, "📌 Giữa màn hình", function() Khung.Position = UDim2.new(0.5, -140, 0.5, -230) end)
taoNut(c, "🔍 Đổi kích thước (280→320→360)", function()
    local k = Khung.Size.X.Offset
    local tiep = (k == 280) and 320 or (k == 320) and 360 or 280
    DichVuChuyenDong:Create(Khung, TweenInfo.new(0.2), { Size = UDim2.new(0, tiep, 0, 460) }):Play()
end)
taoNut(c, "❌ Đóng menu", function() ManHinh:Destroy() end)

--/// 10. CHẨN ĐOÁN ///
local tabCD2 = taoTab("Chẩn Đoán", "🔧")
local c = tabCD2.khung
taoMuc(c, "🔧")
taoNut(c, "🖱️ Nhấp in thông tin vật thể (F9)", function()
    local vong
    vong = DichVuNhapLieu.InputBegan:Connect(function(i, xl)
        if xl then return end
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local m = DichVuNhapLieu:GetMouseLocation()
        local tia = MayAnh:ViewportPointToRay(m.X, m.Y)
        local ts = RaycastParams.new()
        ts.FilterType = Enum.RaycastFilterType.Exclude
        ts.FilterDescendantsInstances = { layNhanVat(), ManHinh }
        local kq = KhongGianLamViec:Raycast(tia.Origin, tia.Direction * 1000, ts)
        if kq and kq.Instance then
            local doi = kq.Instance
            local moHinh = doi:FindFirstAncestorOfClass("Model") or doi
            print("=== CHẨN ĐOÁN ===")
            print("Phần:", doi:GetFullName(), "|", doi.ClassName)
            print("Mô hình:", moHinh:GetFullName(), "|", moHinh.ClassName)
            print("Có người:", moHinh:FindFirstChildOfClass("Humanoid") ~= nil)
            print("Kích thước:", doi.Size, "| Vị trí:", doi.Position)
            print("Thuộc tính:")
            for k, v in pairs(doi:GetAttributes()) do print("  ", k, "=", tostring(v)) end
            print("Thẻ:", table.concat(DichVuThe:GetTags(doi), ", "))
            print("Chuỗi cha:")
            local p = doi
            for _ = 1, 8 do
                if not p or p == game then break end
                print("  ", p.Name, "(" .. p.ClassName .. ")")
                p = p.Parent
            end
            print("=== HẾT ===")
        end
    end)
    task.delay(30, function() if vong then vong:Disconnect() end end)
end)
taoNut(c, "📊 Liệt kê mọi mô hình (F9)", function()
    local n = 0
    for _, o in pairs(KhongGianLamViec:GetDescendants()) do
        if o:IsA("Model") then
            n = n + 1
            print(o.Name, "Có người=" .. tostring(o:FindFirstChildOfClass("Humanoid") ~= nil), "|", o:GetFullName())
        end
    end
    print("Tổng:", n)
end)
taoNut(c, "🔍 Liệt kê mọi tool (F9)", function()
    local n = 0
    for _, o in pairs(game:GetDescendants()) do
        if o:IsA("Tool") then n = n + 1; print(o:GetFullName()) end
    end
    print("Tổng:", n)
end)
taoNut(c, "📁 Liệt kê Folder Workspace (F9)", function()
    print("=== FOLDER WORKSPACE ===")
    for _, f in pairs(KhongGianLamViec:GetChildren()) do
        print(" ", f.ClassName, "|", f.Name, "| Số con:", #f:GetChildren())
    end
end)
taoNut(c, "📡 Liệt kê Remote (F9)", function()
    print("=== REMOTE ===")
    local dem = 0
    for _, o in pairs(game:GetDescendants()) do
        if o:IsA("RemoteEvent") or o:IsA("RemoteFunction") then
            dem = dem + 1; print(" ", o.ClassName, "|", o:GetFullName())
        end
    end
    print("Tổng:", dem)
end)
local tenTim = ""
taoODien(c, "Nhập tên cần tìm...", function(v) tenTim = v end)
taoNut(c, "🔍 Tìm trong Workspace", function()
    if tenTim == "" then return end
    print("=== TÌM:", tenTim, "===")
    local dem = 0
    for _, o in pairs(KhongGianLamViec:GetDescendants()) do
        if string.find(string.lower(o.Name), string.lower(tenTim), 1, true) then
            dem = dem + 1; print(" ", o.ClassName, "|", o:GetFullName())
        end
    end
    print("Tìm thấy:", dem)
end)
taoNut(c, "🚀 Teleport tới vật đầu tiên tìm được", function()
    if tenTim == "" then return end
    for _, o in pairs(KhongGianLamViec:GetDescendants()) do
        if string.find(string.lower(o.Name), string.lower(tenTim), 1, true) then
            local pp
            if o:IsA("BasePart") then pp = o
            elseif o:IsA("Model") then pp = o:FindFirstChildWhichIsA("BasePart") end
            if pp then
                local hrp = layThanNguoi()
                if hrp then hrp.CFrame = pp.CFrame + Vector3.new(0, 3, 0); thongBao("ANON HUB", "Đã tới: " .. o.Name, 2) end
                return
            end
        end
    end
end)

--/// 11. GIẢI TRÍ ///
local tabGT = taoTab("Giải Trí", "🎉")
local c = tabGT.khung
taoMuc(c, "🌈 Hiệu ứng")
taoCongTac(c, "Cầu vồng", false, function(v) TrangThai.cauVong = v; apCauVong() end)
taoCongTac(c, "Xoay camera", false, function(v) TrangThai.xoayCamera = v; apXoayCamera() end)
taoThanhTruot(c, "Tốc độ xoay camera", 1, 30, TrangThai.tocDoXoayCamera, function(v) TrangThai.tocDoXoayCamera = v end)
taoMuc(c, "📏 Kích thước")
taoCongTac(c, "Không đầu", false, function(v)
    local ch = NguoiChoi.Character
    if ch and v then
        local dau = ch:FindFirstChild("Head")
        if dau then
            dau.Transparency = 1
            local mat = dau:FindFirstChild("face"); if mat then mat:Destroy() end
        end
    end
end)
taoCongTac(c, "Khổng lồ (x3)", false, function(v)
    TrangThai.khongLo = v
    local ch = NguoiChoi.Character
    if ch and v then
        local n = ch:FindFirstChildOfClass("Humanoid")
        if n then
            for _, ten in ipairs({"BodyDepthScale", "BodyWidthScale", "BodyHeightScale", "BodyHeadScale"}) do
                local o = n:FindFirstChild(ten) or Instance.new("NumberValue", n)
                o.Name = ten; o.Value = TrangThai.tyLeKhongLo
            end
        end
    end
end)
taoThanhTruot(c, "Tỷ lệ khổng lồ", 1.5, 10, TrangThai.tyLeKhongLo, function(v) TrangThai.tyLeKhongLo = v end)
taoCongTac(c, "Tí hon (x0.3)", false, function(v)
    TrangThai.tiHon = v
    local ch = NguoiChoi.Character
    if ch and v then
        local n = ch:FindFirstChildOfClass("Humanoid")
        if n then
            for _, ten in ipairs({"BodyDepthScale", "BodyWidthScale", "BodyHeightScale", "BodyHeadScale"}) do
                local o = n:FindFirstChild(ten) or Instance.new("NumberValue", n)
                o.Name = ten; o.Value = TrangThai.tyLeTiHon
            end
        end
    end
end)
taoThanhTruot(c, "Tỷ lệ tí hon", 0.1, 1, TrangThai.tyLeTiHon, function(v) TrangThai.tyLeTiHon = v end)
taoMuc(c, "🔊")
taoNut(c, "🎵 Bật nhạc nền", function()
    local s = Instance.new("Sound", DichVuAmThanh)
    s.Name = "ANON_Nhac"; s.SoundId = "rbxassetid://1837879082"
    s.Looped = true; s.Volume = 0.3; s:Play()
end)
taoNut(c, "🔊 Phát âm thanh test", function()
    local s = Instance.new("Sound", KhongGianLamViec)
    s.SoundId = "rbxassetid://131961136"; s.Volume = 5; s:Play()
    task.delay(3, function() s:Destroy() end)
end)
taoNut(c, "🎨 Đổi màu ngẫu nhiên", function()
    local ch = NguoiChoi.Character
    if ch then for _, p in pairs(ch:GetDescendants()) do
        if p:IsA("BasePart") then
            p.Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
        end
    end end
end)

--/// 12. DI CHUYỂN ///
local tabDC = taoTab("Di Chuyển", "🏊")
local c = tabDC.khung
taoMuc(c, "🌊 Nước / Dung nham")
taoCongTac(c, "Đi trên nước", false, function(v) TrangThai.diTrenNuoc = v; apDiTrenNuoc() end)
taoMuc(c, "🪁 Lơ lửng")
taoCongTac(c, "Lơ lửng", false, function(v) TrangThai.loLung = v; apLoLung() end)
taoThanhTruot(c, "Độ cao lơ lửng", 1, 50, TrangThai.doCaoLoLung, function(v) TrangThai.doCaoLoLung = v end)
taoMuc(c, "📍 Teleport")
taoCongTac(c, "Nhấp để teleport", false, function(v)
    TrangThai.nhapNhayTele = v
    if v then
        datVong("tptele", function() return DichVuNhapLieu.InputBegan:Connect(function(i, xl)
            if xl then return end
            if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            local m = DichVuNhapLieu:GetMouseLocation()
            local tia = MayAnh:ViewportPointToRay(m.X, m.Y)
            local ts = RaycastParams.new()
            ts.FilterType = Enum.RaycastFilterType.Exclude
            ts.FilterDescendantsInstances = { layNhanVat(), ManHinh }
            local kq = KhongGianLamViec:Raycast(tia.Origin, tia.Direction * 1000, ts)
            if kq and kq.Instance then
                local hrp = layThanNguoi()
                if hrp then hrp.CFrame = CFrame.new(kq.Position + Vector3.new(0, 3, 0)) end
            end
        end) end)
    else datVong("tptele", nil) end
end)
taoMuc(c, "👥 Theo dõi / Xoay quanh")
taoODien(c, "Tên người chơi để theo dõi...", function(v)
    TrangThai.theoDoi = v ~= "" and v or nil
    if TrangThai.theoDoi then
        datVong("theodoi", function() return DichVuVongLap.Heartbeat:Connect(function()
            local t = DichVuNguoiChoi:FindFirstChild(TrangThai.theoDoi)
            if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = layThanNguoi()
                if hrp then
                    local dich = t.Character.HumanoidRootPart.Position
                    local mongMuon = dich + (hrp.Position - dich).Unit * TrangThai.khoangCachTheoDoi
                    hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(mongMuon), 0.15)
                end
            end
        end) end)
    else datVong("theodoi", nil) end
end)
taoThanhTruot(c, "Khoảng cách theo dõi", 3, 50, TrangThai.khoangCachTheoDoi, function(v) TrangThai.khoangCachTheoDoi = v end)
taoODien(c, "Tên để xoay quanh...", function(v)
    TrangThai.xoayQuanh = v ~= "" and v or nil
    if TrangThai.xoayQuanh then
        local goc = 0
        datVong("xoayquanh", function() return DichVuVongLap.Heartbeat:Connect(function(dt)
            goc = goc + dt * TrangThai.tocDoXoayQuanh
            local t = DichVuNguoiChoi:FindFirstChild(TrangThai.xoayQuanh)
            if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                local tam = t.Character.HumanoidRootPart.Position
                local vt = tam + Vector3.new(math.cos(goc) * TrangThai.banKinhXoay, 3, math.sin(goc) * TrangThai.banKinhXoay)
                local hrp = layThanNguoi()
                if hrp then hrp.CFrame = CFrame.new(vt, tam) end
            end
        end) end)
    else datVong("xoayquanh", nil) end
end)
taoThanhTruot(c, "Bán kính xoay", 5, 100, TrangThai.banKinhXoay, function(v) TrangThai.banKinhXoay = v end)
taoThanhTruot(c, "Tốc độ xoay", 0.5, 20, TrangThai.tocDoXoayQuanh, function(v) TrangThai.tocDoXoayQuanh = v end)

--/// 13. CHỐNG ///
local tabChong = taoTab("Chống", "🛡️")
local c = tabChong.khung
taoMuc(c, "🛡️ Chống hiệu ứng xấu")
taoCongTac(c, "Chống bị đẩy", false, function(v) TrangThai.chongDay = v; apChongDay() end)
taoCongTac(c, "Chống ragdoll", false, function(v) TrangThai.chongRagdoll = v; apChongRagdoll() end)
taoCongTac(c, "Chống làm chậm", false, function(v) TrangThai.chongLamCham = v; apChongLamCham() end)
taoMuc(c, "🌍 Trọng lực")
taoCongTac(c, "Chỉnh trọng lực", false, function(v)
    TrangThai.chongTrongLuc = v
    KhongGianLamViec.Gravity = v and TrangThai.giaTriTrongLuc or 196.2
end)
taoThanhTruot(c, "Giá trị trọng lực", 0, 500, TrangThai.giaTriTrongLuc, function(v)
    TrangThai.giaTriTrongLuc = v
    if TrangThai.chongTrongLuc then KhongGianLamViec.Gravity = v end
end)
taoMuc(c, "⚠️ Cảnh báo")
local canhBao = Instance.new("TextLabel", c)
canhBao.Size = UDim2.new(1, 0, 0, 50); canhBao.BackgroundColor3 = Color3.fromRGB(30, 20, 20)
canhBao.TextColor3 = Color3.fromRGB(255, 180, 180); canhBao.Font = Enum.Font.Gotham
canhBao.TextSize = 9; canhBao.TextWrapped = true
canhBao.Text = "Chống đá / chống ban thật sự KHÔNG THỂ làm phía người chơi. Máy chủ kiểm tra và đá — phía client không chặn được. Cần trình chạy có bypass thật."
canhBao.Parent = c
Instance.new("UICorner", canhBao).CornerRadius = UDim.new(0, 4)

--/// 14. CÔNG CỤ ///
local tabCC = taoTab("Công Cụ", "🧰")
local c = tabCC.khung
taoMuc(c, "🧰 THÔNG TIN NHANH")
taoNut(c, "📊 In toàn bộ thông tin game (F9)", function()
    print("=== THÔNG TIN GAME ===")
    pcall(function() print("Tên:", DichVuThiTruong:GetProductInfo(game.PlaceId).Name) end)
    print("PlaceId:", game.PlaceId, "| JobId:", game.JobId)
    print("Creator:", game.CreatorId, "|", game.CreatorType)
    print("Số người:", #DichVuNguoiChoi:GetPlayers())
    print("Trọng lực:", KhongGianLamViec.Gravity)
    print("Giờ trong game:", DichVuAnhSang.ClockTime)
end)
taoNut(c, "👥 In danh sách người chơi (F9)", function()
    print("=== NGƯỜI CHƠI ===")
    for i, p in ipairs(DichVuNguoiChoi:GetPlayers()) do
        local char = p.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local pos = hrp and string.format("X=%.0f Y=%.0f Z=%.0f", hrp.Position.X, hrp.Position.Y, hrp.Position.Z) or "?"
        local n = char and char:FindFirstChildOfClass("Humanoid")
        local mau = n and (math.floor(n.Health) .. "/" .. math.floor(n.MaxHealth)) or "?"
        print(i, p.Name, "| Máu:", mau, "|", pos)
    end
end)
taoNut(c, "🌐 In dịch vụ game (F9)", function()
    print("=== DỊCH VỤ ===")
    for _, s in pairs(game:GetChildren()) do
        if s:IsA("Service") then print(" ", s.ClassName, "|", s.Name) end
    end
end)
taoNut(c, "📦 In túi đồ (F9)", function()
    print("=== TÚI ĐỒ ===")
    local bp = NguoiChoi:FindFirstChildOfClass("Backpack")
    if bp then for _, t in pairs(bp:GetChildren()) do
        if t:IsA("Tool") then print(" -", t.Name) end
    end end
    local ch = NguoiChoi.Character
    if ch then for _, t in pairs(ch:GetChildren()) do
        if t:IsA("Tool") then print(" - (cầm)", t.Name) end
    end end
end)
taoMuc(c, "📋 SAO CHÉP")
taoNut(c, "📋 Sao chép tên người gần nhất", function()
    local hrp = layThanNguoi(); if not hrp then return end
    local ganNhat, khoang = nil, math.huge
    for _, p in pairs(DichVuNguoiChoi:GetPlayers()) do
        if p ~= NguoiChoi and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < khoang then ganNhat, khoang = p, d end
        end
    end
    if ganNhat then
        if setclipboard then setclipboard(ganNhat.Name) end
        thongBao("ANON HUB", "Đã copy: " .. ganNhat.Name .. " (" .. math.floor(khoang) .. "m)", 3)
    end
end)
taoNut(c, "📋 Sao chép toạ độ", function()
    local hrp = layThanNguoi(); if not hrp then return end
    local s = string.format("X=%.0f Y=%.0f Z=%.0f", hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
    if setclipboard then setclipboard(s) end
    thongBao("ANON HUB", s, 3)
end)
taoMuc(c, "✂️ CẮT / DÁN VỊ TRÍ")
local viTriCat = nil
taoNut(c, "✂️ Cắt vị trí hiện tại", function()
    local hrp = layThanNguoi()
    if hrp then viTriCat = { pos = hrp.Position, look = hrp.CFrame.LookVector }; thongBao("ANON HUB", "Đã cắt") end
end)
taoNut(c, "📌 Dán vị trí đã cắt", function()
    if not viTriCat then thongBao("ANON HUB", "Chưa cắt"); return end
    local hrp = layThanNguoi()
    if hrp then hrp.CFrame = CFrame.lookAt(viTriCat.pos, viTriCat.pos + viTriCat.look) end
end)

--/// 15. PHÂN TÍCH ///
local tabPT = taoTab("Phân Tích", "🔬")
local c = tabPT.khung
taoMuc(c, "🔬 PHÂN TÍCH")
taoNut(c, "📁 Folder Workspace", function()
    print("=== FOLDER WORKSPACE ===")
    for _, f in pairs(KhongGianLamViec:GetChildren()) do
        print(" ", f.ClassName, "|", f.Name, "| Số con:", #f:GetChildren())
    end
end)
taoNut(c, "📡 RemoteEvent / RemoteFunction", function()
    print("=== REMOTE ===")
    local dem = 0
    for _, o in pairs(game:GetDescendants()) do
        if o:IsA("RemoteEvent") or o:IsA("RemoteFunction") then
            dem = dem + 1; print(" ", o.ClassName, "|", o:GetFullName())
        end
    end
    print("Tổng:", dem)
end)
taoNut(c, "🎒 Mọi Tool trong game", function()
    local dem = 0
    for _, o in pairs(game:GetDescendants()) do
        if o:IsA("Tool") then dem = dem + 1; print(o:GetFullName()) end
    end
    print("Tổng:", dem)
end)
taoNut(c, "🧍 Model có Humanoid (quái/NPC)", function()
    print("=== MODEL CÓ HUMANOID ===")
    local dem = 0
    for _, o in pairs(KhongGianLamViec:GetDescendants()) do
        if o:IsA("Model") and o:FindFirstChildOfClass("Humanoid") then
            dem = dem + 1; print(o.Name, "|", o:GetFullName())
        end
    end
    print("Tổng:", dem)
end)
taoNut(c, "🎨 Model không Humanoid (item)", function()
    print("=== MODEL KHÔNG HUMANOID (item nhỏ) ===")
    local dem = 0
    for _, o in pairs(KhongGianLamViec:GetDescendants()) do
        if o:IsA("Model") and not o:FindFirstChildOfClass("Humanoid") then
            local pp = o:FindFirstChildWhichIsA("BasePart")
            if pp and pp.Size.Magnitude < 30 then
                dem = dem + 1; print(o.Name, "|", o:GetFullName())
            end
        end
    end
    print("Tổng:", dem)
end)

--/// 16. TIỆN ÍCH 2 ///
local tabTI2 = taoTab("Tiện Ích 2", "🎯")
local c = tabTI2.khung
taoMuc(c, "🎯 ĐÁNH DẤU")
taoNut(c, "🔴 Đánh dấu mọi người chơi", function()
    for _, p in pairs(DichVuNguoiChoi:GetPlayers()) do
        if p ~= NguoiChoi and p.Character then
            local hl = p.Character:FindFirstChild("ANON_DanhDau") or Instance.new("Highlight", p.Character)
            hl.Name = "ANON_DanhDau"; hl.FillColor = Color3.fromRGB(255, 0, 0); hl.FillTransparency = 0.5
        end
    end
    thongBao("ANON HUB", "Đã đánh dấu")
end)
taoNut(c, "🧹 Xoá đánh dấu", function()
    for _, o in pairs(KhongGianLamViec:GetDescendants()) do
        if o:FindFirstChild("ANON_DanhDau") then o.ANON_DanhDau:Destroy() end
    end
end)
taoMuc(c, "📍 TELEPORT")
taoNut(c, "📍 Bay lên 100m", function()
    local hrp = layThanNguoi(); if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0, 100, 0) end
end)
taoNut(c, "📍 Bay xuống đất", function()
    local hrp = layThanNguoi()
    if hrp then
        local tia = Ray.new(hrp.Position, Vector3.new(0, -1000, 0))
        local vat, vt = KhongGianLamViec:FindPartOnRay(tia, NguoiChoi.Character)
        if vat then hrp.CFrame = CFrame.new(vt + Vector3.new(0, 3, 0)) end
    end
end)
taoNut(c, "📍 Bay tới tâm (0,50,0)", function()
    local hrp = layThanNguoi(); if hrp then hrp.CFrame = CFrame.new(0, 50, 0) end
end)
taoMuc(c, "🎮 TƯƠNG TÁC")
taoNut(c, "🖱️ Kích hoạt mọi gợi ý gần", function()
    local hrp = layThanNguoi(); if not hrp then return end
    local dem = 0
    for _, o in pairs(KhongGianLamViec:GetDescendants()) do
        if o:IsA("ProximityPrompt") then
            local cha = o.Parent
            if cha and cha:IsA("BasePart") and (cha.Position - hrp.Position).Magnitude < 30 and o.Enabled then
                pcall(function() o:InputHoldBegin(); task.wait(o.HoldDuration + 0.1); o:InputHoldEnd() end)
                dem = dem + 1
            end
        end
    end
    thongBao("ANON HUB", "Đã kích hoạt " .. dem .. " gợi ý", 3)
end)
taoMuc(c, "🔧 ĐỔI THUỘC TÍNH")
local tenTT = ""
taoODien(c, "Tên thuộc tính (VD: WalkSpeed)...", function(v) tenTT = v end)
taoNut(c, "🔧 Đổi giá trị = 999", function()
    if tenTT == "" then return end
    local n = layNguoi()
    if n then pcall(function()
        n[tenTT] = 999; thongBao("ANON HUB", "Đã đổi " .. tenTT, 2)
    end) end
end)

-- ============================================================
-- KHỞI ĐỘNG
-- ============================================================
tabESP.nut.MouseButton1Click:Fire()

if TrangThai.chongAfk then apChongAfk() end
if TrangThai.chayNhanh then apChayNhanh() end
if TrangThai.nhayCao then apNhayCao() end

thongBao("ANON HUB HỢP NHẤT", "Đã nạp — 16 tab, ~300 chức năng", 4)
print("[ANON HUB HỢP NHẤT] Đã nạp.")
print("[ANON HUB] 16 tab: Mắt Thần | Nhân Vật | Thế Giới | Tiện Ích | Chiến Đấu | Nông Trại | Nâng Cao | Máy Chủ | Giao Diện | Chẩn Đoán | Giải Trí | Di Chuyển | Chống | Công Cụ | Phân Tích | Tiện Ích 2")
print("[ANON HUB] Luật: quái=" .. #Luat.quai .. " vật phẩm=" .. #Luat.vatPham)
