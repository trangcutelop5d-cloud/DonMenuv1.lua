-- =================================================================
-- ⚡ QUANTUM HUB - LIGHT GREEN (ULTRA STABLE EDITION)
-- =================================================================

pcall(function()
    for _, v in pairs(game.Players.LocalPlayer.PlayerGui:GetChildren()) do
        if v.Name == "QuantumHub_UI" then
            v:Destroy()
        end
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Cấu hình mặc định
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
local ThemeDark = Color3.fromRGB(12, 18, 14)
local PanelColor = Color3.fromRGB(18, 26, 20)

-- Tạo Giao Diện UI
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuantumHub_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- Nút Bật/Tắt Tròn
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 48, 0, 48)
ToggleBtn.Position = UDim2.new(0, 15, 0.35, 0)
ToggleBtn.BackgroundColor3 = ThemeDark
ToggleBtn.Text = "🟢"
ToggleBtn.TextColor3 = ThemeColor
ToggleBtn.TextSize = 20
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Parent = ScreenGui

Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local BtnStroke = Instance.new("UIStroke", ToggleBtn)
BtnStroke.Color = ThemeColor
BtnStroke.Thickness = 2

-- Bảng Main
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 280)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -140)
MainFrame.BackgroundColor3 = ThemeDark
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = ThemeColor
MainStroke.Thickness = 1.5

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 32)
Title.BackgroundColor3 = PanelColor
Title.Text = "⚡ QUANTUM HUB - LIGHT GREEN"
Title.TextColor3 = ThemeColor
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Khung Nội Dung Chức Năng
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, -16, 1, -44)
ContentScroll.Position = UDim2.new(0, 8, 0, 38)
ContentScroll.BackgroundTransparency = 1
ContentScroll.ScrollBarThickness = 3
ContentScroll.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout", ContentScroll)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 6)

local function AddToggle(text, configKey)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -6, 0, 32)
    Btn.BackgroundColor3 = Config[configKey] and ThemeColor or PanelColor
    Btn.Text = "  " .. text .. (Config[configKey] and ": [ON]" or ": [OFF]")
    Btn.TextColor3 = Config[configKey] and ThemeDark or Color3.fromRGB(180, 220, 180)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 11
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Parent = ContentScroll
    
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    Btn.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        Btn.Text = "  " .. text .. (Config[configKey] and ": [ON]" or ": [OFF]")
        Btn.TextColor3 = Config[configKey] and ThemeDark or Color3.fromRGB(180, 220, 180)
        Btn.BackgroundColor3 = Config[configKey] and ThemeColor or PanelColor
    end)
end

-- Các Nút Chức Năng
AddToggle("👁️ ESP Bật/Tắt Tổng", "ESPEnabled")
AddToggle("📦 ESP Box Khung", "BoxESP")
AddToggle("💚 ESP Thanh Máu", "HealthBar")
AddToggle("📏 ESP Đường Kẻ (Line)", "LineESP")
AddToggle("👤 ESP Tên Người Chơi", "NameESP")
AddToggle("🚩 ESP Khoảng Cách", "DistanceESP")
AddToggle("🧱 XG (Noclip Xuyên Tường)", "Noclip")
AddToggle("🎯 FF Headshot Aim (Kéo Tâm)", "HeadshotAssist")

ContentScroll.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)

-- Kho Lưu Trữ Drawing ESP
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
    if ESPStorage[player] or not Drawing then return end
    
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

Players.PlayerRemoving:Connect(RemoveESP)

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

-- Vòng Lặp Xử Lý ESP & Headshot Aim
RunService.RenderStepped:Connect(function()
    pcall(function()
        Camera = workspace.CurrentCamera
        if not Camera then return end

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                if Config.ESPEnabled and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") then
                    local char = p.Character
                    local hrp = char.HumanoidRootPart
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    
                    if hum.Health > 0 then
                        CreateESP(p)
                        local esp = ESPStorage[p]
                        if esp then
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
                        end
                    else
                        RemoveESP(p)
                    end
                else
                    RemoveESP(p)
                end
            end
        end

        -- Kéo Tâm Đầu
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
                local headPos = targetHead.Position + (targetHead.Velocity * Config.PredictionValue)
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, headPos), Config.Smoothness)
            end
        end
    end)
end)

-- XG (Noclip)
RunService.Stepped:Connect(function()
    pcall(function()
        if Config.Noclip and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)
