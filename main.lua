-- =================================================================
-- ⚡ QUANTUM HUB - HERMANOS'DEV ULTIMATE EDITION
-- =================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

local function SendNotification(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 3
        })
    end)
end

SendNotification("Quantum Hub", "Đang nạp phiên bản Ultimate...")

-- ==========================================
-- ⚙️ BẢNG CẤU HÌNH TỔNG (SETTINGS)
-- ==========================================
getgenv().DonMenu = {
    -- Auto Farm
    AutoFarmLevel = false,
    BringMob = false,        
    FastAttack = false,      
    FarmDistance = 7,
    AutoEquip = true,
    
    -- Silent Aim & Prediction
    SilentAim = false,
    Prediction = true,
    PredictionStrength = 0.165, -- Hệ số dự đoán vận tốc
    TargetPart = "HumanoidRootPart",
    FOV = 150,
    ShowFOV = true,

    -- ESP Player Info
    ESP = false,
    ESPInfo = true, -- Tên, Máu, Khoảng cách, Vũ khí
    ESPHighlight = true,

    -- Player & Misc
    Invisible = false,
    Speed = false,
    SpeedValue = 50,
    Noclip = false,
    AntiAFK = true
}
local Settings = getgenv().DonMenu

-- Khởi tạo vòng FOV
local FOVCircle = nil
pcall(function()
    if Drawing and Drawing.new then
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
local ParentTarget = LocalPlayer:FindFirstChildOfClass("PlayerGui") or CoreGui

for _, oldUI in ipairs(ParentTarget:GetChildren()) do
    if oldUI.Name == "DonMenuQuantumUI" then oldUI:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DonMenuQuantumUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = ParentTarget

local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Name = "FloatingBtn"
FloatingBtn.Size = UDim2.new(0, 50, 0, 50)
FloatingBtn.Position = UDim2.new(0, 15, 0.35, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
FloatingBtn.Text = "⚡"
FloatingBtn.TextColor3 = Color3.fromRGB(140, 82, 255)
FloatingBtn.TextSize = 22
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
MainFrame.Size = UDim2.new(0, 540, 0, 360)
MainFrame.Position = UDim2.new(0.5, -270, 0.5, -180)
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
TitleText.Text = "QUANTUM HUB • ULTIMATE EDITION"
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

local function CreateToggle(parentTab, name, settingKey, defaultState)
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
-- 🗂️ TẠO BẢNG ĐIỀU KHIỂN
-- ==========================================
local MainTab = CreateTab("🌾 Auto Farm")
CreateToggle(MainTab, "Auto Farm Level", "AutoFarmLevel")
CreateToggle(MainTab, "Gom Quái (Bring Mob)", "BringMob")
CreateToggle(MainTab, "Đánh Nhanh (Fast Attack)", "FastAttack")

local AimTab = CreateTab("🎯 Silent Aim Skill")
CreateToggle(AimTab, "Silent Aim (Tự Khóa Skill)", "SilentAim")
CreateToggle(AimTab, "Skill Prediction (Dự Đoán)", "Prediction", true)
CreateTextBox(AimTab, "Độ Nhạy Dự Đoán", Settings.PredictionStrength, function(v) Settings.PredictionStrength = v end)
CreateTextBox(AimTab, "Kích Thước Vòng FOV", Settings.FOV, function(v) Settings.FOV = v end)
CreateToggle(AimTab, "Hiện Vòng FOV", "ShowFOV")

local ESPTab = CreateTab("👁️ ESP Player")
CreateToggle(ESPTab, "Bật ESP", "ESP")
CreateToggle(ESPTab, "Hiện Thông Tin (Máu/Vũ khí)", "ESPInfo", true)
CreateToggle(ESPTab, "Highlight Viền Vùng", "ESPHighlight", true)

local PlayerTab = CreateTab("⚡ Player & Etc")
CreateToggle(PlayerTab, "Invisible (Tàng Hình)", "Invisible")
CreateToggle(PlayerTab, "Speed Hack", "Speed")
CreateTextBox(PlayerTab, "Tốc Độ Di Chuyển", Settings.SpeedValue, function(v) Settings.SpeedValue = v end)
CreateToggle(PlayerTab, "Noclip Xuyên Tường", "Noclip")
CreateButton(PlayerTab, "🔄 Server Hop (Đổi Server)", function()
    pcall(function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
        for _, s in ipairs(servers) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id)
                break
            end
        end
    end)
end)
CreateButton(PlayerTab, "🔁 Rejoin Game", function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
end)

if FirstTab then
    FirstTab.Content.Visible = true
    FirstTab.Button.BackgroundColor3 = Color3.fromRGB(140, 82, 255)
    FirstTab.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
end

-- ==========================================
-- 🎯 SILENT AIMBOT & PREDICTION LOGIC
-- ==========================================
local TargetPlayer = nil

local function GetClosestTarget()
    local target = nil
    local minDist = Settings.FOV or 150
    local Camera = workspace.CurrentCamera
    if not Camera then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild(Settings.TargetPart or "HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < minDist then
                        minDist = dist
                        target = p
                    end
                end
            end
        end
    end
    return target
end

-- Hook Index / Mouse Target cho Silent Aim
local rawMeta = getrawmetatable(game)
local oldIndex = rawMeta.__index
setreadonly(rawMeta, false)

rawMeta.__index = newcclosure(function(self, key)
    if Settings.SilentAim and not checkcaller() and (key == "Hit" or key == "Target") then
        if TargetPlayer and TargetPlayer.Character then
            local targetPart = TargetPlayer.Character:FindFirstChild(Settings.TargetPart)
            if targetPart then
                local predictedPos = targetPart.Position
                if Settings.Prediction then
                    predictedPos = predictedPos + (targetPart.Velocity * Settings.PredictionStrength)
                end

                if key == "Hit" then
                    return CFrame.new(predictedPos)
                elseif key == "Target" then
                    return targetPart
                end
            end
        end
    end
    return oldIndex(self, key)
end)

setreadonly(rawMeta, true)

-- ==========================================
-- 👁️ ESP PLAYER INFORMATION SYSTEM
-- ==========================================
local ESPFolder = Instance.new("Folder", ParentTarget)
ESPFolder.Name = "QuantumESP_Folder"

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
                        local pHum = pChar:FindFirstChildOfClass("Humanoid")

                        if pHrp and pHead and pHum and pHum.Health > 0 then
                            -- Highlight
                            if Settings.ESPHighlight then
                                local hl = Instance.new("Highlight")
                                hl.Adornee = pChar
                                hl.FillColor = Color3.fromRGB(255, 50, 50)
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                hl.FillTransparency = 0.6
                                hl.Parent = ESPFolder
                            end

                            -- Info Billboard
                            if Settings.ESPInfo then
                                local dist = myHrp and math.floor((myHrp.Position - pHrp.Position).Magnitude) or 0
                                local tool = pChar:FindFirstChildOfClass("Tool")
                                local toolName = tool and tool.Name or "None"

                                local bg = Instance.new("BillboardGui")
                                bg.Adornee = pHead
                                bg.Size = UDim2.new(0, 150, 0, 50)
                                bg.StudsOffset = Vector3.new(0, 2.5, 0)
                                bg.AlwaysOnTop = true
                                bg.Parent = ESPFolder

                                local txt = Instance.new("TextLabel")
                                txt.Size = UDim2.new(1, 0, 1, 0)
                                txt.BackgroundTransparency = 1
                                txt.Text = string.format("%s\nHP: %d/%d | [%dm]\nHeld: %s", 
                                    p.Name, math.floor(pHum.Health), math.floor(pHum.MaxHealth), dist, toolName)
                                txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                                txt.TextSize = 10
                                txt.Font = Enum.Font.GothamBold
                                txt.TextStrokeTransparency = 0
                                txt.Parent = bg
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- ==========================================
-- ⚙️ RENDER LOOP & EXTRA LOGICS
-- ==========================================
RunService.RenderStepped:Connect(function()
    pcall(function()
        -- FOV Update
        local Camera = workspace.CurrentCamera
        if FOVCircle and Camera then
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            FOVCircle.Radius = Settings.FOV
            FOVCircle.Visible = Settings.ShowFOV and Settings.SilentAim
        end

        -- Cập nhật mục tiêu Silent Aim
        if Settings.SilentAim then
            TargetPlayer = GetClosestTarget()
        else
            TargetPlayer = nil
        end

        -- Invisible Mode Logic
        if Settings.Invisible then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("LowerTorso") then
                char.LowerTorso.RootRigAtt.CFrame = CFrame.new(0, 5000, 0)
            end
        end

        -- Speed Hack
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and Settings.Speed then
            hum.WalkSpeed = Settings.SpeedValue
        end
    end)
end)

-- Noclip Loop
RunService.Stepped:Connect(function()
    pcall(function()
        if Settings.Noclip or Settings.AutoFarmLevel then
            local char = LocalPlayer.Character
            if char then
                for _, p in ipairs(char:GetChildren()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end
    end)
end)

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    if Settings.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end)

SendNotification("Quantum Hub", "Đã khởi chạy hoàn tất Ultimate Edition!")
