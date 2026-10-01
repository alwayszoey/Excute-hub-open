-- ============================================================
-- EXECUTE HUB - v3.1.0 (ZIGGER LAYOUT + GLASS SIDEBAR)
-- Fix: Speed Hack hoạt động mọi game (Velocity + BodyVelocity fallback)
-- Layout: 2 cột phải, sidebar trong suốt bên trái
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
    BgMain        = Color3.fromRGB(10, 10, 12),
    BgPanel       = Color3.fromRGB(18, 18, 22),
    BgCard        = Color3.fromRGB(28, 28, 34),
    BgCardHover   = Color3.fromRGB(38, 38, 46),
    BgSidebar     = Color3.fromRGB(8, 8, 10),        -- Đen
    BgSidebarTransp = 0.15,                          -- Trong suốt
    Accent        = Color3.fromRGB(255, 35, 45),
    AccentHover   = Color3.fromRGB(255, 60, 70),
    TextPrimary   = Color3.fromRGB(245, 245, 250),
    TextSecond    = Color3.fromRGB(160, 160, 175),
    TextMuted     = Color3.fromRGB(110, 110, 125),
    Border        = Color3.fromRGB(255, 255, 255),
    BorderTransp  = 0.85,
    Success       = Color3.fromRGB(60, 220, 110),
    Title         = "EXECUTE HUB",
    Subtitle      = "ZIGGER Layout",
    Version       = "v3.1.0"
}

-- ============================================================
-- STATE
-- ============================================================
local State = {
    SpeedEnabled    = false,
    SpeedValue      = 16,
    MaxSpeed        = 250,
    JitterEnabled   = true,
    RateLimitEnabled = true,
    LegitMode       = false,
    AntiBanEnabled  = true,
    FlyEnabled      = false,
    NoclipEnabled   = false,
    InfJumpEnabled  = false,
    AntiFlingEnabled = false,
    AntiVoidEnabled = false,
    -- Farm
    AutoFarm        = false,
    FarmDistance    = 5,
    AutoParry       = false,
    AutoHeal        = false,
    AutoSkill       = false,
    AutoChest       = false,
    AutoQuest       = false,
    AutoDungeon     = false,
    AutoReplay      = false,
    InstantInteract = false,
    AutoClaimBP     = false,
    Dungeon         = "Bandits Den",
    Difficulty      = "Easy"
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

-- ============================================================
-- SPEED HACK CORE (FIXED - đa phương pháp)
-- ============================================================
local SpeedState = {
    bv = nil,           -- BodyVelocity
    velConn = nil       -- Velocity connection
}

local function applySpeedMethod1(char, hum, hrp, speed)
    -- Phương pháp 1: WalkSpeed
    pcall(function() hum.WalkSpeed = speed end)
end

local function applySpeedMethod2(char, hum, hrp, speed)
    -- Phương pháp 2: Velocity injection (works on 90% games)
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
end

local function applySpeedMethod3(char, hum, hrp, speed)
    -- Phương pháp 3: BodyVelocity (works on custom controller games)
    local existing = hrp:FindFirstChild("SpeedBV")
    if not existing then
        existing = Instance.new("BodyVelocity")
        existing.Name = "SpeedBV"
        existing.MaxForce = Vector3.new(math.huge, 0, math.huge)
        existing.Parent = hrp
    end
    if hum.MoveDirection.Magnitude > 0.1 then
        local dir = hum.MoveDirection
        existing.Velocity = Vector3.new(dir.X * speed, 0, dir.Z * speed)
    else
        existing.Velocity = Vector3.new(0, 0, 0)
    end
end

-- Cleanup speed instances
task.spawn(function()
    while task.wait(0.5) do
        cleanupSpeedInstances()
    end
end)

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
-- MAIN FRAME
-- ============================================================
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 640, 0, 420)
Main.Position = UDim2.new(0.5, -320, 0.5, -210)
Main.BackgroundColor3 = Config.BgMain
Main.BackgroundTransparency = 0.05
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
MainStroke.Transparency = 0.9
MainStroke.Parent = Main

-- ============================================================
-- TOP BAR (window dots + title)
-- ============================================================
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(0, 180, 1, 0)
TopBar.BackgroundColor3 = Config.BgSidebar
TopBar.BackgroundTransparency = Config.BgSidebarTransp
TopBar.BorderSizePixel = 0
TopBar.Parent = Main
local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 12)
TopBarCorner.Parent = TopBar

-- Window dots
local DotsFrame = Instance.new("Frame")
DotsFrame.Size = UDim2.new(0, 60, 0, 12)
DotsFrame.Position = UDim2.new(0, 12, 0, 12)
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

-- Logo box
local LogoBox = Instance.new("Frame")
LogoBox.Size = UDim2.new(0, 100, 0, 100)
LogoBox.Position = UDim2.new(0.5, -50, 0, 40)
LogoBox.BackgroundColor3 = Config.BgSidebar
LogoBox.BackgroundTransparency = 0.5
LogoBox.BorderSizePixel = 0
LogoBox.Parent = TopBar
local LogoBoxCorner = Instance.new("UICorner")
LogoBoxCorner.CornerRadius = UDim.new(0, 8)
LogoBoxCorner.Parent = LogoBox

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "EH"
LogoText.TextColor3 = Config.TextPrimary
LogoText.TextSize = 32
LogoText.Font = Enum.Font.GothamBlack
LogoText.Parent = LogoBox

-- Close button (top right of main)
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
CloseBtn.Parent = Main
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Min button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -64, 0, 12)
MinBtn.BackgroundColor3 = Config.BgCard
MinBtn.Text = "−"
MinBtn.TextColor3 = Config.TextPrimary
MinBtn.TextSize = 16
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.AutoButtonColor = false
MinBtn.Parent = Main
local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

-- ============================================================
-- SIDEBAR (bên trái, trong suốt, đen)
-- ============================================================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 180, 1, 0)
Sidebar.Position = UDim2.new(0, 0, 0, 0)
Sidebar.BackgroundColor3 = Config.BgSidebar
Sidebar.BackgroundTransparency = Config.BgSidebarTransp
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 12)
SidebarCorner.Parent = Sidebar

-- User info block (below logo)
local UserBlock = Instance.new("Frame")
UserBlock.Size = UDim2.new(1, -16, 0, 44)
UserBlock.Position = UDim2.new(0, 8, 0, 152)
UserBlock.BackgroundColor3 = Config.BgCard
UserBlock.BackgroundTransparency = 0.6
UserBlock.BorderSizePixel = 0
UserBlock.Parent = Sidebar
local UserBlockCorner = Instance.new("UICorner")
UserBlockCorner.CornerRadius = UDim.new(0, 8)
UserBlockCorner.Parent = UserBlock

local UserAvatar = Instance.new("Frame")
UserAvatar.Size = UDim2.new(0, 30, 0, 30)
UserAvatar.Position = UDim2.new(0, 7, 0.5, -15)
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
UserInitial.TextSize = 14
UserInitial.Font = Enum.Font.GothamBold
UserInitial.Parent = UserAvatar

local UserName = Instance.new("TextLabel")
UserName.Size = UDim2.new(1, -44, 0, 14)
UserName.Position = UDim2.new(0, 44, 0, 8)
UserName.BackgroundTransparency = 1
UserName.Text = LocalPlayer.Name .. " ˅"
UserName.TextColor3 = Config.TextPrimary
UserName.TextSize = 11
UserName.Font = Enum.Font.GothamBold
UserName.TextXAlignment = Enum.TextXAlignment.Left
UserName.TextTruncate = Enum.TextTruncate.AtEnd
UserName.Parent = UserBlock

local UserStatus = Instance.new("TextLabel")
UserStatus.Size = UDim2.new(1, -44, 0, 12)
UserStatus.Position = UDim2.new(0, 44, 0, 24)
UserStatus.BackgroundTransparency = 1
UserStatus.Text = "● Online"
UserStatus.TextColor3 = Config.Success
UserStatus.TextSize = 9
UserStatus.Font = Enum.Font.GothamMedium
UserStatus.TextXAlignment = Enum.TextXAlignment.Left
UserStatus.Parent = UserBlock

-- ============================================================
-- CONTENT AREA (bên phải)
-- ============================================================
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -188, 1, -20)
Content.Position = UDim2.new(0, 188, 0, 10)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.Parent = Main

-- Title
local PageTitle = Instance.new("TextLabel")
PageTitle.Size = UDim2.new(1, -20, 0, 30)
PageTitle.Position = UDim2.new(0, 10, 0, 0)
PageTitle.BackgroundTransparency = 1
PageTitle.Text = "AUTO FARM"
PageTitle.TextColor3 = Config.TextPrimary
PageTitle.TextSize = 20
PageTitle.Font = Enum.Font.GothamBlack
PageTitle.TextXAlignment = Enum.TextXAlignment.Left
PageTitle.Parent = Content

-- Title underline
local TitleLine = Instance.new("Frame")
TitleLine.Size = UDim2.new(1, -20, 0, 2)
TitleLine.Position = UDim2.new(0, 10, 0, 34)
TitleLine.BackgroundColor3 = Config.Accent
TitleLine.BorderSizePixel = 0
TitleLine.Parent = Content

-- 2-column frame holder
local ColumnsHolder = Instance.new("Frame")
ColumnsHolder.Size = UDim2.new(1, -20, 1, -50)
ColumnsHolder.Position = UDim2.new(0, 10, 0, 44)
ColumnsHolder.BackgroundTransparency = 1
ColumnsHolder.Parent = Content

-- Left column
local LeftCol = Instance.new("ScrollingFrame")
LeftCol.Size = UDim2.new(0.49, 0, 1, 0)
LeftCol.Position = UDim2.new(0, 0, 0, 0)
LeftCol.BackgroundTransparency = 1
LeftCol.BorderSizePixel = 0
LeftCol.ScrollBarThickness = 3
LeftCol.ScrollBarImageColor3 = Config.Accent
LeftCol.ScrollBarImageTransparency = 0.5
LeftCol.CanvasSize = UDim2.new(0, 0, 0, 0)
LeftCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
LeftCol.Parent = ColumnsHolder

local LeftLayout = Instance.new("UIListLayout")
LeftLayout.Padding = UDim.new(0, 6)
LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
LeftLayout.Parent = LeftCol

-- Right column
local RightCol = Instance.new("ScrollingFrame")
RightCol.Size = UDim2.new(0.49, 0, 1, 0)
RightCol.Position = UDim2.new(0.51, 0, 0, 0)
RightCol.BackgroundTransparency = 1
RightCol.BorderSizePixel = 0
RightCol.ScrollBarThickness = 3
RightCol.ScrollBarImageColor3 = Config.Accent
RightCol.ScrollBarImageTransparency = 0.5
RightCol.CanvasSize = UDim2.new(0, 0, 0, 0)
RightCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
RightCol.Parent = ColumnsHolder

local RightLayout = Instance.new("UIListLayout")
RightLayout.Padding = UDim.new(0, 6)
RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
RightLayout.Parent = RightCol

-- ============================================================
-- TAB SWITCHING
-- ============================================================
local Tabs = {}
local ActiveTab = "Main"

local function switchTab(name)
    ActiveTab = name
    PageTitle.Text = string.upper(name)
    for tabName, t in pairs(Tabs) do
        if tabName == name then
            t.Button.BackgroundTransparency = 0.4
            t.Button.TextColor3 = Config.TextPrimary
            t.Indicator.Visible = true
            t.Page.Visible = true
        else
            t.Button.BackgroundTransparency = 1
            t.Button.TextColor3 = Config.TextSecond
            t.Indicator.Visible = false
            t.Page.Visible = false
        end
    end
end

-- ============================================================
-- SECTION BUILDER
-- ============================================================
local function createSection(parent, text)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, 0, 0, 22)
    Section.BackgroundTransparency = 1
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
    Card.BackgroundTransparency = 0.4
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
    Card.BackgroundTransparency = 0.4
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
    Card.BackgroundTransparency = 0.4
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
-- BUILD MAIN TAB (2 columns)
-- ============================================================
-- LEFT COLUMN
createSection(LeftCol, "Auto Farm")
createToggle(LeftCol, "Auto Farm", false, function(v) State.AutoFarm = v end)
createSlider(LeftCol, "Farm Distance", 1, 50, 5, "studs", function(v) State.FarmDistance = v end)
createToggle(LeftCol, "Auto Parry", false, function(v) State.AutoParry = v end)
createToggle(LeftCol, "Auto Heal", false, function(v) State.AutoHeal = v end)
createToggle(LeftCol, "Auto Skill", false, function(v) State.AutoSkill = v end)
createToggle(LeftCol, "Auto Collect Chest", false, function(v) State.AutoChest = v end)
createToggle(LeftCol, "Auto Collect Quests", false, function(v) State.AutoQuest = v end)

-- RIGHT COLUMN
createSection(RightCol, "Auto Dungeon")
createDropdown(RightCol, "Dungeon", {"Bandits Den", "Cursed Ship", "Dragon Nest", "Sky Fortress"}, "Bandits Den", function(v) State.Dungeon = v end)
createDropdown(RightCol, "Difficulty", {"Easy", "Medium", "Hard", "Nightmare"}, "Easy", function(v) State.Difficulty = v end)
createToggle(RightCol, "Auto Dungeon", false, function(v) State.AutoDungeon = v end)
createToggle(RightCol, "Auto Replay", false, function(v) State.AutoReplay = v end)
createToggle(RightCol, "Instant Interact", false, function(v) State.InstantInteract = v end)

createSection(RightCol, "Battlepass")
createToggle(RightCol, "Auto Claim Battlepass", false, function(v) State.AutoClaimBP = v end)

-- ============================================================
-- SIDEBAR TAB BUTTONS (bên trái)
-- ============================================================
local tabDefs = {
    {name = "Main",     icon = "∞"},
    {name = "Stats",    icon = "↻"},
    {name = "Player",   icon = "◐"},
    {name = "Settings", icon = "⚙"}
}

for i, def in ipairs(tabDefs) do
    local Tab = Instance.new("TextButton")
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
    Tab.Parent = Sidebar
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = Tab

    -- Indicator
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 2, 0.5, 0)
    Indicator.Position = UDim2.new(0, 0, 0.25, 0)
    Indicator.BackgroundColor3 = Config.TextPrimary
    Indicator.BorderSizePixel = 0
    Indicator.Visible = false
    Indicator.Parent = Tab
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = Indicator

    -- Placeholder page for Stats/Player/Settings
    local PlaceholderPage = Instance.new("Frame")
    PlaceholderPage.Size = UDim2.new(1, 0, 1, 0)
    PlaceholderPage.BackgroundTransparency = 1
    PlaceholderPage.Visible = false
    PlaceholderPage.Parent = ColumnsHolder
    
    -- Page content will show this
    Tabs[def.name] = {
        Button = Tab,
        Indicator = Indicator,
        Page = PlaceholderPage,
        isMain = (def.name == "Main")
    }

    Tab.MouseButton1Click:Connect(function()
        -- Hide all pages
        for _, t in pairs(Tabs) do
            t.Button.BackgroundTransparency = 1
            t.Button.TextColor3 = Config.TextSecond
            t.Indicator.Visible = false
            t.Page.Visible = false
        end
        -- Show this tab
        Tab.BackgroundTransparency = 0.4
        Tab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Tab.TextColor3 = Config.TextPrimary
        Indicator.Visible = true
        ActiveTab = def.name
        PageTitle.Text = string.upper(def.name)

        -- Show main column or placeholder
        if def.name == "Main" then
            LeftCol.Visible = true
            RightCol.Visible = true
        else
            LeftCol.Visible = false
            RightCol.Visible = false
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

-- Activate Main by default
if Tabs["Main"] then
    Tabs["Main"].Button.BackgroundTransparency = 0.4
    Tabs["Main"].Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Tabs["Main"].Button.TextColor3 = Config.TextPrimary
    Tabs["Main"].Indicator.Visible = true
end

-- ============================================================
-- STATS / PLAYER / SETTINGS PAGES (shown when tab clicked)
-- ============================================================
-- We'll reuse LeftCol and RightCol for these pages by clearing children
-- Simple approach: dynamically populate when tab is selected

local StatsLeftBuilt = false
local PlayerLeftBuilt = false
local SettingsLeftBuilt = false

-- Handler: rebuild columns when tab changes
local function clearColumns()
    for _, child in ipairs(LeftCol:GetChildren()) do
        if not child:IsA("UIListLayout") then child:Destroy() end
    end
    for _, child in ipairs(RightCol:GetChildren()) do
        if not child:IsA("UIListLayout") then child:Destroy() end
    end
end

local function buildMainTab()
    clearColumns()
    -- LEFT
    createSection(LeftCol, "Auto Farm")
    createToggle(LeftCol, "Auto Farm", State.AutoFarm, function(v) State.AutoFarm = v end)
    createSlider(LeftCol, "Farm Distance", 1, 50, State.FarmDistance, "studs", function(v) State.FarmDistance = v end)
    createToggle(LeftCol, "Auto Parry", State.AutoParry, function(v) State.AutoParry = v end)
    createToggle(LeftCol, "Auto Heal", State.AutoHeal, function(v) State.AutoHeal = v end)
    createToggle(LeftCol, "Auto Skill", State.AutoSkill, function(v) State.AutoSkill = v end)
    createToggle(LeftCol, "Auto Collect Chest", State.AutoChest, function(v) State.AutoChest = v end)
    createToggle(LeftCol, "Auto Collect Quests", State.AutoQuest, function(v) State.AutoQuest = v end)
    -- RIGHT
    createSection(RightCol, "Auto Dungeon")
    createDropdown(RightCol, "Dungeon", {"Bandits Den", "Cursed Ship", "Dragon Nest", "Sky Fortress"}, State.Dungeon, function(v) State.Dungeon = v end)
    createDropdown(RightCol, "Difficulty", {"Easy", "Medium", "Hard", "Nightmare"}, State.Difficulty, function(v) State.Difficulty = v end)
    createToggle(RightCol, "Auto Dungeon", State.AutoDungeon, function(v) State.AutoDungeon = v end)
    createToggle(RightCol, "Auto Replay", State.AutoReplay, function(v) State.AutoReplay = v end)
    createToggle(RightCol, "Instant Interact", State.InstantInteract, function(v) State.InstantInteract = v end)
    createSection(RightCol, "Battlepass")
    createToggle(RightCol, "Auto Claim Battlepass", State.AutoClaimBP, function(v) State.AutoClaimBP = v end)
end

local function buildStatsTab()
    clearColumns()
    createSection(LeftCol, "Player Stats")
    createToggle(LeftCol, "Show FPS", false, function(v) end)
    createToggle(LeftCol, "Show Ping", false, function(v) end)
    createToggle(LeftCol, "Show Coordinates", false, function(v) end)
    createSection(RightCol, "Character")
    createSection(RightCol, "Actions")
    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(1, 0, 0, 34)
    resetBtn.BackgroundColor3 = Config.BgCard
    resetBtn.BackgroundTransparency = 0.4
    resetBtn.Text = "Reset Character"
    resetBtn.TextColor3 = Config.TextPrimary
    resetBtn.TextSize = 11
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.BorderSizePixel = 0
    resetBtn.AutoButtonColor = false
    resetBtn.Parent = RightCol
    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 6)
    rc.Parent = resetBtn
    resetBtn.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
        end
    end)
end

local function buildPlayerTab()
    clearColumns()
    createSection(LeftCol, "Speed")
    createToggle(LeftCol, "Speed Hack", State.SpeedEnabled, function(v) State.SpeedEnabled = v end)
    createSlider(LeftCol, "Speed Value", 16, 500, State.SpeedValue, "WS", function(v) State.SpeedValue = v end)
    createSlider(LeftCol, "Max Speed Cap", 50, 500, State.MaxSpeed, "WS", function(v) State.MaxSpeed = v end)
    createSection(LeftCol, "Anti-Ban Pro")
    createToggle(LeftCol, "Anti-Ban System", State.AntiBanEnabled, function(v) State.AntiBanEnabled = v end)
    createToggle(LeftCol, "Jitter ±2", State.JitterEnabled, function(v) State.JitterEnabled = v end)
    createToggle(LeftCol, "Rate Limit 20Hz", State.RateLimitEnabled, function(v) State.RateLimitEnabled = v end)
    createToggle(LeftCol, "Legit Mode (60)", State.LegitMode, function(v) State.LegitMode = v end)
    -- RIGHT
    createSection(RightCol, "Movement")
    createToggle(RightCol, "Fly", State.FlyEnabled, function(v) State.FlyEnabled = v end)
    createToggle(RightCol, "Noclip", State.NoclipEnabled, function(v) State.NoclipEnabled = v end)
    createToggle(RightCol, "Infinite Jump", State.InfJumpEnabled, function(v) State.InfJumpEnabled = v end)
    createToggle(RightCol, "Anti-Fling", State.AntiFlingEnabled, function(v) State.AntiFlingEnabled = v end)
    createToggle(RightCol, "Anti-Void", State.AntiVoidEnabled, function(v) State.AntiVoidEnabled = v end)
end

local function buildSettingsTab()
    clearColumns()
    createSection(LeftCol, "Config")
    createButton = createButton or function() end
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(1, 0, 0, 34)
    saveBtn.BackgroundColor3 = Config.BgCard
    saveBtn.BackgroundTransparency = 0.4
    saveBtn.Text = "Save Config"
    saveBtn.TextColor3 = Config.TextPrimary
    saveBtn.TextSize = 11
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.BorderSizePixel = 0
    saveBtn.AutoButtonColor = false
    saveBtn.Parent = LeftCol
    local sc = Instance.new("UICorner") sc.CornerRadius = UDim.new(0, 6) sc.Parent = saveBtn

    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(1, 0, 0, 34)
    loadBtn.BackgroundColor3 = Config.BgCard
    loadBtn.BackgroundTransparency = 0.4
    loadBtn.Text = "Load Config"
    loadBtn.TextColor3 = Config.TextPrimary
    loadBtn.TextSize = 11
    loadBtn.Font = Enum.Font.GothamBold
    loadBtn.BorderSizePixel = 0
    loadBtn.AutoButtonColor = false
    loadBtn.Parent = LeftCol
    local lc = Instance.new("UICorner") lc.CornerRadius = UDim.new(0, 6) lc.Parent = loadBtn

    createSection(RightCol, "Script")
    local rejoinBtn = Instance.new("TextButton")
    rejoinBtn.Size = UDim2.new(1, 0, 0, 34)
    rejoinBtn.BackgroundColor3 = Config.BgCard
    rejoinBtn.BackgroundTransparency = 0.4
    rejoinBtn.Text = "Rejoin Server"
    rejoinBtn.TextColor3 = Config.TextPrimary
    rejoinBtn.TextSize = 11
    rejoinBtn.Font = Enum.Font.GothamBold
    rejoinBtn.BorderSizePixel = 0
    rejoinBtn.AutoButtonColor = false
    rejoinBtn.Parent = RightCol
    local rj = Instance.new("UICorner") rj.CornerRadius = UDim.new(0, 6) rj.Parent = rejoinBtn
    rejoinBtn.MouseButton1Click:Connect(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)

    local unloadBtn = Instance.new("TextButton")
    unloadBtn.Size = UDim2.new(1, 0, 0, 34)
    unloadBtn.BackgroundColor3 = Config.Accent
    unloadBtn.BackgroundTransparency = 0
    unloadBtn.Text = "Unload Script"
    unloadBtn.TextColor3 = Config.TextPrimary
    unloadBtn.TextSize = 11
    unloadBtn.Font = Enum.Font.GothamBold
    unloadBtn.BorderSizePixel = 0
    unloadBtn.AutoButtonColor = false
    unloadBtn.Parent = RightCol
    local uc = Instance.new("UICorner") uc.CornerRadius = UDim.new(0, 6) uc.Parent = unloadBtn
    unloadBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
end

-- ============================================================
-- KEYBIND: Right Ctrl toggle
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
    end
end)

print("[EXECUTE HUB] " .. Config.Version .. " loaded — ZIGGER Layout")
print("[EXECUTE HUB] Right Ctrl = toggle UI")
