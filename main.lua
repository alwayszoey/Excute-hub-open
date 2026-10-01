-- ============================================================
-- EXECUTE HUB - v2.0.0 (RAYFIELD DARK/RED THEME)
-- Full Auto Farm + Speed + Anti-Ban
-- Yêu cầu: Executor có HTTP (Delta Pro, Arceus X, Fluxus, Krnl)
-- ============================================================

-- ============================================================
-- LOAD RAYFIELD LIBRARY
-- ============================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ============================================================
-- SERVICES
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- STATE
-- ============================================================
local State = {
    -- Auto Farm
    AutoFarmEnabled    = false,
    AutoFarmMode       = "Nearest",
    AutoFarmRange      = 50,
    AutoCollectDrop    = false,
    AutoOpenChest      = false,
    -- Speed
    SpeedEnabled       = false,
    SpeedValue         = 16,
    -- Anti-Ban
    AntiBanEnabled     = true,
    JitterEnabled      = true,
    RateLimitEnabled   = true,
    LegitMode          = false,
    MaxSpeed           = 250,
    -- Movement
    FlyEnabled         = false,
    NoclipEnabled      = false,
    InfJumpEnabled     = false,
    AntiFlingEnabled   = false,
    AntiVoidEnabled    = false,
    -- Misc
    AntiAfkEnabled     = true,
    AutoSkillEnabled   = false,
    SelectedSkills     = {}
}

-- ============================================================
-- ANTI-BAN CORE
-- ============================================================
local AntiBan = {
    tick = 0,
    currentRampSpeed = 16,
    originalWalkspeed = 16
}

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

local function applyLegitCap(speed)
    if not State.LegitMode then return speed end
    return math.min(speed, 60)
end

-- ============================================================
-- CLEANUP HELPERS
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
-- RAYFIELD WINDOW (Dark/Red Theme)
-- ============================================================
local Window = Rayfield:CreateWindow({
    Name = "EXECUTE HUB | Pro Edition",
    LoadingTitle = "EXECUTE HUB",
    LoadingSubtitle = "by x2Swiftz • Pro v2.0.0",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ExecuteHub",
        FileName = "MainConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = false
    },
    KeySystem = false,
    Theme = "DarkBlue"  -- Rayfield built-in theme
})

-- ============================================================
-- TAB 1: AUTO FARM
-- ============================================================
local AutoFarmTab = Window:CreateTab("Auto Farm", 4483362458)

AutoFarmTab:CreateSection("Auto Farm Settings")

AutoFarmTab:CreateToggle({
    Name = "Enable Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarmEnabled",
    Callback = function(value)
        State.AutoFarmEnabled = value
    end,
})

AutoFarmTab:CreateDropdown({
    Name = "Farm Mode",
    Options = {"Nearest", "Lowest HP", "Highest HP", "Random"},
    CurrentOption = {"Nearest"},
    Flag = "FarmMode",
    Callback = function(option)
        State.AutoFarmMode = option[1]
    end,
})

AutoFarmTab:CreateSlider({
    Name = "Farm Range",
    Range = {10, 200},
    Increment = 5,
    Suffix = " studs",
    CurrentValue = 50,
    Flag = "FarmRange",
    Callback = function(value)
        State.AutoFarmRange = value
    end,
})

AutoFarmTab:CreateToggle({
    Name = "Auto Collect Drop",
    CurrentValue = false,
    Flag = "AutoCollectDrop",
    Callback = function(value)
        State.AutoCollectDrop = value
    end,
})

AutoFarmTab:CreateToggle({
    Name = "Auto Open Chest",
    CurrentValue = false,
    Flag = "AutoOpenChest",
    Callback = function(value)
        State.AutoOpenChest = value
    end,
})

AutoFarmTab:CreateSection("Combat")

AutoFarmTab:CreateToggle({
    Name = "Instant Kill",
    CurrentValue = false,
    Flag = "InstantKill",
    Callback = function(value)
        State.InstantKill = value
    end,
})

AutoFarmTab:CreateSlider({
    Name = "Attack Distance",
    Range = {1, 30},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 10,
    Flag = "AttackDistance",
    Callback = function(value)
        State.AttackDistance = value
    end,
})

AutoFarmTab:CreateSlider({
    Name = "Attack Cooldown",
    Range = {0.1, 5},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = 0.5,
    Flag = "AttackCooldown",
    Callback = function(value)
        State.AttackCooldown = value
    end,
})

AutoFarmTab:CreateButton({
    Name = "🔄 Refresh Target",
    Callback = function()
        Rayfield:Notify({
            Title = "Auto Farm",
            Content = "Target refreshed",
            Duration = 2,
            Image = 4483362458
        })
    end,
})

-- ============================================================
-- TAB 2: SPEED
-- ============================================================
local SpeedTab = Window:CreateTab("Speed", 4483362458)

SpeedTab:CreateSection("Speed Hack")

SpeedTab:CreateToggle({
    Name = "Enable Speed Hack",
    CurrentValue = false,
    Flag = "SpeedEnabled",
    Callback = function(value)
        State.SpeedEnabled = value
        if not value then AntiBan.currentRampSpeed = 16 end
    end,
})

SpeedTab:CreateSlider({
    Name = "Speed Value",
    Range = {16, 500},
    Increment = 1,
    Suffix = " WS",
    CurrentValue = 16,
    Flag = "SpeedValue",
    Callback = function(value)
        State.SpeedValue = value
        if value < AntiBan.currentRampSpeed then
            AntiBan.currentRampSpeed = value
        end
    end,
})

SpeedTab:CreateSection("Quick Actions")

SpeedTab:CreateButton({
    Name = "⚡ Set Speed 50",
    Callback = function()
        State.SpeedValue = 50
        State.SpeedEnabled = true
    end,
})

SpeedTab:CreateButton({
    Name = "⚡ Set Speed 100",
    Callback = function()
        State.SpeedValue = 100
        State.SpeedEnabled = true
    end,
})

SpeedTab:CreateButton({
    Name = "⚡ Set Speed 200",
    Callback = function()
        State.SpeedValue = 200
        State.SpeedEnabled = true
    end,
})

SpeedTab:CreateButton({
    Name = "🛑 Reset Speed",
    Callback = function()
        State.SpeedValue = 16
        State.SpeedEnabled = false
        AntiBan.currentRampSpeed = 16
        resetCharacterPhysics()
    end,
})

-- ============================================================
-- TAB 3: MOVEMENT
-- ============================================================
local MoveTab = Window:CreateTab("Movement", 4483362458)

MoveTab:CreateSection("Movement Features")

MoveTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "FlyEnabled",
    Callback = function(value) State.FlyEnabled = value end,
})

MoveTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoclipEnabled",
    Callback = function(value) State.NoclipEnabled = value end,
})

MoveTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJumpEnabled",
    Callback = function(value) State.InfJumpEnabled = value end,
})

MoveTab:CreateSection("Protection")

MoveTab:CreateToggle({
    Name = "Anti-Fling",
    CurrentValue = false,
    Flag = "AntiFlingEnabled",
    Callback = function(value) State.AntiFlingEnabled = value end,
})

MoveTab:CreateToggle({
    Name = "Anti-Void",
    CurrentValue = false,
    Flag = "AntiVoidEnabled",
    Callback = function(value) State.AntiVoidEnabled = value end,
})

MoveTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Flag = "AntiAfkEnabled",
    Callback = function(value) State.AntiAfkEnabled = value end,
})

-- ============================================================
-- TAB 4: AUTO SKILLS
-- ============================================================
local SkillTab = Window:CreateTab("Auto Skills", 4483362458)

SkillTab:CreateSection("Auto Skill Usage")

SkillTab:CreateToggle({
    Name = "Enable Auto Skills",
    CurrentValue = false,
    Flag = "AutoSkillEnabled",
    Callback = function(value) State.AutoSkillEnabled = value end,
})

SkillTab:CreateDropdown({
    Name = "Select Skills",
    Options = {"Skill 1", "Skill 2", "Skill 3", "Skill 4", "Skill 5"},
    CurrentOption = {"..."},
    MultipleOptions = true,
    Flag = "SelectedSkills",
    Callback = function(options)
        State.SelectedSkills = options
    end,
})

SkillTab:CreateSlider({
    Name = "Skill Cooldown",
    Range = {0.1, 10},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = 1,
    Flag = "SkillCooldown",
    Callback = function(value) State.SkillCooldown = value end,
})

SkillTab:CreateSection("Key Hold Timings")

SkillTab:CreateSlider({
    Name = "Hold (Z)",
    Range = {0, 5},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = 0,
    Flag = "HoldZ",
    Callback = function(value) State.HoldZ = value end,
})

SkillTab:CreateSlider({
    Name = "Hold (X)",
    Range = {0, 5},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = 0,
    Flag = "HoldX",
    Callback = function(value) State.HoldX = value end,
})

SkillTab:CreateSlider({
    Name = "Hold (C)",
    Range = {0, 5},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = 0,
    Flag = "HoldC",
    Callback = function(value) State.HoldC = value end,
})

SkillTab:CreateSlider({
    Name = "Hold (V)",
    Range = {0, 5},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = 0,
    Flag = "HoldV",
    Callback = function(value) State.HoldV = value end,
})

-- ============================================================
-- TAB 5: ANTI-BAN
-- ============================================================
local AntiBanTab = Window:CreateTab("Anti-Ban", 4483362458)

AntiBanTab:CreateSection("Anti-Ban Pro System")

AntiBanTab:CreateToggle({
    Name = "Anti-Ban System",
    CurrentValue = true,
    Flag = "AntiBanEnabled",
    Callback = function(value) State.AntiBanEnabled = value end,
})

AntiBanTab:CreateToggle({
    Name = "Jitter Random ±2",
    CurrentValue = true,
    Flag = "JitterEnabled",
    Callback = function(value) State.JitterEnabled = value end,
})

AntiBanTab:CreateToggle({
    Name = "Rate Limit 20Hz",
    CurrentValue = true,
    Flag = "RateLimitEnabled",
    Callback = function(value) State.RateLimitEnabled = value end,
})

AntiBanTab:CreateToggle({
    Name = "Ramp Up Smooth",
    CurrentValue = true,
    Flag = "RampUpEnabled",
    Callback = function(value) State.SpeedRampUp = value end,
})

AntiBanTab:CreateToggle({
    Name = "Legit Mode (cap 60)",
    CurrentValue = false,
    Flag = "LegitMode",
    Callback = function(value) State.LegitMode = value end,
})

AntiBanTab:CreateSlider({
    Name = "Max Speed Cap",
    Range = {50, 500},
    Increment = 10,
    Suffix = " WS",
    CurrentValue = 250,
    Flag = "MaxSpeed",
    Callback = function(value) State.MaxSpeed = value end,
})

AntiBanTab:CreateSection("Emergency")

AntiBanTab:CreateButton({
    Name = "🧹 Panic Cleanup",
    Callback = function()
        resetCharacterPhysics()
        State.SpeedEnabled = false
        State.FlyEnabled = false
        State.NoclipEnabled = false
        State.AntiFlingEnabled = false
        State.AntiVoidEnabled = false
        State.AutoFarmEnabled = false
        AntiBan.currentRampSpeed = 16
        Rayfield:Notify({
            Title = "Anti-Ban",
            Content = "Panic cleanup executed",
            Duration = 3,
            Image = 4483362458
        })
    end,
})

AntiBanTab:CreateButton({
    Name = "🔧 Reset Physics",
    Callback = function()
        resetCharacterPhysics()
        Rayfield:Notify({
            Title = "Anti-Ban",
            Content = "Physics reset to default",
            Duration = 3,
            Image = 4483362458
        })
    end,
})

-- ============================================================
-- TAB 6: SETTINGS
-- ============================================================
local SettingsTab = Window:CreateTab("Settings", 4483362458)

SettingsTab:CreateSection("Character")

SettingsTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
        end
    end,
})

SettingsTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end,
})

SettingsTab:CreateSection("Script")

SettingsTab:CreateButton({
    Name = "Unload Script",
    Callback = function()
        resetCharacterPhysics()
        Rayfield:Destroy()
    end,
})

SettingsTab:CreateParagraph({
    Title = "EXECUTE HUB",
    Content = "Version: v2.0.0 Pro\nDeveloper: x2Swiftz\nTheme: Dark/Red\nTabs: Auto Farm, Speed, Movement, Auto Skills, Anti-Ban, Settings"
})

-- ============================================================
-- CORE LOOPS
-- ============================================================

-- Speed Hack Loop
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
        local speed = getJitteredSpeed(target)

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

-- Cleanup Loop
task.spawn(function()
    while task.wait(0.5) do
        cleanupSpeedInstances()
    end
end)

-- Anti-Fling / Anti-Void Loop
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

-- Noclip Loop
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

-- Auto Farm Loop
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFarmEnabled then
            local char = LocalPlayer.Character
            if not char then continue end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            -- Find nearest enemy/NPC
            local target = nil
            local shortestDist = State.AutoFarmRange or 50

            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") then
                    local isPlayer = Players:GetPlayerFromCharacter(obj)
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 and not isPlayer then
                        local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                        if rootPart then
                            local dist = (rootPart.Position - hrp.Position).Magnitude
                            if dist < shortestDist then
                                shortestDist = dist
                                target = obj
                            end
                        end
                    end
                end
            end

            -- Attack target
            if target then
                local tRoot = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChildWhichIsA("BasePart")
                if tRoot then
                    pcall(function()
                        hrp.CFrame = CFrame.new(tRoot.Position + Vector3.new(0, 3, 0))
                    end)
                    -- Fire all tools
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            pcall(function() tool:Activate() end)
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Collect Drop Loop
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoCollectDrop then
            local char = LocalPlayer.Character
            if not char then continue end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") or obj:IsA("Model") then
                    local name = string.lower(obj.Name)
                    if string.find(name, "drop") or string.find(name, "loot") then
                        local pos = obj:IsA("BasePart") and obj.Position or (obj.PrimaryPart and obj.PrimaryPart.Position)
                        if pos then
                            pcall(function()
                                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                            end)
                        end
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

-- ============================================================
-- NOTIFY
-- ============================================================
Rayfield:Notify({
    Title = "EXECUTE HUB",
    Content = "Loaded successfully — Pro v2.0.0",
    Duration = 5,
    Image = 4483362458
})

print("[EXECUTE HUB] v2.0.0 Rayfield loaded")
print("[EXECUTE HUB] User: " .. LocalPlayer.Name)
print("[EXECUTE HUB] Tabs: Auto Farm, Speed, Movement, Auto Skills, Anti-Ban, Settings")
