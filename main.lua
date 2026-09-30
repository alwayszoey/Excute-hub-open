-- ============================================================
-- EXECUTE HUB - UNIVERSAL ROBLOX SCRIPT (RED/BLACK THEME FIXED)
-- Ngôn ngữ: Lua (Roblox Executor)
-- Theme: Đen - Đỏ (Black/Red) - ĐÃ SỬA
-- Logo: https://i.postimg.cc/kGmZ8sZx/Untitled14-20260930231234.png
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

--// CONFIG - ĐEN ĐỎ
local CONFIG = {
    Theme = {
        Background   = Color3.fromRGB(10, 10, 10),      -- Đen tuyền
        Panel        = Color3.fromRGB(20, 20, 20),      -- Đen panel
        Secondary    = Color3.fromRGB(28, 28, 28),      -- Xám đen
        Accent       = Color3.fromRGB(230, 30, 30),     -- Đỏ tươi
        AccentHover  = Color3.fromRGB(255, 60, 60),     -- Đỏ sáng
        AccentDark   = Color3.fromRGB(160, 15, 15),     -- Đỏ tối
        Text         = Color3.fromRGB(245, 245, 245),   -- Trắng
        TextDim      = Color3.fromRGB(150, 150, 150),   -- Xám
        Border       = Color3.fromRGB(45, 45, 45),      -- Viền xám
        Danger       = Color3.fromRGB(255, 0, 0)        -- Đỏ nguy hiểm
    },
    Logo = "https://i.postimg.cc/kGmZ8sZx/Untitled14-20260930231234.png",
    Title = "EXECUTE HUB",
    Version = "v1.0.0",
    DefaultSpeed = 16,
    MaxSpeed = 500
}

local State = {
    SpeedEnabled = false,
    SpeedValue = CONFIG.DefaultSpeed,
    AntiFlingEnabled = false,
    AntiVoidEnabled = false,
    FlyEnabled = false,
    NoclipEnabled = false,
    InfiniteJumpEnabled = false
}

--// UTILS
local function getCharacter() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
local function getHRP() return getCharacter():FindFirstChild("HumanoidRootPart") end
local function getHumanoid() return getCharacter():FindFirstChildOfClass("Humanoid") end

--// CLEAN
pcall(function()
    if CoreGui:FindFirstChild("ExecuteHub") then CoreGui.ExecuteHub:Destroy() end
end)
pcall(function()
    if LocalPlayer.PlayerGui:FindFirstChild("ExecuteHub") then LocalPlayer.PlayerGui.ExecuteHub:Destroy() end
end)

--// GUI ROOT
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExecuteHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.SỀibling
pcall(function() ScreenGui.Parent =N CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

--// MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 540, 0, 380)
MainFrame.Position = UDim2.new(0.5, -270, 0.5, -190)
MainFrame.BackgroundColor3 = CONFIG.Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = CONFIG.Theme.Accent
MainStroke.Thickness = 2
MainStroke.Transparency = 0.3
MainStroke.Parent = MainFrame

--// GLOW EFFECT ĐỎ
local Glow = Instance.new("Frame")
Glow.Size = UDim2.new(1, 0, 1, 0)
Glow.Position = UDim2.new(0, 0, 0, 0)
Glow.BackgroundColor3 = CONFIG.Theme.Accent
Glow.BackgroundTransparency = 0.92
Glow.BorderSizePixel = 0
Glow.ZIndex = 0
Glow.Parent = MainFrame
Instance.new("UICorner", Glow).CornerRadius = UDim.new(0, 14)

--// TOP BAR
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 52)
TopBar.BackgroundColor3 = CONFIG.Theme.Panel
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 14)

local TopCover = Instance.new("Frame")
TopCover.Size = UDim2.new(1, 0, 0, 20)
TopCover.Position = UDim2.new(0, 0, 1, -20)
TopCover.BackgroundColor3 = CONFIG.Theme.Panel
TopCover.BorderSizePixel = 0
TopCover.Parent = TopBar

--// LOGO VỚI VI ĐỎ
local LogoFrame = Instance.new("Frame")
LogoFrame.Size = UDim2.new(0, 40, 0, 40)
LogoFrame.Position = UDim2.new(0, 10, 0.5, -20)
LogoFrame.BackgroundColor3 = CONFIG.Theme.Accent
LogoFrame.BorderSizePixel = 0
LogoFrame.Parent = TopBar
Instance.new("UICorner", LogoFrame).CornerRadius = UDim.new(0, 8)

local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(1, -4, 1, -4)
Logo.Position = UDim2.new(0, 2, 0, 2)
Logo.BackgroundTransparency = 1
Logo.Image = CONFIG.Logo
Logo.Parent = LogoFrame
Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 6)

--// TITLE
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 250, 0, 26)
Title.Position = UDim2.new(0, 60, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = CONFIG.Title
Title.TextColor3 = CONFIG.Theme.Accent
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(0, 250, 0, 14)
SubTitle.Position = UDim2.new(0, 60, 0, 30)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = CONFIG.Version .. "  •  Universal  •  Red Edition"
SubTitle.TextColor3 = CONFIG.Theme.TextDim
SubTitle.TextSize = 11
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = TopBar

--// MINIMIZE
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -72, 0.5, -15)
MinBtn.BackgroundColor3 = CONFIG.Theme.Secondary
MinBtn.Text = "—"
MinBtn.TextColor3 = CONFIG.Theme.Text
MinBtn.TextSize = 18
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TopBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

--// CLOSE
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -15)
CloseBtn.BackgroundColor3 = CONFIG.Theme.Accent
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = CONFIG.Theme.Text
CloseBtn.TextSize = 15
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

--// HOVER EFFECT CHO CLOSE
CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.Theme.AccentHover}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.Theme.Accent}):Play()
end)

--// SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 145, 1, -64)
Sidebar.Position = UDim2.new(0, 0, 0, 52)
Sidebar.BackgroundColor3 = CONFIG.Theme.Panel
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

--// RED LINE PHÂN CÁCH
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0, 2, 1, -10)
Divider.Position = UDim2.new(1, -2, 0, 5)
Divider.BackgroundColor3 = CONFIG.Theme.Accent
Divider.BorderSizePixel = 0
Divider.Parent = Sidebar

--// CONTENT
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -150, 1, -64)
Content.Position = UDim2.new(0, 148, 0, 52)
Content.BackgroundColor3 = CONFIG.Theme.Background
Content.BorderSizePixel = 0
Content.Parent = MainFrame

--// TAB SYSTEM
local Tabs = {}
local ActiveTab = nil

local function createTab(name, icon)
    local Tab = Instance.new("TextButton")
    Tab.Size = UDim2.new(1, -10, 0, 38)
    Tab.Position = UDim2.new(0, 5, 0, (#Tabs * 44) + 8)
    Tab.BackgroundColor3 = CONFIG.Theme.Panel
    Tab.Text = "   " .. icon .. "   " .. name
    Tab.TextColor3 = CONFIG.Theme.TextDim
    Tab.TextSize = 13
    Tab.Font = Enum.Font.GothamMedium
    Tab.TextXAlignment = Enum.TextXAlignment.Left
    Tab.BorderSizePixel = 0
    Tab.Parent = Sidebar
    Instance.new("UICorner", Tab).CornerRadius = UDim.new(0, 8)

    -- RED BAR CHỈ BÁO ACTIVE
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 3, 0.6, 0)
    Indicator.Position = UDim2.new(0, 0, 0.2, 0)
    Indicator.BackgroundColor3 = CONFIG.Theme.Accent
    Indicator.BorderSizePixel = 0
    Indicator.Visible = false
    Indicator.Parent = Tab
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = CONFIG.Theme.Accent
    Page.Visible = false
    Page.Parent = Content

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Page

    local Padding = Instance.new("UIPadding")
    Padding.PaddingTop = UDim.new(0, 10)
    Padding.PaddingLeft = UDim.new(0, 8)
    Padding.PaddingRight = UDim.new(0, 8)
    Padding.Parent = Page

    Tabs[name] = { Button = Tab, Page = Page, Indicator = Indicator }

    Tab.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Button.BackgroundColor3 = CONFIG.Theme.Panel
            t.Button.TextColor3 = CONFIG.Theme.TextDim
            t.Page.Visible = false
            t.Indicator.Visible = false
        end
        Tab.BackgroundColor3 = CONFIG.Theme.Secondary
        Tab.TextColor3 = CONFIG.Theme.Accent
        Page.Visible = true
        Indicator.Visible = true
        ActiveTab = name
    end)

    -- HOVER
    Tab.MouseEnter:Connect(function()
        if ActiveTab ~= name then
            TweenService:Create(Tab, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.Theme.Secondary}):Play()
        end
    end)
    Tab.MouseLeave:Connect(function()
        if ActiveTab ~= name then
            TweenService:Create(Tab, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.Theme.Panel}):Play()
        end
    end)

    return Page
end

--// TOGGLE - ĐỎ ĐEN
local function createToggle(parent, text, default, callback)
    local Toggle = Instance.new("Frame")
    Toggle.Size = UDim2.new(1, 0, 0, 42)
    Toggle.BackgroundColor3 = CONFIG.Theme.Panel
    Toggle.BorderSizePixel = 0
    Toggle.Parent = parent
    Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 8)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = CONFIG.Theme.Border
    Stroke.Thickness = 1
    Stroke.Parent = Toggle

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -80, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = CONFIG.Theme.Text
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Toggle

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 46, 0, 24)
    ToggleBtn.Position = UDim2.new(1, -58, 0.5, -12)
    ToggleBtn.BackgroundColor3 = default and CONFIG.Theme.Accent or CONFIG.Theme.Border
    ToggleBtn.Text = ""
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = Toggle
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 18, 0, 18)
    Circle.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    Circle.BackgroundColor3 = CONFIG.Theme.Text
    Circle.BorderSizePixel = 0
    Circle.Parent = ToggleBtn
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

    local isOn = default

    ToggleBtn.MouseButton1Click:Connect(function()
        isOn = not isOn
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = isOn and CONFIG.Theme.Accent or CONFIG.Theme.Border
        }):Play()
        TweenService:Create(Circle, TweenInfo.new(0.2), {
            Position = isOn and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        }):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.2), {
            Color = isOn and CONFIG.Theme.Accent or CONFIG.Theme.Border
        }):Play()
        if callback then callback(isOn) end
    end)

    return Toggle
end

--// SLIDER - ĐỎ ĐEN
local function createSlider(parent, text, min, max, default, callback)
    local Slider = Instance.new("Frame")
    Slider.Size = UDim2.new(1, 0, 0, 60)
    Slider.BackgroundColor3 = CONFIG.Theme.Panel
    Slider.BorderSizePixel = 0
    Slider.Parent = parent
    Instance.new("UICorner", Slider).CornerRadius = UDim.new(0, 8)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = CONFIG.Theme.Border
    Stroke.Thickness = 1
    Stroke.Parent = Slider

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -80, 0, 20)
    Label.Position = UDim2.new(0, 14, 0, 8)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = CONFIG.Theme.Text
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Slider

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 60, 0, 20)
    ValueLabel.Position = UDim2.new(1, -70, 0, 8)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = CONFIG.Theme.Accent
    ValueLabel.TextSize = 13
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Slider

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -28, 0, 6)
    SliderBar.Position = UDim2.new(0, 14, 0, 42)
    SliderBar.BackgroundColor3 = CONFIG.Theme.Border
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = Slider
    Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = CONFIG.Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = SliderBar
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 16, 0, 16)
    Dot.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    Dot.BackgroundColor3 = CONFIG.Theme.Accent
    Dot.BorderSizePixel = 0
    Dot.Parent = SliderBar
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

    local DotInner = Instance.new("Frame")
    DotInner.Size = UDim2.new(1, -6, 1, -6)
    DotInner.Position = UDim2.new(0, 3, 0, 3)
    DotInner.BackgroundColor3 = CONFIG.Theme.Text
    DotInner.BorderSizePixel = 0
    DotInner.Parent = Dot
    Instance.new("UICorner", DotInner).CornerRadius = UDim.new(1, 0)

    local dragging = false

    local function updateValue(input)
        local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
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
            updateValue(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return Slider
end

--// BUTTON - ĐỎ ĐEN
local function createButton(parent, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 42)
    Button.BackgroundColor3 = CONFIG.Theme.Panel
    Button.Text = text
    Button.TextColor3 = CONFIG.Theme.Text
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamMedium
    Button.BorderSizePixel = 0
    Button.Parent = parent
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = CONFIG.Theme.Border
    Stroke.Thickness = 1
    Stroke.Parent = Button

    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.Theme.Accent}):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.15), {Color = CONFIG.Theme.AccentHover}):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.Theme.Panel}):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.15), {Color = CONFIG.Theme.Border}):Play()
    end)

    Button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return Button
end

--// TABS
local MainPage = createTab("Main", "🏠")
createToggle(MainPage, "Speed Hack", false, function(on) State.SpeedEnabled = on end)
createSlider(MainPage, "Speed Value", 16, CONFIG.MaxSpeed, CONFIG.DefaultSpeed, function(v) State.SpeedValue = v end)
createToggle(MainPage, "Anti-Fling", false, function(on) State.AntiFlingEnabled = on end)
createToggle(MainPage, "Anti-Void", false, function(on) State.AntiVoidEnabled = on end)

local MovePage = createTab("Movement", "🏃")
createToggle(MovePage, "Fly", false, function(on) State.FlyEnabled = on end)
createToggle(MovePage, "Noclip", false, function(on) State.NoclipEnabled = on end)
createToggle(MovePage, "Infinite Jump", false, function(on) State.InfiniteJumpEnabled = on end)

local SettingsPage = createTab("Settings", "⚙️")
createButton(SettingsPage, "Reset Character", function()
    local char = getCharacter()
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end
end)
createButton(SettingsPage, "Unload Script", function() ScreenGui:Destroy() end)

--// LOGIC
RunService.Heartbeat:Connect(function()
    if State.SpeedEnabled then
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = State.SpeedValue end
    end
end)

RunService.Heartbeat:Connect(function()
    if State.AntiFlingEnabled then
        local hrp = getHRP()
        if hrp then
            hrp.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 1, 1)
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if State.AntiVoidEnabled then
        local hrp = getHRP()
        if hrp and hrp.Position.Y < -50 then
            hrp.CFrame = CFrame.new(0, 50, 0)
        end
    end
end)

RunService.Stepped:Connect(function()
    if State.NoclipEnabled then
        local char = getCharacter()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

--// FLY
local flyConn = nil
local flyCleanup = nil

local function startFly()
    local hrp = getHRP()
    local hum = getHumanoid()
    if not hrp or not hum then return end

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 10000
    bg.D = 500
    bg.Parent = hrp

    hum.PlatformStand = true

    flyConn = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
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
        if flyConn then flyConn:Disconnect() end
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
        if hum then hum.PlatformStand = false end
    end
end

RunService.Heartbeat:Connect(function()
    if State.FlyEnabled and not flyConn then
        startFly()
    elseif not State.FlyEnabled and flyConn then
        if flyCleanup then flyCleanup() end
        flyConn = nil
        flyCleanup = nil
    end
end)

UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJumpEnabled then
        local hum = getHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if State.SpeedEnabled then
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = State.SpeedValue end
    end
end)

--// KEYBIND
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    MainFrame.Size = minimized and UDim2.new(0, 540, 0, 52) or UDim2.new(0, 540, 0, 380)
    Sidebar.Visible = not minimized
    Content.Visible = not minimized
end)

--// DEFAULT TAB
Tabs["Main"].Button.BackgroundColor3 = CONFIG.Theme.Secondary
Tabs["Main"].Button.TextColor3 = CONFIG.Theme.Accent
Tabs["Main"].Page.Visible = true
Tabs["Main"].Indicator.Visible = true
ActiveTab = "Main"

--// NOTIFICATION ĐỎ
local Notif = Instance.new("Frame")
Notif.Size = UDim2.new(0, 320, 0, 54)
Notif.Position = UDim2.new(0.5, -160, 0, 20)
Notif.BackgroundColor3 = CONFIG.Theme.Panel
Notif.BorderSizePixel = 0
Notif.Parent = ScreenGui
Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 10)

local NotifStroke = Instance.new("UIStroke")
NotifStroke.Color = CONFIG.Theme.Accent
NotifStroke.Thickness = 2
NotifStroke.Parent = Notif

local NotifText = Instance.new("TextLabel")
NotifText.Size = UDim2.new(1, -20, 1, 0)
NotifText.Position = UDim2.new(0, 10, 0, 0)
NotifText.BackgroundTransparency = 1
NotifText.Text = "✅ Execute Hub đã load - Red Edition"
NotifText.TextColor3 = CONFIG.Theme.Accent
NotifText.TextSize = 13
NotifText.Font = Enum.Font.GothamBold
NotifText.Parent = Notif

task.wait(3)
TweenService:Create(Notif, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
TweenService:Create(NotifText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
TweenService:Create(NotifStroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
task.wait(0.5)
Notif:Destroy()

print("[EXECUTE HUB] Red Edition loaded v" .. CONFIG.Version)
print("[EXECUTE HUB] Right Ctrl = toggle UI")
