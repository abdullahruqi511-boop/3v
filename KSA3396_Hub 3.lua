-- KSA3396 Hub v3.0 | Delta Executor Script
-- Developer by KSA3396

-- ==================== SERVICES ====================
local ok, Players    = pcall(function() return game:GetService("Players") end)
if not ok then Players = game.Players end
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local Lighting       = game:GetService("Lighting")
local Workspace      = game:GetService("Workspace")
local UIS            = game:GetService("UserInputService")
local Debris         = game:GetService("Debris")
local CoreGui        = game:GetService("CoreGui")

local LocalPlayer    = Players.LocalPlayer
local Camera         = Workspace.CurrentCamera

-- انتظر الشخصية
if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end
local Character        = LocalPlayer.Character
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 10)
local Humanoid         = Character:WaitForChild("Humanoid", 10)

-- Mouse (موبايل متوافق)
local Mouse = nil
pcall(function() Mouse = LocalPlayer:GetMouse() end)

-- ==================== STATE ====================
local flyEnabled    = false
local flySpeed      = 100
local flyConnection = nil
local flyBV         = nil
local flyBG         = nil
local walkSpeed     = 16
local jumpPower     = 50
local flingEnabled  = false
local flingLoop     = nil
local noclipEnabled = false
local noclipConn    = nil
local espEnabled    = false
local espConns      = {}
local infiniteJump  = false
local antiAfk       = false
local chatSpam      = false
local selectedTarget = nil
local spectating    = false
local spectateConn  = nil
local placingCube   = false
local darkCubes     = {}

-- ==================== إزالة GUI القديم إذا موجود ====================
pcall(function()
    local old = CoreGui:FindFirstChild("KSA3396Hub")
    if old then old:Destroy() end
end)
pcall(function()
    local old = LocalPlayer.PlayerGui:FindFirstChild("KSA3396Hub")
    if old then old:Destroy() end
end)

-- ==================== GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "KSA3396Hub"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

-- حاول CoreGui أولاً، إذا فشل استخدم PlayerGui
local guiParented = false
pcall(function()
    ScreenGui.Parent = CoreGui
    guiParented = true
end)
if not guiParented then
    pcall(function()
        ScreenGui.Parent = LocalPlayer.PlayerGui
        guiParented = true
    end)
end

-- إشعار تحميل سريع
task.spawn(function()
    pcall(function()
        local notif = Instance.new("ScreenGui")
        notif.Name           = "KSA_Notif"
        notif.ResetOnSpawn   = false
        notif.IgnoreGuiInset = true
        pcall(function() notif.Parent = CoreGui end)
        if not notif.Parent then notif.Parent = LocalPlayer.PlayerGui end

        local frame = Instance.new("Frame", notif)
        frame.Size             = UDim2.new(0, 320, 0, 60)
        frame.Position         = UDim2.new(0.5, -160, 0, 20)
        frame.BackgroundColor3 = Color3.fromRGB(90, 40, 190)
        frame.BorderSizePixel  = 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size             = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text             = "✅ KSA3396 Hub جاهز! | RightShift لفتح اللوحة"
        lbl.TextColor3       = Color3.fromRGB(255, 255, 255)
        lbl.TextSize         = 14
        lbl.Font             = Enum.Font.GothamBold
        lbl.TextWrapped      = true

        task.wait(4)
        pcall(function() notif:Destroy() end)
    end)
end)

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name            = "MainFrame"
MainFrame.Size            = UDim2.new(0, 440, 0, 620)
MainFrame.Position        = UDim2.new(0.5, -220, 0.5, -310)
MainFrame.BackgroundColor3= Color3.fromRGB(13, 13, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active          = true
MainFrame.Draggable       = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Color3.fromRGB(160, 90, 255)
mainStroke.Thickness = 2

-- Title Bar
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size             = UDim2.new(1, 0, 0, 52)
TitleBar.BackgroundColor3 = Color3.fromRGB(90, 40, 190)
TitleBar.BorderSizePixel  = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)
local tbFix = Instance.new("Frame", TitleBar)
tbFix.Size             = UDim2.new(1, 0, 0, 20)
tbFix.Position         = UDim2.new(0, 0, 1, -20)
tbFix.BackgroundColor3 = Color3.fromRGB(90, 40, 190)
tbFix.BorderSizePixel  = 0

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size              = UDim2.new(1, -70, 1, 0)
TitleLabel.Position          = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text              = "⚡ KSA3396 Hub  v3.0"
TitleLabel.TextColor3        = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize          = 19
TitleLabel.Font              = Enum.Font.GothamBold
TitleLabel.TextXAlignment    = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size             = UDim2.new(0, 32, 0, 32)
CloseBtn.Position         = UDim2.new(1, -42, 0.5, -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(210, 55, 55)
CloseBtn.Text             = "✕"
CloseBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize         = 15
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.BorderSizePixel  = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Dev Label
local DevLabel = Instance.new("TextLabel", MainFrame)
DevLabel.Size             = UDim2.new(1, 0, 0, 22)
DevLabel.Position         = UDim2.new(0, 0, 0, 52)
DevLabel.BackgroundColor3 = Color3.fromRGB(70, 25, 145)
DevLabel.Text             = "  Developer by KSA3396  |  RightShift = فتح / إغلاق"
DevLabel.TextColor3       = Color3.fromRGB(210, 165, 255)
DevLabel.TextSize         = 12
DevLabel.Font             = Enum.Font.GothamBold
DevLabel.TextXAlignment   = Enum.TextXAlignment.Left
DevLabel.BorderSizePixel  = 0

-- Scroll Frame
local ScrollFrame = Instance.new("ScrollingFrame", MainFrame)
ScrollFrame.Size                 = UDim2.new(1, -16, 1, -82)
ScrollFrame.Position             = UDim2.new(0, 8, 0, 78)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel      = 0
ScrollFrame.ScrollBarThickness   = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(140, 70, 255)
ScrollFrame.CanvasSize           = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize  = Enum.AutomaticSize.Y
local listLayout = Instance.new("UIListLayout", ScrollFrame)
listLayout.Padding      = UDim.new(0, 7)
listLayout.SortOrder    = Enum.SortOrder.LayoutOrder
local listPad = Instance.new("UIPadding", ScrollFrame)
listPad.PaddingTop    = UDim.new(0, 6)
listPad.PaddingBottom = UDim.new(0, 10)

-- ==================== HELPER BUILDERS ====================

local function MakeSection(text)
    local L = Instance.new("TextLabel", ScrollFrame)
    L.Size             = UDim2.new(1, 0, 0, 28)
    L.BackgroundColor3 = Color3.fromRGB(70, 35, 140)
    L.BackgroundTransparency = 0.25
    L.Text             = "  " .. text
    L.TextColor3       = Color3.fromRGB(195, 155, 255)
    L.TextSize         = 13
    L.Font             = Enum.Font.GothamBold
    L.TextXAlignment   = Enum.TextXAlignment.Left
    L.BorderSizePixel  = 0
    Instance.new("UICorner", L).CornerRadius = UDim.new(0, 6)
    return L
end

local function MakeToggle(text, cb)
    local Btn = Instance.new("TextButton", ScrollFrame)
    Btn.Size             = UDim2.new(1, 0, 0, 44)
    Btn.BackgroundColor3 = Color3.fromRGB(26, 17, 46)
    Btn.BorderSizePixel  = 0
    Btn.Text             = ""
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 9)
    local stroke = Instance.new("UIStroke", Btn)
    stroke.Color     = Color3.fromRGB(75, 45, 130)
    stroke.Thickness = 1

    local lbl = Instance.new("TextLabel", Btn)
    lbl.Size             = UDim2.new(1, -62, 1, 0)
    lbl.Position         = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = text
    lbl.TextColor3       = Color3.fromRGB(215, 215, 215)
    lbl.TextSize         = 13
    lbl.Font             = Enum.Font.Gotham
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.TextWrapped      = true

    local track = Instance.new("Frame", Btn)
    track.Size             = UDim2.new(0, 42, 0, 22)
    track.Position         = UDim2.new(1, -52, 0.5, -11)
    track.BackgroundColor3 = Color3.fromRGB(75, 75, 95)
    track.BorderSizePixel  = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 11)

    local dot = Instance.new("Frame", track)
    dot.Size             = UDim2.new(0, 16, 0, 16)
    dot.Position         = UDim2.new(0, 3, 0.5, -8)
    dot.BackgroundColor3 = Color3.fromRGB(195, 195, 195)
    dot.BorderSizePixel  = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(0, 8)

    local on = false
    Btn.MouseButton1Click:Connect(function()
        on = not on
        if on then
            TweenService:Create(track, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(110, 55, 240)}):Play()
            TweenService:Create(dot,   TweenInfo.new(0.18), {Position = UDim2.new(0, 23, 0.5, -8)}):Play()
            stroke.Color = Color3.fromRGB(140, 70, 255)
        else
            TweenService:Create(track, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(75, 75, 95)}):Play()
            TweenService:Create(dot,   TweenInfo.new(0.18), {Position = UDim2.new(0, 3, 0.5, -8)}):Play()
            stroke.Color = Color3.fromRGB(75, 45, 130)
        end
        cb(on)
    end)
    return Btn
end

local function MakeSlider(text, min, max, default, cb)
    local C = Instance.new("Frame", ScrollFrame)
    C.Size             = UDim2.new(1, 0, 0, 58)
    C.BackgroundColor3 = Color3.fromRGB(26, 17, 46)
    C.BorderSizePixel  = 0
    Instance.new("UICorner", C).CornerRadius = UDim.new(0, 9)
    local cs = Instance.new("UIStroke", C)
    cs.Color = Color3.fromRGB(75, 45, 130); cs.Thickness = 1

    local cl = Instance.new("TextLabel", C)
    cl.Size             = UDim2.new(1, -10, 0, 22)
    cl.Position         = UDim2.new(0, 10, 0, 4)
    cl.BackgroundTransparency = 1
    cl.Text             = text .. ": " .. default
    cl.TextColor3       = Color3.fromRGB(215, 215, 215)
    cl.TextSize         = 13
    cl.Font             = Enum.Font.Gotham
    cl.TextXAlignment   = Enum.TextXAlignment.Left

    local bg = Instance.new("Frame", C)
    bg.Size             = UDim2.new(1, -20, 0, 6)
    bg.Position         = UDim2.new(0, 10, 0, 38)
    bg.BackgroundColor3 = Color3.fromRGB(55, 35, 95)
    bg.BorderSizePixel  = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 3)

    local fill = Instance.new("Frame", bg)
    fill.Size             = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(110, 55, 240)
    fill.BorderSizePixel  = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

    local sdot = Instance.new("TextButton", bg)
    sdot.Size             = UDim2.new(0, 16, 0, 16)
    sdot.Position         = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    sdot.BackgroundColor3 = Color3.fromRGB(185, 135, 255)
    sdot.Text             = ""
    sdot.BorderSizePixel  = 0
    Instance.new("UICorner", sdot).CornerRadius = UDim.new(0, 8)

    local drag = false
    sdot.MouseButton1Down:Connect(function() drag = true end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
    RunService.RenderStepped:Connect(function()
        if drag then
            local rel = math.clamp((UIS:GetMouseLocation().X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + rel * (max - min))
            fill.Size     = UDim2.new(rel, 0, 1, 0)
            sdot.Position = UDim2.new(rel, -8, 0.5, -8)
            cl.Text       = text .. ": " .. val
            cb(val)
        end
    end)
    return C
end

local function MakeButton(text, color, cb)
    local Btn = Instance.new("TextButton", ScrollFrame)
    Btn.Size             = UDim2.new(1, 0, 0, 42)
    Btn.BackgroundColor3 = color or Color3.fromRGB(90, 40, 190)
    Btn.BorderSizePixel  = 0
    Btn.Text             = text
    Btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    Btn.TextSize         = 13
    Btn.Font             = Enum.Font.GothamBold
    Btn.TextWrapped      = true
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 9)
    Btn.MouseButton1Click:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(155, 85, 255)}):Play()
        task.delay(0.15, function()
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = color or Color3.fromRGB(90, 40, 190)}):Play()
        end)
        cb()
    end)
    return Btn
end

local function MakeInfoBox(text)
    local L = Instance.new("TextLabel", ScrollFrame)
    L.Size             = UDim2.new(1, 0, 0, 44)
    L.BackgroundColor3 = Color3.fromRGB(18, 12, 32)
    L.BackgroundTransparency = 0.25
    L.Text             = text
    L.TextColor3       = Color3.fromRGB(165, 125, 255)
    L.TextSize         = 12
    L.Font             = Enum.Font.Gotham
    L.TextWrapped      = true
    L.BorderSizePixel  = 0
    Instance.new("UICorner", L).CornerRadius = UDim.new(0, 8)
    return L
end

-- ==================== PLAYER SELECTOR POPUP ====================

local function MakeSelectorRow(labelText)
    local row = Instance.new("Frame", ScrollFrame)
    row.Size             = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(26, 17, 46)
    row.BorderSizePixel  = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 9)
    local rs = Instance.new("UIStroke", row)
    rs.Color = Color3.fromRGB(75, 45, 130); rs.Thickness = 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Size             = UDim2.new(0.6, 0, 1, 0)
    lbl.Position         = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = labelText
    lbl.TextColor3       = Color3.fromRGB(255, 200, 80)
    lbl.TextSize         = 13
    lbl.Font             = Enum.Font.GothamBold
    lbl.TextXAlignment   = Enum.TextXAlignment.Left

    return row, lbl, rs
end

-- Target info row
local targetRow, targetLabel, targetStroke = MakeSelectorRow("🎯 الهدف: لم يتم الاختيار")

-- Popup frame for player list
local PopupFrame = Instance.new("Frame", MainFrame)
PopupFrame.Size             = UDim2.new(0, 230, 0, 10)
PopupFrame.Position         = UDim2.new(0.5, -115, 0.5, -120)
PopupFrame.BackgroundColor3 = Color3.fromRGB(18, 12, 32)
PopupFrame.BorderSizePixel  = 0
PopupFrame.Visible          = false
PopupFrame.ZIndex           = 20
Instance.new("UICorner", PopupFrame).CornerRadius = UDim.new(0, 10)
local popupStroke = Instance.new("UIStroke", PopupFrame)
popupStroke.Color = Color3.fromRGB(150, 75, 255); popupStroke.Thickness = 2

local popupTitle = Instance.new("TextLabel", PopupFrame)
popupTitle.Size             = UDim2.new(1, 0, 0, 36)
popupTitle.BackgroundColor3 = Color3.fromRGB(90, 40, 190)
popupTitle.BackgroundTransparency = 0
popupTitle.Text             = "اختر اللاعب"
popupTitle.TextColor3       = Color3.fromRGB(255, 255, 255)
popupTitle.TextSize         = 14
popupTitle.Font             = Enum.Font.GothamBold
popupTitle.ZIndex           = 21
Instance.new("UICorner", popupTitle).CornerRadius = UDim.new(0, 10)
local ptFix = Instance.new("Frame", PopupFrame)
ptFix.Size             = UDim2.new(1, 0, 0, 18)
ptFix.Position         = UDim2.new(0, 0, 0, 18)
ptFix.BackgroundColor3 = Color3.fromRGB(90, 40, 190)
ptFix.BorderSizePixel  = 0
ptFix.ZIndex           = 21

local popupClose = Instance.new("TextButton", PopupFrame)
popupClose.Size             = UDim2.new(0, 28, 0, 28)
popupClose.Position         = UDim2.new(1, -34, 0, 4)
popupClose.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
popupClose.Text             = "✕"
popupClose.TextColor3       = Color3.fromRGB(255, 255, 255)
popupClose.TextSize         = 13
popupClose.Font             = Enum.Font.GothamBold
popupClose.BorderSizePixel  = 0
popupClose.ZIndex           = 22
Instance.new("UICorner", popupClose).CornerRadius = UDim.new(0, 6)
popupClose.MouseButton1Click:Connect(function() PopupFrame.Visible = false end)

local popupScroll = Instance.new("ScrollingFrame", PopupFrame)
popupScroll.Size                 = UDim2.new(1, -10, 1, -42)
popupScroll.Position             = UDim2.new(0, 5, 0, 38)
popupScroll.BackgroundTransparency = 1
popupScroll.BorderSizePixel      = 0
popupScroll.ScrollBarThickness   = 3
popupScroll.ScrollBarImageColor3 = Color3.fromRGB(140, 70, 255)
popupScroll.CanvasSize           = UDim2.new(0, 0, 0, 0)
popupScroll.AutomaticCanvasSize  = Enum.AutomaticSize.Y
popupScroll.ZIndex               = 21
local psList = Instance.new("UIListLayout", popupScroll)
psList.Padding   = UDim.new(0, 4)
psList.SortOrder = Enum.SortOrder.LayoutOrder
local psPad = Instance.new("UIPadding", popupScroll)
psPad.PaddingTop = UDim.new(0, 4); psPad.PaddingBottom = UDim.new(0, 4)

local function RefreshPopup(onSelect)
    for _, c in ipairs(popupScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local count = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            count += 1
            local pb = Instance.new("TextButton", popupScroll)
            pb.Size             = UDim2.new(1, 0, 0, 34)
            pb.BackgroundColor3 = Color3.fromRGB(45, 22, 85)
            pb.BorderSizePixel  = 0
            pb.Text             = "👤  " .. p.Name
            pb.TextColor3       = Color3.fromRGB(215, 190, 255)
            pb.TextSize         = 13
            pb.Font             = Enum.Font.Gotham
            pb.ZIndex           = 22
            Instance.new("UICorner", pb).CornerRadius = UDim.new(0, 7)
            pb.MouseButton1Click:Connect(function()
                onSelect(p)
                PopupFrame.Visible = false
            end)
        end
    end
    local h = math.max(110, math.min(280, 42 + count * 38))
    PopupFrame.Size = UDim2.new(0, 230, 0, h)
end

local function OpenSelector(onSelect)
    RefreshPopup(onSelect)
    PopupFrame.Visible = true
end

-- Open button
MakeButton("📋 اختر لاعب هدف", Color3.fromRGB(55, 28, 110), function()
    OpenSelector(function(p)
        selectedTarget = p
        targetLabel.Text = "🎯 الهدف: " .. p.Name
        targetStroke.Color = Color3.fromRGB(255, 140, 40)
    end)
end)

-- ==================== SPECTATE ====================

MakeSection("👁️ View / Spectate (مراقبة لاعب)")

MakeToggle("👁️ Spectate الهدف المختار", function(on)
    spectating = on
    if on then
        if spectateConn then spectateConn:Disconnect() end
        if not selectedTarget then
            spectating = false
            return
        end
        Camera.CameraType = Enum.CameraType.Scriptable
        spectateConn = RunService.RenderStepped:Connect(function()
            if not spectating then return end
            local t = selectedTarget
            if t and t.Character then
                local hrp = t.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    Camera.CFrame = CFrame.new(
                        hrp.Position + Vector3.new(0, 6, 14),
                        hrp.Position + Vector3.new(0, 2, 0)
                    )
                end
            end
        end)
    else
        if spectateConn then spectateConn:Disconnect() spectateConn = nil end
        Camera.CameraType = Enum.CameraType.Custom
        Camera.CameraSubject = Character and Character:FindFirstChild("Humanoid") or nil
    end
end)

MakeButton("👁️ مراقبة لاعب → اختر من القائمة", Color3.fromRGB(35, 20, 75), function()
    OpenSelector(function(p)
        selectedTarget = p
        targetLabel.Text = "🎯 الهدف: " .. p.Name
        targetStroke.Color = Color3.fromRGB(255, 140, 40)
        -- Auto enable spectate
        spectating = true
        Camera.CameraType = Enum.CameraType.Scriptable
        if spectateConn then spectateConn:Disconnect() end
        spectateConn = RunService.RenderStepped:Connect(function()
            if not spectating then return end
            local char = p.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    Camera.CFrame = CFrame.new(
                        hrp.Position + Vector3.new(0, 6, 14),
                        hrp.Position + Vector3.new(0, 2, 0)
                    )
                end
            end
        end)
    end)
end)

MakeButton("🔙 إيقاف المراقبة / رجوع لكاميرا اللاعب", Color3.fromRGB(60, 30, 30), function()
    spectating = false
    if spectateConn then spectateConn:Disconnect() spectateConn = nil end
    Camera.CameraType    = Enum.CameraType.Custom
    local hum = Character and Character:FindFirstChildOfClass("Humanoid")
    Camera.CameraSubject = hum
end)

-- ==================== SKY CHANGER ====================

MakeSection("🌌 Sky Hack (سماء يشوفها الكل - طريقة الهاكرز)")

-- الطريقة الحقيقية: Part ضخم فوق الماب = يظهر للجميع
-- + RemoteEvent scan = يحاول يغير من السيرفر مباشرة
-- + Lighting local = تأثير إضافي

local currentSkyDome = nil  -- الـ Part الضخم الحالي

local function RemoveSkyDome()
    if currentSkyDome and currentSkyDome.Parent then
        currentSkyDome:Destroy()
        currentSkyDome = nil
    end
    -- ابحث وازل أي dome قديم
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name == "KSA_SkyDome" then obj:Destroy() end
    end
end

local function FireLightingRemotes(color, brightness)
    -- يحاول يلاقي RemoteEvents في اللعبة تغير الإضاءة ويـfire عليها
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local n = obj.Name:lower()
            if n:find("light") or n:find("sky") or n:find("weather")
            or n:find("ambient") or n:find("fog") or n:find("time")
            or n:find("day") or n:find("night") or n:find("sun") then
                pcall(function()
                    obj:FireServer(color, brightness)
                end)
                pcall(function()
                    obj:FireServer(brightness)
                end)
                pcall(function()
                    obj:FireServer()
                end)
            end
        end
        if obj:IsA("RemoteFunction") then
            local n = obj.Name:lower()
            if n:find("light") or n:find("sky") or n:find("weather") then
                pcall(function()
                    obj:InvokeServer(color, brightness)
                end)
            end
        end
    end
end

local function ApplySkyHack(color1, color2, fogColor, brightness, fogEnd, transparency, useTexture, textureId)
    RemoveSkyDome()

    -- ① Part ضخم فوق الماب (يظهر للجميع)
    local dome = Instance.new("Part")
    dome.Name         = "KSA_SkyDome"
    dome.Size         = Vector3.new(20000, 1, 20000)
    dome.CFrame       = CFrame.new(0, 2000, 0)
    dome.Anchored     = true
    dome.CanCollide   = false
    dome.CastShadow   = false
    dome.Color        = color1
    dome.Transparency = transparency or 0.0
    dome.Material     = Enum.Material.Neon
    dome.Parent       = Workspace
    currentSkyDome    = dome

    -- ② طبقة ثانية (fog effect)
    local dome2 = Instance.new("Part")
    dome2.Name         = "KSA_SkyDome"
    dome2.Size         = Vector3.new(20000, 1, 20000)
    dome2.CFrame       = CFrame.new(0, 1800, 0)
    dome2.Anchored     = true
    dome2.CanCollide   = false
    dome2.CastShadow   = false
    dome2.Color        = color2 or color1
    dome2.Transparency = (transparency or 0.0) + 0.3
    dome2.Material     = Enum.Material.Neon
    dome2.Parent       = Workspace

    -- ③ Lighting محلي (تأثير إضافي للشخص نفسه)
    Lighting.Ambient        = color2 or color1
    Lighting.OutdoorAmbient = color1
    Lighting.Brightness     = brightness or 1
    Lighting.FogColor       = fogColor or color1
    Lighting.FogEnd         = fogEnd or 3000
    Lighting.FogStart       = fogEnd and (fogEnd * 0.3) or 500

    -- إزالة السماء القديمة محلياً
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("Sky") then obj:Destroy() end
    end

    -- ④ RemoteEvent scan (محاولة تغيير السيرفر)
    task.spawn(function()
        FireLightingRemotes(color1, brightness)
    end)

    -- إضافة texture إذا موجود
    if useTexture and textureId then
        local tex = Instance.new("Texture")
        tex.Texture    = "rbxassetid://" .. textureId
        tex.Face       = Enum.NormalId.Bottom
        tex.StudsPerTileU = 500
        tex.StudsPerTileV = 500
        tex.Parent     = dome
    end
end

-- ======================== أنواع السماء ========================

local skyPresets = {
    {
        name  = "🔴 جهنم (Hell Fire)",
        c1    = Color3.fromRGB(180, 20, 10),
        c2    = Color3.fromRGB(100, 10, 0),
        fog   = Color3.fromRGB(150, 30, 10),
        br    = 0.4,
        fe    = 800,
        tr    = 0.05,
    },
    {
        name  = "🟣 بنفسجي (Galaxy)",
        c1    = Color3.fromRGB(60, 0, 120),
        c2    = Color3.fromRGB(30, 0, 80),
        fog   = Color3.fromRGB(50, 0, 100),
        br    = 0.2,
        fe    = 1500,
        tr    = 0.05,
    },
    {
        name  = "⚫ ظلام تام (Blackout)",
        c1    = Color3.fromRGB(5, 5, 5),
        c2    = Color3.fromRGB(0, 0, 0),
        fog   = Color3.fromRGB(0, 0, 0),
        br    = 0.0,
        fe    = 80,
        tr    = 0.0,
    },
    {
        name  = "🔵 محيط (Ocean)",
        c1    = Color3.fromRGB(10, 40, 120),
        c2    = Color3.fromRGB(5, 20, 80),
        fog   = Color3.fromRGB(20, 60, 150),
        br    = 0.6,
        fe    = 1200,
        tr    = 0.15,
    },
    {
        name  = "🟠 غروب (Sunset)",
        c1    = Color3.fromRGB(220, 90, 20),
        c2    = Color3.fromRGB(180, 50, 0),
        fog   = Color3.fromRGB(200, 80, 30),
        br    = 1.0,
        fe    = 2000,
        tr    = 0.1,
    },
    {
        name  = "❄️ ثلج (Blizzard)",
        c1    = Color3.fromRGB(200, 225, 255),
        c2    = Color3.fromRGB(180, 210, 240),
        fog   = Color3.fromRGB(220, 230, 255),
        br    = 3.5,
        fe    = 120,
        tr    = 0.25,
    },
    {
        name  = "🟢 غابة (Forest)",
        c1    = Color3.fromRGB(10, 60, 15),
        c2    = Color3.fromRGB(5, 40, 10),
        fog   = Color3.fromRGB(20, 80, 20),
        br    = 0.5,
        fe    = 1000,
        tr    = 0.1,
    },
    {
        name  = "🌃 ليل مدينة",
        c1    = Color3.fromRGB(15, 15, 40),
        c2    = Color3.fromRGB(10, 10, 30),
        fog   = Color3.fromRGB(20, 20, 55),
        br    = 0.2,
        fe    = 2500,
        tr    = 0.05,
    },
    {
        name  = "☁️ غيوم بيضاء",
        c1    = Color3.fromRGB(200, 210, 230),
        c2    = Color3.fromRGB(180, 195, 220),
        fog   = Color3.fromRGB(210, 215, 235),
        br    = 3.0,
        fe    = 200,
        tr    = 0.3,
    },
    {
        name  = "🩸 دم (Blood Moon)",
        c1    = Color3.fromRGB(120, 5, 5),
        c2    = Color3.fromRGB(80, 0, 0),
        fog   = Color3.fromRGB(100, 10, 10),
        br    = 0.1,
        fe    = 600,
        tr    = 0.0,
    },
}

for _, preset in ipairs(skyPresets) do
    local p = preset
    MakeButton("🌌 " .. p.name, Color3.fromRGB(25, 12, 55), function()
        ApplySkyHack(p.c1, p.c2, p.fog, p.br, p.fe, p.tr)
    end)
end

MakeButton("🔄 إزالة السماء وإعادة الأصل", Color3.fromRGB(50, 25, 80), function()
    RemoveSkyDome()
    -- ازل جميع KSA_SkyDome في الماب
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name == "KSA_SkyDome" then obj:Destroy() end
    end
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("Sky") or obj:IsA("ColorCorrectionEffect") then obj:Destroy() end
    end
    Lighting.Ambient        = Color3.fromRGB(70, 70, 70)
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    Lighting.Brightness     = 2
    Lighting.FogEnd         = 100000
    Lighting.FogStart       = 0
    Lighting.ClockTime      = 14
end)

-- ==================== SKY SELF TRANSFORM ====================

MakeSection("🌌 حوّل نفسك إلى سماء (الكل يشوفك)")

-- الفكرة: تحويل جسم اللاعب إلى معكب ضخم ملون
-- الشخصية موجودة على السيرفر → الكل يشوفها

local originalSizes   = {}
local originalColors  = {}
local originalTransp  = {}
local originalMat     = {}
local isSkyForm       = false
local skyFormColor    = Color3.fromRGB(60, 0, 120)
local skyFormSize     = 30

local function SaveOriginalChar()
    originalSizes  = {}
    originalColors = {}
    originalTransp = {}
    originalMat    = {}
    Character = LocalPlayer.Character
    if not Character then return end
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            originalSizes[part]  = part.Size
            originalColors[part] = part.Color
            originalTransp[part] = part.Transparency
            originalMat[part]    = part.Material
        end
    end
end

local function TransformToSkyCube(color, size)
    Character = LocalPlayer.Character
    if not Character then return end
    SaveOriginalChar()
    isSkyForm    = true
    skyFormColor = color
    skyFormSize  = size

    local HRP = Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    -- اجعل كل أجزاء الجسم شفافة ما عدا الـ HumanoidRootPart
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 1
            part.CanCollide   = false
        end
    end

    -- حوّل الـ HumanoidRootPart إلى معكب ضخم ملون
    HRP.Size         = Vector3.new(size, size, size)
    HRP.Color        = color
    HRP.Material     = Enum.Material.Neon
    HRP.Transparency = 0.0
    HRP.CanCollide   = false

    -- أضف BillboardGui باسمك
    local existingBB = HRP:FindFirstChild("KSA_SkyBB")
    if existingBB then existingBB:Destroy() end

    local bb = Instance.new("BillboardGui", HRP)
    bb.Name        = "KSA_SkyBB"
    bb.Size        = UDim2.new(0, 200, 0, 50)
    bb.StudsOffset = Vector3.new(0, size / 2 + 5, 0)
    bb.AlwaysOnTop = true

    local bbl = Instance.new("TextLabel", bb)
    bbl.Size             = UDim2.new(1, 0, 1, 0)
    bbl.BackgroundTransparency = 1
    bbl.Text             = "⚡ " .. LocalPlayer.Name .. " | KSA3396"
    bbl.TextColor3       = Color3.fromRGB(255, 255, 0)
    bbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    bbl.TextStrokeTransparency = 0
    bbl.TextSize         = 18
    bbl.Font             = Enum.Font.GothamBold

    -- اجعل الكاميرا تتبعه بشكل طبيعي
    local hum = Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.CameraOffset = Vector3.new(0, size / 2, 0)
    end
end

local function RestoreOriginalChar()
    isSkyForm = false
    Character = LocalPlayer.Character
    if not Character then return end
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            if originalSizes[part]  then part.Size         = originalSizes[part]  end
            if originalColors[part] then part.Color        = originalColors[part] end
            if originalTransp[part] then part.Transparency = originalTransp[part] end
            if originalMat[part]    then part.Material     = originalMat[part]    end
            part.CanCollide = true
        end
    end
    local HRP = Character:FindFirstChild("HumanoidRootPart")
    if HRP then
        local bb = HRP:FindFirstChild("KSA_SkyBB")
        if bb then bb:Destroy() end
    end
    local hum = Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.CameraOffset = Vector3.new(0, 0, 0) end
    originalSizes  = {}
    originalColors = {}
    originalTransp = {}
    originalMat    = {}
end

-- اختيار لون السماء
local skyTransformPresets = {
    {"🟣 بنفسجي (مثل الصورة)", Color3.fromRGB(80, 10, 150)},
    {"🔴 أحمر / جهنم",         Color3.fromRGB(180, 15, 10)},
    {"🩸 Blood Moon",           Color3.fromRGB(110, 0, 0)},
    {"⚫ ظلام",                 Color3.fromRGB(8, 8, 8)},
    {"🔵 مائي (Ocean)",         Color3.fromRGB(10, 50, 150)},
    {"🟠 غروب (Sunset)",        Color3.fromRGB(200, 80, 10)},
    {"⬜ أبيض (Cloud)",         Color3.fromRGB(230, 230, 240)},
    {"🟢 غابة (Forest)",        Color3.fromRGB(15, 80, 20)},
}

-- Slider حجم المعكب الشخصي
local selfCubeSize = 30
MakeSlider("حجم معكب جسمك", 10, 120, 30, function(v) selfCubeSize = v end)

for _, preset in ipairs(skyTransformPresets) do
    local pName, pColor = preset[1], preset[2]
    MakeButton("🌌 " .. pName, Color3.fromRGB(40, 10, 85), function()
        TransformToSkyCube(pColor, selfCubeSize)
        -- أيضاً غير السماء للون نفسه (يظهر للجميع عبر الـ dome)
        ApplySkyHack(pColor, pColor, pColor, 0.2, 2000, 0.1)
    end)
end

MakeButton("🔙 رجوع لشكلك الأصلي", Color3.fromRGB(60, 25, 25), function()
    RestoreOriginalChar()
    RemoveSkyDome()
end)

-- ==================== DARK CUBE PLACEMENT ====================

MakeSection("🟫 Dark Cube (معكب ظلام - يضغط مكان ويجيه)")

local placeStatus = Instance.new("TextLabel", ScrollFrame)
placeStatus.Size             = UDim2.new(1, 0, 0, 34)
placeStatus.BackgroundColor3 = Color3.fromRGB(26, 17, 46)
placeStatus.BackgroundTransparency = 0.2
placeStatus.Text             = "⬜ وضع التحديد: معطّل"
placeStatus.TextColor3       = Color3.fromRGB(180, 180, 180)
placeStatus.TextSize         = 13
placeStatus.Font             = Enum.Font.GothamBold
placeStatus.BorderSizePixel  = 0
Instance.new("UICorner", placeStatus).CornerRadius = UDim.new(0, 8)

local cubeSize = 30  -- default cube size
MakeSlider("حجم المعكب", 10, 200, 30, function(v) cubeSize = v end)

MakeToggle("🖱️ وضع التحديد (اضغط على الأرض لوضع معكب)", function(on)
    placingCube = on
    if on then
        placeStatus.Text      = "🟢 وضع التحديد: شغّال — اضغط على مكان في الماب"
        placeStatus.TextColor3= Color3.fromRGB(100, 255, 120)
    else
        placeStatus.Text      = "⬜ وضع التحديد: معطّل"
        placeStatus.TextColor3= Color3.fromRGB(180, 180, 180)
    end
end)

-- Click to place cube (متوافق موبايل + كمبيوتر)
local function OnClick()
    if not placingCube then return end
    local hitPos = nil
    pcall(function()
        if Mouse then hitPos = Mouse.Hit.Position end
    end)
    if not hitPos then
        -- fallback: ضع المعكب أمام اللاعب
        Character = LocalPlayer.Character
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            hitPos = Character.HumanoidRootPart.Position + Character.HumanoidRootPart.CFrame.LookVector * 20
        end
    end
    if hitPos then
        -- Spawn a giant dark cube at that position
        local cube = Instance.new("Part")
        cube.Name          = "KSA_DarkCube"
        cube.Size          = Vector3.new(cubeSize, cubeSize, cubeSize)
        cube.BrickColor    = BrickColor.new("Really black")
        cube.Material      = Enum.Material.SmoothPlastic
        cube.Transparency  = 0.0
        cube.Anchored      = true
        cube.CanCollide    = true
        cube.CastShadow    = true
        cube.Position      = hitPos + Vector3.new(0, cubeSize / 2, 0)
        cube.Parent        = Workspace

        -- Add a surface neon outline effect
        local sel = Instance.new("SelectionBox")
        sel.Adornee          = cube
        sel.Color3           = Color3.fromRGB(255, 0, 0)
        sel.LineThickness    = 0.08
        sel.SurfaceTransparency = 1
        sel.Parent           = cube

        -- Darkness inside via PointLight with negative trick
        local att = Instance.new("Attachment", cube)
        att.Position = Vector3.new(0, 0, 0)
        local pl = Instance.new("PointLight", att)
        pl.Brightness  = 0
        pl.Range       = cubeSize * 0.8
        pl.Color       = Color3.fromRGB(0, 0, 0)
        pl.Enabled     = true

        -- BillboardGui label
        local bb = Instance.new("BillboardGui", cube)
        bb.Size        = UDim2.new(0, 110, 0, 30)
        bb.StudsOffset = Vector3.new(0, cubeSize / 2 + 4, 0)
        bb.AlwaysOnTop = true
        local bbl = Instance.new("TextLabel", bb)
        bbl.Size             = UDim2.new(1, 0, 1, 0)
        bbl.BackgroundTransparency = 1
        bbl.Text             = "⚡ KSA3396"
        bbl.TextColor3       = Color3.fromRGB(255, 60, 60)
        bbl.TextSize         = 14
        bbl.Font             = Enum.Font.GothamBold

        table.insert(darkCubes, cube)
    end
end

-- ربط الضغط (كمبيوتر + موبايل)
if Mouse then
    Mouse.Button1Down:Connect(OnClick)
end
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.Touch then
        OnClick()
    end
end)

MakeButton("🗑️ إزالة آخر معكب", Color3.fromRGB(80, 30, 30), function()
    if #darkCubes > 0 then
        local last = darkCubes[#darkCubes]
        if last and last.Parent then last:Destroy() end
        table.remove(darkCubes, #darkCubes)
    end
end)

MakeButton("🗑️ إزالة كل المعاكيب", Color3.fromRGB(110, 25, 25), function()
    for _, c in ipairs(darkCubes) do
        if c and c.Parent then c:Destroy() end
    end
    darkCubes = {}
end)

-- ==================== PLAYER ====================

MakeSection("👤 Player (اللاعب)")

MakeSlider("Speed (السرعة)", 16, 500, 16, function(v)
    walkSpeed = v
    Character = LocalPlayer.Character
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkSpeed = v
    end
end)

MakeSlider("Jump Power (القفزة)", 50, 500, 50, function(v)
    jumpPower = v
    Character = LocalPlayer.Character
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.JumpPower = v
    end
end)

MakeToggle("Noclip (اختراق الجدران)", function(on)
    noclipEnabled = on
    if on then
        noclipConn = RunService.Stepped:Connect(function()
            Character = LocalPlayer.Character
            if Character then
                for _, p in ipairs(Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    end
end)

UIS.JumpRequest:Connect(function()
    if infiniteJump then
        Character = LocalPlayer.Character
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
MakeToggle("Infinite Jump (قفز لا نهائي)", function(on) infiniteJump = on end)

-- ==================== FLY ====================

MakeSection("✈️ Fly (تحليق)")

MakeToggle("Fly (تفعيل الطيران)", function(on)
    flyEnabled = on
    Character     = LocalPlayer.Character
    if not Character then return end
    HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return end
    if on then
        flyBV = Instance.new("BodyVelocity", HumanoidRootPart)
        flyBV.Velocity  = Vector3.new(0, 0, 0)
        flyBV.MaxForce  = Vector3.new(1e9, 1e9, 1e9)
        flyBG = Instance.new("BodyGyro", HumanoidRootPart)
        flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        flyBG.D         = 100
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flyEnabled then return end
            local cam = Workspace.CurrentCamera
            local dir = Vector3.new(0, 0, 0)
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
            if dir.Magnitude > 0 then dir = dir.Unit end
            flyBV.Velocity = dir * flySpeed
            if dir.Magnitude > 0 then flyBG.CFrame = CFrame.new(Vector3.zero, dir) end
        end)
    else
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
    end
end)

MakeSlider("Fly Speed (سرعة الطيران)", 10, 500, 100, function(v) flySpeed = v end)

-- ==================== FLING ====================

MakeSection("💥 Fling (تطيير اللاعبين)")

local function DoCubeFling(target)
    if not target or not target.Character then return end
    local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
    if not tHRP then return end

    local cube = Instance.new("Part")
    cube.Name        = "KSA_FlingCube"
    cube.Size        = Vector3.new(28, 28, 28)
    cube.BrickColor  = BrickColor.new("Bright red")
    cube.Material    = Enum.Material.Neon
    cube.Transparency= 0.1
    cube.Anchored    = false
    cube.CanCollide  = true
    cube.Position    = tHRP.Position + Vector3.new(0, 90, 0)
    cube.Parent      = Workspace

    -- KSA label
    local bb = Instance.new("BillboardGui", cube)
    bb.Size        = UDim2.new(0, 130, 0, 36)
    bb.StudsOffset = Vector3.new(0, 16, 0)
    bb.AlwaysOnTop = true
    local bbl = Instance.new("TextLabel", bb)
    bbl.Size             = UDim2.new(1, 0, 1, 0)
    bbl.BackgroundTransparency = 1
    bbl.Text             = "⚡ KSA3396 HUB"
    bbl.TextColor3       = Color3.fromRGB(255, 255, 0)
    bbl.TextSize         = 15
    bbl.Font             = Enum.Font.GothamBold

    -- Drop fast to target
    local dropBV = Instance.new("BodyVelocity", cube)
    dropBV.Velocity  = Vector3.new(0, -250, 0)
    dropBV.MaxForce  = Vector3.new(1e9, 1e9, 1e9)

    task.delay(0.3, function()
        -- Fling the player upward + sideways
        if target.Character then
            local hrp2 = target.Character:FindFirstChild("HumanoidRootPart")
            if hrp2 then
                for _, v in ipairs(hrp2:GetChildren()) do
                    if v:IsA("BodyVelocity") then v:Destroy() end
                end
                local fBV = Instance.new("BodyVelocity", hrp2)
                fBV.Velocity = Vector3.new(
                    math.random(-350, 350),
                    900,
                    math.random(-350, 350)
                )
                fBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                Debris:AddItem(fBV, 0.22)
                local hum = target.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end
            end
        end
        -- Cube flash effect
        cube.BrickColor = BrickColor.new("Bright yellow")
        Debris:AddItem(cube, 2)
    end)
end

MakeToggle("Fling القريبين تلقائياً", function(on)
    flingEnabled = on
    if on then
        flingLoop = RunService.Heartbeat:Connect(function()
            if not flingEnabled then return end
            Character     = LocalPlayer.Character
            HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
            if not HumanoidRootPart then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local tHRP = p.Character:FindFirstChild("HumanoidRootPart")
                    if tHRP and (HumanoidRootPart.Position - tHRP.Position).Magnitude < 30 then
                        local bv = Instance.new("BodyVelocity", tHRP)
                        bv.Velocity  = (tHRP.Position - HumanoidRootPart.Position).Unit * 280 + Vector3.new(0,180,0)
                        bv.MaxForce  = Vector3.new(1e9,1e9,1e9)
                        Debris:AddItem(bv, 0.2)
                    end
                end
            end
        end)
    else
        if flingLoop then flingLoop:Disconnect() flingLoop = nil end
    end
end)

MakeButton("🟥 Cube Fling → الهدف المختار", Color3.fromRGB(140, 35, 35), function()
    if selectedTarget then
        DoCubeFling(selectedTarget)
    else
        targetLabel.Text = "⚠️ اختر لاعب أولاً!"
    end
end)

MakeButton("🟥 Cube Fling → كل اللاعبين", Color3.fromRGB(140, 35, 35), function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            task.spawn(DoCubeFling, p)
            task.wait(0.05)
        end
    end
end)

-- ==================== TELEPORT ====================

MakeSection("📍 Teleport (انتقال)")

MakeButton("📍 انتقل للهدف", Color3.fromRGB(30, 60, 30), function()
    if not selectedTarget or not selectedTarget.Character then
        targetLabel.Text = "⚠️ اختر لاعب أولاً!"
        return
    end
    Character = LocalPlayer.Character
    local tHRP = selectedTarget.Character:FindFirstChild("HumanoidRootPart")
    if Character and Character:FindFirstChild("HumanoidRootPart") and tHRP then
        Character.HumanoidRootPart.CFrame = tHRP.CFrame * CFrame.new(0, 4, 0)
    end
end)

MakeButton("📍 انتقل لعشوائي", Color3.fromRGB(30, 50, 80), function()
    local ps = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(ps, p)
        end
    end
    if #ps > 0 then
        local t = ps[math.random(1, #ps)]
        Character = LocalPlayer.Character
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 4, 0)
        end
    end
end)

MakeButton("📍 انتقل للـ Spawn", Color3.fromRGB(30, 45, 70), function()
    Character = LocalPlayer.Character
    local sp = Workspace:FindFirstChildOfClass("SpawnLocation")
    if Character and Character:FindFirstChild("HumanoidRootPart") and sp then
        Character.HumanoidRootPart.CFrame = sp.CFrame * CFrame.new(0, 5, 0)
    end
end)

-- ==================== COMBAT ====================

MakeSection("💀 Combat (قتال)")

MakeToggle("God Mode (لا موت)", function(on)
    RunService.Heartbeat:Connect(function()
        if on then
            Character = LocalPlayer.Character
            if Character and Character:FindFirstChild("Humanoid") then
                Character.Humanoid.Health = Character.Humanoid.MaxHealth
            end
        end
    end)
end)

MakeToggle("ESP (رؤية اللاعبين)", function(on)
    for _, c in ipairs(espConns) do c:Disconnect() end espConns = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local h = p.Character:FindFirstChildOfClass("Highlight")
            if on then
                if not h then
                    local hl = Instance.new("Highlight", p.Character)
                    hl.FillColor           = Color3.fromRGB(255, 50, 50)
                    hl.OutlineColor        = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency    = 0.5
                end
            else
                if h then h:Destroy() end
            end
        end
    end
end)

MakeButton("💥 Kill الهدف", Color3.fromRGB(100, 20, 20), function()
    if selectedTarget and selectedTarget.Character then
        local h = selectedTarget.Character:FindFirstChildOfClass("Humanoid")
        if h then h.Health = 0 end
    else
        targetLabel.Text = "⚠️ اختر لاعب أولاً!"
    end
end)

MakeButton("💥 Kill الكل", Color3.fromRGB(120, 20, 20), function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if h then h.Health = 0 end
        end
    end
end)

-- ==================== EXTRAS ====================

MakeSection("⚙️ Extras (إضافات)")

MakeToggle("Anti-AFK (ضد الطرد)", function(on)
    antiAfk = on
    if on then
        local VU = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            if antiAfk then
                VU:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                task.wait(1)
                VU:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            end
        end)
    end
end)

MakeToggle("Chat Spam (إزعاج الشات)", function(on)
    chatSpam = on
    if on then
        task.spawn(function()
            while chatSpam do
                local rs  = game:GetService("ReplicatedStorage")
                local evt = rs:FindFirstChild("DefaultChatSystemChatEvents")
                if evt then
                    local sm = evt:FindFirstChild("SayMessageRequest")
                    if sm then sm:FireServer("⚡ KSA3396 HUB 👑 | Developer by KSA3396", "All") end
                end
                task.wait(0.9)
            end
        end)
    end
end)

-- ==================== INFO ====================

MakeSection("ℹ️ Info")
MakeInfoBox("⚡ KSA3396 Hub v3.0\nDeveloper by KSA3396 | Delta Executor\nRightShift = فتح / إغلاق اللوحة\nاضغط على الماب لوضع المعكب المظلم")

-- ==================== زر تبديل موبايل (دائماً ظاهر) ====================
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size              = UDim2.new(0, 80, 0, 35)
ToggleBtn.Position          = UDim2.new(0, 10, 0.5, -17)
ToggleBtn.BackgroundColor3  = Color3.fromRGB(90, 40, 190)
ToggleBtn.TextColor3        = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text              = "🎛️ KSA"
ToggleBtn.TextSize          = 13
ToggleBtn.Font              = Enum.Font.GothamBold
ToggleBtn.BorderSizePixel   = 0
ToggleBtn.ZIndex            = 999
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ==================== KEYBIND ====================
UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ==================== RESPAWN FIX ====================
LocalPlayer.CharacterAdded:Connect(function(char)
    Character        = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Humanoid         = char:WaitForChild("Humanoid")
    Humanoid.WalkSpeed  = walkSpeed
    Humanoid.JumpPower  = jumpPower
    if spectating then
        Camera.CameraType = Enum.CameraType.Custom
        Camera.CameraSubject = Humanoid
    end
    -- حافظ على شكل السماء بعد الريسبون
    if isSkyForm then
        task.wait(1.2)
        TransformToSkyCube(skyFormColor, selfCubeSize)
    end
end)

print("✅ KSA3396 Hub v3.0 Loaded! | Developer by KSA3396")
print("📌 RightShift → فتح / إغلاق | اضغط على الماب لوضع معكب ظلام")
