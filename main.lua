-- =================================================================
-- ⚡ DONMENU MASTER - QUANTUM UI (AUTO PVP + AUTO FARM EDITION)
-- =================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

while not LocalPlayer do
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

-- ==========================================
-- ⚙️ BẢNG CẤU HÌNH TỔNG (SETTINGS)
-- ==========================================
getgenv().DonMenu = {
    -- Combat & Aim
    Aim = false,
    LegitAim = true,       
    AimOnShoot = true,     
    Smoothness = 0.08,     
    TargetPart = "Head",   
    ShowFOV = true,
    FOV = 120,

    -- Auto PvP & Skill Aim
    SkillAim = false,
    Prediction = 0.15,
    AutoPvP = false,
    AutoDodge = false,
    AutoCombo = false,
    ComboDelay = 0.35,

    -- Auto Farm
    AutoFarmMob = false,
    FarmDistance = 7,
    BringMobs = false,

    -- Player & Visual
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
    FullBright = false,
    FixLag = false
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
-- 📱 1. GIAO DIỆN STYLE QUANTUM HUB
-- ==========================================
pcall(function()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui and pGui:FindFirstChild("DonMenuQuantumUI") then
        pGui.DonMenuQuantumUI:Destroy()
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DonMenuQuantumUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Name = "FloatingBtn"
FloatingBtn.Size = UDim2.new(0, 45, 0, 45)
FloatingBtn.Position = UDim2.new(0, 20, 0.4, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
FloatingBtn.Text = "⚡"
FloatingBtn.TextColor3 = Color3.fromRGB(140, 82, 255)
FloatingBtn.TextSize = 20
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.Active = true
FloatingBtn.Draggable = true
FloatingBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatingBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(140, 82, 255)
FloatStroke.Thickness = 2
FloatStroke.Parent = FloatingBtn

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 310)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(140, 82, 255)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

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
TitleText.Text = "QUANTUM HUB • Auto Farm Edition"
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

FloatingBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

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

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 130, 1, -48)
Sidebar.Position = UDim2.new(0, 6, 0, 44)
Sidebar.BackgroundTransparency = 1
Sidebar.ScrollBarThickness = 0
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.Parent = Sidebar

local ContentHolder = Instance.new("Frame")
ContentHolder.Size = UDim2.new(1, -144, 1, -48)
ContentHolder.Position = UDim2.new(0, 140, 0, 44)
ContentHolder.BackgroundTransparency = 1
ContentHolder.Parent = MainFrame

-- ==========================================
-- 🗂️ HỆ THỐNG TAB & UI COMPONENTS
-- ==========================================
local Tabs = {}
local FirstTab = nil

local function CreateTab(tabName)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 34)
    tabBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
    tabBtn.Text = "  " .. tabName
    tabBtn.TextColor3 = Color3.fromRGB(160, 160, 180)
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.TextSize = 11
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

local function CreateToggle(parentTab, name, settingKey, defaultState, callback)
    if defaultState ~= nil then Settings[settingKey] = defaultState end
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(140, 82, 255) or Color3.fromRGB(24, 24, 34)
    btn.Text = "  " .. name .. (Settings[settingKey] and ": ON" or ": OFF")
    btn.TextColor3 = Settings[settingKey] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
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
        if callback then callback(Settings[settingKey]) end
    end)
end

local function CreateTextBox(parentTab, labelName, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
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
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelName
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.TextSize = 11
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.32, 0, 0.68, 0)
    box.Position = UDim2.new(0.65, 0, 0.16, 0)
    box.BackgroundColor3 = Color3.fromRGB(34, 34, 48)
    box.Text = tostring(defaultVal)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 11
    box.Parent = frame

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = box

    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then callback(num) else box.Text = tostring(defaultVal) end
    end)
end

-- ==========================================
-- 🛠️ 2. TẠO CÁC TAB TÍNH NĂNG
-- ==========================================
-- TAB AUTO FARM MỚI
local FarmTab = CreateTab("🌾 Auto Farm")
CreateToggle(FarmTab, "Auto Farm Quái (Universal)", "AutoFarmMob")
CreateTextBox(FarmTab, "Khoảng Cách Trụ Trên Đầu", Settings.FarmDistance, function(v) Settings.FarmDistance = math.clamp(v, 3, 20) end)
CreateToggle(FarmTab, "Tụ Quái Lại Gần (Bring Mobs)", "BringMobs")

local PvPTab = CreateTab("⚔️ Auto PvP")
CreateToggle(PvPTab, "Aim Skill (Đón Đầu Di Chuyển)", "SkillAim")
CreateTextBox(PvPTab, "Thời Gian Dự Đoán (0.1-0.5)", Settings.Prediction, function(v) Settings.Prediction = math.clamp(v, 0.05, 1) end)
CreateToggle(PvPTab, "Tự Động Áp Sát & Đánh", "AutoPvP")
CreateToggle(PvPTab, "Né Chiêu (Auto Dodge)", "AutoDodge")
CreateToggle(PvPTab, "Tự Động Combo Skill (Z,X,C,V)", "AutoCombo")
CreateTextBox(PvPTab, "Delay Skill (giây)", Settings.ComboDelay, function(v) Settings.ComboDelay = math.clamp(v, 0.1, 2) end)

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

local function ApplyFixLag()
    pcall(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                v.Enabled = false
            end
        end
        Lighting.GlobalShadows = false
        Lighting.Brightness = 1
    end)
end
CreateToggle(VisualTab, "Fix Lag (Tối ưu FPS)", "FixLag", false, function(state) if state then ApplyFixLag() end end)

local MiscTab = CreateTab("🚀 Misc")
CreateToggle(MiscTab, "Fly (Bay)", "Fly")
CreateTextBox(MiscTab, "Tốc độ Fly", Settings.FlySpeed, function(v) Settings.FlySpeed = v end)
CreateToggle(MiscTab, "Click TP (Ctrl+Click)", "ClickTP")

-- ==========================================
-- ⚙️ 3. LOGIC HỆ THỐNG AUTO FARM QUÁI
-- ==========================================
local function GetClosestMob()
    local closestMob = nil
    local minDist = math.huge
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if not hrp then return nil end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Parent and obj.Parent ~= char then
            local enemyChar = obj.Parent
            local isPlayer = Players:GetPlayerFromCharacter(enemyChar)
            
            if not isPlayer and obj.Health > 0 then
                local eHrp = enemyChar:FindFirstChild("HumanoidRootPart") or enemyChar:FindFirstChild("Torso")
                if eHrp then
                    local dist = (hrp.Position - eHrp.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closestMob = enemyChar
                    end
                end
            end
        end
    end
    return closestMob
end

-- VÒNG LẶP AUTO FARM QUÁI
task.spawn(function()
    while task.wait(0.05) do
        if Settings.AutoFarmMob then
            local mob = GetClosestMob()
            if mob then
                local mHrp = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso")
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                if mHrp and hrp then
                    -- Bay và giữ khoảng cách an toàn ngay trên đầu quái
                    hrp.CFrame = CFrame.new(mHrp.Position + Vector3.new(0, Settings.FarmDistance or 7, 0), mHrp.Position)

                    -- Gom quái xung quanh lại gần nếu bật Bring Mobs
                    if Settings.BringMobs then
                        for _, obj in ipairs(workspace:GetDescendants()) do
                            if obj:IsA("Humanoid") and obj.Parent and obj.Parent ~= char and obj.Parent ~= mob then
                                local otherChar = obj.Parent
                                if not Players:GetPlayerFromCharacter(otherChar) and obj.Health > 0 then
                                    local oHrp = otherChar:FindFirstChild("HumanoidRootPart")
                                    if oHrp and (oHrp.Position - mHrp.Position).Magnitude < 35 then
                                        oHrp.CFrame = mHrp.CFrame
                                        oHrp.CanCollide = false
                                    end
                                end
                            end
                        end
                    end

                    -- Tự động bấm chuột đánh quái
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    task.wait(0.02)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end
            end
        end
    end
end)

-- ==========================================
-- ⚙️ LOGIC CÁC TÍNH NĂNG KHÁC
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
            local tar
