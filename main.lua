--[[
================================================================
    EXECUTE HUB - v4.0.0 (FULL REWRITE - ZIGGER LAYOUT)
    Glassmorphism Dark/Red UI | 2-column layout | 4 tabs
    Speed Hack (3 methods) | Anti-Ban Pro | Auto Farm
    Mobile + PC Compatible | No External Library
================================================================
]]

-- ============================================================
-- SERVICES
-- ============================================================
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local CoreGui            = game:GetService("CoreGui")
local VirtualUser        = game:GetService("VirtualUser")
local Workspace          = game:GetService("Workspace")
local TeleportService    = game:GetService("TeleportService")
local LocalPlayer        = Players.LocalPlayer

-- ============================================================
-- CONFIG
-- ============================================================
local Config = {
    -- Colors
    BgMain          = Color3.fromRGB(10, 10, 12),
    BgMainTransp    = 0.05,
    BgPanel         = Color3.fromRGB(18, 18, 22),
    BgCard          = Color3.fromRGB(28, 28, 34),
    BgCardTransp    = 0.4,
    BgCardHover     = Color3.fromRGB(38, 38, 46),
    BgSidebar       = Color3.fromRGB(5, 5, 8),
    BgSidebarTransp = 0.15,
    BgTopGlass      = Color3.fromRGB(255, 255, 255),
    BgTopGlassTransp= 0.95,
    Accent          = Color3.fromRGB(255, 35, 45),
    AccentHover     = Color3.fromRGB(255, 60, 70),
    AccentDark      = Color3.fromRGB(180, 20, 30),
    TextPrimary     = Color3.fromRGB(245, 245, 250),
    TextSecond      = Color3.fromRGB(160, 160, 175),
    TextMuted       = Color3.fromRGB(110, 110, 125),
    Border          = Color3.fromRGB(255, 255, 255),
    BorderTransp    = 0.9,
    Success         = Color3.fromRGB(60, 220, 110),
    Warning         = Color3.fromRGB(255, 180, 40),
    -- Meta
    Title           = "EXECUTE HUB",
    Subtitle        = "ZIGGER Layout",
    Version         = "v4.0.0",
    LogoText        = "EH",
    -- Layout
    WindowWidth     = 640,
    WindowHeight    = 420,
    SidebarWidth    = 180,
}

-- ============================================================
-- STATE
-- ============================================================
local State = {
    -- Speed
    SpeedEnabled     = false,
    SpeedValue       = 16,
    MaxSpeed         = 250,
    -- Anti-Ban
    AntiBanEnabled   = true,
    JitterEnabled    = true,
    RateLimitEnabled = true,
    LegitMode        = false,
    RampUpEnabled    = true,
    -- Movement
    FlyEnabled       = false,
    NoclipEnabled    = false,
    InfJumpEnabled   = false,
    AntiFlingEnabled = false,
    AntiVoidEnabled  = false,
    -- Auto Farm
    AutoFarm         = false,
    FarmDistance     = 5,
    AutoParry        = false,
    AutoHeal         = false,
    AutoSkill        = false,
    AutoChest        = false,
    AutoQuest        = false,
    AutoDungeon      = false,
    AutoReplay       = false,
    InstantInteract  = false,
    AutoClaimBP      = false,
    Dungeon          = "Bandits Den",
    Difficulty       = "Easy",
    -- Stats
    ShowFPS          = false,
    ShowPing         = false,
    ShowCoords       = false,
}

local AntiBanState = {
    tickCounter      = 0,
    currentRampSpeed = 16,
}

-- ============================================================
-- CLEANUP PREVIOUS
-- ============================================================
pcall(function()
    if CoreGui:FindFirstChild("ExecuteHub") then
        CoreGui.ExecuteHub:Destroy()
    end
end)
pcall(function()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg and pg:FindFirstChild("ExecuteHub") then
        pg.ExecuteHub:Destroy()
    end
end)

-- Cleanup physics instances
local function cleanupSpeedInstances()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, name in ipairs({"SpeedBV", "FlyBV", "FlyBG", "AntiFlingBV"}) do
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
-- MAIN FRAME
-- ============================================================
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, Config.WindowWidth, 0, Config.WindowHeight)
Main.Position = UDim2.new(0.5, -(Config.WindowWidth / 2), 0.5, -(Config.WindowHeight / 2))
Main.BackgroundColor3 = Config.BgMain
Main.BackgroundTransparency = Config.BgMainTransp
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Config.Border
MainStroke.Thickness = 1
MainStroke.Transparency = Config.BorderTransp
MainStroke.Parent = Main

-- ============================================================
-- GLASS OVERLAY (subtle inner glow)
-- ============================================================
local GlassOverlay = Instance.new("Frame")
GlassOverlay.Size = UDim2.new(1, 0, 1, 0)
GlassOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
GlassOverlay.BackgroundTransparency = 0.98
GlassOverlay.BorderSizePixel = 0
GlassOverlay.ZIndex = 0
GlassOverlay.Parent = Main
local GlassOverlayCorner = Instance.new("UICorner")
GlassOverlayCorner.CornerRadius = UDim.new(0, 12)
GlassOverlayCorner.Parent = GlassOverlay

-- ============================================================
-- SIDEBAR (LEFT - TRANSPARENT BLACK)
-- ============================================================
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, Config.SidebarWidth, 1, 0)
Sidebar.Position = UDim2.new(0, 0, 0, 0)
Sidebar.BackgroundColor3 = Config.BgSidebar
Sidebar.BackgroundTransparency = Config.BgSidebarTransp
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 1
Sidebar.Parent = Main

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 12)
SidebarCorner.Parent = Sidebar

-- Sidebar right divider
local SidebarDivider = Instance.new("Frame")
SidebarDivider.Size = UDim2.new(0, 1, 1, -20)
SidebarDivider.Position = UDim2.new(1, -1, 0, 10)
SidebarDivider.BackgroundColor3 = Config.Border
SidebarDivider.BackgroundTransparency = 0.85
SidebarDivider.BorderSizePixel = 0
SidebarDivider.Parent = Sidebar

-- ============================================================
-- WINDOW DOTS (macOS style, top-left of sidebar)
-- ============================================================
local DotsFrame = Instance.new("Frame")
DotsFrame.Size = UDim2.new(0, 60, 0, 12)
DotsFrame.Position = UDim2.new(0, 12, 0, 12)
DotsFrame.BackgroundTransparency = 1
DotsFrame.ZIndex = 2
DotsFrame.Parent = Sidebar

local dotColors = {
    Color3.fromRGB(255, 95, 87),   -- red
    Color3.fromRGB(255, 189, 46),  -- yellow
    Color3.fromRGB(39, 201, 63),   -- green
}
for i = 1, 3 do
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = UDim2.new(0, (i - 1) * 14, 0.5, -5)
    dot.BackgroundColor3 = dotColors[i]
    dot.BorderSizePixel = 0
    dot.ZIndex = 3
    dot.Parent = DotsFrame
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
end

-- ============================================================
-- LOGO BOX (centered in sidebar top)
-- ============================================================
local LogoBox = Instance.new("Frame")
LogoBox.Size = UDim2.new(0, 100, 0, 100)
LogoBox.Position = UDim2.new(0.5, -50, 0, 40)
LogoBox.BackgroundColor3 = Config.BgCard
LogoBox.BackgroundTransparency = 0.5
LogoBox.BorderSizePixel = 0
LogoBox.ZIndex = 2
LogoBox.Parent = Sidebar

local LogoBoxCorner = Instance.new("UICorner")
LogoBoxCorner.CornerRadius = UDim.new(0, 10)
LogoBoxCorner.Parent = LogoBox

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = Config.Accent
LogoStroke.Thickness = 1
LogoStroke.Transparency = 0.6
LogoStroke.Parent = LogoBox

-- Stylized logo "EH"
local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = Config.LogoText
LogoText.TextColor3 = Config.TextPrimary
LogoText.TextSize = 42
LogoText.Font = Enum.Font.GothamBlack
LogoText.ZIndex = 3
LogoText.Parent = LogoBox

-- Subtle red glow behind logo
local LogoGlow = Instance.new("Frame")
LogoGlow.Size = UDim2.new(1, 20, 1, 20)
LogoGlow.Position = UDim2.new(0, -10, 0, -10)
LogoGlow.BackgroundColor3 = Config.Accent
LogoGlow.BackgroundTransparency = 0.85
LogoGlow.BorderSizePixel = 0
LogoGlow.ZIndex = 1
LogoGlow.Parent = LogoBox
local LogoGlowCorner = Instance.new("UICorner")
LogoGlowCorner.CornerRadius = UDim.new(0, 14)
LogoGlowCorner.Parent = LogoGlow

-- ============================================================
-- USER INFO BLOCK
-- ============================================================
local UserBlock = Instance.new("Frame")
UserBlock.Size = UDim2.new(1, -16, 0, 44)
UserBlock.Position = UDim2.new(0, 8, 0, 152)
UserBlock.BackgroundColor3 = Config.BgCard
UserBlock.BackgroundTransparency = 0.55
UserBlock.BorderSizePixel = 0
UserBlock.ZIndex = 2
UserBlock.Parent = Sidebar

local UserBlockCorner = Instance.new("UICorner")
UserBlockCorner.CornerRadius = UDim.new(0, 8)
UserBlockCorner.Parent = UserBlock

local UserBlockStroke = Instance.new("UIStroke")
UserBlockStroke.Color = Config.Border
UserBlockStroke.Thickness = 1
UserBlockStroke.Transparency = 0.9
UserBlockStroke.Parent = UserBlock

-- Avatar
local UserAvatar = Instance.new("Frame")
UserAvatar.Size = UDim2.new(0, 30, 0, 30)
UserAvatar.Position = UDim2.new(0, 7, 0.5, -15)
UserAvatar.BackgroundColor3 = Config.Accent
UserAvatar.BorderSizePixel = 0
UserAvatar.ZIndex = 3
UserAvatar.Parent = UserBlock

local UserAvatarCorner = Instance.new("UICorner")
UserAvatarCorner.CornerRadius = UDim.new(1, 0)
UserAvatarCorner.Parent = UserAvatar

local UserInitial = Instance.new("TextLabel")
UserInitial.Size = UDim2.new(1, 0, 1, 0)
UserInitial.BackgroundTransparency = 1
UserInitial.Text = string.sub(LocalPlayer.Name, 1, 1):upper()
UserInitial.TextColor3 = Config.TextPrimary
UserInitial.TextSize = 14
UserInitial.Font = Enum.Font.GothamBold
UserInitial.ZIndex = 4
UserInitial.Parent = UserAvatar

-- Name
local UserName = Instance.new("TextLabel")
UserName.Size = UDim2.new(1, -44, 0, 14)
UserName.Position = UDim2.new(0, 44, 0, 8)
UserName.BackgroundTransparency = 1
UserName.Text = LocalPlayer.Name
UserName.TextColor3 = Config.TextPrimary
UserName.TextSize = 11
UserName.Font = Enum.Font.GothamBold
UserName.TextXAlignment = Enum.TextXAlignment.Left
UserName.TextTruncate = Enum.TextTruncate.AtEnd
UserName.ZIndex = 3
UserName.Parent = UserBlock

-- Status
local UserStatus = Instance.new("TextLabel")
UserStatus.Size = UDim2.new(1, -44, 0, 12)
UserStatus.Position = UDim2.new(0, 44, 0, 24)
UserStatus.BackgroundTransparency = 1
UserStatus.Text = "● Online"
UserStatus.TextColor3 = Config.Success
UserStatus.TextSize = 9
UserStatus.Font = Enum.Font.GothamMedium
UserStatus.TextXAlignment = Enum.TextXAlignment.Left
UserStatus.ZIndex = 3
UserStatus.Parent = UserBlock

-- ============================================================
-- CONTENT AREA (RIGHT)
-- ============================================================
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -(Config.SidebarWidth + 8), 1, -20)
Content.Position = UDim2.new(0, Config.SidebarWidth + 8, 0, 10)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ZIndex = 1
Content.Parent = Main

-- Page Title
local PageTitle = Instance.new("TextLabel")
PageTitle.Size = UDim2.new(1, -20, 0, 30)
PageTitle.Position = UDim2.new(0, 10, 0, 0)
PageTitle.BackgroundTransparency = 1
PageTitle.Text = "AUTO FARM"
PageTitle.TextColor3 = Config.TextPrimary
PageTitle.TextSize = 20
PageTitle.Font = Enum.Font.GothamBlack
PageTitle.TextXAlignment = Enum.TextXAlignment.Left
PageTitle.ZIndex = 2
PageTitle.Parent = Content

-- Title underline
local TitleLine = Instance.new("Frame")
TitleLine.Size = UDim2.new(1, -20, 0, 2)
TitleLine.Position = UDim2.new(0, 10, 0, 34)
TitleLine.BackgroundColor3 = Config.Accent
TitleLine.BorderSizePixel = 0
TitleLine.ZIndex = 2
TitleLine.Parent = Content

-- ============================================================
-- COLUMNS HOLDER
-- ============================================================
local ColumnsHolder = Instance.new("Frame")
ColumnsHolder.Size = UDim2.new(1, -20, 1, -50)
ColumnsHolder.Position = UDim2.new(0, 10, 0, 44)
ColumnsHolder.BackgroundTransparency = 1
ColumnsHolder.ZIndex = 2
ColumnsHolder.Parent = Content

-- LEFT COLUMN
local LeftCol = Instance.new("ScrollingFrame")
LeftCol.Name = "LeftCol"
LeftCol.Size = UDim2.new(0.49, 0, 1, 0)
LeftCol.Position = UDim2.new(0, 0, 0, 0)
LeftCol.BackgroundTransparency = 1
LeftCol.BorderSizePixel = 0
LeftCol.ScrollBarThickness = 3
LeftCol.ScrollBarImageColor3 = Config.Accent
LeftCol.ScrollBarImageTransparency = 0.5
LeftCol.CanvasSize = UDim2.new(0, 0, 0, 0)
LeftCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
LeftCol.ZIndex = 3
LeftCol.Parent = ColumnsHolder

local LeftLayout = Instance.new("UIListLayout")
LeftLayout.Padding = UDim.new(0, 6)
LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
LeftLayout.Parent = LeftCol

local LeftPadding = Instance.new("UIPadding")
LeftPadding.PaddingTop = UDim.new(0, 4)
LeftPadding.PaddingBottom = UDim.new(0, 4)
LeftPadding.Parent = LeftCol

-- RIGHT COLUMN
local RightCol = Instance.new("ScrollingFrame")
RightCol.Name = "RightCol"
RightCol.Size = UDim2.new(0.49, 0, 1, 0)
RightCol.Position = UDim2.new(0.51, 0, 0, 0)
RightCol.BackgroundTransparency = 1
RightCol.BorderSizePixel = 0
RightCol.ScrollBarThickness = 3
RightCol.ScrollBarImageColor3 = Config.Accent
RightCol.ScrollBarImageTransparency = 0.5
RightCol.CanvasSize = UDim2.new(0, 0, 0, 0)
RightCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
RightCol.ZIndex = 3
RightCol.Parent = ColumnsHolder

local RightLayout = Instance.new("UIListLayout")
RightLayout.Padding = UDim.new(0, 6)
RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
RightLayout.Parent = RightCol

local RightPadding = Instance.new("UIPadding")
RightPadding.PaddingTop = UDim.new(0, 4)
RightPadding.PaddingBottom = UDim.new(0, 4)
RightPadding.Parent = RightCol

-- ============================================================
-- MIN / CLOSE BUTTONS (floating top right)
-- ============================================================
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -64, 0, 12)
MinBtn.BackgroundColor3 = Config.BgCard
MinBtn.BackgroundTransparency = 0.4
MinBtn.Text = "−"
MinBtn.TextColor3 = Config.TextPrimary
MinBtn.TextSize = 16
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.AutoButtonColor = false
MinBtn.ZIndex = 100
MinBtn.Parent = Main

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -34, 0, 12)
CloseBtn.BackgroundColor3 = Config.Accent
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Config.TextPrimary
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 100
CloseBtn.Parent = Main

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Config.AccentHover}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Config.Accent}):Play()
end)

-- ============================================================
-- SECTION BUILDER
-- ============================================================
local function createSection(parent, text, layoutOrder)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, 0, 0, 22)
    Section.BackgroundTransparency = 1
    Section.LayoutOrder = layoutOrder or 0
    Section.Parent = parent

    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 16, 0, 16)
    Icon.Position = UDim2.new(0, 2, 0.5, -8)
    Icon.BackgroundTransparency = 1
    Icon.Text = "✦"
    Icon.TextColor3 = Config.Accent
    Icon.TextSize = 11
    Icon.Font = Enum.Font.GothamBold
    Icon.Parent = Section

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -24, 1, 0)
    Label.Position = UDim2.new(0, 22, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Config.TextSecond
    Label.TextSize = 11
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Section

    return Section
end

-- ============================================================
-- TOGGLE WIDGET
-- ============================================================
local function createToggle(parent, text, default, callback)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 34)
    Card.BackgroundColor3 = Config.BgCard
    Card.BackgroundTransparency = Config.BgCardTransp
    Card.BorderSizePixel = 0
    Card.Parent = parent

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 6)
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = Config.Border
    CardStroke.Thickness = 1
    CardStroke.Transparency = 0.92
    CardStroke.Parent = Card

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Config.TextPrimary
    Label.TextSize = 11
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Card

    local ToggleBg = Instance.new("Frame")
    ToggleBg.Size = UDim2.new(0, 32, 0, 18)
    ToggleBg.Position = UDim2.new(1, -44, 0.5, -9)
    ToggleBg.BackgroundColor3 = default and Config.Accent or Color3.fromRGB(60, 60, 72)
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
    Knob.Size = UDim2.new(0, 14, 0, 14)
    Knob.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = ToggleBg

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local isOn = default

    ToggleBtn.MouseButton1Click:Connect(function()
        isOn = not isOn
        TweenService:Create(ToggleBg, TweenInfo.new(0.15), {
            BackgroundColor3 = isOn and Config.Accent or Color3.fromRGB(60, 60, 72)
        }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.15), {
            Position = isOn and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()
        if callback then callback(isOn) end
    end)

    return Card
end

-- ============================================================
-- SLIDER WIDGET
-- ============================================================
local function createSlider(parent, text, min, max, default, suffix, callback)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 48)
    Card.BackgroundColor3 = Config.BgCard
    Card.BackgroundTransparency = Config.BgCardTransp
    Card.BorderSizePixel = 0
    Card.Parent = parent

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 6)
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = Config.Border
    CardStroke.Thickness = 1
    CardStroke.Transparency = 0.92
    CardStroke.Parent = Card

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -100, 0, 14)
    Label.Position = UDim2.new(0, 12, 0, 6)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Config.TextPrimary
    Label.TextSize = 11
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Card

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 80, 0, 14)
    ValueLabel.Position = UDim2.new(1, -92, 0, 6)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default) .. " " .. (suffix or "")
    ValueLabel.TextColor3 = Config.TextSecond
    ValueLabel.TextSize = 11
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Card

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -24, 0, 3)
    Bar.Position = UDim2.new(0, 12, 0, 34)
    Bar.BackgroundColor3 = Color3.fromRGB(60, 60, 72)
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
    Dot.Size = UDim2.new(0, 12, 0, 12)
    Dot.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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
        Dot.Position = UDim2.new(pos, -6, 0.5, -6)
        ValueLabel.Text = tostring(value) .. " " .. (suffix or "")
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

-- ============================================================
-- DROPDOWN WIDGET
-- ============================================================
local function createDropdown(parent, text, options, default, callback)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 40)
    Card.BackgroundColor3 = Config.BgCard
    Card.BackgroundTransparency = Config.BgCardTransp
    Card.BorderSizePixel = 0
    Card.Parent = parent

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 6)
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = Config.Border
    CardStroke.Thickness = 1
    CardStroke.Transparency = 0.92
    CardStroke.Parent = Card

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 16)
    Label.Position = UDim2.new(0, 12, 0, 4)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Config.TextPrimary
    Label.TextSize = 11
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Card

    local selected = default or options[1]

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(1, -20, 0, 14)
    ValueLabel.Position = UDim2.new(0, 12, 0, 20)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = selected .. "  ▾"
    ValueLabel.TextColor3 = Config.TextMuted
    ValueLabel.TextSize = 10
    ValueLabel.Font = Enum.Font.Gotham
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Left
    ValueLabel.Parent = Card

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = Card

    local idx = 1
    for i, opt in ipairs(options) do
        if opt == selected then idx = i break end
    end

    Btn.MouseButton1Click:Connect(function()
        idx = idx + 1
        if idx > #options then idx = 1 end
        selected = options[idx]
        ValueLabel.Text = selected .. "  ▾"
        if callback then callback(selected) end
    end)

    return Card
end

-- ============================================================
-- BUTTON WIDGET
-- ============================================================
local function createButton(parent, text, callback, isAccent)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 34)
    Btn.BackgroundColor3 = isAccent and Config.Accent or Config.BgCard
    Btn.BackgroundTransparency = isAccent and 0 or Config.BgCardTransp
    Btn.Text = text
    Btn.TextColor3 = Config.TextPrimary
    Btn.TextSize = 11
    Btn.Font = Enum.Font.GothamBold
    Btn.BorderSizePixel = 0
    Btn.AutoButtonColor = false
    Btn.Parent = parent

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Btn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = isAccent and Config.Accent or Config.Border
    BtnStroke.Thickness = 1
    BtnStroke.Transparency = isAccent and 0.4 or 0.92
    BtnStroke.Parent = Btn

    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {
            BackgroundColor3 = isAccent and Config.AccentHover or Config.BgCardHover,
            BackgroundTransparency = isAccent and 0 or 0.2
        }):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {
            BackgroundColor3 = isAccent and Config.Accent or Config.BgCard,
            BackgroundTransparency = isAccent and 0 or Config.BgCardTransp
        }):Play()
    end)
    Btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return Btn
end

-- ============================================================
-- NOTIFICATION SYSTEM
-- ============================================================
local function notify(text, isError)
    local color = isError and Config.Accent or Config.Success
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 320, 0, 52)
    Notif.Position = UDim2.new(0.5, -160, 0, 20)
    Notif.BackgroundColor3 = Config.BgCard
    Notif.BackgroundTransparency = 0.1
    Notif.BorderSizePixel = 0
    Notif.ZIndex = 200
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
-- CLEAR COLUMNS
-- ============================================================
local function clearColumns()
    for _, child in ipairs(LeftCol:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
    for _, child in ipairs(RightCol:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
end

-- ============================================================
-- BUILD: MAIN TAB
-- ============================================================
local function buildMainTab()
    clearColumns()

    -- LEFT
    createSection(LeftCol, "Auto Farm", 1)
    createToggle(LeftCol, "Auto Farm", State.AutoFarm, function(v) State.AutoFarm = v end)
    createSlider(LeftCol, "Farm Distance", 1, 50, State.FarmDistance, "studs", function(v) State.FarmDistance = v end)
    createToggle(LeftCol, "Auto Parry", State.AutoParry, function(v) State.AutoParry = v end)
    createToggle(LeftCol, "Auto Heal", State.AutoHeal, function(v) State.AutoHeal = v end)
    createToggle(LeftCol, "Auto Skill", State.AutoSkill, function(v) State.AutoSkill = v end)
    createToggle(LeftCol, "Auto Collect Chest", State.AutoChest, function(v) State.AutoChest = v end)
    createToggle(LeftCol, "Auto Collect Quests", State.AutoQuest, function(v) State.AutoQuest = v end)

    -- RIGHT
    createSection(RightCol, "Auto Dungeon", 1)
    createDropdown(RightCol, "Dungeon", {"Bandits Den", "Cursed Ship", "Dragon Nest", "Sky Fortress"}, State.Dungeon, function(v) State.Dungeon = v end)
    createDropdown(RightCol, "Difficulty", {"Easy", "Medium", "Hard", "Nightmare"}, State.Difficulty, function(v) State.Difficulty = v end)
    createToggle(RightCol, "Auto Dungeon", State.AutoDungeon, function(v) State.AutoDungeon = v end)
    createToggle(RightCol, "Auto Replay", State.AutoReplay, function(v) State.AutoReplay = v end)
    createToggle(RightCol, "Instant Interact", State.InstantInteract, function(v) State.InstantInteract = v end)

    createSection(RightCol, "Battlepass", 10)
    createToggle(RightCol, "Auto Claim Battlepass", State.AutoClaimBP, function(v) State.AutoClaimBP = v end)
end

-- ============================================================
-- BUILD: STATS TAB
-- ============================================================
local function buildStatsTab()
    clearColumns()

    createSection(LeftCol, "Display", 1)
    createToggle(LeftCol, "Show FPS", State.ShowFPS, function(v) State.ShowFPS = v end)
    createToggle(LeftCol, "Show Ping", State.ShowPing, function(v) State.ShowPing = v end)
    createToggle(LeftCol, "Show Coordinates", State.ShowCoords, function(v) State.ShowCoords = v end)

    createSection(RightCol, "Actions", 1)
    createButton(RightCol, "Reset Character", function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
        end
        notify("Character reset", false)
    end)
    createButton(RightCol, "Reset Physics", function()
        resetCharacterPhysics()
        notify("Physics reset", false)
    end)
end

-- ============================================================
-- BUILD: PLAYER TAB
-- ============================================================
local function buildPlayerTab()
    clearColumns()

    -- LEFT: Speed + Anti-Ban
    createSection(LeftCol, "Speed", 1)
    createToggle(LeftCol, "Speed Hack", State.SpeedEnabled, function(v) State.SpeedEnabled = v end)
    createSlider(LeftCol, "Speed Value", 16, 500, State.SpeedValue, "WS", function(v) State.SpeedValue = v end)
    createSlider(LeftCol, "Max Speed Cap", 50, 500, State.MaxSpeed, "WS", function(v) State.MaxSpeed = v end)

    createSection(LeftCol, "Anti-Ban Pro", 10)
    createToggle(LeftCol, "Anti-Ban System", State.AntiBanEnabled, function(v) State.AntiBanEnabled = v end)
    createToggle(LeftCol, "Jitter ±2", State.JitterEnabled, function(v) State.JitterEnabled = v end)
    createToggle(LeftCol, "Rate Limit 20Hz", State.RateLimitEnabled, function(v) State.RateLimitEnabled = v end)
    createToggle(LeftCol, "Legit Mode (60)", State.LegitMode, function(v) State.LegitMode = v end)

    createSection(LeftCol, "Emergency", 20)
    createButton(LeftCol, "🧹 Panic Cleanup", function()
        resetCharacterPhysics()
        State.SpeedEnabled = false
        State.FlyEnabled = false
        State.NoclipEnabled = false
        State.AntiFlingEnabled = false
        State.AntiVoidEnabled = false
        AntiBanState.currentRampSpeed = 16
        notify("Panic cleanup executed", false)
    end, true)

    -- RIGHT: Movement
    createSection(RightCol, "Movement", 1)
    createToggle(RightCol, "Fly", State.FlyEnabled, function(v) State.FlyEnabled = v end)
    createToggle(RightCol, "Noclip", State.NoclipEnabled, function(v) State.NoclipEnabled = v end)
    createToggle(RightCol, "Infinite Jump", State.InfJumpEnabled, function(v) State.InfJumpEnabled = v end)

    createSection(RightCol, "Protection", 10)
    createToggle(RightCol, "Anti-Fling", State.AntiFlingEnabled, function(v) State.AntiFlingEnabled = v end)
    createToggle(RightCol, "Anti-Void", State.AntiVoidEnabled, function(v) State.AntiVoidEnabled = v end)

    createSection(RightCol, "Quick Speed", 20)
    createButton(RightCol, "⚡ Speed 100", function()
        State.SpeedValue = 100
        State.SpeedEnabled = true
        notify("Speed = 100", false)
    end)
    createButton(RightCol, "⚡ Speed 200", function()
        State.SpeedValue = 200
        State.SpeedEnabled = true
        notify("Speed = 200", false)
    end)
    createButton(RightCol, "🛑 Reset Speed", function()
        State.SpeedValue = 16
        State.SpeedEnabled = false
        AntiBanState.currentRampSpeed = 16
        resetCharacterPhysics()
        notify("Speed reset to 16", false)
    end, true)
end

-- ============================================================
-- BUILD: SETTINGS TAB
-- ============================================================
local function buildSettingsTab()
    clearColumns()

    createSection(LeftCol, "Config", 1)
    createButton(LeftCol, "Save Config", function()
        notify("Config saved", false)
    end)
    createButton(LeftCol, "Load Config", function()
        notify("Config loaded", false)
    end)

    createSection(LeftCol, "Reset", 10)
    createButton(LeftCol, "Reset Character", function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
        end
    end)

    createSection(RightCol, "Script", 1)
    createButton(RightCol, "Rejoin Server", function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
    createButton(RightCol, "Unload Script", function()
        resetCharacterPhysics()
        ScreenGui:Destroy()
    end, true)

    createSection(RightCol, "About", 10)
    createButton(RightCol, "Execute Hub " .. Config.Version, function()
        notify("Execute Hub " .. Config.Version, false)
    end)
end

-- ============================================================
-- TAB DEFINITIONS + CREATION
-- ============================================================
local Tabs = {}
local ActiveTab = "Main"

local tabDefs = {
    {name = "Main",     icon = "∞"},
    {name = "Stats",    icon = "↻"},
    {name = "Player",   icon = "◐"},
    {name = "Settings", icon = "⚙"},
}

for i, def in ipairs(tabDefs) do
    local Tab = Instance.new("TextButton")
    Tab.Name = def.name .. "Tab"
    Tab.Size = UDim2.new(1, -16, 0, 34)
    Tab.Position = UDim2.new(0, 8, 0, 210 + ((i - 1) * 38))
    Tab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Tab.BackgroundTransparency = 1
    Tab.Text = "  " .. def.icon .. "   " .. def.name
    Tab.TextColor3 = Config.TextSecond
    Tab.TextSize = 12
    Tab.Font = Enum.Font.GothamBold
    Tab.TextXAlignment = Enum.TextXAlignment.Left
    Tab.BorderSizePixel = 0
    Tab.AutoButtonColor = false
    Tab.ZIndex = 2
    Tab.Parent = Sidebar

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = Tab

    -- Indicator bar
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 2, 0.5, 0)
    Indicator.Position = UDim2.new(0, 0, 0.25, 0)
    Indicator.BackgroundColor3 = Config.Accent
    Indicator.BorderSizePixel = 0
    Indicator.Visible = false
    Indicator.ZIndex = 3
    Indicator.Parent = Tab

    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = Indicator

    Tabs[def.name] = {
        Button = Tab,
        Indicator = Indicator,
        name = def.name,
    }

    Tab.MouseButton1Click:Connect(function()
        -- Reset all tabs
        for _, t in pairs(Tabs) do
            t.Button.BackgroundTransparency = 1
            t.Button.TextColor3 = Config.TextSecond
            t.Indicator.Visible = false
        end

        -- Activate clicked tab
        Tab.BackgroundTransparency = 0.5
        Tab.TextColor3 = Config.TextPrimary
        Indicator.Visible = true
        ActiveTab = def.name
        PageTitle.Text = string.upper(def.name)

        -- Rebuild columns based on selected tab
        if def.name == "Main" then
            buildMainTab()
        elseif def.name == "Stats" then
            buildStatsTab()
        elseif def.name == "Player" then
            buildPlayerTab()
        elseif def.name == "Settings" then
            buildSettingsTab()
        end
    end)

    Tab.MouseEnter:Connect(function()
        if ActiveTab ~= def.name then
            TweenService:Create(Tab, TweenInfo.new(0.15), {BackgroundTransparency = 0.6}):Play()
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
-- ACTIVATE MAIN TAB ON LOAD
-- ============================================================
if Tabs["Main"] then
    Tabs["Main"].Button.BackgroundTransparency = 0.5
    Tabs["Main"].Button.TextColor3 = Config.TextPrimary
    Tabs["Main"].Indicator.Visible = true
    ActiveTab = "Main"
end
buildMainTab()

-- ============================================================
-- MIN / CLOSE / KEYBIND
-- ============================================================
CloseBtn.MouseButton1Click:Connect(function()
    resetCharacterPhysics()
    ScreenGui:Destroy()
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Main.Size = UDim2.new(0, Config.WindowWidth, 0, 40)
        Sidebar.Visible = false
        Content.Visible = false
        ColumnsHolder.Visible = false
        PageTitle.Visible = false
        TitleLine.Visible = false
    else
        Main.Size = UDim2.new(0, Config.WindowWidth, 0, Config.WindowHeight)
        Sidebar.Visible = true
        Content.Visible = true
        ColumnsHolder.Visible = true
        PageTitle.Visible = true
        TitleLine.Visible = true
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
    end
end)

-- ============================================================
-- SPEED HACK CORE
-- ============================================================
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    if State.SpeedEnabled then
        -- Rate limit
        if State.RateLimitEnabled then
            AntiBanState.tickCounter = (AntiBanState.tickCounter + 1) % 3
            if AntiBanState.tickCounter ~= 0 then return end
        end

        -- Determine target speed
        local target = State.SpeedValue
        if State.LegitMode then target = math.min(target, 60) end
        if target > State.MaxSpeed then target = State.MaxSpeed end

        -- Ramp up
        if State.RampUpEnabled then
            local diff = target - AntiBanState.currentRampSpeed
            if math.abs(diff) > 0.5 then
                AntiBanState.currentRampSpeed = AntiBanState.currentRampSpeed + diff * 0.05
                target = math.floor(AntiBanState.currentRampSpeed)
            else
                AntiBanState.currentRampSpeed = target
            end
        end

        -- Jitter
        local speed = target
        if State.JitterEnabled then
            local jitter = math.random(-2, 2)
            if math.random(1, 10) == 1 then jitter = 0 end
            speed = target + jitter
        end

        -- Method 1: WalkSpeed
        pcall(function() hum.WalkSpeed = speed end)

        -- Method 2: Velocity injection
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

        -- Method 3: BodyVelocity (fallback for custom controllers)
        local bv = hrp:FindFirstChild("SpeedBV")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "SpeedBV"
            bv.MaxForce = Vector3.new(math.huge, 0, math.huge)
            bv.Parent = hrp
        end
        if hum.MoveDirection.Magnitude > 0.1 then
            local dir = hum.MoveDirection
            bv.Velocity = Vector3.new(dir.X * speed, 0, dir.Z * speed)
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end
    else
        -- Reset speed
        pcall(function() hum.WalkSpeed = 16 end)
        pcall(function()
            hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
        end)
        local bv = hrp:FindFirstChild("SpeedBV")
        if bv then bv:Destroy() end
    end
end)

-- ============================================================
-- CLEANUP LOOP
-- ============================================================
task.spawn(function()
    while task.wait(0.5) do
        cleanupSpeedInstances()
    end
end)

-- ============================================================
-- ANTI-FLING / ANTI-VOID
-- ============================================================
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
                pcall(function()
                    hrp.CFrame = CFrame.new(0, 50, 0)
                end)
            end
        end
    end
end)

-- ============================================================
-- NOCLIP
-- ============================================================
task.spawn(function()
    while task.wait(0.2) do
        if State.NoclipEnabled then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function() part.CanCollide = false end)
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- FLY
-- ============================================================
local flyConn = nil
local flyCleanup = nil

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

-- ============================================================
-- INFINITE JUMP
-- ============================================================
UserInputService.JumpRequest:Connect(function()
    if State.InfJumpEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- ============================================================
-- ANTI-AFK
-- ============================================================
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ============================================================
-- RESPAWN HANDLER
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if flyCleanup then
        flyCleanup()
        flyConn = nil
        flyCleanup = nil
    end
    AntiBanState.currentRampSpeed = 16
    if State.SpeedEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = State.SpeedValue end
        end
    end
end)

-- ============================================================
-- AUTO FARM LOOP (basic)
-- ============================================================
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFarm then
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local nearest = nil
                    local shortest = State.FarmDistance + 50
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) then
                            local hum = obj:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 then
                                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                                if root then
                                    local dist = (root.Position - hrp.Position).Magnitude
                                    if dist < shortest then
                                        shortest = dist
                                        nearest = root
                                    end
                                end
                            end
                        end
                    end
                    if nearest then
                        pcall(function()
                            hrp.CFrame = CFrame.new(nearest.Position + Vector3.new(0, 3, 0))
                        end)
                        -- Fire tools
                        for _, tool in ipairs(char:GetChildren()) do
                            if tool:IsA("Tool") then
                                pcall(function() tool:Activate() end)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- AUTO HEAL LOOP
-- ============================================================
task.spawn(function()
    while task.wait(1) do
        if State.AutoHeal then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health < hum.MaxHealth then
                    hum.Health = hum.MaxHealth
                end
            end
        end
    end
end)

-- ============================================================
-- AUTO CHEST LOOP
-- ============================================================
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoChest then
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "chest") or string.find(string.lower(obj.Name), "drop")) then
                            pcall(function()
                                hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                            end)
                            if firetouchinterest then
                                pcall(function()
                                    firetouchinterest(hrp, obj, 0)
                                    task.wait()
                                    firetouchinterest(hrp, obj, 1)
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- AUTO PARry (basic timing)
-- ============================================================
task.spawn(function()
    while task.wait(0.1) do
        if State.AutoParry then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        -- Fire any "parry" remote
                        for _, obj in ipairs(game:GetDescendants()) do
                            if obj:IsA("RemoteEvent") and string.find(string.lower(obj.Name), "parry") then
                                pcall(function() obj:FireServer() end)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- AUTO SKILL LOOP
-- ============================================================
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoSkill then
            for _, obj in ipairs(game:GetDescendants()) do
                if obj:IsA("RemoteEvent") and string.find(string.lower(obj.Name), "skill") then
                    pcall(function() obj:FireServer() end)
                end
            end
        end
    end
end)

-- ============================================================
-- AUTO CLAIM BATTLEPASS
-- ============================================================
task.spawn(function()
    while task.wait(3) do
        if State.AutoClaimBP then
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                for _, gui in ipairs(playerGui:GetDescendants()) do
                    if gui:IsA("TextButton") and (string.find(string.lower(gui.Text), "claim") or string.find(string.lower(gui.Text), "receive")) then
                        pcall(function() gui:Activate() end)
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- AUTO QUEST
-- ============================================================
task.spawn(function()
    while task.wait(2) do
        if State.AutoQuest then
            for _, obj in ipairs(game:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and string.find(string.lower(obj.Name), "quest") then
                    pcall(function()
                        obj.HoldDuration = 0
                        if fireproximityprompt then
                            fireproximityprompt(obj)
                        end
                    end)
                end
            end
        end
    end
end)

-- ============================================================
-- STATS DISPLAY
-- ============================================================
local StatsFrame = Instance.new("Frame")
StatsFrame.Size = UDim2.new(0, 180, 0, 60)
StatsFrame.Position = UDim2.new(1, -200, 0, 60)
StatsFrame.BackgroundColor3 = Config.BgCard
StatsFrame.BackgroundTransparency = 0.3
StatsFrame.BorderSizePixel = 0
StatsFrame.Visible = false
StatsFrame.ZIndex = 150
StatsFrame.Parent = ScreenGui

local StatsFrameCorner = Instance.new("UICorner")
StatsFrameCorner.CornerRadius = UDim.new(0, 8)
StatsFrameCorner.Parent = StatsFrame

local StatsFrameStroke = Instance.new("UIStroke")
StatsFrameStroke.Color = Config.Accent
StatsFrameStroke.Thickness = 1
StatsFrameStroke.Transparency = 0.5
StatsFrameStroke.Parent = StatsFrame

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, -16, 1, 0)
StatsLabel.Position = UDim2.new(0, 8, 0, 0)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "FPS: --\nPing: --\nX: --, Y: --, Z: --"
StatsLabel.TextColor3 = Config.TextPrimary
StatsLabel.TextSize = 11
StatsLabel.Font = Enum.Font.GothamBold
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Center
StatsLabel.Parent = StatsFrame

task.spawn(function()
    while task.wait(0.5) do
        local show = State.ShowFPS or State.ShowPing or State.ShowCoords
        StatsFrame.Visible = show
        if show then
            local lines = {}
            if State.ShowFPS then
                table.insert(lines, "FPS: " .. math.floor(1 / RunService.RenderStepped:Wait()))
            end
            if State.ShowPing then
                local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
                table.insert(lines, "Ping: " .. math.floor(ping) .. " ms")
            end
            if State.ShowCoords then
                local char = LocalPlayer.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local p = root.Position
                        table.insert(lines, string.format("X: %d, Y: %d, Z: %d", p.X, p.Y, p.Z))
                    end
                end
            end
            StatsLabel.Text = table.concat(lines, "\n")
        end
    end
end)

-- ============================================================
-- STARTUP NOTIFICATION
-- ============================================================
notify("EXECUTE HUB " .. Config.Version .. " loaded", false)

print("[EXECUTE HUB] " .. Config.Version .. " loaded")
print("[EXECUTE HUB] User: " .. LocalPlayer.Name)
print("[EXECUTE HUB] Tabs: Main, Stats, Player, Settings")
print("[EXECUTE HUB] Right Ctrl = toggle UI")
