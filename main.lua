-- ============================================================
-- EXECUTE HUB - MINIMAL FIX (v1.0.3)
-- Loại bỏ mọi dependency ngoài: không ảnh, không font custom
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

--// CLEAN
pcall(function()
    if CoreGui:FindFirstChild("ExecuteHub") then CoreGui.ExecuteHub:Destroy() end
end)
pcall(function()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg and pg:FindFirstChild("ExecuteHub") then pg.ExecuteHub:Destroy() end
end)

--// STATE
local State = {
    SpeedEnabled = false,
    SpeedValue = 16,
    AntiFlingEnabled = false,
    AntiVoidEnabled = false,
    FlyEnabled = false,
    NoclipEnabled = false,
    InfiniteJumpEnabled = false
}

--// GUI
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

--// MAIN
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 560, 0, 400)
Main.Position = UDim2.new(0.5, -280, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 30, 39)
MainStroke.Thickness = 2
MainStroke.Parent = Main

--// TOP BAR (KHÔNG LOGO IMAGE — dùng Frame đỏ + Text)
local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 60)
Top.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Top.BorderSizePixel = 0
Top.Parent = Main
local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 14)
TopCorner.Parent = Top

local TopCover = Instance.new("Frame")
TopCover.Size = UDim2.new(1, 0, 0, 22)
TopCover.Position = UDim2.new(0, 0, 1, -22)
TopCover.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TopCover.BorderSizePixel = 0
TopCover.Parent = Top

-- Logo = ô đỏ + chữ "EH" thay vì ảnh
local LogoBox = Instance.new("Frame")
LogoBox.Size = UDim2.new(0, 44, 0, 44)
LogoBox.Position = UDim2.new(0, 12, 0.5, -22)
LogoBox.BackgroundColor3 = Color3.fromRGB(255, 30, 39)
LogoBox.BorderSizePixel = 0
LogoBox.Parent = Top
local LogoBoxCorner = Instance.new("UICorner")
LogoBoxCorner.CornerRadius = UDim.new(0, 10)
LogoBoxCorner.Parent = LogoBox

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "EH"
LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoText.TextSize = 20
LogoText.Font = Enum.Font.GothamBold
LogoText.Parent = LogoBox

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 320, 0, 26)
Title.Position = UDim2.new(0, 68, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "EXECUTE HUB"
Title.TextColor3 = Color3.fromRGB(255, 30, 39)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(0, 320, 0, 14)
SubTitle.Position = UDim2.new(0, 68, 0, 34)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "v1.0.3  •  Universal  •  Red Edition"
SubTitle.TextColor3 = Color3.fromRGB(170, 170, 180)
SubTitle.TextSize = 11
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = Top

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 30, 39)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Top
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- Min
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -76, 0.5, -16)
MinBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 18
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.Parent = Top
local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinBtn

--// SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, -72)
Sidebar.Position = UDim2.new(0, 0, 0, 60)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

--// CONTENT
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -160, 1, -72)
Content.Position = UDim2.new(0, 158, 0, 60)
Content.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Content.BorderSizePixel = 0
Content.Parent = Main

--// TAB SYSTEM
local Tabs = {}
local ActiveTab = nil

local function createTab(name)
    local tabIndex = 0
    for _ in pairs(Tabs) do tabIndex = tabIndex + 1 end

    local Tab = Instance.new("TextButton")
    Tab.Size = UDim2.new(1, -12, 0, 40)
    Tab.Position = UDim2.new(0, 6, 0, (tabIndex * 46) + 10)
    Tab.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Tab.Text = name
    Tab.TextColor3 = Color3.fromRGB(170, 170, 180)
    Tab.TextSize = 14
    Tab.Font = Enum.Font.GothamBold
    Tab.BorderSizePixel = 0
    Tab.AutoButtonColor = false
    Tab.Parent = Sidebar
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 8)
    tc.Parent = Tab

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Color3.fromRGB(255, 30, 39)
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 500)
    Page.Parent = Content

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Page

    local Pad = Instance.new("UIPadding")
    Pad.PaddingTop = UDim.new(0, 10)
    Pad.PaddingLeft = UDim.new(0, 10)
    Pad.PaddingRight = UDim.new(0, 10)
    Pad.Parent = Page

    Tabs[name] = { Button = Tab, Page = Page }

    Tab.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            t.Button.TextColor3 = Color3.fromRGB(170, 170, 180)
            t.Page.Visible = false
        end
        Tab.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        Tab.TextColor3 = Color3.fromRGB(255, 30, 39)
        Page.Visible = true
        ActiveTab = name
    end)

    return Page
end

--// TOGGLE
local function createToggle(parent, text, default, callback)
    local T = Instance.new("Frame")
    T.Size = UDim2.new(1, 0, 0, 46)
    T.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    T.BorderSizePixel = 0
    T.Parent = parent
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 10)
    tc.Parent = T

    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -90, 1, 0)
    L.Position = UDim2.new(0, 16, 0, 0)
    L.BackgroundTransparency = 1
    L.Text = text
    L.TextColor3 = Color3.fromRGB(255, 255, 255)
    L.TextSize = 14
    L.Font = Enum.Font.GothamBold
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = T

    local B = Instance.new("TextButton")
    B.Size = UDim2.new(0, 48, 0, 24)
    B.Position = UDim2.new(1, -62, 0.5, -12)
    B.BackgroundColor3 = default and Color3.fromRGB(255, 30, 39) or Color3.fromRGB(70, 70, 80)
    B.Text = ""
    B.BorderSizePixel = 0
    B.AutoButtonColor = false
    B.Parent = T
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(1, 0)
    bc.Parent = B

    local C = Instance.new("Frame")
    C.Size = UDim2.new(0, 18, 0, 18)
    C.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    C.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    C.BorderSizePixel = 0
    C.Parent = B
    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(1, 0)
    cc.Parent = C

    local isOn = default
    B.MouseButton1Click:Connect(function()
        isOn = not isOn
        TweenService:Create(B, TweenInfo.new(0.2), {
            BackgroundColor3 = isOn and Color3.fromRGB(255, 30, 39) or Color3.fromRGB(70, 70, 80)
        }):Play()
        TweenService:Create(C, TweenInfo.new(0.2), {
            Position = isOn and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        }):Play()
        if callback then callback(isOn) end
    end)

    return T
end

--// SLIDER
local function createSlider(parent, text, min, max, default, callback)
    local S = Instance.new("Frame")
    S.Size = UDim2.new(1, 0, 0, 70)
    S.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    S.BorderSizePixel = 0
    S.Parent = parent
    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(0, 10)
    sc.Parent = S

    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -90, 0, 20)
    L.Position = UDim2.new(0, 16, 0, 10)
    L.BackgroundTransparency = 1
    L.Text = text
    L.TextColor3 = Color3.fromRGB(255, 255, 255)
    L.TextSize = 14
    L.Font = Enum.Font.GothamBold
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = S

    local V = Instance.new("TextLabel")
    V.Size = UDim2.new(0, 60, 0, 20)
    V.Position = UDim2.new(1, -76, 0, 10)
    V.BackgroundTransparency = 1
    V.Text = tostring(default)
    V.TextColor3 = Color3.fromRGB(255, 30, 39)
    V.TextSize = 14
    V.Font = Enum.Font.GothamBold
    V.TextXAlignment = Enum.TextXAlignment.Right
    V.Parent = S

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -32, 0, 6)
    Bar.Position = UDim2.new(0, 16, 0, 48)
    Bar.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    Bar.BorderSizePixel = 0
    Bar.Parent = S
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(1, 0)
    bc.Parent = Bar

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(255, 30, 39)
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1, 0)
    fc.Parent = Fill

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 18, 0, 18)
    Dot.Position = UDim2.new((default - min) / (max - min), -9, 0.5, -9)
    Dot.BackgroundColor3 = Color3.fromRGB(255, 30, 39)
    Dot.BorderSizePixel = 0
    Dot.Parent = Bar
    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(1, 0)
    dc.Parent = Dot

    local Di = Instance.new("Frame")
    Di.Size = UDim2.new(1, -6, 1, -6)
    Di.Position = UDim2.new(0, 3, 0, 3)
    Di.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Di.BorderSizePixel = 0
    Di.Parent = Dot
    local dic = Instance.new("UICorner")
    dic.CornerRadius = UDim.new(1, 0)
    dic.Parent = Di

    local drag = false
    local function upd(input)
        local p = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * p)
        Fill.Size = UDim2.new(p, 0, 1, 0)
        Dot.Position = UDim2.new(p, -9, 0.5, -9)
        V.Text = tostring(v)
        if callback then callback(v) end
    end

    Dot.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            upd(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            upd(input)
            drag = true
        end
    end)

    return S
end

--// BUTTON
local function createButton(parent, text, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, 0, 0, 46)
    B.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    B.Text = text
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.TextSize = 14
    B.Font = Enum.Font.GothamBold
    B.BorderSizePixel = 0
    B.AutoButtonColor = false
    B.Parent = parent
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 10)
    bc.Parent = B

    B.MouseEnter:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 30, 39)}):Play()
    end)
    B.MouseLeave:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 36)}):Play()
    end)
    B.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return B
end

--// TABS
local MainPage = createTab("Main")
createToggle(MainPage, "Speed Hack", false, function(on) State.SpeedEnabled = on end)
createSlider(MainPage, "Speed Value", 16, 500, 16, function(v) State.SpeedValue = v end)
createToggle(MainPage, "Anti-Fling", false, function(on) State.AntiFlingEnabled = on end)
createToggle(MainPage, "Anti-Void", false, function(on) State.AntiVoidEnabled = on end)

local MovePage = createTab("Movement")
createToggle(MovePage, "Fly", false, function(on) State.FlyEnabled = on end)
createToggle(MovePage, "Noclip", false, function(on) State.NoclipEnabled = on end)
createToggle(MovePage, "Infinite Jump", false, function(on) State.InfiniteJumpEnabled = on end)

local SettingsPage = createTab("Settings")
createButton(SettingsPage, "Reset Character", function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end
end)
createButton(SettingsPage, "Unload Script", function() ScreenGui:Destroy() end)

--// LOGIC
RunService.Heartbeat:Connect(function()
    if State.SpeedEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = State.SpeedValue end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if State.AntiFlingEnabled then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 1, 1)
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if State.AntiVoidEnabled then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Position.Y < -50 then
                hrp.CFrame = CFrame.new(0, 50, 0)
            end
        end
    end
end)

RunService.Stepped:Connect(function()
    if State.NoclipEnabled then
        local char = LocalPlayer.Character
        if char then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

--// FLY
local flyConn, flyCleanup
local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
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
        if not cam then return end
        local dir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
        local sp = 60
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then sp = 120 end
        bv.Velocity = dir * sp
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

--// INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJumpEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

--// KEYBIND
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
    end
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Main.Size = UDim2.new(0, 560, 0, 60)
        Sidebar.Visible = false
        Content.Visible = false
    else
        Main.Size = UDim2.new(0, 560, 0, 400)
        Sidebar.Visible = true
        Content.Visible = true
    end
end)

--// DEFAULT TAB
if Tabs["Main"] then
    Tabs["Main"].Button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Tabs["Main"].Button.TextColor3 = Color3.fromRGB(255, 30, 39)
    Tabs["Main"].Page.Visible = true
    ActiveTab = "Main"
end

print("[EXECUTE HUB] v1.0.3 loaded")
