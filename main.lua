-- =================================================================
-- ⚡ QUANTUM HUB - LIGHT GREEN V2 (FIXED UI & STABLE ESP)
-- =================================================================

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
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

local function Notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Quantum Hub V2",
            Text = text,
            Duration = 2.5
        })
    end)
end

Notify("Đã khởi chạy Quantum Hub phiên bản mới!")

getgenv().QuantumSettings = {
    ESPEnabled = true,
    BoxESP = true,
    HealthBar = true,
    LineESP = true,
    NameESP = true,
    DistanceESP = true,
    Noclip = false,
    HeadshotAssist = false,
    Prediction = true,
    PredictionValue = 0.12,
    FOVRadius = 180,
    Smoothness = 0.25,
    ShowFOV = true,
}
local Config = getgenv().QuantumSettings

local ThemeColor = Color3.fromRGB(120, 255, 140)
local ThemeColorDark = Color3.fromRGB(10, 20, 12)

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
        HealthBar = Drawing.new("Line"),
        HealthBarBg = Drawing.new("Line"),
        Line = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Info = Drawing.new("Text")
    }
    
    drawings.Box.Visible = false
    drawings.Box.Thickness = 1
    drawings.Box.Color = ThemeColor
    drawings.Box.Filled = false
    
    drawings.HealthBarBg.Visible = false
    drawings.HealthBarBg.Thickness = 2
    drawings.HealthBarBg.Color = Color3.fromRGB(20, 30, 20)
    
    drawings.HealthBar.Visible = false
    drawings.HealthBar.Thickness = 1
    drawings.HealthBar.Color = ThemeColor
    
    drawings.Line.Visible = false
    drawings.Line.Thickness = 1
    drawings.Line.Color = ThemeColor
    
    drawings.Name.Visible = false
    drawings.Name.Size = 12
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.Color = Color3.fromRGB(255, 255, 255)
    
    drawings.Info.Visible = false
    drawings.Info.Size = 11
    drawings.Info.Center = true
    drawings.Info.Outline = true
    drawings.Info.Color = Color3.fromRGB(200, 240, 200)
    
    ESPStorage[player] = drawings
end

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

local FOVCircle = nil
pcall(function()
    if Drawing and Drawing.new then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Color = ThemeColor
        FOVCircle.Thickness = 1.5
        FOVCircle.NumSides = 32
        FOVCircle.Radius = Config.FOVRadius
        FOVCircle.Filled = false
        FOVCircle.Visible = false
    end
end)

-- Gán UI trực tiếp vào PlayerGui để chắc chắn hiển thị lên màn hình
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuantumHub_Fixed"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0.3, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(12, 18, 14)
ToggleBtn.Text = "🟢"
ToggleBtn.TextColor3 = ThemeColor
ToggleBtn.TextSize = 22
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Parent = ScreenGui

Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local BtnStroke = Instance.new("UIStroke", ToggleBtn)
BtnStroke.Color = ThemeColor
BtnStroke.Thickness = 2

local MainWindow = Instance.new("Frame")
MainWindow.Size = UDim2.new(0, 490, 0, 330)
MainWindow.Position = UDim2.new(0.5, -245, 0.5, -165)
MainWindow.BackgroundColor3 = Color3.fromRGB(10, 15, 12)
MainWindow.Visible = true
MainWindow.Parent = ScreenGui

Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainWindow)
MainStroke.Color = ThemeColor
MainStroke.Thickness = 1.5

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 34)
Header.BackgroundColor3 = Color3.fromRGB(14, 22, 16)
Header.Parent = MainWindow
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -15, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "QUANTUM HUB • LIGHT GREEN V2"
TitleLabel.TextColor3 = ThemeColor
TitleLabel.TextSize = 11
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

ToggleBtn.MouseButton1Click:Connect(function()
    MainWindow.Visible = not MainWindow.Visible
end)

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 120, 1, -44)
Sidebar.Position = UDim2.new(0, 6, 0, 38)
Sidebar.BackgroundTransparency = 1
Sidebar.ScrollBarThickness = 0
Sidebar.Parent = MainWindow

local SidebarList = Instance.new("UIListLayout", Sidebar)
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Padding = UDim.new(0, 5)

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
    TabBtn.BackgroundColor3 = Color3.fromRGB(15, 22, 17)
    TabBtn.Text = "  " .. tabTitle
    TabBtn.TextColor3 = Color3.fromRGB(150, 180, 150)
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
            t.Button.BackgroundColor3 = Color3.fromRGB(15, 22, 17)
            t.Button.TextColor3 = Color3.fromRGB(150, 180, 150)
        end
        TabContainer.Visible = true
        TabBtn.BackgroundColor3 = ThemeColor
        TabBtn.TextColor3 = ThemeColorDark
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
    ToggleButton.Size = UDim2.new(1, -4, 0, 30)
    ToggleButton.BackgroundColor3 = Config[configKey] and ThemeColor or Color3.fromRGB(15, 22, 17)
    ToggleButton.Text = "  " .. labelText .. (Config[configKey] and ": [ON]" or ": [OFF]")
    ToggleButton.TextColor3 = Config[configKey] and ThemeColorDark or Color3.fromRGB(170, 200, 170)
    ToggleButton.Font = Enum.Font.GothamSemibold
    ToggleButton.TextSize = 11
    ToggleButton.TextXAlignment = Enum.TextXAlignment.Left
    ToggleButton.Parent = parentTab
    
    Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 6)

    ToggleButton.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        ToggleButton.Text = "  " .. labelText .. (Config[configKey] and ": [ON]" or ": [OFF]")
        ToggleButton.TextColor3 = Config[configKey] and ThemeColorDark or Color3.fromRGB(170, 200, 170)
        ToggleButton.BackgroundColor3 = Config[configKey] and ThemeColor or Color3.fromRGB(15, 22, 17)
    end)
end

local function MakeSlider(parentTab, labelText, configKey, step, minVal, maxVal)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -4, 0, 42)
    Container.BackgroundColor3 = Color3.fromRGB(15, 22, 17)
    Container.Parent = parentTab
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -90, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText .. ": " .. tostring(Config[configKey])
    Label.TextColor3 = Color3.fromRGB(190, 220, 190)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local MinusBtn = Instance.new("TextButton")
    MinusBtn.Size = UDim2.new(0, 35, 0, 26)
    MinusBtn.Position = UDim2.new(1, -78, 0.5, -13)
    MinusBtn.BackgroundColor3 = Color3.fromRGB(25, 38, 28)
    MinusBtn.Text = "-"
    MinusBtn.TextColor3 = ThemeColor
    MinusBtn.Font = Enum.Font.GothamBold
    MinusBtn.TextSize = 14
    MinusBtn.Parent = Container
    Instance.new("UICorner", MinusBtn).CornerRadius = UDim.new(0, 4)

    local PlusBtn = Instance.new("TextButton")
    PlusBtn.Size = UDim2.new(0, 35, 0, 26)
    PlusBtn.Position = UDim2.new(1, -39, 0.5, -13)
    PlusBtn.BackgroundColor3 = Color3.fromRGB(25, 38, 28)
    PlusBtn.Text = "+"
    PlusBtn.TextColor3 = ThemeColor
    PlusBtn.Font = Enum.Font.GothamBold
    PlusBtn.TextSize = 14
    PlusBtn.Parent = Container
    Instance.new("UICorner", PlusBtn).CornerRadius = UDim.new(0, 4)

    MinusBtn.MouseButton1Click:Connect(function()
        Config[configKey] = math.clamp(Config[configKey] - step, minVal, maxVal)
        Config[configKey] = tonumber(string.format("%.2f", Config[configKey]))
        Label.Text = labelText .. ": " .. tostring(Config[configKey])
    end)

    PlusBtn.MouseButton1Click:Connect(function()
        Config[configKey] = math.clamp(Config[configKey] + step, minVal, maxVal)
        Config[configKey] = tonumber(string.format("%.2f", Config[configKey]))
        Label.Text = labelText .. ": " .. tostring(Config[configKey])
    end)
end

local ESPCategory = MakeTab("👁️ ESP Xanh Lá")
MakeToggle(ESPCategory, "Bật/Tắt Tổng ESP", "ESPEnabled", true)
MakeToggle(ESPCategory, "ESP Khung (Box)", "BoxESP", true)
MakeToggle(ESPCategory, "ESP Thanh Máu", "HealthBar", true)
MakeToggle(ESPCategory, "ESP Đường Kẻ (Line)", "LineESP", true)
MakeToggle(ESPCategory, "ESP Tên Người Chơi", "NameESP", true)
MakeToggle(ESPCategory, "ESP Khoảng Cách (m)", "DistanceESP", true)

local XGCategory = MakeTab("🧱 XG (Xuyên Tường)")
MakeToggle(XGCategory, "Noclip Xuyên Tường", "Noclip", false)

local AimCategory = MakeTab("🎯 FF Headshot")
MakeToggle(AimCategory, "Kéo Tâm Đầu (FF)", "HeadshotAssist", false)
MakeToggle(AimCategory, "Dự Đoán Đường Bay", "Prediction", true)
MakeToggle(AimCategory, "Hiển Thị Vòng FOV", "ShowFOV", true)

local ConfigCategory = MakeTab("⚙️ Tùy Chỉnh Số")
MakeSlider(ConfigCategory, "Bán kính FOV", "FOVRadius", 10, 50, 400)
MakeSlider(ConfigCategory, "Độ mượt (Smooth)", "Smoothness", 0.05, 0.05, 1.0)
MakeSlider(ConfigCategory, "Độ dự đoán (Pred)", "PredictionValue", 0.01, 0.0, 0.5)

if FirstTabContent then
    FirstTabContent.Container.Visible = true
    FirstTabContent.Button.BackgroundColor3 = ThemeColor
    FirstTabContent.Button.TextColor3 = ThemeColorDark
end

local isFiring = false
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isFiring = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isFiring = false
    end
end)

RunService.RenderStepped:Connect(function()
    pcall(function()
        Camera = workspace.CurrentCamera
        if not Camera then return end

        if FOVCircle then
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            FOVCircle.Radius = Config.FOVRadius
            FOVCircle.Visible = Config.ShowFOV and Config.HeadshotAssist
        end

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
                            local boxX = rootPos.X - boxWidth / 2
                            local boxY = topPos.Y
                            
                            if Config.BoxESP then
                                esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                                esp.Box.Position = Vector2.new(boxX, boxY)
                                esp.Box.Visible = true
                            else
                                esp.Box.Visible = false
                            end
                            
                            if Config.HealthBar then
                                local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                                local barHeight = boxHeight * healthPercent
                                
                                esp.HealthBarBg.From = Vector2.new(boxX - 5, boxY)
                                esp.HealthBarBg.To = Vector2.new(boxX - 5, boxY + boxHeight)
                                esp.HealthBarBg.Visible = true
                                
                                esp.HealthBar.From = Vector2.new(boxX - 5, boxY + boxHeight)
                                esp.HealthBar.To = Vector2.new(boxX - 5, (boxY + boxHeight) - barHeight)
                                esp.HealthBar.Visible = true
                            else
                                esp.HealthBarBg.Visible = false
                                esp.HealthBar.Visible = false
                            end
                            
                            if Config.LineESP then
                                esp.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                esp.Line.To = Vector2.new(rootPos.X, bottomPos.Y)
                                esp.Line.Visible = true
                            else
                                esp.Line.Visible = false
                            end
                            
                            if Config.NameESP then
                                esp.Name.Text = p.Name
                                esp.Name.Position = Vector2.new(rootPos.X, boxY - 16)
                                esp.Name.Visible = true
                            else
                                esp.Name.Visible = false
                            end
                            
                            if Config.DistanceESP and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                                esp.Info.Text = dist .. "m"
                                esp.Info.Position = Vector2.new(rootPos.X, bottomPos.Y + 2)
                                esp.Info.Visible = true
                            else
                                esp.Info.Visible = false
                            end
                        else
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

        if Config.HeadshotAssist and isFiring then
            local targetHead = nil
            local minDistance = Config.FOVRadius

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local head = p.Character:FindFirstChild("Head")
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if head and hum and hum.Health > 0 then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                            if mouseDist < minDistance then
                                minDistance = mouseDist
                                targetHead = head
                            end
                        end
                    end
                end
            end

            if targetHead then
                local headPos = targetHead.Position
                if Config.Prediction then
                    headPos = headPos + (targetHead.Velocity * Config.PredictionValue)
                end
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, headPos), Config.Smoothness)
            end
        end
    end)
end)

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

Notify("Đã sửa lỗi hiển thị và load thành công!")
