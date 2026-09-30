-- ============================================================
-- EXECUTE HUB - v1.3.0 SPEED + ANTIBAN PRO
-- Bỏ Universal/NPC Ignore. Chỉ Speed + Anti-Ban chuyên nghiệp
-- Anti-Ban: Randomize, Jitter, Bypass detection
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- CONFIG
-- ============================================================
local Config = {
    BgColor     = Color3.fromRGB(15, 15, 18),
    PanelColor  = Color3.fromRGB(25, 25, 30),
    CardColor   = Color3.fromRGB(35, 35, 42),
    Accent      = Color3.fromRGB(255, 30, 39),
    AccentHover = Color3.fromRGB(224, 22, 31),
    TextColor   = Color3.fromRGB(255, 255, 255),
    TextDim     = Color3.fromRGB(180, 180, 190),
    BorderColor = Color3.fromRGB(70, 70, 80),
    Version     = "v1.3.0-Pro"
}

-- ============================================================
-- STATE
-- ============================================================
local State = {
    SpeedEnabled      = false,
    SpeedValue        = 16,
    AntiFlingEnabled  = false,
    AntiVoidEnabled   = false,
    FlyEnabled        = false,
    NoclipEnabled     = false,
    InfJumpEnabled    = false,
    AntiAfkEnabled    = true,
    -- ANTI-BAN PRO
    AntiBanEnabled    = true,
    JitterEnabled     = true,       -- Random offset mỗi frame
    RateLimitEnabled  = true,       -- Chỉ update 20 lần/s (không 60)
    VelocityBypass    = true,       -- Dùng velocity thay WalkSpeed khi cần
    LegitMode         = false,      -- Speed giả lập người chơi thật
    MaxSpeed          = 250,        -- Trần speed tối đa (không cho hack quá)
    SpeedRampUp       = true        -- Tăng dần thay vì nhảy đột ngột
}

-- ============================================================
-- ANTI-BAN PRO CORE
-- ============================================================
local AntiBan = {
    -- Tick counter để rate limit
    tick = 0,
    -- Speed history để phát hiện pattern
    speedHistory = {},
    -- Random seed
    seed = 0,
    -- Ramp-up state
    currentRampSpeed = 16
}

-- Jitter: random offset nhỏ ±2 (giống player thật)
local function getJitteredSpeed(base)
    if not State.JitterEnabled then return base end
    local jitter = math.random(-2, 2)
    -- Đôi khi không jitter (10% cases)
    if math.random(1, 10) == 1 then jitter = 0 end
    return base + jitter
end

-- Rate limiter: chỉ update mỗi 3 frame (20Hz)
local function shouldUpdate()
    if not State.RateLimitEnabled then return true end
    AntiBan.tick = (AntiBan.tick + 1) % 3
    return AntiBan.tick == 0
end

-- Ramp-up: tăng tốc từ từ thay vì nhảy ngay
local function getRampSpeed(target)
    if not State.SpeedRampUp then return target end
    local diff = target - AntiBan.currentRampSpeed
    if math.abs(diff) < 0.5 then
        AntiBan.currentRampSpeed = target
        return target
    end
    -- Tăng/giảm mỗi frame 5% của diff
    AntiBan.currentRampSpeed = AntiBan.currentRampSpeed + diff * 0.05
    return math.floor(AntiBan.currentRampSpeed)
end

-- Legit mode: giới hạn speed bằng ngưỡng an toàn
local function applyLegitCap(speed)
    if not State.LegitMode then return speed end
    -- Giới hạn như người chơi bình thường: max 60
    if speed > 60 then return 60 end
    return speed
end

-- Phát hiện server-side velocity check
local function isServerChecking()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    -- Nếu WalkSpeed bị server reset về 16 → server check
    if State.SpeedEnabled and hum.WalkSpeed == 16 and State.SpeedValue > 20 then
        return true
    end
    return false
end

-- ============================================================
-- CLEANUP
-- ============================================================
pcall(function()
    if CoreGui:FindFirstChild("ExecuteHub") then CoreGui.ExecuteHub:Destroy() end
end)
pcall(function()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg and pg:FindFirstChild("ExecuteHub") then pg.ExecuteHub:Destroy() end
end)

local function cleanupSpeedInstances()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, name in ipairs({"SpeedBV", "AntiFlingBV", "FlyBV", "FlyBG"}) do
        local obj = hrp:FindFirstChild(name)
        if obj then pcall(function() obj:Destroy() end) end
    end
end

local function resetCharacterPhysics()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function() hum.WalkSpeed = 16 end)
        pcall(function() hum.JumpPower = 50 end)
        pcall(function() hum.PlatformStand = false end)
    end
    cleanupSpeedInstances()
end

-- ============================================================
-- UI ROOT
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExecuteHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 560, 0, 460)
Main.Position = UDim2.new(0.5, -280, 0.5, -230)
Main.BackgroundColor3 = Config.BgColor
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Config.Accent
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.4
MainStroke.Parent = Main

-- TOP BAR
local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 60)
Top.BackgroundColor3 = Config.PanelColor
Top.BorderSizePixel = 0
Top.Parent = Main
local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 14)
TopCorner.Parent = Top

local TopCover = Instance.new("Frame")
TopCover.Size = UDim2.new(1, 0, 0, 20)
TopCover.Position = UDim2.new(0, 0, 1, -20)
TopCover.BackgroundColor3 = Config.PanelColor
TopCover.BorderSizePixel = 0
TopCover.Parent = Top

local LogoBox = Instance.new("Frame")
LogoBox.Size = UDim2.new(0, 44, 0, 44)
LogoBox.Position = UDim2.new(0, 12, 0.5, -22)
LogoBox.BackgroundColor3 = Config.Accent
LogoBox.BorderSizePixel = 0
LogoBox.Parent = Top
local LogoBoxCorner = Instance.new("UICorner")
LogoBoxCorner.CornerRadius = UDim.new(0, 10)
LogoBoxCorner.Parent = LogoBox

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "EH"
LogoText.TextColor3 = Config.TextColor
LogoText.TextSize = 20
LogoText.Font = Enum.Font.GothamBold
LogoText.Parent = LogoBox

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 320, 0, 26)
Title.Position = UDim2.new(0, 68, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "EXECUTE HUB"
Title.TextColor3 = Config.Accent
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(0, 320, 0, 14)
SubTitle.Position = UDim2.new(0, 68, 0, 34)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = Config.Version .. "  •  Speed Pro"
SubTitle.TextColor3 = Config.TextDim
SubTitle.TextSize = 11
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = Top

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -16)
CloseBtn.BackgroundColor3 = Config.Accent
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Config.TextColor
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Top
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -76, 0.5, -16)
MinBtn.BackgroundColor3 = Config.CardColor
MinBtn.Text = "-"
MinBtn.TextColor3 = Config.TextColor
MinBtn.TextSize = 20
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.AutoButtonColor = false
MinBtn.Parent = Top
local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinBtn

-- SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, -72)
Sidebar.Position = UDim2.new(0, 0, 0, 60)
Sidebar.BackgroundColor3 = Config.PanelColor
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SidebarDivider = Instance.new("Frame")
SidebarDivider.Size = UDim2.new(0, 2, 1, -20)
SidebarDivider.Position = UDim2.new(1, -2, 0, 10)
SidebarDivider.BackgroundColor3 = Config.Accent
SidebarDivider.BorderSizePixel = 0
SidebarDivider.Parent = Sidebar

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -160, 1, -72)
Content.Position = UDim2.new(0, 158, 0, 60)
Content.BackgroundColor3 = Config.BgColor
Content.BorderSizePixel = 0
Content.Parent = Main

-- ============================================================
-- BUILDERS
-- ============================================================
local Tabs = {}

local function createTab(name)
    local index = 0
    for _ in pairs(Tabs) do index = index + 1 end

    local Tab = Instance.new("TextButton")
    Tab.Size = UDim2.new(1, -12, 0, 40)
    Tab.Position = UDim2.new(0, 6, 0, (index * 46) + 10)
    Tab.BackgroundColor3 = Config.PanelColor
    Tab.Text = name
    Tab.TextColor3 = Config.TextDim
    Tab.TextSize = 13
    Tab.Font = Enum.Font.GothamBold
    Tab.BorderSizePixel = 0
    Tab.AutoButtonColor = false
    Tab.Parent = Sidebar
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = Tab

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 3, 0.6, 0)
    Indicator.Position = UDim2.new(0, 0, 0.2, 0)
    Indicator.BackgroundColor3 = Config.Accent
    Indicator.BorderSizePixel = 0
    Indicator.Visible = false
    Indicator.Parent = Tab
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = Indicator

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Config.Accent
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Visible = false
    Page.Parent = Content

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Page

    local Padding = Instance.new("UIPadding")
    Padding.PaddingTop = UDim.new(0, 10)
    Padding.PaddingLeft = UDim.new(0, 10)
    Padding.PaddingRight = UDim.new(0, 10)
    Padding.PaddingBottom = UDim.new(0, 10)
    Padding.Parent = Page

    Tabs[name] = { Button = Tab, Page = Page, Indicator = Indicator }

    Tab.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Button.BackgroundColor3 = Config.PanelColor
            t.Button.TextColor3 = Config.TextDim
            t.Page.Visible = false
            t.Indicator.Visible = false
        end
        Tab.BackgroundColor3 = Config.CardColor
        Tab.TextColor3 = Config.Accent
        Page.Visible = true
        Indicator.Visible = true
    end)

    return Page
end

local function createToggle(parent, text, default, callback)
    local T = Instance.new("Frame")
    T.Size = UDim2.new(1, 0, 0, 44)
    T.BackgroundColor3 = Config.CardColor
    T.BorderSizePixel = 0
    T.Parent = parent
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 10)
    TCorner.Parent = T

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -90, 1, 0)
    Label.Position = UDim2.new(0, 16, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Config.TextColor
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = T

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0, 46, 0, 22)
    Toggle.Position = UDim2.new(1, -60, 0.5, -11)
    Toggle.BackgroundColor3 = default and Config.Accent or Config.BorderColor
    Toggle.Text = ""
    Toggle.BorderSizePixel = 0
    Toggle.AutoButtonColor = false
    Toggle.Parent = T
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = Toggle

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    Circle.BackgroundColor3 = Config.TextColor
    Circle.BorderSizePixel = 0
    Circle.Parent = Toggle
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle

    local isOn = default
    Toggle.MouseButton1Click:Connect(function()
        isOn = not isOn
        TweenService:Create(Toggle, TweenInfo.new(0.2), {
            BackgroundColor3 = isOn and Config.Accent or Config.BorderColor
        }):Play()
        TweenService:Create(Circle, TweenInfo.new(0.2), {
            Position = isOn and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        }):Play()
        if callback then callback(isOn) end
    end)
    return T
end

local function createSlider(parent, text, min, max, default, callback)
    local S = Instance.new("Frame")
    S.Size = UDim2.new(1, 0, 0, 68)
    S.BackgroundColor3 = Config.CardColor
    S.BorderSizePixel = 0
    S.Parent = parent
    local SCorner = Instance.new("UICorner")
    SCorner.CornerRadius = UDim.new(0, 10)
    SCorner.Parent = S

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -90, 0, 20)
    Label.Position = UDim2.new(0, 16, 0, 10)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Config.TextColor
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = S

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 60, 0, 20)
    ValueLabel.Position = UDim2.new(1, -76, 0, 10)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Config.Accent
    ValueLabel.TextSize = 13
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = S

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -32, 0, 6)
    Bar.Position = UDim2.new(0, 16, 0, 46)
    Bar.BackgroundColor3 = Config.BorderColor
    Bar.BorderSizePixel = 0
    Bar.Parent = S
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = Bar

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Config.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 18, 0, 18)
    Dot.Position = UDim2.new((default - min) / (max - min), -9, 0.5, -9)
    Dot.BackgroundColor3 = Config.Accent
    Dot.BorderSizePixel = 0
    Dot.Parent = Bar
    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = Dot

    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        Dot.Position = UDim2.new(pos, -9, 0.5, -9)
        ValueLabel.Text = tostring(value)
        if callback then callback(value) end
    end

    Dot.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            update(input)
            dragging = true
        end
    end)

    return S
end

local function createButton(parent, text, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, 0, 0, 44)
    B.BackgroundColor3 = Config.CardColor
    B.Text = text
    B.TextColor3 = Config.TextColor
    B.TextSize = 13
    B.Font = Enum.Font.GothamBold
    B.BorderSizePixel = 0
    B.AutoButtonColor = false
    B.Parent = parent
    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 10)
    BCorner.Parent = B

    B.MouseEnter:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.15), {BackgroundColor3 = Config.Accent}):Play()
    end)
    B.MouseLeave:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.15), {BackgroundColor3 = Config.CardColor}):Play()
    end)
    B.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return B
end

-- ============================================================
-- NOTIFICATION
-- ============================================================
local function notify(text, isError)
    local color = isError and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(50, 220, 100)
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 320, 0, 56)
    Notif.Position = UDim2.new(0.5, -160, 0, 20)
    Notif.BackgroundColor3 = Config.CardColor
    Notif.BorderSizePixel = 0
    Notif.Parent = ScreenGui
    local NCorner = Instance.new("UICorner")
    NCorner.CornerRadius = UDim.new(0, 10)
    NCorner.Parent = Notif

    local NStroke = Instance.new("UIStroke")
    NStroke.Color = color
    NStroke.Thickness = 2
    NStroke.Parent = Notif

    local NText = Instance.new("TextLabel")
    NText.Size = UDim2.new(1, -20, 1, 0)
    NText.Position = UDim2.new(0, 10, 0, 0)
    NText.BackgroundTransparency = 1
    NText.Text = text
    NText.TextColor3 = color
    NText.TextSize = 13
    NText.Font = Enum.Font.GothamBold
    NText.TextWrapped = true
    NText.Parent = Notif

    task.spawn(function()
        task.wait(3)
        TweenService:Create(Notif, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(NText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(NStroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
        task.wait(0.5)
        Notif:Destroy()
    end)
end

-- ============================================================
-- SPEED TAB
-- ============================================================
local SpeedPage = createTab("Speed")

createToggle(SpeedPage, "⚡ Speed Hack", false, function(on) 
    State.SpeedEnabled = on 
    if not on then AntiBan.currentRampSpeed = 16 end
end)

createSlider(SpeedPage, "Speed Value", 16, 500, 16, function(v) 
    State.SpeedValue = v 
    -- Reset ramp khi user kéo slider
    if v < AntiBan.currentRampSpeed then
        AntiBan.currentRampSpeed = v
    end
end)

createButton(SpeedPage, "🚀 Quick Speed 100", function()
    State.SpeedValue = 100
    State.SpeedEnabled = true
    notify("⚡ Speed set to 100", false)
end)

createButton(SpeedPage, "🚀 Quick Speed 200", function()
    State.SpeedValue = 200
    State.SpeedEnabled = true
    notify("⚡ Speed set to 200", false)
end)

createButton(SpeedPage, "🛑 Reset Speed to 16", function()
    State.SpeedValue = 16
    State.SpeedEnabled = false
    AntiBan.currentRampSpeed = 16
    resetCharacterPhysics()
    notify("✅ Speed reset", false)
end)

-- ============================================================
-- MOVEMENT TAB
-- ============================================================
local MovePage = createTab("Movement")
createToggle(MovePage, "Fly", false, function(on) State.FlyEnabled = on end)
createToggle(MovePage, "Noclip", false, function(on) State.NoclipEnabled = on end)
createToggle(MovePage, "Infinite Jump", false, function(on) State.InfJumpEnabled = on end)
createToggle(MovePage, "Anti-Fling", false, function(on) State.AntiFlingEnabled = on end)
createToggle(MovePage, "Anti-Void", false, function(on) State.AntiVoidEnabled = on end)

-- ============================================================
-- ANTI-BAN TAB (PRO)
-- ============================================================
local AntiBanPage = createTab("Anti-Ban")

createToggle(AntiBanPage, "🛡️ Anti-Ban System", true, function(on) State.AntiBanEnabled = on end)
createToggle(AntiBanPage, "🎭 Jitter (random ±2)", true, function(on) State.JitterEnabled = on end)
createToggle(AntiBanPage, "⏱️ Rate Limit (20Hz)", true, function(on) State.RateLimitEnabled = on end)
createToggle(AntiBanPage, "📈 Ramp Up (tăng dần)", true, function(on) State.SpeedRampUp = on end)
createToggle(AntiBanPage, "👤 Legit Mode (max 60)", false, function(on) State.LegitMode = on end)

createSlider(AntiBanPage, "Max Speed Cap", 50, 500, 250, function(v) State.MaxSpeed = v end)

createButton(AntiBanPage, "🔍 Test Server Detection", function()
    if isServerChecking() then
        notify("⚠️ Server đang check WalkSpeed! Giảm speed lại.", true)
    else
        notify("✅ Server không check WalkSpeed", false)
    end
end)

createButton(AntiBanPage, "🧹 Panic Cleanup", function()
    resetCharacterPhysics()
    State.SpeedEnabled = false
    State.FlyEnabled = false
    State.NoclipEnabled = false
    State.AntiFlingEnabled = false
    State.AntiVoidEnabled = false
    AntiBan.currentRampSpeed = 16
    notify("✅ Panic cleanup executed", false)
end)

createButton(AntiBanPage, "🔧 Reset Physics", function()
    resetCharacterPhysics()
    notify("✅ Physics reset", false)
end)

-- ============================================================
-- SETTINGS
-- ============================================================
local SettingsPage = createTab("Settings")
createButton(SettingsPage, "Reset Character", function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end
end)
createButton(SettingsPage, "Unload Script", function()
    resetCharacterPhysics()
    ScreenGui:Destroy()
end)

-- Default
if Tabs["Speed"] then
    Tabs["Speed"].Button.BackgroundColor3 = Config.CardColor
    Tabs["Speed"].Button.TextColor3 = Config.Accent
    Tabs["Speed"].Page.Visible = true
    Tabs["Speed"].Indicator.Visible = true
end

-- ============================================================
-- SPEED HACK CORE (with Anti-Ban Pro)
-- ============================================================
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    if State.SpeedEnabled and State.AntiBanEnabled then
        -- Rate limit
        if not shouldUpdate() then return end

        local target = State.SpeedValue

        -- Legit mode cap
        target = applyLegitCap(target)

        -- Max speed cap
        if target > State.MaxSpeed then target = State.MaxSpeed end

        -- Ramp up
        local speed = getRampSpeed(target)

        -- Jitter
        speed = getJitteredSpeed(speed)

        -- Apply WalkSpeed
        pcall(function() hum.WalkSpeed = speed end)

        -- Velocity injection khi di chuyển
        if hum.MoveDirection.Magnitude > 0.1 then
            local dir = hum.MoveDirection
            pcall(function()
                hrp.Velocity = Vector3.new(dir.X * speed, hrp.Velocity.Y, dir.Z * speed)
            end)
        else
            pcall(function()
                hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
            end)
        end

    elseif State.SpeedEnabled and not State.AntiBanEnabled then
        -- Speed thô không anti-ban
        local v = State.SpeedValue
        pcall(function() hum.WalkSpeed = v end)
        if hum.MoveDirection.Magnitude > 0.1 then
            local dir = hum.MoveDirection
            pcall(function()
                hrp.Velocity = Vector3.new(dir.X * v, hrp.Velocity.Y, dir.Z * v)
            end)
        end
    else
        pcall(function()
            hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
        end)
    end
end)

-- Cleanup loop
task.spawn(function()
    while task.wait(0.5) do
        cleanupSpeedInstances()
    end
end)

-- Anti-Fling / Anti-Void
task.spawn(function()
    while task.wait(0.1) do
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if State.AntiFlingEnabled and hrp then
                pcall(function()
                    hrp.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 1, 1)
                end)
            end
            if State.AntiVoidEnabled and hrp and hrp.Position.Y < -50 then
                pcall(function() hrp.CFrame = CFrame.new(0, 50, 0) end)
            end
        end
    end
end)

-- Noclip
task.spawn(function()
    while task.wait(0.2) do
        if State.NoclipEnabled then
            local char = LocalPlayer.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then
                        pcall(function() p.CanCollide = false end)
                    end
                end
            end
        end
    end
end)

-- Fly
local flyConn, flyCleanup
local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local oldBV = hrp:FindFirstChild("FlyBV")
    if oldBV then oldBV:Destroy() end
    local oldBG = hrp:FindFirstChild("FlyBG")
    if oldBG then oldBG:Destroy() end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "FlyBV"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp

    local bg = Instance.new("BodyGyro")
    bg.Name = "FlyBG"
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 10000
    bg.D = 500
    bg.Parent = hrp

    hum.PlatformStand = true

    flyConn = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local dir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
        local speed = 60
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then speed = 120 end
        bv.Velocity = dir * speed
        bg.CFrame = cam.CFrame
    end)

    flyCleanup = function()
        if flyConn then flyConn:Disconnect() flyConn = nil end
        if bv and bv.Parent then bv:Destroy() end
        if bg and bg.Parent then bg:Destroy() end
        if hum then hum.PlatformStand = false end
    end
end

RunService.Heartbeat:Connect(function()
    if State.FlyEnabled and not flyConn then
        startFly()
    elseif not State.FlyEnabled and flyConn then
        if flyCleanup then flyCleanup() end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if State.InfJumpEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    if State.AntiAfkEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if flyCleanup then
        flyCleanup()
        flyConn = nil
        flyCleanup = nil
    end
    AntiBan.currentRampSpeed = 16
    if State.SpeedEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = State.SpeedValue end
        end
    end
end)

-- Buttons
CloseBtn.MouseButton1Click:Connect(function()
    resetCharacterPhysics()
    ScreenGui:Destroy()
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Main.Size = minimized and UDim2.new(0, 560, 0, 60) or UDim2.new(0, 560, 0, 460)
    Sidebar.Visible = not minimized
    Content.Visible = not minimized
end)

-- Keybind
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
    end
end)

print("[EXECUTE HUB] " .. Config.Version .. " loaded — Speed + Anti-Ban Pro")
print("[EXECUTE HUB] Jitter: " .. (State.JitterEnabled and "ON" or "OFF"))
print("[EXECUTE HUB] Rate Limit: " .. (State.RateLimitEnabled and "ON" or "OFF"))
print("[EXECUTE HUB] Ramp Up: " .. (State.SpeedRampUp and "ON" or "OFF"))
print("[EXECUTE HUB] Right Ctrl = toggle UI")
