-- =================================================================
-- ⚡ QUANTUM HUB - FIXED STABLE EDITION (NO CRASH)
-- =================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
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

SendNotification("Quantum Hub", "Đang khởi động bản ổn định...")

-- ==========================================
-- ⚙️ CẤU HÌNH (SETTINGS)
-- ==========================================
getgenv().DonMenu = {
    AutoFarmLevel = false,
    BringMob = false,        
    FastAttack = false,      
    FarmDistance = 7,
    AutoEquip = true,
    
    -- Aim & Prediction (Đã sửa lại tối ưu không crash)
    AimLock = false,
    Prediction = true,
    PredictionStrength = 0.15,
    FOV = 150,
    ShowFOV = true,

    -- ESP
    ESP = false,
    
    -- Player
    Speed = false,
    SpeedValue = 50,
    Noclip = false,
    AntiAFK = true
}
local Settings = getgenv().DonMenu

-- Khởi tạo FOV an toàn
local FOVCircle = nil
pcall(function()
    if Drawing and Drawing.new then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Color = Color3.fromRGB(140, 82, 255)
        FOVCircle.Thickness = 1.5
        FOVCircle.NumSides = 30
        FOVCircle.Radius = Settings.FOV
        FOVCircle.Filled = false
        FOVCircle.Visible = false
    end
end)

-- ==========================================
-- 📱 GIAO DIỆN GỌN NHẸ
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
FloatingBtn.Size = UDim2.new(0, 45, 0, 45)
FloatingBtn.Position = UDim2.new(0, 15, 0.35, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
FloatingBtn.Text = "⚡"
FloatingBtn.TextColor3 = Color3.fromRGB(140, 82, 255)
FloatingBtn.TextSize = 20
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.Active = true
FloatingBtn.Draggable = true
FloatingBtn.Parent = ScreenGui
Instance.new("UICorner", FloatingBtn).CornerRadius = UDim.new(1, 0)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 320)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
MainFrame.Visible = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -20, 1, 0)
TitleText.Position = UDim2.new(0, 12, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "QUANTUM HUB • STABLE EDITION"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 12
TitleText.Font = Enum.Font.GothamBold
TitleText.Parent = TitleBar

FloatingBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 130, 1, -42)
Sidebar.Position = UDim2.new(0, 6, 0, 38)
Sidebar.BackgroundTransparency = 1
Sidebar.ScrollBarThickness = 0
Sidebar.Parent = MainFrame

local ContentHolder = Instance.new("Frame")
ContentHolder.Size = UDim2.new(1, -142, 1, -42)
ContentHolder.Position = UDim2.new(0, 138, 0, 38)
ContentHolder.BackgroundTransparency = 1
ContentHolder.Parent = MainFrame

local Tabs = {}
local FirstTab = nil

local function CreateTab(tabName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
    btn.Text = "  " .. tabName
    btn.TextColor3 = Color3.fromRGB(160, 160, 180)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 2
    content.Visible = false
    content.Parent = ContentHolder

    local layout = Instance.new("UIListLayout", content)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Content.Visible = false
            t.Button.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
            t.Button.TextColor3 = Color3.fromRGB(160, 160, 180)
        end
        content.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(140, 82, 255)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    if not FirstTab then FirstTab = {Button = btn, Content = content} end
    table.insert(Tabs, {Button = btn, Content = content})
    return content
end

local function CreateToggle(tab, name, key, default)
    if default ~= nil then Settings[key] = default end
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 34)
    btn.BackgroundColor3 = Settings[key] and Color3.fromRGB(140, 82, 255) or Color3.fromRGB(24, 24, 34)
    btn.Text = "  " .. name .. (Settings[key] and ": ON" or ": OFF")
    btn.TextColor3 = Settings[key] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = tab
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        Settings[key] = not Settings[key]
        btn.Text = "  " .. name .. (Settings[key] and ": ON" or ": OFF")
        btn.TextColor3 = Settings[key] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 200)
        btn.BackgroundColor3 = Settings[key] and Color3.fromRGB(140, 82, 255) or Color3.fromRGB(24, 24, 34)
    end)
end

-- TẠO CÁC TAB
local FarmTab = CreateTab("🌾 Auto Farm")
CreateToggle(FarmTab, "Auto Farm Level", "AutoFarmLevel")
CreateToggle(FarmTab, "Gom Quái", "BringMob")

local AimTab = CreateTab("🎯 Aim Lock")
CreateToggle(AimTab, "Aim Lock Skill", "AimLock")
CreateToggle(AimTab, "Dự Đoán (Prediction)", "Prediction", true)
CreateToggle(AimTab, "Hiện Vòng FOV", "ShowFOV")

local ESPTab = CreateTab("👁️ ESP")
CreateToggle(ESPTab, "ESP Highlight", "ESP")

local MiscTab = CreateTab("⚡ Player")
CreateToggle(MiscTab, "Speed Hack", "Speed")
CreateToggle(MiscTab, "Noclip", "Noclip")

if FirstTab then
    FirstTab.Content.Visible = true
    FirstTab.Button.BackgroundColor3 = Color3.fromRGB(140, 82, 255)
    FirstTab.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
end

-- ==========================================
-- 🎯 XỬ LÝ AIM LOCK + PREDICTION AN TOÀN
-- ==========================================
RunService.RenderStepped:Connect(function()
    pcall(function()
        local Camera = workspace.CurrentCamera
        if not Camera then return end

        if FOVCircle then
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            FOVCircle.Radius = Settings.FOV
            FOVCircle.Visible = Settings.ShowFOV and Settings.AimLock
        end

        if Settings.AimLock then
            local closestTarget = nil
            local shortestDist = Settings.FOV

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                            if dist < shortestDist then
                                shortestDist = dist
                                closestTarget = hrp
                            end
                        end
                    end
                end
            end

            if closestTarget then
                local targetPos = closestTarget.Position
                if Settings.Prediction then
                    targetPos = targetPos + (closestTarget.Velocity * Settings.PredictionStrength)
                end
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            end
        end

        -- Speed & Noclip
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and Settings.Speed then
            hum.WalkSpeed = Settings.SpeedValue
        end
    end)
end)

-- Noclip loop riêng biệt
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

SendNotification("Quantum Hub", "Đã nạp thành công bản ổn định!")
