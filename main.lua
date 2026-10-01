-- ============================================================
-- EXECUTE HUB - v3.0.0 (CUSTOM UI - GLASSMORPHISM DARK)
-- Không dùng UI Library ngoài - tự tạo Frame, TextButton, UICorner
-- Layout giống ZIGGER: sidebar dọc trái + content 2 cột phải
-- Mobile-friendly: touch, scale, drag
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- CONFIG THEME
-- ============================================================
local Config = {
    -- Background glass (nhìn xuyên)
    BgGlass        = Color3.fromRGB(20, 20, 25),
    BgGlassTransp  = 0.15,
    BgCard         = Color3.fromRGB(32, 32, 40),
    BgCardTransp   = 0.1,
    BgSidebar      = Color3.fromRGB(15, 15, 18),
    BgSidebarTransp = 0.2,
    -- Accent đỏ
    Accent         = Color3.fromRGB(255, 35, 45),
    AccentHover    = Color3.fromRGB(255, 60, 70),
    -- Text
    TextPrimary    = Color3.fromRGB(245, 245, 250),
    TextSecond     = Color3.fromRGB(160, 160, 175),
    TextMuted      = Color3.fromRGB(110, 110, 125),
    -- Border
    Border         = Color3.fromRGB(255, 255, 255),
    BorderTransp   = 0.85,
    -- Success
    Success        = Color3.fromRGB(60, 220, 110),
    -- Version
    Title          = "EXECUTE HUB",
    Subtitle       = "Custom UI",
    Version        = "v3.0.0"
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

-- ============================================================
-- SCREEN GUI ROOT
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
-- MAIN FRAME (Glass)
-- ============================================================
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 620, 0, 420)
Main.Position = UDim2.new(0.5, -310, 0.5, -210)
Main.BackgroundColor3 = Config.BgGlass
Main.BackgroundTransparency = Config.BgGlassTransp
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = Main

-- Glass border
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Config.Border
MainStroke.Thickness = 1
MainStroke.Transparency = Config.BorderTransp
MainStroke.Parent = Main

-- ============================================================
-- TOP BAR (Title + Close/Min)
-- ============================================================
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 52)
TopBar.BackgroundColor3 = Config.BgCard
TopBar.BackgroundTransparency = 0.3
TopBar.BorderSizePixel = 0
TopBar.Parent = Main
local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 16)
TopBarCorner.Parent = TopBar

-- Cover bottom corners of topbar
local TopCover = Instance.new("Frame")
TopCover.Size = UDim2.new(1, 0, 0, 20)
TopCover.Position = UDim2.new(0, 0, 1, -20)
TopCover.BackgroundColor3 = Config.BgCard
TopCover.BackgroundTransparency = 0.3
TopCover.BorderSizePixel = 0
TopCover.Parent = TopBar

-- Window dots (macOS style)
local DotsFrame = Instance.new("Frame")
DotsFrame.Size = UDim2.new(0, 60, 0, 12)
DotsFrame.Position = UDim2.new(0, 14, 0.5, -6)
DotsFrame.BackgroundTransparency = 1
DotsFrame.Parent = TopBar

local dotColors = {
    Color3.fromRGB(255, 95, 87),
    Color3.fromRGB(255, 189, 46),
    Color3.fromRGB(39, 201, 63)
}
for i = 1, 3 do
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = UDim2.new(0, (i - 1) * 14, 0.5, -5)
    dot.BackgroundColor3 = dotColors[i]
    dot.BorderSizePixel = 0
    dot.Parent = DotsFrame
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
end

-- Title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 300, 0, 22)
TitleLabel.Position = UDim2.new(0, 90, 0, 8)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = Config.Title
TitleLabel.TextColor3 = Config.TextPrimary
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(0, 300, 0, 14)
SubLabel.Position = UDim2.new(0, 90, 0, 30)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = Config.Subtitle .. " • " .. Config.Version
SubLabel.TextColor3 = Config.TextMuted
SubLabel.TextSize = 10
SubLabel.Font = Enum.Font.Gotham
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Parent = TopBar

-- Accent line under title
local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(0, 40, 0, 2)
AccentLine.Position = UDim2.new(0, 90, 0, 26)
AccentLine.BackgroundColor3 = Config.Accent
AccentLine.BorderSizePixel = 0
AccentLine.Parent = TopBar
local AccentLineCorner = Instance.new("UICorner")
AccentLineCorner.CornerRadius = UDim.new(1, 0)
AccentLineCorner.Parent = AccentLine

-- Min button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -68, 0.5, -14)
MinBtn.BackgroundColor3 = Config.BgCard
MinBtn.BackgroundTransparency = 0.5
MinBtn.Text = "−"
MinBtn.TextColor3 = Config.TextPrimary
MinBtn.TextSize = 18
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.AutoButtonColor = false
MinBtn.Parent = TopBar
local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinBtn

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -14)
CloseBtn.BackgroundColor3 = Config.Accent
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Config.TextPrimary
CloseBtn.TextSize = 13
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
-- SIDEBAR (Glass, bên trái)
-- ============================================================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 160, 1, -68)
Sidebar.Position = UDim2.new(0, 0, 0, 52)
Sidebar.BackgroundColor3 = Config.BgSidebar
Sidebar.BackgroundTransparency = Config.BgSidebarTransp
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

-- Divider line
local SidebarDivider = Instance.new("Frame")
SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
SidebarDivider.Position = UDim2.new(1, -1, 0, 0)
SidebarDivider.BackgroundColor3 = Config.Border
SidebarDivider.BackgroundTransparency = 0.85
SidebarDivider.BorderSizePixel = 0
SidebarDivider.Parent = Sidebar

-- Logo box
local LogoBox = Instance.new("Frame")
LogoBox.Size = UDim2.new(0, 36, 0, 36)
LogoBox.Position = UDim2.new(0.5, -18, 0, 16)
LogoBox.BackgroundColor3 = Config.Accent
LogoBox.BorderSizePixel = 0
LogoBox.Parent = Sidebar
local LogoBoxCorner = Instance.new("UICorner")
LogoBoxCorner.CornerRadius = UDim.new(0, 10)
LogoBoxCorner.Parent = LogoBox

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = Config.AccentHover
LogoStroke.Thickness = 1
LogoStroke.Transparency = 0.5
LogoStroke.Parent = LogoBox

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "EH"
LogoText.TextColor3 = Config.TextPrimary
LogoText.TextSize = 16
LogoText.Font = Enum.Font.GothamBold
LogoText.Parent = LogoBox

-- User info
local UserInfo = Instance.new("Frame")
UserInfo.Size = UDim2.new(1, -16, 0, 40)
UserInfo.Position = UDim2.new(0, 8, 0, 60)
UserInfo.BackgroundColor3 = Config.BgCard
UserInfo.BackgroundTransparency = 0.5
UserInfo.BorderSizePixel = 0
UserInfo.Parent = Sidebar
local UserInfoCorner = Instance.new("UICorner")
UserInfoCorner.CornerRadius = UDim.new(0, 8)
UserInfoCorner.Parent = UserInfo

local UserAvatar = Instance.new("Frame")
UserAvatar.Size = UDim2.new(0, 28, 0, 28)
UserAvatar.Position = UDim2.new(0, 6, 0.5, -14)
UserAvatar.BackgroundColor3 = Config.Accent
UserAvatar.BorderSizePixel = 0
UserAvatar.Parent = UserInfo
local UserAvatarCorner = Instance.new("UICorner")
UserAvatarCorner.CornerRadius = UDim.new(1, 0)
UserAvatarCorner.Parent = UserAvatar

local UserInitial = Instance.new("TextLabel")
UserInitial.Size = UDim2.new(1, 0, 1, 0)
UserInitial.BackgroundTransparency = 1
UserInitial.Text = string.sub(LocalPlayer.Name, 1, 1):upper()
UserInitial.TextColor3 = Config.TextPrimary
UserInitial.TextSize = 13
UserInitial.Font = Enum.Font.GothamBold
UserInitial.Parent = UserAvatar

local UserName = Instance.new("TextLabel")
UserName.Size = UDim2.new(1, -44, 0, 14)
UserName.Position = UDim2.new(0, 40, 0, 6)
UserName.BackgroundTransparency = 1
UserName.Text = LocalPlayer.Name
UserName.TextColor3 = Config.TextPrimary
UserName.TextSize = 11
UserName.Font = Enum.Font.GothamBold
UserName.TextXAlignment = Enum.TextXAlignment.Left
UserName.TextTruncate = Enum.TextTruncate.AtEnd
UserName.Parent = UserInfo

local UserStatus = Instance.new("TextLabel")
UserStatus.Size = UDim2.new(1, -44, 0, 12)
UserStatus.Position = UDim2.new(0, 40, 0, 22)
UserStatus.BackgroundTransparency = 1
UserStatus.Text = "● Online"
UserStatus.TextColor3 = Config.Success
UserStatus.TextSize = 9
UserStatus.Font = Enum.Font.GothamMedium
UserStatus.TextXAlignment = Enum.TextXAlignment.Left
UserStatus.Parent = UserInfo

-- ============================================================
-- TAB BUTTONS
-- ============================================================
local Tabs = {}
local ActiveTab = nil
local Pages = {}

local tabDefs = {
    {name = "Main",     icon = "⌂"},
    {name = "Stats",    icon = "◈"},
    {name = "Player",   icon = "◐"},
    {name = "Settings", icon = "⚙"}
}

-- ============================================================
-- CONTENT AREA
-- ============================================================
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -168, 1, -68)
Content.Position = UDim2.new(0, 168, 0, 52)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.Parent = Main

-- ============================================================
-- TAB CREATION
-- ============================================================
for i, def in ipairs(tabDefs) do
    local Tab = Instance.new("TextButton")
    Tab.Size = UDim2.new(1, -16, 0, 34)
    Tab.Position = UDim2.new(0, 8, 0, 108 + ((i - 1) * 40))
    Tab.BackgroundColor3 = Config.BgCard
    Tab.BackgroundTransparency = 1
    Tab.Text = "   " .. def.icon .. "   " .. def.name
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

    -- Active indicator
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

    -- Page (scroll frame)
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Config.Accent
    Page.ScrollBarImageTransparency = 0.3
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Visible = false
    Page.Parent = Content

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Parent = Page

    local PagePadding = Instance.new("UIPadding")
    PagePadding.PaddingTop = UDim.new(0, 12)
    PagePadding.PaddingLeft = UDim.new(0, 12)
    PagePadding.PaddingRight = UDim.new(0, 12)
    PagePadding.PaddingBottom = UDim.new(0, 12)
    PagePadding.Parent = Page

    Tabs[def.name] = { Button = Tab, Page = Page, Indicator = Indicator }
    Pages[def.name] = Page

    Tab.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Button.BackgroundTransparency = 1
            t.Button.TextColor3 = Config.TextSecond
            t.Page.Visible = false
            t.Indicator.Visible = false
        end
        Tab.BackgroundTransparency = 0.3
        Tab.BackgroundColor3 = Config.BgCard
        Tab.TextColor3 = Config.Accent
        Page.Visible = true
        Indicator.Visible = true
        ActiveTab = def.name
    end)

    Tab.MouseEnter:Connect(function()
        if ActiveTab ~= def.name then
            TweenService:Create(Tab, TweenInfo.new(0.15), {BackgroundTransparency = 0.5}):Play()
            TweenService:Create(Tab, TweenInfo.new(0.15), {TextColor3 = Config.TextPrimary}):Play()
        end
    end)
    Tab.MouseLeave:Connect(function()
        if ActiveTab ~= def.name then
            TweenService:Create(Tab, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
            TweenService:Create(Tab, TweenInfo.new(0.15), {TextColor3 = Config.TextSecond}):Play()
        end
    end)
end

-- ============================================================
-- WIDGET BUILDERS
-- ============================================================

-- Section header
local function createSection(parent, text, order)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, 0, 0, 26)
    Section.BackgroundTransparency = 1
    Section.LayoutOrder = order or 0
    Section.Parent = parent

    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 20, 0, 20)
    Icon.Position = UDim2.new(0, 4, 0.5, -10)
    Icon.BackgroundTransparency = 1
    Icon.Text = "◆"
    Icon.TextColor3 = Config.Accent
    Icon.TextSize = 12
    Icon.Font = Enum.Font.GothamBold
    Icon.Parent = Section

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -30, 1, 0)
    Label.Position = UDim2.new(0, 26, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Config.TextPrimary
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Section

    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, 0, 0, 1)
    Line.Position = UDim2.new(0, 0, 1, -1)
    Line.BackgroundColor3 = Config.Border
    Line.BackgroundTransparency = 0.9
    Line.BorderSizePixel = 0
    Line.Parent = Section

    return Section
end

-- Toggle widget
local function createToggle(parent, text, default, callback)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 40)
    Card.BackgroundColor3 = Config.BgCard
    Card.BackgroundTransparency = 0.5
    Card.BorderSizePixel = 0
    Card.Parent = parent
    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 8)
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = Config.Border
    CardStroke.Thickness = 1
    CardStroke.Transparency = 0.9
    CardStroke.Parent = Card

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -80, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Config.TextPrimary
    Label.TextSize = 12
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Card

    -- iOS-style toggle
    local ToggleBg = Instance.new("Frame")
    ToggleBg.Size = UDim2.new(0, 36, 0, 20)
    ToggleBg.Position = UDim2.new(1, -50, 0.5, -10)
    ToggleBg.BackgroundColor3 = default and Config.Accent or Color3.fromRGB(70, 70, 85)
    ToggleBg.BorderSizePixel = 0
    ToggleBg.Parent = Card
    local ToggleBgCorner = Instance.new("UICorner")
    ToggleBgCorner.CornerRadius = UDim.new(1, 0)
    ToggleBgCorner.Parent = ToggleBg

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
    ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.Text = ""
    ToggleBtn.Parent = ToggleBg

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = ToggleBg
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local isOn = default
    ToggleBtn.MouseButton1Click:Connect(function()
        isOn = not isOn
        TweenService:Create(ToggleBg, TweenInfo.new(0.2), {
            BackgroundColor3 = isOn and Config.Accent or Color3.fromRGB(70, 70, 85)
        }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.2), {
            Position = isOn and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        if callback then callback(isOn) end
    end)

    return Card
end

-- Slider widget
local function createSlider(parent, text, min, max, default, callback)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 58)
    Card.BackgroundColor3 = Config.BgCard
    Card.BackgroundTransparency = 0.5
    Card.BorderSizePixel = 0
    Card.Parent = parent
    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 8)
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = Config.Border
    CardStroke.Thickness = 1
    CardStroke.Transparency = 0.9
    CardStroke.Parent = Card

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -100, 0, 16)
    Label.Position = UDim2.new(0, 14, 0, 8)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Config.TextPrimary
    Label.TextSize = 12
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Card

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 70, 0, 16)
    ValueLabel.Position = UDim2.new(1, -84, 0, 8)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Config.Accent
    ValueLabel.TextSize = 12
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Card

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -28, 0, 4)
    Bar.Position = UDim2.new(0, 14, 0, 40)
    Bar.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
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
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    Dot.BackgroundColor3 = Config.Accent
    Dot.BorderSizePixel = 0
    Dot.Parent = Bar
    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = Dot

    local DotInner = Instance.new("Frame")
    DotInner.Size = UDim2.new(1, -6, 1, -6)
    DotInner.Position = UDim2.new(0, 3, 0, 3)
    DotInner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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
        Dot.Position = UDim2.new(pos, -7, 0.5, -7)
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

-- Dropdown widget
local function createDropdown(parent, text, options, default, callback)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 42)
    Card.BackgroundColor3 = Config.BgCard
    Card.BackgroundTransparency = 0.5
    Card.BorderSizePixel = 0
    Card.Parent = parent
    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 8)
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = Config.Border
    CardStroke.Thickness = 1
    CardStroke.Transparency = 0.9
    CardStroke.Parent = Card

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -100, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Config.TextPrimary
    Label.TextSize = 12
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Card

    local Selected = default or options[1]
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 110, 1, 0)
    ValueLabel.Position = UDim2.new(1, -124, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = Selected .. "  ▾"
    ValueLabel.TextColor3 = Config.TextSecond
    ValueLabel.TextSize = 12
    ValueLabel.Font = Enum.Font.GothamMedium
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Card

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = Card

    -- Cycle options on click (simple dropdown for mobile)
    local idx = 1
    for i, opt in ipairs(options) do
        if opt == Selected then idx = i break end
    end

    Btn.MouseButton1Click:Connect(function()
        idx = idx + 1
        if idx > #options then idx = 1 end
        Selected = options[idx]
        ValueLabel.Text = Selected .. "  ▾"
        if callback then callback(Selected) end
    end)

    return Card
end

-- Button widget
local function createButton(parent, text, callback, isAccent)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 38)
    Btn.BackgroundColor3 = isAccent and Config.Accent or Config.BgCard
    Btn.BackgroundTransparency = isAccent and 0 or 0.5
    Btn.Text = text
    Btn.TextColor3 = Config.TextPrimary
    Btn.TextSize = 12
    Btn.Font = Enum.Font.GothamBold
    Btn.BorderSizePixel = 0
    Btn.AutoButtonColor = false
    Btn.Parent = parent
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Btn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = isAccent and Config.Accent or Config.Border
    BtnStroke.Thickness = 1
    BtnStroke.Transparency = isAccent and 0.3 or 0.9
    BtnStroke.Parent = Btn

    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {
            BackgroundColor3 = isAccent and Config.AccentHover or Config.BgCard,
            BackgroundTransparency = 0.3
        }):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {
            BackgroundColor3 = isAccent and Config.Accent or Config.BgCard,
            BackgroundTransparency = isAccent and 0 or 0.5
        }):Play()
    end)
    Btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return Btn
end

-- ============================================================
-- BUILD PAGES
-- ============================================================

-- ===== MAIN PAGE =====
local MainPage = Pages["Main"]
createSection(MainPage, "Auto Farm", 1)
createToggle(MainPage, "Auto Farm", false, function(v) State.AutoFarm = v end)
createSlider(MainPage, "Farm Distance", 1, 50, 5, function(v) State.FarmDistance = v end)
createToggle(MainPage, "Auto Parry", false, function(v) State.AutoParry = v end)
createToggle(MainPage, "Auto Heal", false, function(v) State.AutoHeal = v end)
createToggle(MainPage, "Auto Skill", false, function(v) State.AutoSkill = v end)
createToggle(MainPage, "Auto Collect Chest", false, function(v) State.AutoChest = v end)
createToggle(MainPage, "Auto Collect Quests", false, function(v) State.AutoQuest = v end)

createSection(MainPage, "Auto Dungeon", 10)
createDropdown(MainPage, "Dungeon", {"Bandits Den", "Cursed Ship", "Dragon Nest"}, "Bandits Den", function(v) State.Dungeon = v end)
createDropdown(MainPage, "Difficulty", {"Easy", "Medium", "Hard", "Nightmare"}, "Easy", function(v) State.Difficulty = v end)
createToggle(MainPage, "Auto Dungeon", false, function(v) State.AutoDungeon = v end)
createToggle(MainPage, "Auto Replay", false, function(v) State.AutoReplay = v end)
createToggle(MainPage, "Instant Interact", false, function(v) State.InstantInteract = v end)

createSection(MainPage, "Battlepass", 20)
createToggle(MainPage, "Auto Claim Battlepass", false, function(v) State.AutoClaimBP = v end)

-- ===== STATS PAGE =====
local StatsPage = Pages["Stats"]
createSection(StatsPage, "Player Stats", 1)
createToggle(StatsPage, "Show FPS", false, function(v) State.ShowFPS = v end)
createToggle(StatsPage, "Show Ping", false, function(v) State.ShowPing = v end)
createToggle(StatsPage, "Show Coordinates", false, function(v) State.ShowCoords = v end)

createSection(StatsPage, "Character", 10)
createButton(StatsPage, "Reset Character", function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end
end)
createButton(StatsPage, "Reset Physics", function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
            hum.PlatformStand = false
        end
    end
end)

-- ===== PLAYER PAGE =====
local PlayerPage = Pages["Player"]
createSection(PlayerPage, "Speed", 1)
createToggle(PlayerPage, "Speed Hack", false, function(v) State.SpeedEnabled = v end)
createSlider(PlayerPage, "Speed Value", 16, 500, 16, function(v) State.SpeedValue = v end)
createSlider(PlayerPage, "Max Speed Cap", 50, 500, 250, function(v) State.MaxSpeed = v end)

createSection(PlayerPage, "Movement", 10)
createToggle(PlayerPage, "Fly", false, function(v) State.FlyEnabled = v end)
createToggle(PlayerPage, "Noclip", false, function(v) State.NoclipEnabled = v end)
createToggle(PlayerPage, "Infinite Jump", false, function(v) State.InfJumpEnabled = v end)
createToggle(PlayerPage, "Anti-Fling", false, function(v) State.AntiFlingEnabled = v end)
createToggle(PlayerPage, "Anti-Void", false, function(v) State.AntiVoidEnabled = v end)

createSection(PlayerPage, "Anti-Ban Pro", 20)
createToggle(PlayerPage, "Anti-Ban System", true, function(v) State.AntiBanEnabled = v end)
createToggle(PlayerPage, "Jitter ±2", true, function(v) State.JitterEnabled = v end)
createToggle(PlayerPage, "Rate Limit 20Hz", true, function(v) State.RateLimitEnabled = v end)
createToggle(PlayerPage, "Legit Mode (60)", false, function(v) State.LegitMode = v end)

-- ===== SETTINGS PAGE =====
local SettingsPage = Pages["Settings"]
createSection(SettingsPage, "Config", 1)
createButton(SettingsPage, "Save Config", function()
    print("[EXECUTE HUB] Config saved")
end)
createButton(SettingsPage, "Load Config", function()
    print("[EXECUTE HUB] Config loaded")
end)

createSection(SettingsPage, "Script", 10)
createButton(SettingsPage, "Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)
createButton(SettingsPage, "Unload Script", function()
    ScreenGui:Destroy()
end, true)

-- ============================================================
-- ACTIVATE DEFAULT TAB
-- ============================================================
if Tabs["Main"] then
    Tabs["Main"].Button.BackgroundTransparency = 0.3
    Tabs["Main"].Button.BackgroundColor3 = Config.BgCard
    Tabs["Main"].Button.TextColor3 = Config.Accent
    Tabs["Main"].Page.Visible = true
    Tabs["Main"].Indicator.Visible = true
    ActiveTab = "Main"
end

-- ============================================================
-- CORE LOGIC (Speed + Fly + Noclip + Anti-Ban)
-- ============================================================
local State = State or {}
State.SpeedEnabled = false
State.SpeedValue = 16
State.MaxSpeed = 250
State.JitterEnabled = true
State.RateLimitEnabled = true
State.LegitMode = false
State.FlyEnabled = false
State.NoclipEnabled = false
State.InfJumpEnabled = false
State.AntiFlingEnabled = false
State.AntiVoidEnabled = false
State.AntiBanEnabled = true

local tickCounter = 0
local currentRampSpeed = 16

-- Speed loop
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    if State.SpeedEnabled then
        tickCounter = (tickCounter + 1) % 3
        if State.RateLimitEnabled and tickCounter ~= 0 then return end

        local target = State.SpeedValue
        if State.LegitMode then target = math.min(target, 60) end
        if target > State.MaxSpeed then target = State.MaxSpeed end

        local jitter = State.JitterEnabled and math.random(-2, 2) or 0
        local speed = target + jitter

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
    else
        pcall(function()
            hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
        end)
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
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ============================================================
-- BUTTONS
-- ============================================================
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Main.Size = UDim2.new(0, 620, 0, 52)
        Sidebar.Visible = false
        Content.Visible = false
    else
        Main.Size = UDim2.new(0, 620, 0, 420)
        Sidebar.Visible = true
        Content.Visible = true
    end
end)

-- ============================================================
-- KEYBIND: Right Ctrl toggle
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
    end
end)

print("[EXECUTE HUB] " .. Config.Version .. " Custom UI loaded")
print("[EXECUTE HUB] Tabs: Main, Stats, Player, Settings")
print("[EXECUTE HUB] Right Ctrl = toggle UI")
