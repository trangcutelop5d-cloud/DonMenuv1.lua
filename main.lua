-- =================================================================
-- ⚡ QUANTUM HUB - HERMANOS'DEV EDITION (FULL BLOX FRUITS / RPG)
-- =================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do task.wait() LocalPlayer = Players.LocalPlayer end

-- ==========================================
-- ⚙️ BẢNG CẤU HÌNH TỔNG (SETTINGS)
-- ==========================================
getgenv().DonMenu = {
    -- Auto Farm Level & Quest
    AutoFarmLevel = false,
    AutoSelectQuest = true,
    BringMob = false,        -- Gom quái lại 1 điểm
    FastAttack = false,      -- Đánh siêu tốc
    FarmDistance = 7,
    AutoEquip = true,
    
    -- Auto Chest & Farm Khác
    AutoChest = false,
    AutoStats = false,
    StatSelect = "Melee",    -- Melee, Defense, Sword, Gun, Blox Fruit

    -- Combat & Aim
    Aim = false,
    LegitAim = true,       
    Smoothness = 0.1,        -- Tốc độ Aim (0.01 = Khóa cứng, 0.5 = Mượt)
    TargetPart = "Head",   
    ShowFOV = true,
    FOV = 150,

    -- Player & Visual
    ESP = false,           
    Speed = false,
    SpeedValue = 50,
    Jump = false,
    JumpValue = 100,
    InfJump = false,
    Noclip = false,
    FullBright = false
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
-- 📱 GIAO DIỆN QUANTUM HUB
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

Instance.new("UICorner", FloatingBtn).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatingBtn)
FloatStroke.Color = Color3.fromRGB(140, 82, 255)
FloatStroke.Thickness = 2

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 530, 0, 350)
MainFrame.Position = UDim2.new(0.5, -265, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(140, 82, 255)
UIStroke.Thickness = 1.5

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Position = UDim2.new(0, 16, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "QUANTUM HUB • HERMANOS'DEV EDITION"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 13
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

FloatingBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 135, 1, -48)
Sidebar.Position = UDim2.new(0, 6, 0, 44)
Sidebar.BackgroundTransparency = 1
Sidebar.ScrollBarThickness = 0
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 6)

local ContentHolder = Instance.new("Frame")
ContentHolder.Size = UDim2.new(1, -148, 1, -48)
ContentHolder.Position = UDim2.new(0, 144, 0, 44)
ContentHolder.BackgroundTransparency = 1
ContentHolder.Parent = MainFrame

-- TAB UI
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
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)

    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.ScrollBarThickness = 3
    tabContent.ScrollBarImageColor3 = Color3.fromRGB(140, 82, 255)
    tabContent.Visible = false
    tabContent.Parent = ContentHolder

    local layout = Instance.new("UIListLayout", tabContent)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)

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

    if not FirstTab then FirstTab = {Button = tabBtn, Content = tabContent} end
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
    btn.Size = UDim2.new(1, -6, 0, 36)
    btn.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(140, 82, 255) or Color3.fromRGB(24, 24, 34)
    btn.Text = "  " .. name .. (Settings[settingKey] and ": ON" or ": OFF")
    btn.TextColor3 = Settings[settingKey] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = parentTab
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        btn.Text = "  " .. name .. (Settings[settingKey] and ": ON" or ": OFF")
        btn.TextColor3 = Settings[settingKey] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 200)
        btn.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(140, 82, 255) or Color3.fromRGB(24, 24, 34)
        if callback then callback(Settings[settingKey]) end
    end)
end

local function CreateTextBox(parentTab, labelName, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -6, 0, 36)
    frame.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
    frame.Parent = parentTab
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelName
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.TextSize = 11
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.28, 0, 0.68, 0)
    box.Position = UDim2.new(0.68, 0, 0.16, 0)
    box.BackgroundColor3 = Color3.fromRGB(34, 34, 48)
    box.Text = tostring(defaultVal)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 11
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then callback(num) else box.Text = tostring(defaultVal) end
    end)
end

local function CreateButton(parentTab, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(34, 34, 48)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.Parent = parentTab
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        if callback then callback(btn) end
    end)
end

-- ==========================================
-- 🗂️ CÁC TAB CHỨC NĂNG HERMANOS'DEV
-- ==========================================

-- TAB MAIN FARM
local MainTab = CreateTab("🌾 Auto Farm")
CreateToggle(MainTab, "Auto Farm Level + Quest", "AutoFarmLevel")
CreateToggle(MainTab, "Tự Động Nhận Quest", "AutoSelectQuest", true)
CreateToggle(MainTab, "Gom Quái Lại (Bring Mob)", "BringMob")
CreateToggle(MainTab, "Đánh Siêu Tốc (Fast Attack)", "FastAttack")
CreateToggle(MainTab, "Tự Động Cầm Vũ Khí", "AutoEquip", true)
CreateTextBox(MainTab, "Khoảng Cách Đứng Trên Quái", Settings.FarmDistance, function(v) Settings.FarmDistance = math.clamp(v, 1, 20) end)

-- TAB EXTRA FARM
local ExtraTab = CreateTab("🎁 Extra Farm")
CreateToggle(ExtraTab, "Auto Nhặt Rương (Auto Chest)", "AutoChest")
CreateToggle(ExtraTab, "Auto Cộng Điểm Stats", "AutoStats")
CreateButton(ExtraTab, "Stats Ưu Tiên: " .. Settings.StatSelect, function(btn)
    local list = {"Melee", "Defense", "Sword", "Gun", "Blox Fruit"}
    local idx = table.find(list, Settings.StatSelect) or 1
    idx = (idx % #list) + 1
    Settings.StatSelect = list[idx]
    btn.Text = "Stats Ưu Tiên: " .. Settings.StatSelect
end)

-- TAB COMBAT & AIM
local CombatTab = CreateTab("🎯 Combat & Aim")
CreateToggle(CombatTab, "Aim Lock (Khóa Tâm)", "Aim")
CreateTextBox(CombatTab, "Tốc Độ Aim (0.01 Nhanh -> 0.5 Mượt)", Settings.Smoothness, function(v) Settings.Smoothness = math.clamp(v, 0.01, 1) end)
CreateTextBox(CombatTab, "Kích Thước FOV", Settings.FOV, function(v) Settings.FOV = v end)
CreateToggle(CombatTab, "Hiện Vòng FOV", "ShowFOV")

-- TAB PLAYER & VISUAL
local PlayerTab = CreateTab("⚡ Player / Visual")
CreateToggle(PlayerTab, "ESP Người Chơi", "ESP")
CreateToggle(PlayerTab, "Speed Hack", "Speed")
CreateTextBox(PlayerTab, "Chỉnh Speed", Settings.SpeedValue, function(v) Settings.SpeedValue = v end)
CreateToggle(PlayerTab, "Jump Hack", "Jump")
CreateTextBox(PlayerTab, "Chỉnh Độ Nhảy", Settings.JumpValue, function(v) Settings.JumpValue = v end)
CreateToggle(PlayerTab, "Nhảy Vô Hạn", "InfJump")
CreateToggle(PlayerTab, "Noclip Xuyên Tường", "Noclip")
CreateToggle(PlayerTab, "FullBright (Sáng Đêm)", "FullBright")

-- ==========================================
-- 🛠️ LOGIC AUTO FARM & BRING MOB & FAST ATTACK
-- ==========================================
local function EquipWeapon()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if not char:FindFirstChildOfClass("Tool") then
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            local tool = backpack:FindFirstChildOfClass("Tool")
            if tool then hum:EquipTool(tool) end
        end
    end

    if Settings.FastAttack then
        pcall(function()
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end)
    else
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end)
    end
end

local function GetTargetMob()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end

    local targetMob = nil
    local minDist = math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= char then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
            
            if hum and hrp and hum.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                local dist = (char.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    targetMob = obj
                end
            end
        end
    end
    return targetMob
end

-- VÒNG LẶP AUTOMATION (FARM + BRING MOB + AUTO STATS + AUTO CHEST)
task.spawn(function()
    while task.wait(0.02) do
        -- 1. Auto Farm Level & Mob
        if Settings.AutoFarmLevel then
            pcall(function()
                local mob = GetTargetMob()
                if mob then
                    local mHrp = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso")
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if mHrp and hrp then
                        -- Bay lên đầu quái
                        hrp.CFrame = CFrame.new(mHrp.Position + Vector3.new(0, Settings.FarmDistance or 7, 0), mHrp.Position)
                        
                        -- Bring Mob (Gom quái lại một chỗ)
                        if Settings.BringMob then
                            for _, obj in ipairs(workspace:GetDescendants()) do
                                if obj:IsA("Model") and obj ~= mob and obj ~= char then
                                    local oHum = obj:FindFirstChildOfClass("Humanoid")
                                    local oHrp = obj:FindFirstChild("HumanoidRootPart")
                                    if oHum and oHrp and oHum.Health > 0 and (oHrp.Position - mHrp.Position).Magnitude < 300 then
                                        oHrp.CFrame = mHrp.CFrame
                                        oHrp.CanCollide = false
                                    end
                                end
                            end
                        end

                        if Settings.AutoEquip then EquipWeapon() end
                    end
                end
            end)
        end

        -- 2. Auto Chest (Tự nhặt rương)
        if Settings.AutoChest then
            pcall(function()
                for _, chest in ipairs(workspace:GetDescendants()) do
                    if chest.Name:find("Chest") and chest:IsA("BasePart") then
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            char.HumanoidRootPart.CFrame = chest.CFrame
                            task.wait(0.1)
                        end
                    end
                end
            end)
        end

        -- 3. Auto Stats
        if Settings.AutoStats then
            pcall(function()
                local mainComm = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                if mainComm then
                    mainComm:InvokeServer("AddPoint", Settings.StatSelect, 3)
                end
            end)
        end
    end
end)

-- ==========================================
-- 🎯 LOGIC AIM LOCK (CHỈNH AIM SPEED & FOV)
-- ==========================================
local function GetClosestPlayer()
    local target = nil
    local minDist = Settings.FOV or 150
    local Camera = workspace.CurrentCamera
    if not Camera then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local targetPart = p.Character:FindFirstChild(Settings.TargetPart or "Head")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if targetPart and hum and hum.Health > 0 then
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
    end
    return target
end

-- ==========================================
-- 👁️ ESP SYSTEM
-- ==========================================
local ESPFolder = Instance.new("Folder", ParentTarget)
ESPFolder.Name = "DonMenuESP_Folder"

task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            ESPFolder:ClearAllChildren()
            if Settings.ESP then
                local myChar = LocalPlayer.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local pChar = p.Character
                        local pHrp = pChar:FindFirstChild("HumanoidRootPart")
                        local pHead = pChar:FindFirstChild("Head")

                        if pHrp and pHead then
                            local hl = Instance.new("Highlight")
                            hl.Adornee = pChar
                            hl.FillColor = Color3.fromRGB(255, 50, 50)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.5
                            hl.Parent = ESPFolder

                            local dist = myHrp and math.floor((myHrp.Position - pHrp.Position).Magnitude) or 0
                            local bg = Instance.new("BillboardGui")
                            bg.Adornee = pHead
                            bg.Size = UDim2.new(0, 100, 0, 40)
                            bg.StudsOffset = Vector3.new(0, 2, 0)
                            bg.AlwaysOnTop = true
                            bg.Parent = ESPFolder

                            local txt = Instance.new("TextLabel")
                            txt.Size = UDim2.new(1, 0, 1, 0)
                            txt.BackgroundTransparency = 1
                            txt.Text = string.format("%s\n[%dm]", p.Name, dist)
                            txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                            txt.TextSize = 11
                            txt.Font = Enum.Font.GothamBold
                            txt.TextStrokeTr
