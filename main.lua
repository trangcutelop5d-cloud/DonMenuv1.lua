-- =================================================================
-- 🚀 DONMENU MOBILE - BẢN ĐẦY ĐỦ + GIAO DIỆN KÉO THẢ (DRAGGABLE GUI)
-- =================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Bảng cấu hình
getgenv().DonMenu = {
    Aim = false,
    ESP = false,
    Speed = false,
    SpeedValue = 50,
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
    InfJump = false
}
local Settings = getgenv().DonMenu

-- ==========================================
-- 📱 1. TẠO GUI & BỘ KÉO THẢ (DRAG) CHO MOBILE
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DonMenuMobileUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 180, 0, 260)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Thanh Tiêu Đề (Nơi đè ngón tay để kéo Menu)
local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TitleBar.Text = "🖐️ DonMenu (Kéo ở đây)"
TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.TextSize = 13
TitleBar.Font = Enum.Font.SourceSansBold
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

-- Xử lý logic kéo thả mượt mà trên màn hình cảm ứng Mobile
local dragging, dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ==========================================
-- 🔘 2. TẠO CÁC NÚT BẤM TRÊN MENU
-- ==========================================
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -10, 1, -45)
Container.Position = UDim2.new(0, 5, 0, 40)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 2
Container.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 5)
UIList.Parent = Container

local function CreateToggle(name, settingKey)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.Parent = Container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        if Settings[settingKey] then
            btn.Text = name .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
        else
            btn.Text = name .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        end
    end)
end

CreateToggle("🎯 Aim Lock", "Aim")
CreateToggle("👁️ ESP Box", "ESP")
CreateToggle("⚡ Speed (50)", "Speed")
CreateToggle("🕊️ Fly (Bay)", "Fly")
CreateToggle("👻 Noclip", "Noclip")
CreateToggle("🦘 Inf Jump", "InfJump")

-- ==========================================
-- ⚙️ 3. LOGIC HỆ THỐNG
-- ==========================================

-- Aim
local function GetClosestPlayer()
    local target = nil
    local minDist = 200
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if dist < minDist then
                    minDist = dist
                    target = p.Character.Head
                end
            end
        end
    end
    return target
end

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ESP Highlight
local HighlightFolder = Instance.new("Folder", workspace)
HighlightFolder.Name = "DonMenuESP"

-- Fly Logic
local flyBV, flyBG
local function StartFly()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hrp and hum then
        hum.PlatformStand = true
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        flyBV.Velocity = Vector3.new(0,0,0)
        flyBV.Parent = hrp
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        flyBG.CFrame = hrp.CFrame
        flyBG.Parent = hrp
    end
end

local function StopFly()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
end

-- ==========================================
-- 🔄 4. VÒNG LẶP CHÍNH (RENDER & STEPPED)
-- ==========================================
RunService.Stepped:Connect(function()
    if Settings.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    -- Aim
    if Settings.Aim then
        local target = GetClosestPlayer()
        if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
    end

    -- Speed
    if hum then
        hum.WalkSpeed = Settings.Speed and Settings.SpeedValue or 16
    end

    -- ESP
    HighlightFolder:ClearAllChildren()
    if Settings.ESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hl = Instance.new("Highlight")
                hl.Adornee = p.Character
                local isTeam = p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team
                hl.FillColor = isTeam and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
                hl.Parent = HighlightFolder
            end
        end
    end

    -- Fly
    if Settings.Fly and hrp then
        if not flyBV or not flyBV.Parent then StartFly() end
        if flyBV and flyBG then
            flyBV.Velocity = Camera.CFrame.LookVector * Settings.FlySpeed
            flyBG.CFrame = Camera.CFrame
        end
    else
        StopFly()
    end
end)
