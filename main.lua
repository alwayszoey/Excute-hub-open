-- ============================================================
-- EXECUTE HUB - v1.0.7 ANTI-BAN + SPEED FIX
-- Fix: nhân vật di chuyển khi thả phím (BodyVelocity leak)
-- Anti-Flag: SafeMode mặc định, cleanup tự động
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
    Version     = "v1.0.7"
}

-- ============================================================
-- STATE
-- ============================================================
local State = {
    SpeedEnabled     = false,
    SpeedValue       = 16,
    AntiFlingEnabled = false,
    AntiVoidEnabled  = false,
    FlyEnabled       = false,
    NoclipEnabled    = false,
    InfJumpEnabled   = false,
    NpcIgnoreEnabled = false,
    NoCollideEnabled = false,
    AntiAfkEnabled   = true,
    AntiFlagEnabled  = true,
    SafeMode         = true     -- true = tránh bị flag, false = speed mạnh
}

-- ============================================================
-- CLEANUP OLD
-- ============================================================
pcall(function()
    if CoreGui:FindFirstChild("ExecuteHub") then CoreGui.ExecuteHub:Destroy() end
end)
pcall(function()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg and pg:FindFirstChild("ExecuteHub") then pg.ExecuteHub:Destroy() end
end)

-- ============================================================
-- CLEANUP HELPER - xóa mọi instance script tạo
-- ============================================================
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

-- ============================================================
-- MAIN FRAME
-- ============================================================
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 560, 0, 440)
Main.Position = UDim2.new(0.5, -280, 0.5, -220)
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

-- ============================================================
-- TOP BAR
-- ============================================================
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
SubTitle.Text = Config.Version .. "  •  Anti-Ban Mode"
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

-- ============================================================
-- SIDEBAR
-- ============================================================
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

-- ============================================================
-- CONTENT
-- ============================================================
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
    Tab.Size = UDim2.new(1, -12, 0, 42)
    Tab.Position = UDim2.new(0, 6, 0, (index * 48) + 10)
    Tab.BackgroundColor3 = Config.PanelColor
    Tab.Text = name
    Tab.TextColor3 = Config.TextDim
    Tab.TextSize = 14
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
    T.Size = UDim2.new(1, 0, 0, 46)
    T.BackgroundColor3 = Config.CardColor
    T.BorderSizePixel = 0
    T.Parent = parent
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 10)
    TCorner.Parent = T

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Config.BorderColor
    Stroke.Thickness = 1
    Stroke.Transparency = 0.5
    Stroke.Parent = T

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -90, 1, 0)
    Label.Position = UDim2.new(0, 16, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Config.TextColor
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = T

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0, 48, 0, 24)
    Toggle.Position = UDim2.new(1, -62, 0.5, -12)
    Toggle.BackgroundColor3 = default and Config.Accent or Config.BorderColor
    Toggle.Text = ""
    Toggle.BorderSizePixel = 0
    Toggle.AutoButtonColor = false
    Toggle.Parent = T
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = Toggle

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 18, 0, 18)
    Circle.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
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
            Position = isOn and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        }):Play()
        if callback then callback(isOn) end
    end)
    return T
end

local function createSlider(parent, text, min, max, default, callback)
    local S = Instance.new("Frame")
    S.Size = UDim2.new(1, 0, 0, 70)
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
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = S

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 60, 0, 20)
    ValueLabel.Position = UDim2.new(1, -76, 0, 10)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Config.Accent
    ValueLabel.TextSize = 14
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = S

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -32, 0, 6)
    Bar.Position = UDim2.new(0, 16, 0, 48)
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

    local DotInner = Instance.new("Frame")
    DotInner.Size = UDim2.new(1, -6, 1, -6)
    DotInner.Position = UDim2.new(0, 3, 0, 3)
    DotInner.BackgroundColor3 = Config.TextColor
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
    B.Size = UDim2.new(1, 0, 0, 46)
    B.BackgroundColor3 = Config.CardColor
    B.Text = text
    B.TextColor3 = Config.TextColor
    B.TextSize = 14
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
-- TABS
-- ============================================================
local MainPage = createTab("Main")
createToggle(MainPage, "Speed Hack", false, function(on) State.SpeedEnabled = on end)
createSlider(MainPage, "Speed Value", 16, 300, 16, function(v) State.SpeedValue = v end)
createToggle(MainPage, "Anti-Fling", false, function(on) State.AntiFlingEnabled = on end)
createToggle(MainPage, "Anti-Void", false, function(on) State.AntiVoidEnabled = on end)

local MovePage = createTab("Movement")
createToggle(MovePage, "Fly", false, function(on) State.FlyEnabled = on end)
createToggle(MovePage, "Noclip", false, function(on) State.NoclipEnabled = on end)
createToggle(MovePage, "Infinite Jump", false, function(on) State.InfJumpEnabled = on end)

local UniversalPage = createTab("Universal")
createToggle(UniversalPage, "NPC Ignore", false, function(on) State.NpcIgnoreEnabled = on end)
createToggle(UniversalPage, "No Collide Players", false, function(on) State.NoCollideEnabled = on end)
createToggle(UniversalPage, "Anti-AFK", true, function(on) State.AntiAfkEnabled = on end)

local AntiBanPage = createTab("Anti-Ban")
createToggle(AntiBanPage, "Safe Mode (khuyến nghị)", true, function(on) State.SafeMode = on end)
createButton(AntiBanPage, "Panic Cleanup", function()
    resetCharacterPhysics()
    State.SpeedEnabled = false
    State.FlyEnabled = false
    State.NoclipEnabled = false
    State.AntiFlingEnabled = false
    State.AntiVoidEnabled = false
    State.NpcIgnoreEnabled = false
    State.NoCollideEnabled = false
    print("[ANTI-BAN] Panic cleanup executed")
end)
createButton(AntiBanPage, "Reset Physics", function()
    resetCharacterPhysics()
    print("[ANTI-BAN] Physics reset — WalkSpeed = 16, JumpPower = 50")
end)

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
if Tabs["Main"] then
    Tabs["Main"].Button.BackgroundColor3 = Config.CardColor
    Tabs["Main"].Button.TextColor3 = Config.Accent
    Tabs["Main"].Page.Visible = true
    Tabs["Main"].Indicator.Visible = true
end

-- ============================================================
-- SPEED HACK - FIXED (không dùng BodyVelocity nữa)
-- ============================================================
-- VẤN ĐỀ CŨ: BodyVelocity giữ nhân vật di chuyển mãi sau khi thả phím
-- NGUYÊN NHÂN: BodyVelocity không tự hủy khi MoveDirection = 0
-- FIX: Chỉ dùng Velocity injection (tự reset khi thả phím)
--      + Destroy mọi BodyVelocity cũ khi bật/tắt

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    if State.SpeedEnabled then
        local v = State.SpeedValue

        -- Safe Mode: giới hạn tốc độ
        if State.SafeMode and v > 100 then
            v = 100
        end

        -- Randomize ± 2 để tránh pattern detection
        v = v + math.random(-2, 2)

        -- Set WalkSpeed (cơ bản)
        pcall(function() hum.WalkSpeed = v end)

        -- Velocity injection: CHỈ khi đang di chuyển
        -- Khi thả phím → MoveDirection = 0 → Velocity không được set → nhân vật dừng
        if hum.MoveDirection.Magnitude > 0.1 then
            local dir = hum.MoveDirection
            pcall(function()
                hrp.Velocity = Vector3.new(dir.X * v, hrp.Velocity.Y, dir.Z * v)
            end)
        else
            -- Khi thả phím → reset velocity ngang về 0
            pcall(function()
                hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
            end)
        end
    else
        -- Khi tắt Speed Hack → đảm bảo Velocity được reset
        pcall(function()
            hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
        end)
    end
end)

-- ============================================================
-- CLEANUP LOOP - xóa mọi BodyVelocity leak mỗi 0.5s
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
        if State.AntiFlagEnabled then
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
-- NPC IGNORE
-- ============================================================
task.spawn(function()
    while task.wait(2) do
        if State.NpcIgnoreEnabled then
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) then
                        if obj.Name ~= LocalPlayer.Name and obj.Name ~= "Camera" then
                            for _, part in ipairs(obj:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    pcall(function()
                                        part.CanCollide = false
                                        part.CanTouch = false
                                        part.CanQuery = false
                                    end)
                                elseif part:IsA("Humanoid") then
                                    pcall(function()
                                        part.Health = 0
                                        part:ChangeState(Enum.HumanoidStateType.Dead)
                                    end)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- NO COLLIDE PLAYERS
-- ============================================================
task.spawn(function()
    while task.wait(0.5) do
        if State.NoCollideEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    for _, part in ipairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            pcall(function() part.CanCollide = false end)
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- FLY - FIXED (destroy BodyVelocity khi tắt)
-- ============================================================
local flyConn = nil
local flyCleanup = nil

local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    -- Xóa BV cũ nếu có
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
        if flyConn then
            flyConn:Disconnect()
            flyConn = nil
        end
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
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

-- ============================================================
-- ANTI-AFK
-- ============================================================
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    if State.AntiAfkEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- ============================================================
-- CHARACTER RESPAWN CLEANUP
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    -- Reset state khi respawn
    if flyCleanup then
        flyCleanup()
        flyConn = nil
        flyCleanup = nil
    end
    if State.SpeedEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = State.SpeedValue end
        end
    end
end)

-- ============================================================
-- BUTTONS
-- ============================================================
CloseBtn.MouseButton1Click:Connect(function()
    resetCharacterPhysics()
    ScreenGui:Destroy()
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Main.Size = minimized and UDim2.new(0, 560, 0, 60) or UDim2.new(0, 560, 0, 440)
    Sidebar.Visible = not minimized
    Content.Visible = not minimized
end)

-- ============================================================
-- KEYBIND
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
    end
end)

print("[EXECUTE HUB] v1.0.7 loaded — Anti-Ban + Speed Fix")
