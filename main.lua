-- =================================================================
-- ⚡ QUANTUM HUB - FULL ESP EDITION (BOX, LINE, NAME, DISTANCE)
-- =================================================================

-- 1. DỌN DẸP TOÀN BỘ GIAO DIỆN CŨ
pcall(function()
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name:find("Quantum") or v.Name:find("DonMenu") then
            v:Destroy()
        end
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

local function Notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Quantum Hub",
            Text = text,
            Duration = 2.5
        })
    end)
end

Notify("Đang khởi động hệ thống Full ESP...")

-- 2. CẤU HÌNH HỆ THỐNG
getgenv().QuantumSettings = {
    -- ESP Toggles
    ESPEnabled = false,
    BoxESP = true,
    LineESP = true,
    NameESP = true,
    DistanceESP = true,
    
    -- Aim & Misc
    AimLock = false,
    Prediction = true,
    PredictionValue = 0.15,
    FOVRadius = 150,
    ShowFOV = true,
    SpeedHack = false,
    SpeedVal = 50,
    Noclip = false,
}
local Config = getgenv().QuantumSettings

-- 3. HỆ THỐNG ESP DRAWING STORAGE
local ESPStorage = {}

local function RemoveESP(player)
    if ESPStorage[player] then
        for _, drawing in pairs(ESPStorage[player]) do
            pcall(function() drawing:Remove() end)
        end
        ESPStorage[player] = nil
    end
end

local function CreateESP(player)
    if ESPStorage[player] then return end
    
    local drawings = {
        Box = Drawing.new("Square"),
        Line = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text")
    }
    
    -- Cấu hình Box
    drawings.Box.Visible = false
    drawings.Box.Thickness = 1.5
    drawings.Box.Color = Color3.fromRGB(0, 255, 200)
    drawings.Box.Filled = false
    
    -- Cấu hình Line (Thẻ kẻ từ giữa màn hình đáy lên nhân vật)
    drawings.Line.Visible = false
    drawings.Line.Thickness = 1
    drawings.Line.Color = Color3.fromRGB(0, 255, 200)
    
    -- Cấu hình Tên
    drawings.Name.Visible = false
    drawings.Name.Size = 13
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.Color = Color3.fromRGB(255, 255, 255)
    
    -- Cấu hình Khoảng cách
    drawings.Distance.Visible = false
    drawings.Distance.Size = 12
    drawings.Distance.Center = true
    drawings.Distance.Outline = true
    drawings.Distance.Color = Color3.fromRGB(0, 255, 200)
    
    ESPStorage[player] = drawings
end

-- Xóa ESP khi người chơi rời game
Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

-- 4. VÒNG TRÒN FOV
local FOVCircle = nil
pcall(function()
    if Drawing and Drawing.new then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Color = Color3.fromRGB(0, 255, 200)
        FOVCircle.Thickness = 1.5
        FOVCircle.NumSides = 32
        FOVCircle.Radius = Config.FOVRadius
        FOVCircle.Filled = false
        FOVCircle.Visible = false
    end
end)

-- 5. XÂY DỰNG GIAO DIỆN (UI)
local CoreGui = game:GetService("CoreGui")
local TargetParent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or CoreGui

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuantumHub_FullESP"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = TargetParent

-- Nút mở/đóng menu
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 48, 0, 48)
ToggleBtn.Position = UDim2.new(0, 15, 0.3, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
ToggleBtn.Text = "⚡"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
ToggleBtn.TextSize = 22
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Parent = ScreenGui

Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local BtnStroke = Instance.new("UIStroke", ToggleBtn)
BtnStroke.Color = Color3.fromRGB(0, 255, 200)
BtnStroke.Thickness = 2

-- Khung Menu Chính
local MainWindow = Instance.new("Frame")
MainWindow.Size = UDim2.new(0, 480, 0, 310)
MainWindow.Position = UDim2.new(0.5, -240, 0.5, -155)
MainWindow.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainWindow.Visible = true
MainWindow.Parent = ScreenGui

Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainWindow)
MainStroke.Color = Color3.fromRGB(0, 255, 200)
MainStroke.Thickness = 1.5

-- Thanh Tiêu Đề
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 34)
Header.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
Header.Parent = MainWindow
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -15, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "QUANTUM HUB • FULL ESP EDITION"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 11
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

ToggleBtn.MouseButton1Click:Connect(function()
    MainWindow.Visible = not MainWindow.Visible
end)

-- Sidebar
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 120, 1, -44)
Sidebar.Position = UDim2.new(0, 6, 0, 38)
Sidebar.BackgroundTransparency = 1
Sidebar.ScrollBarThickness = 0
Sidebar.Parent = MainWindow

local SidebarList = Instance.new("UIListLayout", Sidebar)
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Padding = UDim.new(0, 5)

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -134, 1, -44)
ContentArea.Position = UDim2.new(0, 130, 0, 38)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainWindow

local TabsList = {}
local FirstTabContent = nil

local function MakeTab(tabTitle)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 30)
    TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    TabBtn.Text = "  " .. tabTitle
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 170)
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 11
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 2
    TabContainer.Visible = false
    TabContainer.Parent = ContentArea

    local ContainerLayout = Instance.new("UIListLayout", TabContainer)
    ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContainerLayout.Padding = UDim.new(0, 5)

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in ipairs(TabsList) do
            t.Container.Visible = false
            t.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
            t.Button.TextColor3 = Color3.fromRGB(150, 150, 170)
        end
        TabContainer.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
        TabBtn.TextColor3 = Color3.fromRGB(15, 15, 22)
    end)

    if not FirstTabContent then 
        FirstTabContent = {Button = TabBtn, Container = TabContainer} 
    end
    table.insert(TabsList, {Button = TabBtn, Container = TabContainer})
    return TabContainer
end

local function MakeToggle(parentTab, labelText, configKey, defaultVal)
    if defaultVal ~= nil then Config[configKey] = defaultVal end
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(1, -4, 0, 32)
    ToggleButton.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(20, 20, 30)
    ToggleButton.Text = "  " .. labelText .. (Config[configKey] and ": [ON]" or ": [OFF]")
    ToggleButton.TextColor3 = Config[configKey] and Color3.fromRGB(15, 15, 22) or Color3.fromRGB(180, 180, 200)
    ToggleButton.Font = Enum.Font.GothamSemibold
    ToggleButton.TextSize = 11
    ToggleButton.TextXAlignment = Enum.TextXAlignment.Left
    ToggleButton.Parent = parentTab
    
    Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 6)

    ToggleButton.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        ToggleButton.Text = "  " .. labelText .. (Config[configKey] and ": [ON]" or ": [OFF]")
        ToggleButton.TextColor3 = Config[configKey] and Color3.fromRGB(15, 15, 22) or Color3.fromRGB(180, 180, 200)
        ToggleButton.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(20, 20, 30)
    end)
end

-- TẠO CÁC TAB CHỨC NĂNG
local ESPCategory = MakeTab("👁️ ESP Config")
MakeToggle(ESPCategory, "Bật/Tắt ESP", "ESPEnabled", true)
MakeToggle(ESPCategory, "ESP Box", "BoxESP", true)
MakeToggle(ESPCategory, "ESP Line", "LineESP", true)
MakeToggle(ESPCategory, "ESP Name", "NameESP", true)
MakeToggle(ESPCategory, "ESP Distance", "DistanceESP", true)

local AimCategory = MakeTab("🎯 Aim Lock")
MakeToggle(AimCategory, "Aim Lock Skill", "AimLock")
MakeToggle(AimCategory, "Dự Đoán Đường Bay", "Prediction", true)
MakeToggle(AimCategory, "Hiển Thị Vòng FOV", "ShowFOV", true)

local MiscCategory = MakeTab("⚡ Player")
MakeToggle(MiscCategory, "Speed Hack", "SpeedHack")
MakeToggle(MiscCategory, "Noclip Xuyên Tường", "Noclip")

if FirstTabContent then
    FirstTabContent.Container.Visible = true
    FirstTabContent.Button.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    FirstTabContent.Button.TextColor3 = Color3.fromRGB(15, 15, 22)
end

-- 6. VÒNG LẶP RENDER CHÍNH (XỬ LÝ ESP, AIM, SPEED)
RunService.RenderStepped:Connect(function()
    pcall(function()
        Camera = workspace.CurrentCamera
        if not Camera then return end

        -- Cập nhật FOV Circle
        if FOVCircle then
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            FOVCircle.Radius = Config.FOVRadius
            FOVCircle.Visible = Config.ShowFOV and Config.AimLock
        end

        -- Xử lý toàn bộ ESP cho Players
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                if Config.ESPEnabled and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") then
                    local char = p.Character
                    local hrp = char.HumanoidRootPart
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    
                    if hum.Health > 0 then
                        CreateESP(p)
                        local esp = ESPStorage[p]
                        
                        local rootPos, rootOnScreen = Camera:WorldToViewportPoint(hrp.Position)
                        
                        if rootOnScreen then
                            local head = char:FindFirstChild("Head") or hrp
                            local topPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.8, 0))
                            local bottomPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.5, 0))
                            
                            local boxHeight = math.abs(topPos.Y - bottomPos.Y)
                            local boxWidth = boxHeight / 2
                            
                            -- 1. Box ESP
                            if Config.BoxESP then
                                esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                                esp.Box.Position = Vector2.new(rootPos.X - boxWidth / 2, topPos.Y)
                                esp.Box.Visible = true
                            else
                                esp.Box.Visible = false
                            end
                            
                            -- 2. Line ESP (Kẻ từ giữa màn hình dưới lên nhân vật)
                            if Config.LineESP then
                                esp.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                esp.Line.To = Vector2.new(rootPos.X, bottomPos.Y)
                                esp.Line.Visible = true
                            else
                                esp.Line.Visible = false
                            end
                            
                            -- 3. Name ESP
                            if Config.NameESP then
                                esp.Name.Text = p.Name
                                esp.Name.Position = Vector2.new(rootPos.X, topPos.Y - 16)
                                esp.Name.Visible = true
                            else
                                esp.Name.Visible = false
                            end
                            
                            -- 4. Distance ESP
                            if Config.DistanceESP and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                                esp.Distance.Text = "[" .. dist .. "m]"
                                esp.Distance.Position = Vector2.new(rootPos.X, bottomPos.Y + 2)
                                esp.Distance.Visible = true
                            else
                                esp.Distance.Visible = false
                            end
                        else
                            -- Ẩn khi ra khỏi màn hình
                            for _, d in pairs(esp) do d.Visible = false end
                        end
                    else
                        RemoveESP(p)
                    end
                else
                    RemoveESP(p)
                end
            end
        end

        -- Xử lý Aim Lock
        if Config.AimLock then
            local targetInstance = nil
            local minDistance = Config.FOVRadius

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                            if mouseDist < minDistance then
                                minDistance = mouseDist
                                targetInstance = hrp
                            end
                        end
                    end
                end
            end

            if targetInstance then
                local finalPos = targetInstance.Position
                if Config.Prediction then
                    finalPos = finalPos + (targetInstance.Velocity * Config.PredictionValue)
                end
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, finalPos)
            end
        end

        -- Xử lý Speed Hack
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid and Config.SpeedHack then
            humanoid.WalkSpeed = Config.SpeedVal
        end
    end)
end)

-- Xử lý Noclip
RunService.Stepped:Connect(function()
    pcall(function()
        if Config.Noclip then
            local character = LocalPlayer.Character
            if character then
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end)

Notify("Đã kích hoạt hệ thống Full ESP thành công!")
