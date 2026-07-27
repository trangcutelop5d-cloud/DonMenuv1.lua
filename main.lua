-- =================================================================
-- ⚡ DONMENU MASTER - QUANTUM UI (ULTIMATE FIX - BẬT LÀ LÊN)
-- =================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local Camera = workspace.CurrentCamera

-- Đợi LocalPlayer load xong hẳn để tránh lỗi nil lúc mới vào game
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

-- ==========================================
-- ⚙️ BẢNG CẤU HÌNH TỔNG (SETTINGS)
-- ==========================================
getgenv().DonMenu = {
    Aim = false,
    LegitAim = true,       
    AimOnShoot = true,     
    Smoothness = 0.08,     
    TargetPart = "Head",   
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
    if Drawing then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Color = Color3.fromRGB(140, 82, 255)
        FOVCircle.Thickness = 1.5
        FOVCircle.NumSides = 60
        FOVCircle.Radius = Settings.FOV
        FOVCircle.Filled = false
        FOVCircle.Visible = false
    end
end)

-- ==========================================
-- 📱 1. GIAO DIỆN STYLE QUANTUM HUB (Đa tầng bảo vệ)
-- ==========================================
pcall(function()
    if gethui and gethui():FindFirstChild("DonMenuQuantumUI") then
        gethui().DonMenuQuantumUI:Destroy()
    end
    if game:GetService("CoreGui"):FindFirstChild("DonMenuQuantumUI") then
        game:GetService("CoreGui").DonMenuQuantumUI:Destroy()
    end
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui and pGui:FindFirstChild("DonMenuQuantumUI") then
        pGui.DonMenuQuantumUI:Destroy()
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DonMenuQuantumUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- Tự động tìm nơi chứa GUI tối ưu nhất trên Mobile & PC
local guiSuccess = pcall(function()
    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game:GetService("CoreGui")
    else
        ScreenGui.Parent = game:GetService("CoreGui")
    end
end)

if not guiSuccess then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Khung chính Quantum
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 560, 0, 330)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -165)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(140, 82, 255)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Thanh Tiêu Đề
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleCover = Instance.new("Frame")
TitleCover.Size = UDim2.new(1, 0, 0, 10)
TitleCover.Position = UDim2.new(0, 0, 1, -10)
TitleCover.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TitleCover.BorderSizePixel = 0
TitleCover.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Position = UDim2.new(0, 16, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "QUANTUM HUB • DonMenu (Fixed)"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 14
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.Position = UDim2.new(0, 0, 1, -2)
AccentLine.BackgroundColor3 = Color3.fromRGB(140, 82, 255)
AccentLine.BorderSizePixel = 0
AccentLine.Parent = TitleBar

-- Nút Thu Nhỏ (-)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Position = UDim2.new(1, -36, 0, 6)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 16
MinimizeBtn.Parent = TitleBar

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = MinimizeBtn

-- Kéo Thả Menu
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

-- Sidebar Tabs
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 140, 1, -48)
Sidebar.Position = UDim2.new(0, 6, 0, 44)
Sidebar.BackgroundTransparency = 1
Sidebar.ScrollBarThickness = 0
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.Parent = Sidebar

-- Content Holder
local ContentHolder = Instance.new("Frame")
ContentHolder.Size = UDim2.new(1, -156, 1, -48)
ContentHolder.Position = UDim2.new(0, 150, 0, 44)
ContentHolder.BackgroundTransparency = 1
ContentHolder.Parent = MainFrame

-- Thu Nhỏ / Phóng To Menu
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        Sidebar.Visible = false
        ContentHolder.Visible = false
        MainFrame.Size = UDim2.new(0, 560, 0, 40)
        MinimizeBtn.Text = "+"
    else
        Sidebar.Visible = true
        ContentHolder.Visible = true
        MainFrame.Size = UDim2.new(0, 560, 0, 330)
        MinimizeBtn.Text = "-"
    end
end)

-- ==========================================
-- 🗂️ HỆ THỐNG TAB & UI COMPONENTS
-- ==========================================
local Tabs = {}
local FirstTab = nil

local function CreateTab(tabName)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 36)
    tabBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
    tabBtn.Text = "  " .. tabName
    tabBtn.TextColor3 = Color3.fromRGB(160, 160, 180)
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.TextSize = 12
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = Sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = tabBtn

    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.ScrollBarThickness = 3
    tabContent.ScrollBarImageColor3 = Color3.fromRGB(140, 82, 255)
    tabContent.Visible = false
    tabContent.Parent = ContentHolder

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = tabContent

    local pad = Instance.new("UIPadding")
    pad.PaddingRight = UDim.new(0, 6)
    pad.Parent = tabContent

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Content.Visible = false
            t.Button.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
            t.Button.TextColor3 = Color3.fromRGB(160, 160, 180)
        end
        tabContent.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(140, 82, 255)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    if not FirstTab then
        FirstTab = {Button = tabBtn, Content = tabContent}
    end

    table.insert(Tabs, {Button = tabBtn, Content = tabContent})
    return tabContent
end

task.defer(function()
    if FirstTab then
        FirstTab.Content.Visible = true
        FirstTab.Button.BackgroundColor3 = Color3.fromRGB(140, 82, 255)
        FirstTab.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

local function CreateToggle(parentTab, name, settingKey, defaultState)
    if defaultState ~= nil then Settings[settingKey] = defaultState end
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(140, 82, 255) or Color3.fromRGB(24, 24, 34)
    btn.Text = "  " .. name .. (Settings[settingKey] and ": ON" or ": OFF")
    btn.TextColor3 = Settings[settingKey] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = parentTab

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Settings[settingKey] and Color3.fromRGB(180, 130, 255) or Color3.fromRGB(40, 40, 55)
    stroke.Thickness = 1
    stroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        if Settings[settingKey] then
            btn.Text = "  " .. name .. ": ON"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.BackgroundColor3 = Color3.fromRGB(140, 82, 255)
            stroke.Color = Color3.fromRGB(180, 130, 255)
        else
            btn.Text = "  " .. name .. ": OFF"
            btn.TextColor3 = Color3.fromRGB(180, 180, 200)
            btn.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
            stroke.Color = Color3.fromRGB(40, 40, 55)
        end
    end)
end

local function CreateTextBox(parentTab, labelName, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
    frame.Parent = parentTab

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(40, 40, 55)
    stroke.Thickness = 1
    stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelName
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.TextSize = 12
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.28, 0, 0.68, 0)
    box.Position = UDim2.new(0.69, 0, 0.16, 0)
    box.BackgroundColor3 = Color3.fromRGB(34, 34, 48)
    box.Text = tostring(defaultVal)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 12
    box.Parent = frame

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
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
-- 🛠️ 2. TẠO CÁC TAB & TÍNH NĂNG
-- ==========================================
local CombatTab = CreateTab("🎯 Combat")
CreateToggle(CombatTab, "Aim Lock", "Aim")
CreateToggle(CombatTab, "Bắn Mới Aim", "AimOnShoot", true)
CreateToggle(CombatTab, "Aim Tự Nhiên (Smooth)", "LegitAim", true)
CreateTextBox(CombatTab, "Độ Mượt (0.01-0.2)", Settings.Smoothness, function(v) Settings.Smoothness = math.clamp(v, 0.01, 1) end)
CreateToggle(CombatTab, "Hiện Vòng FOV", "ShowFOV")
CreateTextBox(CombatTab, "Cỡ FOV", Settings.FOV, function(v) Settings.FOV = v end)

local PlayerTab = CreateTab("⚡ Player")
CreateToggle(PlayerTab, "Speed Hack", "Speed")
CreateTextBox(PlayerTab, "Tốc độ Speed", Settings.SpeedValue, function(v) Settings.SpeedValue = v end)
CreateToggle(PlayerTab, "Nhảy Cao", "Jump")
CreateTextBox(PlayerTab, "Lực Nhảy", Settings.JumpValue, function(v) Settings.JumpValue = v end)
CreateToggle(PlayerTab, "Nhảy Vô Hạn", "InfJump")
CreateToggle(PlayerTab, "Noclip Xuyên Tường", "Noclip")

local VisualTab = CreateTab("👁️ Visual")
CreateToggle(VisualTab, "ESP Tên & Khoảng Cách", "ESP")
CreateToggle(VisualTab, "FullBright (Sáng Đêm)", "FullBright")

local MiscTab = CreateTab("🚀 Misc")
CreateToggle(MiscTab, "Fly (Bay)", "Fly")
CreateTextBox(MiscTab, "Tốc độ Fly", Settings.FlySpeed, function(v) Settings.FlySpeed = v end)
CreateToggle(MiscTab, "Click TP (Ctrl+Click)", "ClickTP")

-- ==========================================
-- ⚙️ 3. LOGIC XỬ LÝ HỆ THỐNG
-- ==========================================
local isShooting = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isShooting = true
    end

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

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isShooting = false
    end
end)

local function GetClosestPlayer()
    local target = nil
    local minDist = Settings.FOV
    local partName = Settings.TargetPart or "Head"

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(partName) then
            local targetPart = p.Character[partName]
            local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if dist < minDist then
                    minDist = dist
                    target = targetPart
                end
            end
        end
    end
    return target
end

UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

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

local ESPFolder = Instance.new("Folder", workspace)
ESPFolder.Name = "DonMenuESP"

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
    if FOVCircle then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = Settings.FOV
        FOVCircle.Visible = Settings.Aim and Settings.ShowFOV
    end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if Settings.Aim then
        local canAim = not Settings.AimOnShoot or isShooting
        if canAim then
            local target = GetClosestPlayer()
            if target then
                local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
                if Settings.LegitAim then
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Smoothness)
                else
                    Camera.CFrame = targetCFrame
                end
            end
        end
    end

    if hum then
        if Settings.Speed then hum.WalkSpeed = Settings.SpeedValue end
        if Settings.Jump then
            hum.UseJumpPower = true
            hum.JumpPower = Settings.JumpValue
        end
    end

    ESPFolder:ClearAllChildren()
    if Settings.ESP then
        local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local pChar = p.Character
                local pHrp = pChar:FindFirstChild("HumanoidRootPart")
                local pHead = pChar:FindFirstChild("Head")

                if pHrp and pHead then
                    local isTeam = p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team
                    local espColor = isTeam and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)

                    local hl = Instance.new("Highlight")
                    hl.Adornee = pChar
                    hl.FillColor = espColor
                    hl.OutlineColor = espColor
                    hl.FillT
