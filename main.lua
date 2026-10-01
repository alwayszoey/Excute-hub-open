--[[
================================================================
    EXECUTE HUB - v5.0.0 (STEAL / SAVE-TELEPORT EDITION)
    UI tối giản hình vuông, mobile-friendly
    Features:
      - No Cooldown Steal
      - Save Position + Teleport to Save
      - Teleport to XYZ (manual input)
      - Speed Hack + Anti-Ban
      - Clean compact UI
================================================================
]]

-- ============================================================
-- SERVICES
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- CONFIG
-- ============================================================
local Config = {
    BgMain       = Color3.fromRGB(15, 15, 18),
    BgPanel      = Color3.fromRGB(25, 25, 30),
    BgCard       = Color3.fromRGB(35, 35, 42),
    BgHover      = Color3.fromRGB(48, 48, 58),
    BgSidebar    = Color3.fromRGB(10, 10, 12),
    BgSidebarTransp = 0.1,
    Accent       = Color3.fromRGB(255, 35, 45),
    AccentHover  = Color3.fromRGB(255, 60, 70),
    TextPrimary  = Color3.fromRGB(245, 245, 250),
    TextSecond   = Color3.fromRGB(160, 160, 175),
    TextMuted    = Color3.fromRGB(110, 110, 125),
    Border       = Color3.fromRGB(255, 255, 255),
    BorderTransp = 0.9,
    Success      = Color3.fromRGB(60, 220, 110),
    Warning      = Color3.fromRGB(255, 180, 40),
    Version      = "v5.0.0",
    Title        = "EXECUTE HUB",
    LogoText     = "EH",
    -- Compact size (mobile-friendly)
    Width        = 480,
    Height       = 340
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
    -- Steal
    AutoSteal        = false,
    NoCooldownSteal  = false,
    InstantSteal     = false,
    StealRange       = 30,
    -- Save/Teleport
    SavedPositions   = {},
    -- Misc
    AntiAfkEnabled   = true,
}

local AntiBanState = {
    tickCounter = 0,
    currentRampSpeed = 16,
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
-- MAIN WINDOW (compact square)
-- ============================================================
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, Config.Width, 0, Config.Height)
Main.Position = UDim2.new(0.5, -(Config.Width/2), 0.5, -(Config.Height/2))
Main.BackgroundColor3 = Config.BgMain
Main.BackgroundTransparency = 0.05
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Config.Border
MainStroke.Thickness = 1
MainStroke.Transparency = Config.BorderTransp
MainStroke.Parent = Main

-- ============================================================
-- TOP BAR
-- ============================================================
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Config.BgPanel
TopBar.BackgroundTransparency = 0.3
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 14)
TopBarCorner.Parent = TopBar

local TopCover = Instance.new("Frame")
TopCover.Size = UDim2.new(1, 0, 0, 15)
TopCover.Position = UDim2.new(0, 0, 1, -15)
TopCover.BackgroundColor3 = Config.BgPanel
TopCover.BackgroundTransparency = 0.3
TopCover.BorderSizePixel = 0
TopCover.Parent = TopBar

-- Window dots
local DotsFrame = Instance.new("Frame")
DotsFrame.Size = UDim2.new(0, 50, 0, 12)
DotsFrame.Position = UDim2.new(0, 12, 0.5, -6)
DotsFrame.BackgroundTransparency = 1
DotsFrame.Parent = TopBar

local dotColors = {
    Color3.fromRGB(255, 95, 87),
    Color3.fromRGB(255, 189, 46),
    Color3.fromRGB(39, 201, 63)
}
for i = 1, 3 do
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 9, 0, 9)
    dot.Position = UDim2.new(0, (i - 1) * 12, 0.5, -4.5)
    dot.BackgroundColor3 = dotColors[i]
    dot.BorderSizePixel = 0
    dot.Parent = DotsFrame
    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(1, 0)
    dc.Parent = dot
end

-- Title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 200, 0, 18)
TitleLabel.Position = UDim2.new(0, 66, 0, 6)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = Config.Title
TitleLabel.TextColor3 = Config.TextPrimary
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(0, 200, 0, 12)
SubLabel.Position = UDim2.new(0, 66, 0, 22)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "Pro Edition • " .. Config.Version
SubLabel.TextColor3 = Config.TextMuted
SubLabel.TextSize = 9
SubLabel.Font = Enum.Font.Gotham
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Parent = TopBar

-- Min
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 22, 0, 22)
MinBtn.Position = UDim2.new(1, -54, 0.5, -11)
MinBtn.BackgroundColor3 = Config.BgCard
MinBtn.BackgroundTransparency = 0.5
MinBtn.Text = "−"
MinBtn.TextColor3 = Config.TextPrimary
MinBtn.TextSize = 14
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.AutoButtonColor = false
MinBtn.Parent = TopBar
local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -11)
CloseBtn.BackgroundColor3 = Config.Accent
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Config.TextPrimary
CloseBtn.TextSize = 11
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TopBar
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- ============================================================
-- SIDEBAR (compact left menu, transparent)
-- ============================================================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -48)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Config.BgSidebar
Sidebar.BackgroundTransparency = Config.BgSidebarTransp
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 12)
SidebarCorner.Parent = Sidebar

local SidebarDivider = Instance.new("Frame")
SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
SidebarDivider.Position = UDim2.new(1, -1, 0, 0)
SidebarDivider.BackgroundColor3 = Config.Border
SidebarDivider.BackgroundTransparency = 0.85
SidebarDivider.BorderSizePixel = 0
SidebarDivider.Parent = Sidebar

-- User info block
local UserBlock = Instance.new("Frame")
UserBlock.Size = UDim2.new(1, -12, 0, 36)
UserBlock.Position = UDim2.new(0, 6, 0, 8)
UserBlock.BackgroundColor3 = Config.BgCard
UserBlock.BackgroundTransparency = 0.6
UserBlock.BorderSizePixel = 0
UserBlock.Parent = Sidebar
local UserBlockCorner = Instance.new("UICorner")
UserBlockCorner.CornerRadius = UDim.new(0, 6)
UserBlockCorner.Parent = UserBlock

local UserAvatar = Instance.new("Frame")
UserAvatar.Size = UDim2.new(0, 24, 0, 24)
UserAvatar.Position = UDim2.new(0, 6, 0.5, -12)
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
UserInitial.TextSize = 12
UserInitial.Font = Enum.Font.GothamBold
UserInitial.Parent = UserAvatar

local UserName = Instance.new("TextLabel")
UserName.Size = UDim2.new(1, -38, 0, 12)
UserName.Position = UDim2.new(0, 36, 0, 6)
UserName.BackgroundTransparency = 1
UserName.Text = LocalPlayer.Name
UserName.TextColor3 = Config.TextPrimary
UserName.TextSize = 10
UserName.Font = Enum.Font.GothamBold
UserName.TextXAlignment = Enum.TextXAlignment.Left
UserName.TextTruncate = Enum.TextTruncate.AtEnd
UserName.Parent = UserBlock

local UserStatus = Instance.new("TextLabel")
UserStatus.Size = UDim2.new(1, -38, 0, 10)
UserStatus.Position = UDim2.new(0, 36, 0, 20)
UserStatus.BackgroundTransparency = 1
UserStatus.Text = "● Online"
UserStatus.TextColor3 = Config.Success
UserStatus.TextSize = 8
UserStatus.Font = Enum.Font.GothamMedium
UserStatus.TextXAlignment = Enum.TextXAlignment.Left
UserStatus.Parent = UserBlock

-- ============================================================
-- CONTENT
-- ============================================================
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -138, 1, -48)
Content.Position = UDim2.new(0, 138, 0, 40)
Content.BackgroundTransparency = 1
Content.Parent = Main

local PageTitle = Instance.new("TextLabel")
PageTitle.Size = UDim2.new(1, -16, 0, 22)
PageTitle.Position = UDim2.new(0, 8, 0, 2)
PageTitle.BackgroundTransparency = 1
PageTitle.Text = "MAIN"
PageTitle.TextColor3 = Config.TextPrimary
PageTitle.TextSize = 14
PageTitle.Font = Enum.Font.GothamBlack
PageTitle.TextXAlignment = Enum.TextXAlignment.Left
PageTitle.Parent = Content

local TitleLine = Instance.new("Frame")
TitleLine.Size = UDim2.new(1, -16, 0, 1)
TitleLine.Position = UDim2.new(0, 8, 0, 26)
TitleLine.BackgroundColor3 = Config.Accent
TitleLine.BorderSizePixel = 0
TitleLine.Parent = Content

local PageHolder = Instance.new("Frame")
PageHolder.Size = UDim2.new(1, -16, 1, -34)
PageHolder.Position = UDim2.new(0, 8, 0, 32)
PageHolder.BackgroundTransparency = 1
PageHolder.Parent = Content

-- Scroll page
local Page = Instance.new("ScrollingFrame")
Page.Size = UDim2.new(1, 0, 1, 0)
Page.BackgroundTransparency = 1
Page.BorderSizePixel = 0
Page.ScrollBarThickness = 3
Page.ScrollBarImageColor3 = Config.Accent
Page.ScrollBarImageTransparency = 0.5
Page.CanvasSize = UDim2.new(0, 0, 0, 0)
Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
Page.Parent = PageHolder

local PageLayout = Instance.new("UIListLayout")
PageLayout.Padding = UDim.new(0, 5)
PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
PageLayout.Parent = Page

local PagePadding = Instance.new("UIPadding")
PagePadding.PaddingTop = UDim.new(0, 4)
PagePadding.PaddingBottom = UDim.new(0, 4)
PagePadding.Parent = Page

-- ============================================================
-- SECTION BUILDER
-- ============================================================
local function createSection(parent, text)
    local Sec = Instance.new("Frame")
    Sec.Size = UDim2.new(1, 0, 0, 20)
    Sec.BackgroundTransparency = 1
    Sec.Parent = parent

    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 14, 0, 14)
    Icon.Position = UDim2.new(0, 2, 0.5, -7)
    Icon.BackgroundTransparency = 1
    Icon.Text = "✦"
    Icon.TextColor3 = Config.Accent
    Icon.TextSize = 10
    Icon.Font = Enum.Font.GothamBold
    Icon.Parent = Sec

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -22, 1, 0)
    Lbl.Position = UDim2.new(0, 20, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text
    Lbl.TextColor3 = Config.TextSecond
    Lbl.TextSize = 10
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Sec

    return Sec
end

-- ============================================================
-- TOGGLE WIDGET
-- ============================================================
local function createToggle(parent, text, default, callback)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 32)
    Card.BackgroundColor3 = Config.BgCard
    Card.BackgroundTransparency = 0.4
    Card.BorderSizePixel = 0
    Card.Parent = parent

    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(0, 6)
    CCorner.Parent = Card

    local CStroke = Instance.new("UIStroke")
    CStroke.Color = Config.Border
    CStroke.Thickness = 1
    CStroke.Transparency = 0.92
    CStroke.Parent = Card

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -55, 1, 0)
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text
    Lbl.TextColor3 = Config.TextPrimary
    Lbl.TextSize = 10
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Card

    local TBg = Instance.new("Frame")
    TBg.Size = UDim2.new(0, 30, 0, 16)
    TBg.Position = UDim2.new(1, -40, 0.5, -8)
    TBg.BackgroundColor3 = default and Config.Accent or Color3.fromRGB(60, 60, 72)
    TBg.BorderSizePixel = 0
    TBg.Parent = Card

    local TBgCorner = Instance.new("UICorner")
    TBgCorner.CornerRadius = UDim.new(1, 0)
    TBgCorner.Parent = TBg

    local TBtn = Instance.new("TextButton")
    TBtn.Size = UDim2.new(1, 0, 1, 0)
    TBtn.BackgroundTransparency = 1
    TBtn.Text = ""
    TBtn.Parent = TBg

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 12, 0, 12)
    Knob.Position = default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = TBg

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local isOn = default

    TBtn.MouseButton1Click:Connect(function()
        isOn = not isOn
        TweenService:Create(TBg, TweenInfo.new(0.15), {
            BackgroundColor3 = isOn and Config.Accent or Color3.fromRGB(60, 60, 72)
        }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.15), {
            Position = isOn and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
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
    Card.Size = UDim2.new(1, 0, 0, 44)
    Card.BackgroundColor3 = Config.BgCard
    Card.BackgroundTransparency = 0.4
    Card.BorderSizePixel = 0
    Card.Parent = parent

    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(0, 6)
    CCorner.Parent = Card

    local CStroke = Instance.new("UIStroke")
    CStroke.Color = Config.Border
    CStroke.Thickness = 1
    CStroke.Transparency = 0.92
    CStroke.Parent = Card

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -80, 0, 12)
    Lbl.Position = UDim2.new(0, 10, 0, 6)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text
    Lbl.TextColor3 = Config.TextPrimary
    Lbl.TextSize = 10
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Card

    local VLbl = Instance.new("TextLabel")
    VLbl.Size = UDim2.new(0, 70, 0, 12)
    VLbl.Position = UDim2.new(1, -80, 0, 6)
    VLbl.BackgroundTransparency = 1
    VLbl.Text = tostring(default) .. " " .. (suffix or "")
    VLbl.TextColor3 = Config.TextSecond
    VLbl.TextSize = 10
    VLbl.Font = Enum.Font.GothamBold
    VLbl.TextXAlignment = Enum.TextXAlignment.Right
    VLbl.Parent = Card

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -20, 0, 3)
    Bar.Position = UDim2.new(0, 10, 0, 30)
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
    Dot.Size = UDim2.new(0, 11, 0, 11)
    Dot.Position = UDim2.new((default - min) / (max - min), -5.5, 0.5, -5.5)
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
        Dot.Position = UDim2.new(pos, -5.5, 0.5, -5.5)
        VLbl.Text = tostring(value) .. " " .. (suffix or "")
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
-- TEXT INPUT WIDGET
-- ============================================================
local function createTextInput(parent, text, placeholder, default, callback)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 42)
    Card.BackgroundColor3 = Config.BgCard
    Card.BackgroundTransparency = 0.4
    Card.BorderSizePixel = 0
    Card.Parent = parent

    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(0, 6)
    CCorner.Parent = Card

    local CStroke = Instance.new("UIStroke")
    CStroke.Color = Config.Border
    CStroke.Thickness = 1
    CStroke.Transparency = 0.92
    CStroke.Parent = Card

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -20, 0, 12)
    Lbl.Position = UDim2.new(0, 10, 0, 4)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text
    Lbl.TextColor3 = Config.TextPrimary
    Lbl.TextSize = 10
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Card

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -20, 0, 20)
    Box.Position = UDim2.new(0, 10, 0, 18)
    Box.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    Box.BorderSizePixel = 0
    Box.Text = default or ""
    Box.PlaceholderText = placeholder or ""
    Box.TextColor3 = Config.TextPrimary
    Box.PlaceholderColor3 = Config.TextMuted
    Box.TextSize = 10
    Box.Font = Enum.Font.GothamBold
    Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.ClearTextOnFocus = false
    Box.Parent = Card

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 4)
    BoxCorner.Parent = Box

    local BoxPad = Instance.new("UIPadding")
    BoxPad.PaddingLeft = UDim.new(0, 6)
    BoxPad.Parent = Box

    Box.FocusLost:Connect(function()
        if callback then callback(Box.Text) end
    end)

    return Card
end

-- ============================================================
-- BUTTON WIDGET
-- ============================================================
local function createButton(parent, text, callback, isAccent)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, 0, 0, 30)
    B.BackgroundColor3 = isAccent and Config.Accent or Config.BgCard
    B.BackgroundTransparency = isAccent and 0 or 0.4
    B.Text = text
    B.TextColor3 = Config.TextPrimary
    B.TextSize = 10
    B.Font = Enum.Font.GothamBold
    B.BorderSizePixel = 0
    B.AutoButtonColor = false
    B.Parent = parent

    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 6)
    BCorner.Parent = B

    local BStroke = Instance.new("UIStroke")
    BStroke.Color = isAccent and Config.Accent or Config.Border
    BStroke.Thickness = 1
    BStroke.Transparency = isAccent and 0.4 or 0.92
    BStroke.Parent = B

    B.MouseEnter:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.15), {
            BackgroundColor3 = isAccent and Config.AccentHover or Config.BgHover,
            BackgroundTransparency = isAccent and 0 or 0.2
        }):Play()
    end)
    B.MouseLeave:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.15), {
            BackgroundColor3 = isAccent and Config.Accent or Config.BgCard,
            BackgroundTransparency = isAccent and 0 or 0.4
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
    local N = Instance.new("Frame")
    N.Size = UDim2.new(0, 260, 0, 44)
    N.Position = UDim2.new(0.5, -130, 0, 20)
    N.BackgroundColor3 = Config.BgCard
    N.BackgroundTransparency = 0.1
    N.BorderSizePixel = 0
    N.ZIndex = 200
    N.Parent = ScreenGui

    local NC = Instance.new("UICorner")
    NC.CornerRadius = UDim.new(0, 8)
    NC.Parent = N

    local NS = Instance.new("UIStroke")
    NS.Color = color
    NS.Thickness = 1.5
    NS.Parent = N

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(0, 3, 1, -10)
    Bar.Position = UDim2.new(0, 5, 0, 5)
    Bar.BackgroundColor3 = color
    Bar.BorderSizePixel = 0
    Bar.Parent = N

    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(1, 0)
    BC.Parent = Bar

    local T = Instance.new("TextLabel")
    T.Size = UDim2.new(1, -25, 1, 0)
    T.Position = UDim2.new(0, 16, 0, 0)
    T.BackgroundTransparency = 1
    T.Text = text
    T.TextColor3 = color
    T.TextSize = 10
    T.Font = Enum.Font.GothamBold
    T.TextWrapped = true
    T.TextXAlignment = Enum.TextXAlignment.Left
    T.Parent = N

    task.spawn(function()
        task.wait(2.5)
        TweenService:Create(N, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        TweenService:Create(T, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        TweenService:Create(NS, TweenInfo.new(0.4), {Transparency = 1}):Play()
        TweenService:Create(Bar, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        task.wait(0.4)
        N:Destroy()
    end)
end

-- ============================================================
-- CLEAR PAGE
-- ============================================================
local function clearPage()
    for _, child in ipairs(Page:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
end

-- ============================================================
-- STEAL HELPERS
-- ============================================================
local function findStealPrompts()
    local prompts = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local name = string.lower(obj.Name)
            local actionText = string.lower(obj.ActionText or "")
            if string.find(name, "steal") or string.find(actionText, "steal") 
               or string.find(name, "egg") or string.find(name, "grab")
               or string.find(name, "take") or string.find(name, "collect") then
                table.insert(prompts, obj)
            end
        elseif obj:IsA("ClickDetector") then
            local name = string.lower(obj.Name)
            if string.find(name, "steal") or string.find(name, "egg") 
               or string.find(name, "grab") or string.find(name, "take") then
                table.insert(prompts, obj)
            end
        end
    end
    return prompts
end

local function fireStealPrompt(prompt)
    pcall(function()
        if prompt:IsA("ProximityPrompt") then
            prompt.HoldDuration = 0
            prompt.MaxActivationDistance = 9999
            prompt.RequiresLineOfSight = false
            if fireproximityprompt then
                fireproximityprompt(prompt)
            end
        elseif prompt:IsA("ClickDetector") then
            prompt.MaxActivationDistance = 9999
            if fireclickdetector then
                fireclickdetector(prompt)
            end
        end
    end)
end

local function findNearestSteal()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local prompts = findStealPrompts()
    local nearest = nil
    local shortest = State.StealRange

    for _, p in ipairs(prompts) do
        local parent = p.Parent
        if parent then
            local part = parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart")
            if part then
                local dist = (part.Position - hrp.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    nearest = { prompt = p, part = part, distance = dist }
                end
            end
        end
    end

    return nearest
end

local function teleportToPosition(pos)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    pcall(function()
        hrp.CFrame = CFrame.new(pos)
    end)
    return true
end

-- ============================================================
-- SAVE POSITION SYSTEM
-- ============================================================
local function savePosition(name)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    State.SavedPositions[name] = {
        x = hrp.Position.X,
        y = hrp.Position.Y,
        z = hrp.Position.Z,
        time = os.time()
    }
    return true
end

local function teleportToSaved(name)
    local pos = State.SavedPositions[name]
    if not pos then return false end
    return teleportToPosition(Vector3.new(pos.x, pos.y, pos.z))
end

local function deleteSavedPosition(name)
    State.SavedPositions[name] = nil
end

-- ============================================================
-- PAGE BUILDER: MAIN
-- ============================================================
local function buildMainPage()
    clearPage()
    PageTitle.Text = "MAIN"

    createSection(Page, "Steal")
    createToggle(Page, "Auto Steal", State.AutoSteal, function(v) State.AutoSteal = v end)
    createToggle(Page, "No Cooldown Steal", State.NoCooldownSteal, function(v) 
        State.NoCooldownSteal = v 
    end)
    createToggle(Page, "Instant Steal", State.InstantSteal, function(v) State.InstantSteal = v end)
    createSlider(Page, "Steal Range", 5, 100, State.StealRange, "studs", function(v) State.StealRange = v end)

    createSection(Page, "Movement")
    createToggle(Page, "Speed Hack", State.SpeedEnabled, function(v) State.SpeedEnabled = v end)
    createSlider(Page, "Speed Value", 16, 500, State.SpeedValue, "WS", function(v) State.SpeedValue = v end)
    createToggle(Page, "Fly", State.FlyEnabled, function(v) State.FlyEnabled = v end)
    createToggle(Page, "Noclip", State.NoclipEnabled, function(v) State.NoclipEnabled = v end)

    createSection(Page, "Actions")
    createButton(Page, "🔥 Fire All Steals", function()
        local prompts = findStealPrompts()
        for _, p in ipairs(prompts) do
            fireStealPrompt(p)
        end
        notify("Fired " .. #prompts .. " steals", false)
    end, true)
    createButton(Page, "🎯 Teleport to Nearest Steal", function()
        local nearest = findNearestSteal()
        if nearest then
            teleportToPosition(nearest.part.Position + Vector3.new(0, 3, 0))
            notify("Teleported to steal", false)
        else
            notify("No steal in range", true)
        end
    end)
end

-- ============================================================
-- PAGE BUILDER: SAVE / TP
-- ============================================================
local SaveInputValue = "spot1"
local TPInputValue = "0, 50, 0"

local function buildSavePage()
    clearPage()
    PageTitle.Text = "SAVE / TELEPORT"

    createSection(Page, "Save Position")
    createTextInput(Page, "Save Name", "e.g. base, farm", SaveInputValue, function(v)
        SaveInputValue = v
    end)
    createButton(Page, "💾 Save Current Position", function()
        if savePosition(SaveInputValue) then
            notify("Saved: " .. SaveInputValue, false)
        else
            notify("Failed to save", true)
        end
    end, true)

    createSection(Page, "Saved Positions")
    for name, pos in pairs(State.SavedPositions) do
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 44)
        Card.BackgroundColor3 = Config.BgCard
        Card.BackgroundTransparency = 0.4
        Card.BorderSizePixel = 0
        Card.Parent = Page

        local CC = Instance.new("UICorner")
        CC.CornerRadius = UDim.new(0, 6)
        CC.Parent = Card

        local CS = Instance.new("UIStroke")
        CS.Color = Config.Border
        CS.Thickness = 1
        CS.Transparency = 0.92
        CS.Parent = Card

        local N = Instance.new("TextLabel")
        N.Size = UDim2.new(1, -10, 0, 12)
        N.Position = UDim2.new(0, 8, 0, 4)
        N.BackgroundTransparency = 1
        N.Text = name
        N.TextColor3 = Config.TextPrimary
        N.TextSize = 10
        N.Font = Enum.Font.GothamBold
        N.TextXAlignment = Enum.TextXAlignment.Left
        N.Parent = Card

        local P = Instance.new("TextLabel")
        P.Size = UDim2.new(1, -10, 0, 10)
        P.Position = UDim2.new(0, 8, 0, 16)
        P.BackgroundTransparency = 1
        P.Text = string.format("%.0f, %.0f, %.0f", pos.x, pos.y, pos.z)
        P.TextColor3 = Config.TextMuted
        P.TextSize = 8
        P.Font = Enum.Font.Gotham
        P.TextXAlignment = Enum.TextXAlignment.Left
        P.Parent = Card

        local TPBtn = Instance.new("TextButton")
        TPBtn.Size = UDim2.new(0, 50, 0, 22)
        TPBtn.Position = UDim2.new(1, -110, 0.5, -11)
        TPBtn.BackgroundColor3 = Config.Accent
        TPBtn.Text = "TP"
        TPBtn.TextColor3 = Config.TextPrimary
        TPBtn.TextSize = 9
        TPBtn.Font = Enum.Font.GothamBold
        TPBtn.BorderSizePixel = 0
        TPBtn.AutoButtonColor = false
        TPBtn.Parent = Card

        local TPC = Instance.new("UICorner")
        TPC.CornerRadius = UDim.new(0, 4)
        TPC.Parent = TPBtn

        TPBtn.MouseButton1Click:Connect(function()
            if teleportToSaved(name) then
                notify("Teleported to " .. name, false)
            end
        end)

        local DBtn = Instance.new("TextButton")
        DBtn.Size = UDim2.new(0, 50, 0, 22)
        DBtn.Position = UDim2.new(1, -56, 0.5, -11)
        DBtn.BackgroundColor3 = Config.BgCard
        DBtn.Text = "DEL"
        DBtn.TextColor3 = Config.TextPrimary
        DBtn.TextSize = 9
        DBtn.Font = Enum.Font.GothamBold
        DBtn.BorderSizePixel = 0
        DBtn.AutoButtonColor = false
        DBtn.Parent = Card

        local DC = Instance.new("UICorner")
        DC.CornerRadius = UDim.new(0, 4)
        DC.Parent = DBtn

        DBtn.MouseButton1Click:Connect(function()
            deleteSavedPosition(name)
            notify("Deleted " .. name, false)
            buildSavePage()
        end)
    end

    createSection(Page, "Teleport to XYZ")
    createTextInput(Page, "Coordinates (x, y, z)", "0, 50, 0", TPInputValue, function(v)
        TPInputValue = v
    end)
    createButton(Page, "📍 Teleport to XYZ", function()
        local coords = {}
        for n in string.gmatch(TPInputValue, "[^,%s]+") do
            table.insert(coords, tonumber(n))
        end
        if #coords == 3 and coords[1] and coords[2] and coords[3] then
            if teleportToPosition(Vector3.new(coords[1], coords[2], coords[3])) then
                notify("Teleported to XYZ", false)
            end
        else
            notify("Invalid XYZ format", true)
        end
    end, true)

    createSection(Page, "Quick Actions")
    createButton(Page, "🏠 Teleport to Spawn", function()
        local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
        if spawn then
            teleportToPosition(spawn.Position + Vector3.new(0, 5, 0))
            notify("Teleported to spawn", false)
        end
    end)
    createButton(Page, "🔝 Teleport Up (+50Y)", function()
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                teleportToPosition(hrp.Position + Vector3.new(0, 50, 0))
                notify("Went up 50 studs", false)
            end
        end
    end)
end

-- ============================================================
-- PAGE BUILDER: SETTINGS
-- ============================================================
local function buildSettingsPage()
    clearPage()
    PageTitle.Text = "SETTINGS"

    createSection(Page, "Anti-Ban")
    createToggle(Page, "Anti-Ban System", State.AntiBanEnabled, function(v) State.AntiBanEnabled = v end)
    createToggle(Page, "Jitter ±2", State.JitterEnabled, function(v) State.JitterEnabled = v end)
    createToggle(Page, "Rate Limit 20Hz", State.RateLimitEnabled, function(v) State.RateLimitEnabled = v end)
    createToggle(Page, "Legit Mode (60)", State.LegitMode, function(v) State.LegitMode = v end)
    createSlider(Page, "Max Speed Cap", 50, 500, State.MaxSpeed, "WS", function(v) State.MaxSpeed = v end)

    createSection(Page, "Protection")
    createToggle(Page, "Anti-Fling", State.AntiFlingEnabled, function(v) State.AntiFlingEnabled = v end)
    createToggle(Page, "Anti-Void", State.AntiVoidEnabled, function(v) State.AntiVoidEnabled = v end)
    createToggle(Page, "Infinite Jump", State.InfJumpEnabled, function(v) State.InfJumpEnabled = v end)

    createSection(Page, "Emergency")
    createButton(Page, "🧹 Panic Cleanup", function()
        resetCharacterPhysics()
        State.SpeedEnabled = false
        State.FlyEnabled = false
        State.NoclipEnabled = false
        State.AutoSteal = false
        State.NoCooldownSteal = false
        State.InstantSteal = false
        AntiBanState.currentRampSpeed = 16
        notify("Panic cleanup executed", false)
    end, true)
    createButton(Page, "🔧 Reset Physics", function()
        resetCharacterPhysics()
        notify("Physics reset", false)
    end)

    createSection(Page, "Script")
    createButton(Page, "Rejoin Server", function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)
    createButton(Page, "Unload Script", function()
        resetCharacterPhysics()
        ScreenGui:Destroy()
    end, true)
end

-- ============================================================
-- TAB SYSTEM
-- ============================================================
local Tabs = {}
local ActiveTab = "Main"

local tabDefs = {
    {name = "Main",     icon = "⚔️", builder = buildMainPage},
    {name = "Save/TP",  icon = "📍", builder = buildSavePage},
    {name = "Settings", icon = "⚙️", builder = buildSettingsPage}
}

for i, def in ipairs(tabDefs) do
    local Tab = Instance.new("TextButton")
    Tab.Size = UDim2.new(1, -12, 0, 30)
    Tab.Position = UDim2.new(0, 6, 0, 56 + ((i - 1) * 34))
    Tab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Tab.BackgroundTransparency = 1
    Tab.Text = "  " .. def.icon .. "  " .. def.name
    Tab.TextColor3 = Config.TextSecond
    Tab.TextSize = 11
    Tab.Font = Enum.Font.GothamBold
    Tab.TextXAlignment = Enum.TextXAlignment.Left
    Tab.BorderSizePixel = 0
    Tab.AutoButtonColor = false
    Tab.Parent = Sidebar

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = Tab

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 2, 0.55, 0)
    Indicator.Position = UDim2.new(0, 0, 0.225, 0)
    Indicator.BackgroundColor3 = Config.Accent
    Indicator.BorderSizePixel = 0
    Indicator.Visible = false
    Indicator.Parent = Tab

    local ICorner = Instance.new("UICorner")
    ICorner.CornerRadius = UDim.new(1, 0)
    ICorner.Parent = Indicator

    Tabs[def.name] = {
        Button = Tab,
        Indicator = Indicator,
        builder = def.builder
    }

    Tab.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Button.BackgroundTransparency = 1
            t.Button.TextColor3 = Config.TextSecond
            t.Indicator.Visible = false
        end
        Tab.BackgroundTransparency = 0.5
        Tab.TextColor3 = Config.TextPrimary
        Indicator.Visible = true
        ActiveTab = def.name
        if def.builder then def.builder() end
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

-- Activate Main
if Tabs["Main"] then
    Tabs["Main"].Button.BackgroundTransparency = 0.5
    Tabs["Main"].Button.TextColor3 = Config.TextPrimary
    Tabs["Main"].Indicator.Visible = true
end
buildMainPage()

-- ============================================================
-- MIN / CLOSE
-- ============================================================
CloseBtn.MouseButton1Click:Connect(function()
    resetCharacterPhysics()
    ScreenGui:Destroy()
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Main.Size = UDim2.new(0, Config.Width, 0, 40)
        Sidebar.Visible = false
        Content.Visible = false
    else
        Main.Size = UDim2.new(0, Config.Width, 0, Config.Height)
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

-- ============================================================
-- SPEED HACK LOOP
-- ============================================================
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    if State.SpeedEnabled then
        if State.RateLimitEnabled then
            AntiBanState.tickCounter = (AntiBanState.tickCounter + 1) % 3
            if AntiBanState.tickCounter ~= 0 then return end
        end

        local target = State.SpeedValue
        if State.LegitMode then target = math.min(target, 60) end
        if target > State.MaxSpeed then target = State.MaxSpeed end

        if State.RampUpEnabled then
            local diff = target - AntiBanState.currentRampSpeed
            if math.abs(diff) > 0.5 then
                AntiBanState.currentRampSpeed = AntiBanState.currentRampSpeed + diff * 0.05
                target = math.floor(AntiBanState.currentRampSpeed)
            else
                AntiBanState.currentRampSpeed = target
            end
        end

        local speed = target
        if State.JitterEnabled then
            local jitter = math.random(-2, 2)
            if math.random(1, 10) == 1 then jitter = 0 end
            speed = target + jitter
        end

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
        pcall(function() hum.WalkSpeed = 16 end)
        pcall(function()
            hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
        end)
        local bv = hrp:FindFirstChild("SpeedBV")
        if bv then bv:Destroy() end
    end
end)

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
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then
                        pcall(function() p.CanCollide = false end)
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
    if State.AntiAfkEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- ============================================================
-- AUTO STEAL LOOP
-- ============================================================
task.spawn(function()
    while task.wait(0.1) do
        if State.AutoSteal then
            local nearest = findNearestSteal()
            if nearest then
                local char = LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        pcall(function()
                            hrp.CFrame = CFrame.new(nearest.part.Position + Vector3.new(0, 3, 0))
                        end)
                        fireStealPrompt(nearest.prompt)
                        if State.InstantSteal then
                            fireStealPrompt(nearest.prompt)
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- NO COOLDOWN STEAL LOOP
-- ============================================================
task.spawn(function()
    while task.wait(0.05) do
        if State.NoCooldownSteal then
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- Fire ALL steal prompts in range instantly
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") then
                            local name = string.lower(obj.Name)
                            local actionText = string.lower(obj.ActionText or "")
                            if string.find(name, "steal") or string.find(actionText, "steal")
                               or string.find(name, "egg") or string.find(name, "grab") then
                                pcall(function()
                                    obj.HoldDuration = 0
                                    obj.MaxActivationDistance = 9999
                                    obj.RequiresLineOfSight = false
                                    if fireproximityprompt then
                                        fireproximityprompt(obj)
                                    end
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
-- RESPAWN
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if flyCleanup then
        flyCleanup()
        flyConn = nil
        flyCleanup = nil
    end
    AntiBanState.currentRampSpeed = 16
end)

-- ============================================================
-- STARTUP
-- ============================================================
notify(Config.Title .. " " .. Config.Version .. " loaded", false)

print("[EXECUTE HUB] " .. Config.Version .. " loaded")
print("[EXECUTE HUB] User: " .. LocalPlayer.Name)
print("[EXECUTE HUB] Tabs: Main, Save/TP, Settings")
print("[EXECUTE HUB] Right Ctrl = toggle UI")
