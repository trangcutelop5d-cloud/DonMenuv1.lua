-- =================================================================
-- ⚡ DONMENU MASTER - QUANTUM UI (ULTIMATE FUNCTIONAL FIX)
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
    Smoothness = 0.15,     
    TargetPart = "Head",   
    ShowFOV = true,
    FOV = 150,

    -- Auto PvP & Skill
    SkillAim = false,
    Prediction = 0.15,
    AutoPvP = false,

    -- Auto Farm
    AutoFarmMob = false,
    FarmDistance = 7,
    AutoEquip = true,

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

local FloatCorner = Instance.new("UICorner", FloatingBtn)
FloatCorner.CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatingBtn)
FloatStroke.Color = Color3.fromRGB(140, 82, 255)
FloatStroke.Thickness = 2

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
TitleText.Text = "QUANTUM HUB • Working Edition"
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

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 6)

local ContentHolder = Instance.new("Frame")
ContentHolder.Size = UDim2.new(1, -144, 1, -48)
ContentHolder.Position = UDim2.new(0, 140, 0, 44)
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
    btn.Size = UDim2.new(1, 0, 0, 36)
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

-- TẠO MENU TAB
local FarmTab = CreateTab("🌾 Auto Farm")
CreateToggle(FarmTab, "Auto Farm Quái", "AutoFarmMob")
CreateToggle(FarmTab, "Tự Cầm Vũ Khí", "AutoEquip", true)

local CombatTab = CreateTab("🎯 Combat")
CreateToggle(CombatTab, "Aim Lock (Khóa Tâm)", "Aim")
CreateToggle(CombatTab, "Hiện Vòng FOV", "ShowFOV")

local PlayerTab = CreateTab("⚡ Player")
CreateToggle(PlayerTab, "Speed Hack", "Speed")
CreateToggle(PlayerTab, "Nhảy Vô Hạn", "InfJump")
CreateToggle(PlayerTab, "Noclip Xuyên Tường", "Noclip")

local VisualTab = CreateTab("👁️ Visual")
CreateToggle(VisualTab, "ESP Người Chơi", "ESP")
CreateToggle(VisualTab, "FullBright (Sáng Đêm)", "FullBright")

-- ==========================================
-- 🌾 LOGIC AUTO FARM QUÁI TỐI ƯU SÂU
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
            if tool then
                hum:EquipTool(tool)
            end
        end
    end

    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool then
        pcall(function() currentTool:Activate() end)
    end
end

local function GetClosestMob()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myHrp = char.HumanoidRootPart

    local closestMob = nil
    local minDist = math.huge

    -- Quét tất cả nơi có khả năng chứa Quái
    local searchList = {workspace}
    for _, folderName in ipairs({"Enemies", "Mobs", "NPCs", "Monsters", "Live", "Characters"}) do
        local f = workspace:FindFirstChild(folderName)
        if f then table.insert(searchList, f) end
    end

    for _, parentObj in ipairs(searchList) do
        for _, obj in ipairs(parentObj:GetChildren()) do
            if obj:IsA("Model") and obj ~= char then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local eHrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso") or obj:FindFirstChild("Head")
                
                if hum and eHrp and hum.Health > 0 then
                    -- Loại trừ người chơi thật
                    if not Players:GetPlayerFromCharacter(obj) then
                        local dist = (myHrp.Position - eHrp.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            closestMob = obj
                        end
                    end
                end
            end
        end
    end
    return closestMob
end

-- VÒNG LẶP FARM QUÁI
task.spawn(function()
    while task.wait(0.03) do
        if Settings.AutoFarmMob then
            pcall(function()
                local mob = GetClosestMob()
                if mob then
                    local mHrp = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso") or mob:FindFirstChild("UpperTorso") or mob:FindFirstChild("Head")
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if mHrp and hrp then
                        -- Giữ khoảng cách trên đầu quái
                        hrp.CFrame = CFrame.new(mHrp.Position + Vector3.new(0, Settings.FarmDistance or 7, 0), mHrp.Position)
                        
                        -- Tự cầm vũ khí & Đánh
                        if Settings.AutoEquip then EquipWeapon() end
                        
                        pcall(function()
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        end)
                        pcall(function()
                            VirtualUser:Button1Down(Vector2.new(0, 0))
                            VirtualUser:Button1Up(Vector2.new(0, 0))
                        end)
                    end
                end
            end)
        end
    end
end)

-- ==========================================
-- 🎯 LOGIC AIM LOCK CHUẨN XÁC
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
-- 👁️ HỆ THỐNG ESP BỀN VỮNG
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
                            txt.TextStrokeTransparency = 0
                            txt.Parent = bg
                        end
                    end
                end
            end
        end)
    end
end)

-- ==========================================
-- ⚙️ RENDER LOOP TỔNG
-- ==========================================
RunService.RenderStepped:Connect(function()
    pcall(function()
        local Camera = workspace.CurrentCamera
        if FOVCircle and Camera then
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            FOVCircle.Radius = Settings.FOV
            FOVCircle.Visible = Settings.ShowFOV and Settings.Aim
        end

        -- Aim Lock
        if Settings.Aim and Camera then
            local targetPart = GetClosestPlayer()
            if targetPart then
                local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                if Settings.LegitAim then
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Smoothness or 0.15)
                else
                    Camera.CFrame = targetCFrame
                end
            end
        end

        -- Speed & Jump
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if Settings.Speed then hum.WalkSpeed = Settings.SpeedValue end
        end

        -- FullBright
        if Settings.FullBright then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
        end
    end)
end)

-- Noclip & Infinite Jump
RunService.Stepped:Connect(function()
    pcall(function()
        if Settings.Noclip or Settings.AutoFarmMob then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
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

print("[Quantum Hub] Đã nạp thành công bản sửa lỗi tính năng!")
