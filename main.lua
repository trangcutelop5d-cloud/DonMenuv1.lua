-- =================================================================
-- ⚡ DONMENU MASTER - QUANTUM UI (FIXED & OPTIMIZED EDITION)
-- =================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait()
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

-- Khởi tạo vòng FOV
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
local CoreGui = game:GetService("CoreGui")
local ParentTarget = (gethui and gethui()) or CoreGui

pcall(function()
    if ParentTarget:FindFirstChild("DonMenuQuantumUI") then
        ParentTarget.DonMenuQuantumUI:Destroy()
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DonMenuQuantumUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = ParentTarget

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

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Position = UDim2.new(0, 16, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "QUANTUM HUB • Fix Edition"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 14
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

FloatingBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
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

    btn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        if Settings[settingKey] then
            btn.Text = "  " .. name .. ": ON"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.BackgroundColor3 = Color3.fromRGB(140, 82, 255)
        else
            btn.Text = "  " .. name .. ": OFF"
            btn.TextColor3 = Color3.fromRGB(180, 180, 200)
            btn.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
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

    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then callback(num) else box.Text = tostring(defaultVal) end
    end)
end

-- TẠO CÁC TAB
local FarmTab = CreateTab("🌾 Auto Farm")
CreateToggle(FarmTab, "Auto Farm Quái (Universal)", "AutoFarmMob")
CreateTextBox(FarmTab, "Khoảng Cách Trụ Trên Đầu", Settings.FarmDistance, function(v) Settings.FarmDistance = math.clamp(v, 3, 20) end)

local PvPTab = CreateTab("⚔️ Auto PvP")
CreateToggle(PvPTab, "Aim Skill", "SkillAim")
CreateToggle(PvPTab, "Tự Động Áp Sát & Đánh", "AutoPvP")
CreateToggle(PvPTab, "Auto Combo (Z,X,C,V)", "AutoCombo")

local CombatTab = CreateTab("🎯 Combat")
CreateToggle(CombatTab, "Aim Lock", "Aim")
CreateToggle(CombatTab, "Bắn Mới Aim", "AimOnShoot", true)
CreateToggle(CombatTab, "Hiện Vòng FOV", "ShowFOV")

local PlayerTab = CreateTab("⚡ Player")
CreateToggle(PlayerTab, "Speed Hack", "Speed")
CreateTextBox(PlayerTab, "Tốc độ", Settings.SpeedValue, function(v) Settings.SpeedValue = v end)
CreateToggle(PlayerTab, "Nhảy Vô Hạn", "InfJump")
CreateToggle(PlayerTab, "Noclip Xuyên Tường", "Noclip")

local VisualTab = CreateTab("👁️ Visual")
CreateToggle(VisualTab, "ESP Người Chơi", "ESP")
CreateToggle(VisualTab, "FullBright", "FullBright")

-- ==========================================
-- 🛠️ HÀM MÔ PHỎNG ĐÁNH VÀ TÌM QUÁI TỐI ƯU
-- ==========================================
local function SafeClick()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end)
    pcall(function()
        VirtualUser:Button1Down(Vector2.new(0, 0))
        task.wait(0.01)
        VirtualUser:Button1Up(Vector2.new(0, 0))
    end)
    if mouse1click then
        pcall(mouse1click)
    end
end

local function GetClosestMob()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local closestMob = nil
    local minDist = math.huge

    -- Quét các Model trực tiếp ở workspace để tránh Lag
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= char then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local eHrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso")
            
            if hum and eHrp and hum.Health > 0 then
                if not Players:GetPlayerFromCharacter(obj) then
                    local dist = (hrp.Position - eHrp.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closestMob = obj
                    end
                end
            end
        end
    end
    return closestMob
end

-- VÒNG LẶP AUTO FARM QUÁI (AN TOÀN BẢO VỆ BỞI PCALL)
task.spawn(function()
    while task.wait(0.03) do
        if Settings.AutoFarmMob then
            pcall(function()
                local mob = GetClosestMob()
                if mob then
                    local mHrp = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso") or mob:FindFirstChild("UpperTorso")
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if mHrp and hrp then
                        -- Bay treo cố định trên đầu quái
                        hrp.CFrame = CFrame.new(mHrp.Position + Vector3.new(0, Settings.FarmDistance or 7, 0), mHrp.Position)
                        
                        -- Thực hiện đánh quái
                        SafeClick()
                    end
                end
            end)
        end
    end
end)

-- VÒNG LẶP HỖ TRỢ NOCLIP
RunService.Stepped:Connect(function()
    pcall(function()
        if Settings.Noclip or Settings.AutoFarmMob then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end)

-- VÒNG LẶP RENDER CHÍNH
RunService.RenderStepped:Connect(function()
    pcall(function()
        local Camera = workspace.CurrentCamera
        if FOVCircle and Camera then
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            FOVCircle.Radius = Settings.FOV
            FOVCircle.Visible = Settings.ShowFOV and (Settings.Aim or Settings.SkillAim)
        end

        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if Settings.Speed then hum.WalkSpeed = Settings.SpeedValue end
            if Settings.Jump then 
                hum.UseJumpPower = true
                hum.JumpPower = Settings.JumpValue 
            end
        end
    end)
end)

UserInputService.JumpRequest:Connect(function()
    pcall(function()
        if Settings.InfJump then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
end)

print("[Quantum Hub] Đã nạp thành công phiên bản sửa lỗi!")
