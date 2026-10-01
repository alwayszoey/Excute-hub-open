-- ============================================================
-- EXECUTE HUB - v1.4.0 REDESIGNED UI (ReaperX Style)
-- Theme: Đen-Đỏ, sidebar + content layout, logo box
-- Speed + Anti-Ban Pro, optimized stability
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
    -- Colors (ReaperX inspired)
    BgDark       = Color3.fromRGB(12, 12, 15),
    BgPanel      = Color3.fromRGB(22, 22, 28),
    BgCard       = Color3.fromRGB(32, 32, 40),
    BgCardHover  = Color3.fromRGB(45, 45, 55),
    BgSidebar    = Color3.fromRGB(18, 18, 22),
    BgTopBar     = Color3.fromRGB(25, 25, 32),
    Accent       = Color3.fromRGB(255, 35, 45),
    AccentHover  = Color3.fromRGB(255, 60, 70),
    AccentDark   = Color3.fromRGB(180, 20, 30),
    TextPrimary  = Color3.fromRGB(245, 245, 250),
    TextSecond   = Color3.fromRGB(160, 160, 175),
    TextMuted    = Color3.fromRGB(110, 110, 125),
    Border       = Color3.fromRGB(45, 45, 55),
    BorderLight  = Color3.fromRGB(65, 65, 80),
    Success      = Color3.fromRGB(60, 220, 110),
    -- Meta
    Title        = "EXECUTE HUB",
    Subtitle     = "Pro Edition",
    Version      = "v1.4.0",
    LogoText     = "EH"
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
    AntiBanEnabled    = true,
    JitterEnabled     = true,
    RateLimitEnabled  = true,
    LegitMode         = false,
    MaxSpeed          = 250,
    SpeedRampUp       = true
}

local AntiBan = {
    tick = 0,
    currentRampSpeed = 16
}

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
-- ANTI-BAN HELPERS
-- ============================================================
local function getJitteredSpeed(base)
    if not State.JitterEnabled then return base end
    local jitter = math.random(-2, 2)
    if math.random(1, 10) == 1 then jitter = 0 end
    return base + jitter
end

local function shouldUpdate()
    if not State.RateLimitEnabled then return true end
    AntiBan.tick = (AntiBan.tick + 1) % 3
    return AntiBan.tick == 0
end

local function getRampSpeed(target)
    if not State.SpeedRampUp then return target end
    local diff = target - AntiBan.currentRampSpeed
    if math.abs(diff) < 0.5 then
        AntiBan.currentRampSpeed = target
        return target
    end
    AntiBan.currentRampSpeed = AntiBan.currentRampSpeed + diff * 0.05
    return math.floor(AntiBan.currentRampSpeed)
end

local function applyLegitCap(speed)
    if not State.LegitMode then return speed end
    if speed > 60 then return 60 end
    return speed
end

-- ============================================================
-- GUI ROOT
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

-- ============================================================
-- MAIN WINDOW
-- ============================================================
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 620, 0, 440)
Main.Position = UDim2.new(0.5, -310, 0.5, -220)
Main.BackgroundColor3 = Config.BgDark
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

-- Subtle red glow border
local MainGlow = Instance.new("Frame")
MainGlow.Size = UDim2.new(1, 4, 1, 4)
MainGlow.Position = UDim2.new(0, -2, 0, -2)
MainGlow.BackgroundColor3 = Config.Accent
MainGlow.BackgroundTransparency = 0.85
MainGlow.BorderSizePixel = 0
MainGlow.ZIndex = 0
MainGlow.Parent = Main
local MainGlowCorner = Instance.new("UICorner")
MainGlowCorner.CornerRadius = UDim.new(0, 14)
MainGlowCorner.Parent = MainGlow

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Config.Accent
MainStroke.Thickness = 1
MainStroke.Transparency = 0.5
MainStroke.Parent = Main

-- ============================================================
-- TOP BAR
-- ============================================================
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 56)
TopBar.BackgroundColor3 = Config.BgTopBar
TopBar.BorderSizePixel = 0
TopBar.Parent = Main
local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 14)
TopBarCorner.Parent = TopBar

local TopBarCover = Instance.new("Frame")
TopBarCover.Size = UDim2.new(1, 0, 0, 18)
TopBarCover.Position = UDim2.new(0, 0, 1, -18)
TopBarCover.BackgroundColor3 = Config.BgTopBar
TopBarCover.BorderSizePixel = 0
TopBarCover.Parent = TopBar

-- LOGO BOX (đỏ, chữ EH)
local LogoBox = Instance.new("Frame")
LogoBox.Size = UDim2.new(0, 40, 0, 40)
LogoBox.Position = UDim2.new(0, 12, 0.5, -20)
LogoBox.BackgroundColor3 = Config.Accent
LogoBox.BorderSizePixel = 0
LogoBox.Parent = TopBar
local LogoBoxCorner = Instance.new("UICorner")
LogoBoxCorner.CornerRadius = UDim.new(0, 10)
LogoBoxCorner.Parent = LogoBox

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = Config.AccentHover
LogoStroke.Thickness = 1
LogoStroke.Transparency = 0.3
LogoStroke.Parent = LogoBox

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = Config.LogoText
LogoText.TextColor3 = Config.TextPrimary
LogoText.TextSize = 18
LogoText.Font = Enum.Font.GothamBold
LogoText.Parent = LogoBox

-- TITLE
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 280, 0, 24)
Title.Position = UDim2.new(0, 62, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = Config.Title
Title.TextColor3 = Config.Accent
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(0, 280, 0, 14)
SubTitle.Position = UDim2.new(0, 62, 0, 30)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = Config.Subtitle .. "  •  " .. Config.Version
SubTitle.TextColor3 = Config.TextSecond
SubTitle.TextSize = 11
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = TopBar

-- VERSION PILL
local VersionPill = Instance.new("Frame")
VersionPill.Size = UDim2.new(0, 60, 0, 22)
VersionPill.Position = UDim2.new(1, -130, 0.5, -11)
VersionPill.BackgroundColor3 = Config.AccentDark
VersionPill.BorderSizePixel = 0
VersionPill.Parent = TopBar
local VersionCorner = Instance.new("UICorner")
VersionCorner.CornerRadius = UDim.new(1, 0)
VersionCorner.Parent = VersionPill

local VersionText = Instance.new("TextLabel")
VersionText.Size = UDim2.new(1, 0, 1, 0)
VersionText.BackgroundTransparency = 1
VersionText.Text = "PRO"
VersionText.TextColor3 = Config.TextPrimary
VersionText.TextSize = 11
VersionText.Font = Enum.Font.GothamBold
VersionText.Parent = VersionPill

-- MIN BUTTON
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -76, 0.5, -16)
MinBtn.BackgroundColor3 = Config.BgCard
MinBtn.Text = "−"
MinBtn.TextColor3 = Config.TextPrimary
MinBtn.TextSize = 22
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.AutoButtonColor = false
MinBtn.Parent = TopBar
local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinBtn

-- CLOSE BUTTON
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -16)
CloseBtn.BackgroundColor3 = Config.Accent
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Config.TextPrimary
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TopBar
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Config.AccentHover}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Config.Accent}):Play()
end)

-- ============================================================
-- SIDEBAR
-- ============================================================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 155, 1, -68)
Sidebar.Position = UDim2.new(0, 0, 0, 56)
Sidebar.BackgroundColor3 = Config.BgSidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SidebarDivider = Instance.new("Frame")
SidebarDivider.Size = UDim2.new(0, 1, 1, -16)
SidebarDivider.Position = UDim2.new(1, -1, 0, 8)
SidebarDivider.BackgroundColor3 = Config.Border
SidebarDivider.BorderSizePixel = 0
SidebarDivider.Parent = Sidebar

-- User info block (đỉnh sidebar)
local UserBlock = Instance.new("Frame")
UserBlock.Size = UDim2.new(1, -16, 0, 50)
UserBlock.Position = UDim2.new(0, 8, 0, 8)
UserBlock.BackgroundColor3 = Config.BgCard
UserBlock.BorderSizePixel = 0
UserBlock.Parent = Sidebar
local UserBlockCorner = Instance.new("UICorner")
UserBlockCorner.CornerRadius = UDim.new(0, 8)
UserBlockCorner.Parent = UserBlock

local UserAvatar = Instance.new("Frame")
UserAvatar.Size = UDim2.new(0, 34, 0, 34)
UserAvatar.Position = UDim2.new(0, 8, 0.5, -17)
UserAvatar.BackgroundColor3 = Config.Accent
UserAvatar.BorderSizePixel = 0
UserAvatar.Parent = UserBlock
local UserAvatarCorner = Instance.new("UICorner")
UserAvatarCorner.CornerRadius = UDim.new(1, 0)
UserAvatarCorner.Parent = UserAvatar

local UserInitial = Instance.new("TextLabel")
UserInitial.Size = UDim2.new(1, 0, 1, 0)
UserInitial.BackgroundTransparency = 1
UserInitial.Text = string.sub(LocalPlayer.Name, 1, 1):upper()
UserInitial.TextColor3 = Config.TextPrimary
UserInitial.TextSize = 16
UserInitial.Font = Enum.Font.GothamBold
UserInitial.Parent = UserAvatar

local UserName = Instance.new("TextLabel")
UserName.Size = UDim2.new(1, -60, 0, 16)
UserName.Position = UDim2.new(0, 50, 0, 8)
UserName.BackgroundTransparency = 1
UserName.Text = LocalPlayer.Name
UserName.TextColor3 = Config.TextPrimary
UserName.TextSize = 12
UserName.Font = Enum.Font.GothamBold
UserName.TextXAlignment = Enum.TextXAlignment.Left
UserName.TextTruncate = Enum.TextTruncate.AtEnd
UserName.Parent = UserBlock

local UserStatus = Instance.new("TextLabel")
UserStatus.Size = UDim2.new(1, -60, 0, 12)
UserStatus.Position = UDim2.new(0, 50, 0, 26)
UserStatus.BackgroundTransparency = 1
UserStatus.Text = "● Online"
UserStatus.TextColor3 = Config.Success
UserStatus.TextSize = 10
UserStatus.Font = Enum.Font.GothamMedium
UserStatus.TextXAlignment = Enum.TextXAlignment.Left
UserStatus.Parent = UserBlock

-- ============================================================
-- CONTENT
-- ============================================================
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -163, 1, -68)
Content.Position = UDim2.new(0, 163, 0, 56)
Content.BackgroundColor3 = Config.BgDark
Content.BorderSizePixel = 0
Content.Parent = Main

-- ============================================================
-- TAB BUILDER
-- ============================================================
local Tabs = {}
local ActiveTab = nil

local function createTab(name, icon, order)
    order = order or (#Tabs + 1)

    local Tab = Instance.new("TextButton")
    Tab.Size = UDim2.new(1, -16, 0, 34)
    Tab.Position = UDim2.new(0, 8, 0, 66 + ((order - 1) * 38))
    Tab.BackgroundColor3 = Config.BgSidebar
    Tab.Text = "  " .. icon .. "   " .. name
    Tab.TextColor3 = Config.TextSecond
    Tab.TextSize = 12
    Tab.Font = Enum.Font.GothamBold
    Tab.TextXAlignment = Enum.TextXAlignment.Left
    Tab.BorderSizePixel = 0
    Tab.AutoButtonColor = false
    Tab.Parent = Sidebar
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = Tab

    -- Active indicator (red bar)
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 3, 0.55, 0)
    Indicator.Position = UDim2.new(0, 0, 0.225, 0)
    Indicator.BackgroundColor3 = Config.Accent
    Indicator.BorderSizePixel = 0
    Indicator.Visible = false
    Indicator.Parent = Tab
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = Indicator

    -- Page
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Config.Accent
    Page.ScrollBarImageTransparency = 0.3
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Visible = false
    Page.Parent = Content

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 6)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Page

    local PagePadding = Instance.new("UIPadding")
    PagePadding.PaddingTop = UDim.new(0, 10)
    PagePadding.PaddingLeft = UDim.new(0, 12)
    PagePadding.PaddingRight = UDim.new(0, 12)
    PagePadding.PaddingBottom = UDim.new(0, 10)
    PagePadding.Parent = Page

    -- Header label
    local PageHeader = Instance.new("TextLabel")
    PageHeader.Size = UDim2.new(1, 0, 0, 24)
    PageHeader.BackgroundTransparency = 1
    PageHeader.Text = icon .. "  " .. name
    PageHeader.TextColor3 = Config.Accent
    PageHeader.TextSize = 15
    PageHeader.Font = Enum.Font.GothamBold
    PageHeader.TextXAlignment = Enum.TextXAlignment.Left
    PageHeader.LayoutOrder = -1
    PageHeader.Parent = Page

    local HeaderLine = Instance.new("Frame")
    HeaderLine.Size = UDim2.new(1, 0, 0, 1)
    HeaderLine.BackgroundColor3 = Config.Border
    HeaderLine.BorderSizePixel = 0
    HeaderLine.LayoutOrder = -1
    HeaderLine.Parent = Page

    Tabs[name] = { Button = Tab, Page = Page, Indicator = Indicator }

    -- Click handler
    Tab.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Button.BackgroundColor3 = Config.BgSidebar
            t.Button.TextColor3 = Config.TextSecond
            t.Page.Visible = false
            t.Indicator.Visible = false
        end
        Tab.BackgroundColor3 = Config.BgCard
        Tab.TextColor3 = Config.Accent
        Page.Visible = true
        Indicator.Visible = true
        ActiveTab = name
    end)

    -- Hover
    Tab.MouseEnter:Connect(function()
        if ActiveTab ~= name then
            TweenService:Create(Tab, TweenInfo.new(0.15), {BackgroundColor3 = Config.BgCard}):Play()
            TweenService:Create(Tab, TweenInfo.new(0.15), {TextColor3 = Config.TextPrimary}):Play()
        end
    end)
    Tab.MouseLeave:Connect(function()
        if ActiveTab ~= name then
            TweenService:Create(Tab, TweenInfo.new(0.15), {BackgroundColor3 = Config.BgSidebar}):Play()
            TweenService:Create(Tab, TweenInfo.new(0.15), {TextColor3 = Config.TextSecond}):Play()
        end
    end)

    return Page
end

-- ============================================================
-- CARD BUILDERS
-- ============================================================
local function makeCard(parent, height)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, height or 44)
    Card.BackgroundColor3 = Config.BgCard
    Card.BorderSizePixel = 0
    Card.Parent = parent
    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 9)
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = Config.Border
    CardStroke.Thickness = 1
    CardStroke.Transparency = 0.5
    CardStroke.Parent = Card

    return Card
end

local function createToggle(parent, text, default, callback)
    local Card = makeCard(parent, 42)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -80, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Config.TextPrimary
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Card

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 40, 0, 20)
    ToggleBtn.Position = UDim2.new(1, -52, 0.5, -10)
    ToggleBtn.BackgroundColor3 = default and Config.Accent or Config.Border
    ToggleBtn.Text = ""
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.Parent = Card
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleBtn

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 14, 0, 14)
    Circle.Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    Circle.BackgroundColor3 = Config.TextPrimary
    Circle.BorderSizePixel = 0
    Circle.Parent = ToggleBtn
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle

    local isOn = default
    ToggleBtn.MouseButton1Click:Connect(function()
        isOn = not isOn
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = isOn and Config.Accent or Config.Border
        }):Play()
        TweenService:Create(Circle, TweenInfo.new(0.2), {
            Position = isOn and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        }):Play()
        if callback then callback(isOn) end
    end)
    return Card
end

local function createSlider(parent, text, min, max, default, callback)
    local Card = makeCard(parent, 62)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -100, 0, 18)
    Label.Position = UDim2.new(0, 14, 0, 8)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Config.TextPrimary
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Card

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 70, 0, 18)
    ValueLabel.Position = UDim2.new(1, -84, 0, 8)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Config.Accent
    ValueLabel.TextSize = 12
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Card

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -28, 0, 5)
    Bar.Position = UDim2.new(0, 14, 0, 42)
    Bar.BackgroundColor3 = Config.Border
    Bar.BorderSizePixel = 0
    Bar.Parent = Card
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
    Dot.Size = UDim2.new(0, 16, 0, 16)
    Dot.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    Dot.BackgroundColor3 = Config.Accent
    Dot.BorderSizePixel = 0
    Dot.Parent = Bar
    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = Dot

    local DotInner = Instance.new("Frame")
    DotInner.Size = UDim2.new(1, -5, 1, -5)
    DotInner.Position = UDim2.new(0, 2.5, 0, 2.5)
    DotInner.BackgroundColor3 = Config.TextPrimary
    DotInner.BorderSizePixel = 0
    DotInner.Parent = Dot
    local DotInnerCorner = Instance.new("UICorner")
    DotInnerCorner.CornerRadius = UDim.new(1, 0)
    DotInnerCorner.Parent = DotInner

    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        Dot.Position = UDim2.new(pos, -8, 0.5, -8)
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

    return Card
end

local function createButton(parent, text, callback, isAccent)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, 0, 0, 40)
    B.BackgroundColor3 = isAccent and Config.AccentDark or Config.BgCard
    B.Text = text
    B.TextColor3 = Config.TextPrimary
    B.TextSize = 12
    B.Font = Enum.Font.GothamBold
    B.BorderSizePixel = 0
    B.AutoButtonColor = false
    B.Parent = parent
    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 9)
    BCorner.Parent = B

    local BStroke = Instance.new("UIStroke")
    BStroke.Color = isAccent and Config.Accent or Config.Border
    BStroke.Thickness = 1
    BStroke.Transparency = isAccent and 0.2 or 0.5
    BStroke.Parent = B

    B.MouseEnter:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.15), {
            BackgroundColor3 = isAccent and Config.Accent or Config.BgCardHover
        }):Play()
    end)
    B.MouseLeave:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.15), {
            BackgroundColor3 = isAccent and Config.AccentDark or Config.BgCard
        }):Play()
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
    local color = isError and Config.Accent or Config.Success
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 320, 0, 52)
    Notif.Position = UDim2.new(0.5, -160, 0, 20)
    Notif.BackgroundColor3 = Config.BgCard
    Notif.BorderSizePixel = 0
    Notif.Parent = ScreenGui
    local NCorner = Instance.new("UICorner")
    NCorner.CornerRadius = UDim.new(0, 10)
    NCorner.Parent = Notif

    local NStroke = Instance.new("UIStroke")
    NStroke.Color = color
    NStroke.Thickness = 1.5
    NStroke.Parent = Notif

    local NBar = Instance.new("Frame")
    NBar.Size = UDim2.new(0, 3, 1, -12)
    NBar.Position = UDim2.new(0, 6, 0, 6)
    NBar.BackgroundColor3 = color
    NBar.BorderSizePixel = 0
    NBar.Parent = Notif
    local NBarCorner = Instance.new("UICorner")
    NBarCorner.CornerRadius = UDim.new(1, 0)
    NBarCorner.Parent = NBar

    local NText = Instance.new("TextLabel")
    NText.Size = UDim2.new(1, -30, 1, 0)
    NText.Position = UDim2.new(0, 20, 0, 0)
    NText.BackgroundTransparency = 1
    NText.Text = text
    NText.TextColor3 = color
    NText.TextSize = 12
    NText.Font = Enum.Font.GothamBold
    NText.TextWrapped = true
    NText.TextXAlignment = Enum.TextXAlignment.Left
    NText.Parent = Notif

    task.spawn(function()
        task.wait(3)
        TweenService:Create(Notif, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(NText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(NStroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
        TweenService:Create(NBar, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        task.wait(0.5)
        Notif:Destroy()
    end)
end

-- ============================================================
-- TABS CREATION
-- ============================================================
local SpeedPage = createTab("Speed", "⚡", 1)
createToggle(SpeedPage, "Speed Hack", false, function(on)
    State.SpeedEnabled = on
    if not on then AntiBan.currentRampSpeed = 16 end
end)
createSlider(SpeedPage, "Speed Value", 16, 500, 16, function(v)
    State.SpeedValue = v
    if v < AntiBan.currentRampSpeed then AntiBan.currentRampSpeed = v end
end)
createButton(SpeedPage, "🚀 Quick Speed 100", function()
    State.SpeedValue = 100
    State.SpeedEnabled = true
    notify("⚡ Speed = 100", false)
end, true)
createButton(SpeedPage, "🚀 Quick Speed 200", function()
    State.SpeedValue = 200
    State.SpeedEnabled = true
    notify("⚡ Speed = 200", false)
end, true)
createButton(SpeedPage, "🛑 Reset Speed", function()
    State.SpeedValue = 16
    State.SpeedEnabled = false
    AntiBan.currentRampSpeed = 16
    resetCharacterPhysics()
    notify("✅ Speed reset to 16", false)
end)

local MovePage = createTab("Movement", "🏃", 2)
createToggle(MovePage, "Fly", false, function(on) State.FlyEnabled = on end)
createToggle(MovePage, "Noclip", false, function(on) State.NoclipEnabled = on end)
createToggle(MovePage, "Infinite Jump", false, function(on) State.InfJumpEnabled = on end)
createToggle(MovePage, "Anti-Fling", false, function(on) State.AntiFlingEnabled = on end)
createToggle(MovePage, "Anti-Void", false, function(on) State.AntiVoidEnabled = on end)

local AntiBanPage = createTab("Anti-Ban", "🛡️", 3)
createToggle(AntiBanPage, "Anti-Ban System", true, function(on) State.AntiBanEnabled = on end)
createToggle(AntiBanPage, "Jitter Random ±2", true, function(on) State.JitterEnabled = on end)
createToggle(AntiBanPage, "Rate Limit 20Hz", true, function(on) State.RateLimitEnabled = on end)
createToggle(AntiBanPage, "Ramp Up Smooth", true, function(on) State.SpeedRampUp = on end)
createToggle(AntiBanPage, "Legit Mode (cap 60)", false, function(on) State.LegitMode = on end)
createSlider(AntiBanPage, "Max Speed Cap", 50, 500, 250, function(v) State.MaxSpeed = v end)
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

local SettingsPage = createTab("Settings", "⚙️", 4)
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
end, true)

-- Default tab
if Tabs["Speed"] then
    Tabs["Speed"].Button.BackgroundColor3 = Config.BgCard
    Tabs["Speed"].Button.TextColor3 = Config.Accent
    Tabs["Speed"].Page.Visible = true
    Tabs["Speed"].Indicator.Visible = true
    ActiveTab = "Speed"
end

-- ============================================================
-- CORE LOOPS
-- ============================================================
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    if State.SpeedEnabled and State.AntiBanEnabled then
        if not shouldUpdate() then return end

        local target = State.SpeedValue
        target = applyLegitCap(target)
        if target > State.MaxSpeed then target = State.MaxSpeed end

        local speed = getRampSpeed(target)
        speed = getJitteredSpeed(speed)

        pcall(function() hum.WalkSpeed = speed end)

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
    elseif State.SpeedEnabled then
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

task.spawn(function()
    while task.wait(0.5) do
        cleanupSpeedInstances()
    end
end)

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
    if minimized then
        Main.Size = UDim2.new(0, 620, 0, 56)
        Sidebar.Visible = false
        Content.Visible = false
    else
        Main.Size = UDim2.new(0, 620, 0, 440)
        Sidebar.Visible = true
        Content.Visible = true
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
    end
end)

print("[EXECUTE HUB] " .. Config.Version .. " loaded — Redesign UI")
print("[EXECUTE HUB] User: " .. LocalPlayer.Name)
print("[EXECUTE HUB] Right Ctrl = toggle UI")
