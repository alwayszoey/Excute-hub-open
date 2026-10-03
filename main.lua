--[[
================================================================
    EXECUTE HUB - v9.0.0 CASCADE UI EDITION
    UI: Cascade (macOS style, dark/red theme)
    Features: Bypass Gates, Speed, Fly, Noclip, Save/TP, Anti-Ban
    Loading screen + Coordinate HUD
    Tương thích: Delta, Arceus X, Fluxus, Krnl, Synapse
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
    Version        = "9.0.0-Cascade",
    UpdateURL      = "https://raw.githubusercontent.com/alwayszoey/Excute-hub-open/main/version.txt",
    ScriptURL      = "https://raw.githubusercontent.com/alwayszoey/Excute-hub-open/main/main.lua",
    CurrentVersion = "9.0.0"
}

-- ============================================================
-- STATE
-- ============================================================
local State = {
    -- Bypass
    BypassEnabled    = false,
    BypassRange      = 500,
    RemoveCollision  = false,
    AutoEnterLocked  = false,
    -- Movement
    SpeedEnabled     = false,
    SpeedValue       = 16,
    MaxSpeed         = 250,
    FlyEnabled       = false,
    FlySpeed         = 60,
    NoclipEnabled    = false,
    InfJumpEnabled   = false,
    AntiFlingEnabled = false,
    AntiVoidEnabled  = false,
    -- Anti-Ban
    AntiBanEnabled   = true,
    JitterEnabled    = true,
    RateLimitEnabled = true,
    LegitMode        = false,
    RampUpEnabled    = true,
    -- Utils
    ShowCoords       = true,
    AntiAfkEnabled   = true,
    AutoUpdateCheck  = true,
    SavedPositions   = {},
}

local AntiBan = { tickCounter = 0, currentRampSpeed = 16 }

-- ============================================================
-- CLEANUP PREVIOUS
-- ============================================================
pcall(function()
    if CoreGui:FindFirstChild("Cascade") then CoreGui.Cascade:Destroy() end
    if CoreGui:FindFirstChild("ExecuteHubLoading") then CoreGui.ExecuteHubLoading:Destroy() end
    if CoreGui:FindFirstChild("ExecuteHubHUD") then CoreGui.ExecuteHubHUD:Destroy() end
end)
pcall(function()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        if pg:FindFirstChild("Cascade") then pg.Cascade:Destroy() end
        if pg:FindFirstChild("ExecuteHubLoading") then pg.ExecuteHubLoading:Destroy() end
        if pg:FindFirstChild("ExecuteHubHUD") then pg.ExecuteHubHUD:Destroy() end
    end
end)

-- ============================================================
-- LOADING SCREEN
-- ============================================================
local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "ExecuteHubLoading"
LoadingGui.ResetOnSpawn = false
LoadingGui.IgnoreGuiInset = true
LoadingGui.DisplayOrder = 1000
pcall(function() LoadingGui.Parent = CoreGui end)
if not LoadingGui.Parent then LoadingGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local LoadFrame = Instance.new("Frame")
LoadFrame.Size = UDim2.new(0, 340, 0, 180)
LoadFrame.Position = UDim2.new(0.5, -170, 0.5, -90)
LoadFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
LoadFrame.BorderSizePixel = 0
LoadFrame.Parent = LoadingGui
local LFC = Instance.new("UICorner") LFC.CornerRadius = UDim.new(0, 14) LFC.Parent = LoadFrame
local LFS = Instance.new("UIStroke") LFS.Color = Color3.fromRGB(255, 35, 45) LFS.Thickness = 1.5 LFS.Parent = LoadFrame

local LoadLogo = Instance.new("TextLabel")
LoadLogo.Size = UDim2.new(1, 0, 0, 40)
LoadLogo.Position = UDim2.new(0, 0, 0, 20)
LoadLogo.BackgroundTransparency = 1
LoadLogo.Text = "EXECUTE HUB"
LoadLogo.TextColor3 = Color3.fromRGB(255, 35, 45)
LoadLogo.TextSize = 24
LoadLogo.Font = Enum.Font.GothamBlack
LoadLogo.Parent = LoadFrame

local LoadVer = Instance.new("TextLabel")
LoadVer.Size = UDim2.new(1, 0, 0, 14)
LoadVer.Position = UDim2.new(0, 0, 0, 58)
LoadVer.BackgroundTransparency = 1
LoadVer.Text = Config.Version
LoadVer.TextColor3 = Color3.fromRGB(110, 110, 125)
LoadVer.TextSize = 10
LoadVer.Font = Enum.Font.Gotham
LoadVer.Parent = LoadFrame

local LoadBarBg = Instance.new("Frame")
LoadBarBg.Size = UDim2.new(0, 260, 0, 6)
LoadBarBg.Position = UDim2.new(0.5, -130, 0, 100)
LoadBarBg.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
LoadBarBg.BorderSizePixel = 0
LoadBarBg.Parent = LoadFrame
local LBBC = Instance.new("UICorner") LBBC.CornerRadius = UDim.new(1, 0) LBBC.Parent = LoadBarBg

local LoadBarFill = Instance.new("Frame")
LoadBarFill.Size = UDim2.new(0, 0, 1, 0)
LoadBarFill.BackgroundColor3 = Color3.fromRGB(255, 35, 45)
LoadBarFill.BorderSizePixel = 0
LoadBarFill.Parent = LoadBarBg
local LBFC = Instance.new("UICorner") LBFC.CornerRadius = UDim.new(1, 0) LBFC.Parent = LoadBarFill

local LoadStatus = Instance.new("TextLabel")
LoadStatus.Size = UDim2.new(1, 0, 0, 14)
LoadStatus.Position = UDim2.new(0, 0, 0, 120)
LoadStatus.BackgroundTransparency = 1
LoadStatus.Text = "Loading Cascade UI..."
LoadStatus.TextColor3 = Color3.fromRGB(160, 160, 175)
LoadStatus.TextSize = 10
LoadStatus.Font = Enum.Font.GothamBold
LoadStatus.Parent = LoadFrame

local loadingSteps = { "Loading Cascade UI...", "Checking updates...", "Setting up modules...", "Initializing bypass...", "Ready!" }
task.spawn(function()
    for i = 1, 5 do
        LoadStatus.Text = loadingSteps[i]
        TweenService:Create(LoadBarFill, TweenInfo.new(0.35), { Size = UDim2.new(i/5, 0, 1, 0) }):Play()
        task.wait(0.4)
    end
    task.wait(0.3)
    for _, obj in ipairs(LoadFrame:GetDescendants()) do
        if obj:IsA("TextLabel") then
            TweenService:Create(obj, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
        elseif obj:IsA("Frame") then
            TweenService:Create(obj, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
        elseif obj:IsA("UIStroke") then
            TweenService:Create(obj, TweenInfo.new(0.4), { Transparency = 1 }):Play()
        end
    end
    task.wait(0.5)
    LoadingGui:Destroy()
end)

-- ============================================================
-- LOAD CASCADE LIBRARY
-- ============================================================
local Cascade
do
    local source = game:HttpGet("https://raw.githubusercontent.com/alwayszoey/Excute-hub-open/main/cascade.lua")
    Cascade = loadstring(source)()
end

-- Fallback: nếu không load được, dùng Cascade inline (compact version)
if not Cascade or not Cascade.New then
    error("[EXECUTE HUB] Không load được Cascade. Kiểm tra HTTP executor và file cascade.lua trên GitHub.")
end

-- ============================================================
-- DARK/RED THEME OVERRIDE
-- ============================================================
local DarkRedTheme = {
    Text = {
        Primary         = { Cascade.Themes.Dark.Text.Primary[1], 0.15 },
        Secondary       = { Cascade.Themes.Dark.Text.Secondary[1], 0.45 },
        Tertiary        = { Cascade.Themes.Dark.Text.Tertiary[1], 0.75 },
        PrimaryAccent   = { Color3.fromRGB(255, 35, 45), 0.62 },
        SelectionPrimary= { Color3.fromRGB(255, 255, 255), 0 },
    },
    Controls = {
        Background      = { Color3.fromRGB(12, 12, 14), 0 },
        View            = { Color3.fromRGB(20, 20, 24), 0 },
        ViewBorder      = { Color3.fromRGB(255, 255, 255), 0.92 },
        Sidebar         = { Color3.fromRGB(8, 8, 10), 0.15 },
        Separator       = {
            Background  = { Color3.fromRGB(0, 0, 0), 0.5 },
            Shadow      = { Color3.fromRGB(255, 255, 255), 0.9 },
        },
        Titlebar        = { Color3.fromRGB(22, 22, 26), 0 },
        TitlebarShadow  = {
            Background  = { Color3.fromRGB(0, 0, 0), 0.5 },
            Color       = { Color3.fromRGB(0, 0, 0) },
            Transparency= { 0.5 },
        },
        Selection       = { Color3.fromRGB(255, 35, 45), 0 },
        SelectionFocused= { Color3.fromRGB(255, 35, 45), 0 },
        SelectionFocusedAccent = { Color3.fromRGB(255, 255, 255), 0.1 },
        SelectionStroke = { Color3.fromRGB(255, 35, 45), 0.4 },
        Exit            = { Color3.fromRGB(255, 95, 87), 0 },
        Minimize        = { Color3.fromRGB(255, 189, 46), 0 },
        Zoom            = { Color3.fromRGB(39, 201, 63), 0 },
        WindowControlIcon = { Color3.fromRGB(0, 0, 0), 0.5 },
        WindowControlStroke = { Color3.fromRGB(255, 255, 255), 0.85 },
        Toggle          = {
            Knob        = { Color3.fromRGB(255, 255, 255), 0 },
            KnobEffects = { Color3.fromRGB(255, 255, 255), 0 },
            SwitchOff   = { Color3.fromRGB(70, 70, 85), 0.6 },
            SwitchOn    = { Color3.fromRGB(255, 35, 45), 0 },
            DepthEffect = { Color3.fromRGB(120, 15, 20) },
        },
        Slider          = {
            Track       = { Color3.fromRGB(45, 45, 55), 0 },
            TrackEffects= { Color3.fromRGB(0, 0, 0), 0.9 },
            TrackFill   = { Color3.fromRGB(255, 35, 45), 0 },
            Thumb       = { Color3.fromRGB(255, 255, 255), 0 },
            ThumbStroke = { Color3.fromRGB(0, 0, 0), 0.8 },
            ThumbEffects= { Color3.fromRGB(255, 255, 255), 0 },
        },
        Button          = {
            Shadow      = { Color3.fromRGB(0, 0, 0) },
            FillPrimary = { Color3.fromRGB(255, 35, 45) },
            FillSecondary = { Color3.fromRGB(40, 40, 50) },
        },
        Stepper         = {
            Background  = { Color3.fromRGB(35, 35, 45), 0 },
            Dropshadow  = { Color3.fromRGB(0, 0, 0), 0 },
            Separator   = { Color3.fromRGB(255, 255, 255), 0.9 },
            Filler      = { Color3.fromRGB(255, 255, 255), 0.96 },
            SegmentShadow = { Color3.fromRGB(0, 0, 0) },
        },
        RadioButtonGroup = {
            Background  = { Color3.fromRGB(35, 35, 45), 0 },
            Dot         = { Color3.fromRGB(255, 255, 255), 0 },
            Stroke      = { Color3.fromRGB(0, 0, 0), 0.8 },
            Overlay     = { Color3.fromRGB(255, 255, 255), 0.92 },
            InnerShadow = { Color3.fromRGB(255, 255, 255), 0.9 },
        },
        MenuButton      = {
            IndicatorBackground = { Color3.fromRGB(255, 255, 255), 0.9 },
            MenuBackground      = { Color3.fromRGB(35, 35, 42), 0.05 },
        },
    },
    Accents = {
        Red = { Color3.fromRGB(255, 35, 45), 0 },
    }
}

-- ============================================================
-- INITIALIZE CASCADE
-- ============================================================
local App = Cascade.New({
    WindowPill = true,
    Theme = DarkRedTheme,
})

-- ============================================================
-- WINDOW
-- ============================================================
local Window = App:Window({
    Title = "EXECUTE HUB",
    Subtitle = "Cascade Edition • " .. Config.Version,
    Size = UDim2.fromOffset(560, 400),
    MaxSize = UDim2.fromOffset(1200, 800),
    MinSize = UDim2.fromOffset(400, 300),
    Maximized = false,
    Minimized = false,
    Searching = true,
    Resizable = true,
    Draggable = true,
    Dropshadow = true,
    UIBlur = true,
})

-- ============================================================
-- TABS
-- ============================================================
local BypassTab = Window:Tab({ Title = "Bypass", Icon = Cascade.Symbols["lockOpen"] })
local MovementTab = Window:Tab({ Title = "Movement", Icon = Cascade.Symbols["figureRun"] })
local SaveTPTab = Window:Tab({ Title = "Save / TP", Icon = Cascade.Symbols["mappin"] })
local AntiBanTab = Window:Tab({ Title = "Anti-Ban", Icon = Cascade.Symbols["shield"] })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = Cascade.Symbols["gearShape"] })

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================
local function cleanupSpeedInstances()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, n in ipairs({"SpeedBV", "FlyBV", "FlyBG", "AntiFlingBV"}) do
        local o = hrp:FindFirstChild(n)
        if o then pcall(function() o:Destroy() end) end
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
-- BYPASS FUNCTIONS
-- ============================================================
local bypassedGates = {}
local bypassedCollisions = {}

local function bypassAllGates()
    local count = 0
    local kw = {"gate","barrier","wall","door","block","lock","required","rebirth","level","quest","unlock","invisible","region","zone","portal"}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = string.lower(obj.Name)
            for _, k in ipairs(kw) do
                if string.find(n, k) then
                    pcall(function()
                        obj.CanCollide = false
                        obj.CanTouch = false
                        obj.CanQuery = false
                        obj.Transparency = 1
                        obj.Massless = true
                        if not bypassedGates[obj] then bypassedGates[obj] = true; count = count + 1 end
                    end)
                    break
                end
            end
        elseif obj:IsA("Model") then
            local n = string.lower(obj.Name)
            for _, k in ipairs(kw) do
                if string.find(n, k) then
                    for _, p in ipairs(obj:GetDescendants()) do
                        if p:IsA("BasePart") then
                            pcall(function()
                                p.CanCollide = false
                                p.CanTouch = false
                                p.CanQuery = false
                                p.Transparency = 1
                                p.Massless = true
                            end)
                        end
                    end
                    count = count + 1
                    break
                end
            end
        end
    end
    return count
end

local function disableGateChecks()
    local c = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local n = string.lower(obj.Name)
            if string.find(n, "barrier") or string.find(n, "gate") or string.find(n, "door") or string.find(n, "block") then
                for _, s in ipairs(obj:GetDescendants()) do
                    if s:IsA("Script") or s:IsA("LocalScript") then
                        pcall(function() s.Disabled = true end)
                        c = c + 1
                    end
                end
            end
        end
    end
    return c
end

local function bypassAllPrompts()
    local c = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            pcall(function()
                obj.HoldDuration = 0
                obj.MaxActivationDistance = 9999
                obj.RequiresLineOfSight = false
                obj.Enabled = true
            end)
            c = c + 1
        end
    end
    return c
end

local function activateAllPrompts()
    local c = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            pcall(function()
                obj.HoldDuration = 0
                obj.MaxActivationDistance = 9999
                obj.RequiresLineOfSight = false
                if fireproximityprompt then fireproximityprompt(obj); c = c + 1 end
            end)
        end
    end
    return c
end

local function disableAllCollision()
    local c = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.CanCollide then
            if not LocalPlayer.Character or not obj:IsDescendantOf(LocalPlayer.Character) then
                pcall(function()
                    bypassedCollisions[obj] = obj.CanCollide
                    obj.CanCollide = false
                    c = c + 1
                end)
            end
        end
    end
    return c
end

local function restoreAllCollision()
    for obj, v in pairs(bypassedCollisions) do
        if obj and obj.Parent then
            pcall(function() obj.CanCollide = v end)
        end
    end
    bypassedCollisions = {}
end

local function teleportThroughGate()
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local nearest, shortest = nil, State.BypassRange
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = string.lower(obj.Name)
            if string.find(n, "gate") or string.find(n, "barrier") or string.find(n, "door") or string.find(n, "wall") then
                local d = (obj.Position - hrp.Position).Magnitude
                if d < shortest then shortest = d; nearest = obj end
            end
        end
    end
    if nearest then
        local fwd = (nearest.Position - hrp.Position).Unit
        pcall(function() hrp.CFrame = CFrame.new(nearest.Position + fwd * 20) end)
        return true
    end
    return false
end

-- ============================================================
-- UPDATE CHECK
-- ============================================================
local function checkForUpdates()
    if not State.AutoUpdateCheck then return end
    pcall(function()
        local v = game:HttpGet(Config.UpdateURL):gsub("%s", "")
        if v ~= Config.CurrentVersion then
            Window:PopUpButton({})
            print("[EXECUTE HUB] New version " .. v .. " available")
            task.wait(2)
            loadstring(game:HttpGet(Config.ScriptURL))()
        end
    end)
end

-- ============================================================
-- TAB: BYPASS
-- ============================================================
do
    local PageSection = BypassTab:PageSection({
        Title = "Bypass Gate System",
        Subtitle = "Bỏ qua mọi yêu cầu quest, level, rebirth để vào vùng khóa"
    })

    local Form = PageSection:Form()

    local row1 = Form:Row()
    row1.Left:TitleStack({ Title = "Bypass All Gates", Subtitle = "Vô hiệu hóa mọi barrier" })
    row1.Right:Toggle({
        Value = false,
        ValueChanged = function(_, v)
            State.BypassEnabled = v
            if v then
                local c = bypassAllGates()
                print("[BYPASS] Bypassed " .. c .. " gates")
            end
        end,
    })

    local row2 = Form:Row()
    row2.Left:TitleStack({ Title = "Bypass Range", Subtitle = "Bán kính quét gate" })
    row2.Right:Slider({
        Minimum = 50, Maximum = 1000, Value = 500,
        ValueChanged = function(_, v) State.BypassRange = v end,
    })

    local row3 = Form:Row()
    row3.Left:TitleStack({ Title = "Remove All Collision", Subtitle = "Đi xuyên mọi vật thể" })
    row3.Right:Toggle({
        Value = false,
        ValueChanged = function(_, v)
            State.RemoveCollision = v
            if v then disableAllCollision() else restoreAllCollision() end
        end,
    })

    local row4 = Form:Row()
    row4.Left:TitleStack({ Title = "Auto Enter Locked Zones", Subtitle = "Tự động TP qua gate" })
    row4.Right:Toggle({
        Value = false,
        ValueChanged = function(_, v) State.AutoEnterLocked = v end,
    })

    local ActionsSection = BypassTab:PageSection({
        Title = "Quick Actions",
        Subtitle = "Bypass tức thì không cần toggle"
    })

    local ActionsForm = ActionsSection:Form()

    local actionRow1 = ActionsForm:Row()
    actionRow1.Left:TitleStack({ Title = "Bypass All Now", Subtitle = "Gate + Script + Prompt" })
    actionRow1.Right:Button({
        Label = "Run",
        State = "Primary",
        Pushed = function()
            local a = bypassAllGates()
            local b = disableGateChecks()
            local c = bypassAllPrompts()
            print("[BYPASS] G:" .. a .. " C:" .. b .. " P:" .. c)
        end,
    })

    local actionRow2 = ActionsForm:Row()
    actionRow2.Left:TitleStack({ Title = "Activate All Prompts", Subtitle = "Fire tất cả ProximityPrompt" })
    actionRow2.Right:Button({
        Label = "Fire",
        State = "Primary",
        Pushed = function() activateAllPrompts() end,
    })

    local actionRow3 = ActionsForm:Row()
    actionRow3.Left:TitleStack({ Title = "Teleport Through Gate", Subtitle = "TP xuyên gate gần nhất" })
    actionRow3.Right:Button({
        Label = "TP",
        State = "Primary",
        Pushed = function() teleportThroughGate() end,
    })

    local actionRow4 = ActionsForm:Row()
    actionRow4.Left:TitleStack({ Title = "Restore All Gates", Subtitle = "Khôi phục trạng thái gốc" })
    actionRow4.Right:Button({
        Label = "Restore",
        State = "Destructive",
        Pushed = function()
            for obj in pairs(bypassedGates) do
                if obj and obj.Parent then
                    pcall(function()
                        obj.CanCollide = true
                        obj.CanTouch = true
                        obj.CanQuery = true
                        obj.Transparency = 0
                    end)
                end
            end
            bypassedGates = {}
            restoreAllCollision()
        end,
    })
end

-- ============================================================
-- TAB: MOVEMENT
-- ============================================================
do
    local SpeedSection = MovementTab:PageSection({ Title = "Speed", Subtitle = "Tăng tốc di chuyển" })
    local SpeedForm = SpeedSection:Form()

    local sr1 = SpeedForm:Row()
    sr1.Left:TitleStack({ Title = "Speed Hack", Subtitle = "Bật tắt speed" })
    sr1.Right:Toggle({
        Value = false,
        ValueChanged = function(_, v) State.SpeedEnabled = v end,
    })

    local sr2 = SpeedForm:Row()
    sr2.Left:TitleStack({ Title = "Speed Value", Subtitle = "16 → 500" })
    sr2.Right:Slider({
        Minimum = 16, Maximum = 500, Value = 16,
        ValueChanged = function(_, v) State.SpeedValue = v end,
    })

    local sr3 = SpeedForm:Row()
    sr3.Left:TitleStack({ Title = "Max Speed Cap", Subtitle = "Giới hạn an toàn" })
    sr3.Right:Slider({
        Minimum = 50, Maximum = 500, Value = 250,
        ValueChanged = function(_, v) State.MaxSpeed = v end,
    })

    local FlySection = MovementTab:PageSection({ Title = "Fly", Subtitle = "Bay tự do" })
    local FlyForm = FlySection:Form()

    local fr1 = FlyForm:Row()
    fr1.Left:TitleStack({ Title = "Fly", Subtitle = "WASD + Space/Ctrl" })
    fr1.Right:Toggle({
        Value = false,
        ValueChanged = function(_, v) State.FlyEnabled = v end,
    })

    local fr2 = FlyForm:Row()
    fr2.Left:TitleStack({ Title = "Fly Speed", Subtitle = "Studs per second" })
    fr2.Right:Slider({
        Minimum = 30, Maximum = 300, Value = 60,
        ValueChanged = function(_, v) State.FlySpeed = v end,
    })

    local ExtrasSection = MovementTab:PageSection({ Title = "Movement Extras", Subtitle = "Tính năng bổ trợ" })
    local ExtrasForm = ExtrasSection:Form()

    local er1 = ExtrasForm:Row()
    er1.Left:TitleStack({ Title = "Noclip", Subtitle = "Xuyên vật thể" })
    er1.Right:Toggle({ Value = false, ValueChanged = function(_, v) State.NoclipEnabled = v end })

    local er2 = ExtrasForm:Row()
    er2.Left:TitleStack({ Title = "Infinite Jump", Subtitle = "Nhảy vô hạn" })
    er2.Right:Toggle({ Value = false, ValueChanged = function(_, v) State.InfJumpEnabled = v end })

    local er3 = ExtrasForm:Row()
    er3.Left:TitleStack({ Title = "Anti-Fling", Subtitle = "Chống bị đẩy" })
    er3.Right:Toggle({ Value = false, ValueChanged = function(_, v) State.AntiFlingEnabled = v end })

    local er4 = ExtrasForm:Row()
    er4.Left:TitleStack({ Title = "Anti-Void", Subtitle = "Chống rơi vực" })
    er4.Right:Toggle({ Value = false, ValueChanged = function(_, v) State.AntiVoidEnabled = v end })

    local er5 = ExtrasForm:Row()
    er5.Left:TitleStack({ Title = "Anti-AFK", Subtitle = "Chống kick idle" })
    er5.Right:Toggle({ Value = true, ValueChanged = function(_, v) State.AntiAfkEnabled = v end })
end

-- ============================================================
-- TAB: SAVE / TP
-- ============================================================
do
    local saveSection = SaveTPTab:PageSection({ Title = "Save Position", Subtitle = "Lưu vị trí hiện tại" })
    local saveForm = saveSection:Form()

    local sr1 = saveForm:Row()
    sr1.Left:TitleStack({ Title = "Save Name", Subtitle = "Đặt tên cho vị trí" })
    sr1.Right:TextField({
        Placeholder = "e.g. base, farm",
        Value = "spot1",
        ValueChanged = function(_, v) State.SaveName = v end,
    })

    local sr2 = saveForm:Row()
    sr2.Left:TitleStack({ Title = "Save Current Position", Subtitle = "Lưu X, Y, Z" })
    sr2.Right:Button({
        Label = "Save",
        State = "Primary",
        Pushed = function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local name = State.SaveName or "spot1"
            State.SavedPositions[name] = { x = hrp.Position.X, y = hrp.Position.Y, z = hrp.Position.Z }
            print("[SAVE] Saved: " .. name)
        end,
    })

    local xyzSection = SaveTPTab:PageSection({ Title = "Teleport to XYZ", Subtitle = "Nhập tọa độ thủ công" })
    local xyzForm = xyzSection:Form()

    local xr1 = xyzForm:Row()
    xr1.Left:TitleStack({ Title = "Coordinates", Subtitle = "Format: x, y, z" })
    xr1.Right:TextField({
        Placeholder = "0, 50, 0",
        Value = "0, 50, 0",
        ValueChanged = function(_, v) State.XYZ = v end,
    })

    local xr2 = xyzForm:Row()
    xr2.Left:TitleStack({ Title = "Teleport to XYZ", Subtitle = "Di chuyển tới tọa độ" })
    xr2.Right:Button({
        Label = "TP",
        State = "Primary",
        Pushed = function()
            local coords = {}
            for n in string.gmatch(State.XYZ or "0, 50, 0", "[^,%s]+") do
                table.insert(coords, tonumber(n))
            end
            if #coords == 3 then
                local char = LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = CFrame.new(Vector3.new(coords[1], coords[2], coords[3]))
                    end
                end
            end
        end,
    })

    local quickSection = SaveTPTab:PageSection({ Title = "Quick Actions", Subtitle = "Lệnh nhanh" })
    local quickForm = quickSection:Form()

    local qr1 = quickForm:Row()
    qr1.Left:TitleStack({ Title = "Teleport to Spawn", Subtitle = "Về điểm spawn" })
    qr1.Right:Button({
        Label = "TP Spawn",
        State = "Primary",
        Pushed = function()
            local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
            if spawn then
                local char = LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CFrame = CFrame.new(spawn.Position + Vector3.new(0, 5, 0)) end
                end
            end
        end,
    })

    local qr2 = quickForm:Row()
    qr2.Left:TitleStack({ Title = "Teleport Up", Subtitle = "+50 studs" })
    qr2.Right:Button({
        Label = "Up",
        State = "Primary",
        Pushed = function()
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0, 50, 0) end
            end
        end,
    })
end

-- ============================================================
-- TAB: ANTI-BAN
-- ============================================================
do
    local coreSection = AntiBanTab:PageSection({ Title = "Core", Subtitle = "Chống phát hiện" })
    local coreForm = coreSection:Form()

    local cr1 = coreForm:Row()
    cr1.Left:TitleStack({ Title = "Anti-Ban System", Subtitle = "Bật hệ thống chống ban" })
    cr1.Right:Toggle({ Value = true, ValueChanged = function(_, v) State.AntiBanEnabled = v end })

    local cr2 = coreForm:Row()
    cr2.Left:TitleStack({ Title = "Jitter ±2", Subtitle = "Random tốc độ" })
    cr2.Right:Toggle({ Value = true, ValueChanged = function(_, v) State.JitterEnabled = v end })

    local cr3 = coreForm:Row()
    cr3.Left:TitleStack({ Title = "Rate Limit 20Hz", Subtitle = "Giảm tần suất update" })
    cr3.Right:Toggle({ Value = true, ValueChanged = function(_, v) State.RateLimitEnabled = v end })

    local cr4 = coreForm:Row()
    cr4.Left:TitleStack({ Title = "Ramp Up Smooth", Subtitle = "Tăng tốc từ từ" })
    cr4.Right:Toggle({ Value = true, ValueChanged = function(_, v) State.RampUpEnabled = v end })

    local cr5 = coreForm:Row()
    cr5.Left:TitleStack({ Title = "Legit Mode", Subtitle = "Giới hạn speed 60" })
    cr5.Right:Toggle({ Value = false, ValueChanged = function(_, v) State.LegitMode = v end })

    local emergencySection = AntiBanTab:PageSection({ Title = "Emergency", Subtitle = "Xử lý khẩn cấp" })
    local emergencyForm = emergencySection:Form()

    local er1 = emergencyForm:Row()
    er1.Left:TitleStack({ Title = "Panic Cleanup", Subtitle = "Xóa mọi dấu vết" })
    er1.Right:Button({
        Label = "Clean",
        State = "Destructive",
        Pushed = function()
            resetCharacterPhysics()
            State.SpeedEnabled = false
            State.FlyEnabled = false
            State.NoclipEnabled = false
            State.BypassEnabled = false
            State.RemoveCollision = false
            AntiBan.currentRampSpeed = 16
            print("[ANTI-BAN] Panic cleanup executed")
        end,
    })

    local er2 = emergencyForm:Row()
    er2.Left:TitleStack({ Title = "Reset Physics", Subtitle = "Reset WalkSpeed/JumpPower" })
    er2.Right:Button({
        Label = "Reset",
        State = "Secondary",
        Pushed = function() resetCharacterPhysics() end,
    })

    local diagSection = AntiBanTab:PageSection({ Title = "Diagnostics", Subtitle = "Kiểm tra hệ thống" })
    local diagForm = diagSection:Form()

    local dr1 = diagForm:Row()
    dr1.Left:TitleStack({ Title = "Check Updates", Subtitle = "So sánh version" })
    dr1.Right:Button({
        Label = "Check",
        State = "Primary",
        Pushed = function() checkForUpdates() end,
    })

    local dr2 = diagForm:Row()
    dr2.Left:TitleStack({ Title = "Force Reload", Subtitle = "Tải lại script" })
    dr2.Right:Button({
        Label = "Reload",
        State = "Primary",
        Pushed = function()
            task.wait(1)
            loadstring(game:HttpGet(Config.ScriptURL))()
        end,
    })
end

-- ============================================================
-- TAB: SETTINGS
-- ============================================================
do
    local displaySection = SettingsTab:PageSection({ Title = "Display", Subtitle = "Cài đặt hiển thị" })
    local displayForm = displaySection:Form()

    local dr1 = displayForm:Row()
    dr1.Left:TitleStack({ Title = "Show Coordinate HUD", Subtitle = "Hiển thị tọa độ" })
    dr1.Right:Toggle({ Value = true, ValueChanged = function(_, v) State.ShowCoords = v end })

    local updatesSection = SettingsTab:PageSection({ Title = "Updates", Subtitle = "Cập nhật tự động" })
    local updatesForm = updatesSection:Form()

    local ur1 = updatesForm:Row()
    ur1.Left:TitleStack({ Title = "Auto Update Check", Subtitle = "Kiểm tra mỗi lần load" })
    ur1.Right:Toggle({ Value = true, ValueChanged = function(_, v) State.AutoUpdateCheck = v end })

    local scriptSection = SettingsTab:PageSection({ Title = "Script", Subtitle = "Quản lý script" })
    local scriptForm = scriptSection:Form()

    local sr1 = scriptForm:Row()
    sr1.Left:TitleStack({ Title = "Rejoin Server", Subtitle = "Vào lại server" })
    sr1.Right:Button({
        Label = "Rejoin",
        State = "Primary",
        Pushed = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end,
    })

    local sr2 = scriptForm:Row()
    sr2.Left:TitleStack({ Title = "Unload Script", Subtitle = "Tắt hoàn toàn" })
    sr2.Right:Button({
        Label = "Unload",
        State = "Destructive",
        Pushed = function()
            resetCharacterPhysics()
            if App.Structures and App.Structures.WindowPill then
                App.Structures.WindowPill:Destroy()
            end
        end,
    })

    local aboutSection = SettingsTab:PageSection({ Title = "About", Subtitle = "Thông tin" })
    local aboutForm = aboutSection:Form()

    local ar1 = aboutForm:Row()
    ar1.Left:TitleStack({ Title = "Execute Hub", Subtitle = Config.Version })
    ar1.Right:Label({ Text = "Cascade UI" })
end

-- ============================================================
-- COORDINATE HUD
-- ============================================================
local CoordGui = Instance.new("ScreenGui")
CoordGui.Name = "ExecuteHubHUD"
CoordGui.ResetOnSpawn = false
CoordGui.IgnoreGuiInset = true
pcall(function() CoordGui.Parent = CoreGui end)
if not CoordGui.Parent then CoordGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local CoordHUD = Instance.new("Frame")
CoordHUD.Size = UDim2.new(0, 190, 0, 62)
CoordHUD.Position = UDim2.new(1, -200, 0, 60)
CoordHUD.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
CoordHUD.BackgroundTransparency = 0.15
CoordHUD.BorderSizePixel = 0
CoordHUD.Active = true
CoordHUD.Draggable = true
CoordHUD.Parent = CoordGui
local CHC = Instance.new("UICorner") CHC.CornerRadius = UDim.new(0, 8) CHC.Parent = CoordHUD
local CHS = Instance.new("UIStroke") CHS.Color = Color3.fromRGB(255, 35, 45) CHS.Thickness = 1 CHS.Transparency = 0.5 CHS.Parent = CoordHUD

local CoordTitle = Instance.new("TextLabel")
CoordTitle.Size = UDim2.new(1, -12, 0, 14)
CoordTitle.Position = UDim2.new(0, 6, 0, 4)
CoordTitle.BackgroundTransparency = 1
CoordTitle.Text = "📍 POSITION"
CoordTitle.TextColor3 = Color3.fromRGB(255, 35, 45)
CoordTitle.TextSize = 9
CoordTitle.Font = Enum.Font.GothamBold
CoordTitle.TextXAlignment = Enum.TextXAlignment.Left
CoordTitle.Parent = CoordHUD

local CoordText = Instance.new("TextLabel")
CoordText.Size = UDim2.new(1, -12, 0, 18)
CoordText.Position = UDim2.new(0, 6, 0, 18)
CoordText.BackgroundTransparency = 1
CoordText.Text = "X: 0.0   Y: 0.0\nZ: 0.0"
CoordText.TextColor3 = Color3.fromRGB(245, 245, 250)
CoordText.TextSize = 10
CoordText.Font = Enum.Font.Code
CoordText.TextXAlignment = Enum.TextXAlignment.Left
CoordText.TextYAlignment = Enum.TextYAlignment.Top
CoordText.Parent = CoordHUD

local StatsText = Instance.new("TextLabel")
StatsText.Size = UDim2.new(1, -12, 0, 12)
StatsText.Position = UDim2.new(0, 6, 0, 44)
StatsText.BackgroundTransparency = 1
StatsText.Text = "FPS: --"
StatsText.TextColor3 = Color3.fromRGB(160, 160, 175)
StatsText.TextSize = 9
StatsText.Font = Enum.Font.Code
StatsText.TextXAlignment = Enum.TextXAlignment.Left
StatsText.Parent = CoordHUD

task.spawn(function()
    while task.wait(0.1) do
        if State.ShowCoords then
            CoordHUD.Visible = true
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local p = hrp.Position
                    CoordText.Text = string.format("X: %.1f   Y: %.1f\nZ: %.1f", p.X, p.Y, p.Z)
                end
            end
        else
            CoordHUD.Visible = false
        end
    end
end)

task.spawn(function()
    local c, t = 0, 0
    RunService.RenderStepped:Connect(function(dt)
        c = c + 1; t = t + dt
        if t >= 0.5 then
            StatsText.Text = string.format("FPS: %d", math.floor(c/t))
            c = 0; t = 0
        end
    end)
end)

-- ============================================================
-- CORE LOOPS
-- ============================================================
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    if State.SpeedEnabled then
        if State.RateLimitEnabled then
            AntiBan.tickCounter = (AntiBan.tickCounter + 1) % 3
            if AntiBan.tickCounter ~= 0 then return end
        end
        local target = State.SpeedValue
        if State.LegitMode then target = math.min(target, 60) end
        if target > State.MaxSpeed then target = State.MaxSpeed end
        if State.RampUpEnabled then
            local d = target - AntiBan.currentRampSpeed
            if math.abs(d) > 0.5 then
                AntiBan.currentRampSpeed = AntiBan.currentRampSpeed + d * 0.05
                target = math.floor(AntiBan.currentRampSpeed)
            else
                AntiBan.currentRampSpeed = target
            end
        end
        local sp = target
        if State.JitterEnabled then
            local j = math.random(-2, 2)
            if math.random(1, 10) == 1 then j = 0 end
            sp = target + j
        end
        pcall(function() hum.WalkSpeed = sp end)
        if hum.MoveDirection.Magnitude > 0.1 then
            local dir = hum.MoveDirection
            pcall(function() hrp.Velocity = Vector3.new(dir.X * sp, hrp.Velocity.Y, dir.Z * sp) end)
        else
            pcall(function() hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0) end)
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
            bv.Velocity = Vector3.new(dir.X * sp, 0, dir.Z * sp)
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end
    else
        pcall(function() hum.WalkSpeed = 16 end)
        pcall(function() hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0) end)
        local bv = hrp:FindFirstChild("SpeedBV")
        if bv then bv:Destroy() end
    end
end)

task.spawn(function() while task.wait(0.5) do cleanupSpeedInstances() end end)

task.spawn(function()
    while task.wait(2) do
        if State.BypassEnabled then
            pcall(bypassAllGates)
            pcall(bypassAllPrompts)
        end
        if State.RemoveCollision then pcall(disableAllCollision) end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if State.AutoEnterLocked and State.BypassEnabled then pcall(teleportThroughGate) end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if State.AntiFlingEnabled and hrp then
                pcall(function() hrp.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 1, 1) end)
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
                    if p:IsA("BasePart") then pcall(function() p.CanCollide = false end) end
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
    local oldBV = hrp:FindFirstChild("FlyBV"); if oldBV then oldBV:Destroy() end
    local oldBG = hrp:FindFirstChild("FlyBG"); if oldBG then oldBG:Destroy() end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "FlyBV"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp
    local bg = Instance.new("BodyGyro")
    bg.Name = "FlyBG"
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 10000; bg.D = 500
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
        local sp = State.FlySpeed or 60
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then sp = sp * 2 end
        bv.Velocity = dir * sp
        bg.CFrame = cam.CFrame
    end)
    flyCleanup = function()
        if flyConn then flyConn:Disconnect(); flyConn = nil end
        if bv and bv.Parent then bv:Destroy() end
        if bg and bg.Parent then bg:Destroy() end
        if hum then hum.PlatformStand = false end
    end
end

RunService.Heartbeat:Connect(function()
    if State.FlyEnabled and not flyConn then startFly()
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

LocalPlayer.Idled:Connect(function()
    if State.AntiAfkEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if flyCleanup then flyCleanup(); flyConn = nil; flyCleanup = nil end
    AntiBan.currentRampSpeed = 16
    task.wait(2)
    if State.BypassEnabled then
        pcall(bypassAllGates)
        pcall(bypassAllPrompts)
    end
end)

-- ============================================================
-- STARTUP
-- ============================================================
print("[EXECUTE HUB] " .. Config.Version .. " loaded (Cascade UI)")
print("[EXECUTE HUB] User: " .. LocalPlayer.Name)
print("[EXECUTE HUB] Tabs: Bypass, Movement, Save/TP, Anti-Ban, Settings")

task.spawn(function()
    task.wait(3)
    checkForUpdates()
end)
