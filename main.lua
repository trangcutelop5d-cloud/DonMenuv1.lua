-- =================================================================
-- 🚀 DONMENU MASTER - REDZ HUD STYLE (FULL TÍNH NĂNG MỚI NHẤT)
-- =================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- ⚙️ BẢNG CẤU HÌNH TỔNG (SETTINGS)
-- ==========================================
getgenv().DonMenu = {
    Aim = false,
    ShowFOV = true,
    FOV = 120,
    ESP = false,
    Speed = false,
    SpeedValue = 50,
    Jump = false,
    JumpValue = 100,
    InfJump = false,
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
    ClickTP = false,
    FullBright = false
}
local Settings = getgenv().DonMenu

-- Khởi tạo vòng FOV an toàn
local FOVCircle = nil
pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Thickness = 1.5
    FOVCircle.NumSides = 60
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Filled = false
    FOVCircle.Visible = false
end)

-- ==========================================
-- 📱 1. GIAO DIỆN REDZ HUD (RỘNG & LƯỚI 2 CỘT)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DonMenuRedzHUD"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 470, 0, 310)
MainFrame.Position = UDim2.new(0.5, -235, 0.5, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(45, 45, 45)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Thanh Tiêu Đề
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleCover = Instance.new("Frame")
TitleCover.Size = UDim2.new(1, 0, 0, 6)
TitleCover.Position = UDim2.new(0, 0, 1, -6)
TitleCover.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleCover.BorderSizePixel = 0
TitleCover.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 12, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "redz hud • DonMenu Master Edition"
TitleText.TextColor3 = Color3.fromRGB(220, 220, 220)
TitleText.TextSize = 13
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Nút Thu Nhỏ (-)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 26, 0, 26)
MinimizeBtn.Position = UDim2.new(1, -34, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 16
MinimizeBtn.Parent = TitleBar

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = MinimizeBtn

-- Kéo Thả Menu (Mouse & Touch)
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

-- Khung Cuộn 2 Cột (UIGridLayout)
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -16, 1, -50)
Container.Position = UDim2.new(0, 8, 0, 42)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 3
Container.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
Container.Parent = MainFrame

local UIGrid = Instance.new("UIGridLayout")
UIGrid.CellSize = UDim2.new(0, 220, 0, 36)
UIGrid.CellPadding = UDim2.new(0, 8, 0, 8)
UIGrid.Parent = Container

-- Logic Thu Nhỏ / Phóng To
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        Container.Visible = false
        MainFrame.Size = UDim2.new(0, 470, 0, 36)
        MinimizeBtn.Text = "+"
    else
        Container.Visible = true
        MainFrame.Size = UDim2.new(0, 470, 0, 310)
        MinimizeBtn.Text = "-"
    end
end)

-- ==========================================
-- 🔘 2. CÁC HÀM TẠO NÚT BẤM & INPUT
-- ==========================================
local function CreateToggle(name, settingKey)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 220, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    btn.Text = "  " .. name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(45, 45, 45)
    stroke.Thickness = 1
    stroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        if Settings[settingKey] then
            btn.Text = "  " .. name .. ": ON"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.BackgroundColor3 = Color3.fromRGB(45, 110, 60)
            stroke.Color = Color3.fromRGB(70, 180, 90)
        else
            btn.Text = "  " .. name .. ": OFF"
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            stroke.Color = Color3.fromRGB(45, 45, 45)
        end
    end)
end

local function CreateTextBox(labelName, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 36)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    frame.Parent = Container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(45, 45, 45)
    stroke.Thickness = 1
    stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelName
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 12
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.3, 0, 0.7, 0)
    box.Position = UDim2.new(0.68, 0, 0.15, 0)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.Text = tostring(defaultVal)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 12
    box.Parent = frame

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = box

    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then
            callback(num)
        else
            box.Text = tostring(defaultVal)
        end
    end)
end

-- ==========================================
-- 🛠️ 3. DÀN TÍNH NĂNG ĐẦY ĐỦ TRÊN MENU
-- ==========================================
CreateToggle("🎯 Aim Lock", "Aim")
CreateToggle("⭕ Hiện Vòng FOV", "ShowFOV")
CreateTextBox("Cỡ FOV", Settings.FOV, function(v) Settings.FOV = v end)

CreateToggle("👁️ ESP Highlight", "ESP")

CreateToggle("⚡ Speed Hack", "Speed")
CreateTextBox("Tốc độ Speed", Settings.SpeedValue, function(v) Settings.SpeedValue = v end)

CreateToggle("🦘 Nhảy Cao", "Jump")
CreateTextBox("Lực Nhảy", Settings.JumpValue, function(v) Settings.JumpValue = v end)

CreateToggle("🕊️ Fly (Bay)", "Fly")
CreateTextBox("Tốc độ Fly", Settings.FlySpeed, function(v) Settings.FlySpeed = v end)

CreateToggle("👻 Noclip Xuyên Tường", "Noclip")
CreateToggle("🚀 Nhảy Vô Hạn", "InfJump")
CreateToggle("⚡ Click TP (Ctrl+Click)", "ClickTP")
CreateToggle("💡 FullBright (Sáng Đêm)", "FullBright")

-- ==========================================
-- ⚙️ 4. LOGIC XỬ LÝ CHÍNH
-- ==========================================

-- Aim Lock Tìm Mục Tiêu Gần Nhất
local function GetClosestPlayer()
    local target = nil
    local minDist = Settings.FOV
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

-- Nhảy vô hạn
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Click TP
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if Settings.ClickTP and input.UserInputType == Enum.UserInputType.MouseButton1 then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            local mousePos = UserInputService:GetMouseLocation()
            local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude

            local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
            if raycastResult and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, 3, 0))
            end
        end
    end
end)

-- Fly
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

-- ESP Folder
local HighlightFolder = Instance.new("Folder", workspace)
HighlightFolder.Name = "DonMenuESP"

-- ==========================================
-- 🔄 5. VÒNG LẶP RENDERSTEPPED & STEPPED
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
    -- Update FOV
    if FOVCircle then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = Settings.FOV
        FOVCircle.Visible = Settings.Aim and Settings.ShowFOV
    end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    -- Aim
    if Settings.Aim then
        local target = GetClosestPlayer()
        if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
    end

    -- Speed & Jump
    if hum then
        if Settings.Speed then hum.WalkSpeed = Settings.SpeedValue end
        if Settings.Jump then
            hum.UseJumpPower = true
            hum.JumpPower = Settings.JumpValue
        end
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

    -- FullBright
    if Settings.FullBright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    end
end)
