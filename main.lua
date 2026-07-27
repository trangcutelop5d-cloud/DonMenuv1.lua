-- =================================================================
-- 🚀 DONMENU - ALL-IN-ONE MASTER SCRIPT
-- =================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==========================================
-- ⚙️ BẢNG CẤU HÌNH TỔNG (SETTINGS)
-- ==========================================
getgenv().DonMenu = {
    Aim = {
        Enabled = false,
        TeamCheck = true,
        TargetPart = "Head", -- "Head" hoặc "HumanoidRootPart"
        FOV = 120,
        ShowFOV = false,
        Smoothness = 0.2
    },
    ESP = {
        Enabled = false,
        ShowTeam = true,
        Boxes = true,
        Names = true,
        Tracers = false,
        EnemyColor = Color3.fromRGB(255, 50, 50), -- Địch màu đỏ
        TeamColor = Color3.fromRGB(50, 255, 50)   -- Đồng đội màu xanh
    },
    Speed = {
        Enabled = false,
        Value = 50
    },
    Jump = {
        Enabled = false,
        Value = 100
    },
    InfJump = { Enabled = false },
    Noclip = { Enabled = false },
    Fly = {
        Enabled = false,
        Speed = 50
    },
    TP = { ClickTPEnabled = false },
    FullBright = { Enabled = false }
}

local Settings = getgenv().DonMenu

-- ==========================================
-- 🎯 1. AIMBOT & FOV CỐ ĐỊNH
-- ==========================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 60
FOVCircle.Radius = Settings.Aim.FOV
FOVCircle.Filled = false
FOVCircle.Visible = false

local function GetScreenCenter()
    return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function GetClosestPlayer()
    local closestTarget = nil
    local shortestDistance = Settings.Aim.FOV
    local centerPos = GetScreenCenter()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if Settings.Aim.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                continue
            end

            local part = player.Character:FindFirstChild(Settings.Aim.TargetPart)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - centerPos).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestTarget = part
                    end
                end
            end
        end
    end
    return closestTarget
end

-- ==========================================
-- 👁️ 2. HỆ THỐNG ESP
-- ==========================================
local ESPObjects = {}

local function CreateESP(player)
    if player == LocalPlayer then return end

    local drawings = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Tracer = Drawing.new("Line")
    }

    drawings.Box.Thickness = 1.5
    drawings.Box.Filled = false
    drawings.Box.Visible = false

    drawings.Name.Size = 14
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.Color = Color3.fromRGB(255, 255, 255)
    drawings.Name.Visible = false

    drawings.Tracer.Thickness = 1.5
    drawings.Tracer.Visible = false

    ESPObjects[player] = drawings
end

local function RemoveESP(player)
    if ESPObjects[player] then
        for _, drawing in pairs(ESPObjects[player]) do
            drawing:Remove()
        end
        ESPObjects[player] = nil
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    CreateESP(player)
end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- ==========================================
-- 🦘 3. NHẢY VÔ HẠN (INF JUMP)
-- ==========================================
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump.Enabled then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ==========================================
-- 👻 4. XUYÊN TƯỜNG (NOCLIP)
-- ==========================================
RunService.Stepped:Connect(function()
    if Settings.Noclip.Enabled then
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

-- ==========================================
-- 🕊️ 5. FLY (BAY TỰ DO)
-- ==========================================
local flyBV, flyBG

local function StartFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    hum.PlatformStand = true

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBV.Parent = hrp

    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    flyBG.CFrame = hrp.CFrame
    flyBG.Parent = hrp
end

local function StopFly()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
    end

    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
end

-- ==========================================
-- ⚡ 6. CLICK TELEPORT
-- ==========================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if Settings.TP.ClickTPEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
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

-- ==========================================
-- 🔄 VÒNG LẶP CẬP NHẬT RENDERSTEPPED
-- ==========================================
RunService.RenderStepped:Connect(function()
    -- 1. AIM & FOV
    FOVCircle.Position = GetScreenCenter()
    FOVCircle.Radius = Settings.Aim.FOV
    FOVCircle.Visible = Settings.Aim.ShowFOV and Settings.Aim.Enabled

    if Settings.Aim.Enabled then
        local targetPart = GetClosestPlayer()
        if targetPart then
            local currentCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, targetPart.Position)
            Camera.CFrame = currentCFrame:Lerp(targetCFrame, Settings.Aim.Smoothness)
        end
    end

    -- 2. ESP
    for player, drawings in pairs(ESPObjects) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")

        local isAlive = char and hrp and hum and hum.Health > 0
        local isTeam = player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team
        local shouldShow = Settings.ESP.Enabled and isAlive and (not isTeam or Settings.ESP.ShowTeam)

        if shouldShow then
            local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                local currentColor = isTeam and Settings.ESP.TeamColor or Settings.ESP.EnemyColor
                local head = char:FindFirstChild("Head")
                local headPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or hrpPos
                local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

                local height = math.abs(headPos.Y - legPos.Y)
                local width = height / 1.5

                if Settings.ESP.Boxes then
                    drawings.Box.Size = Vector2.new(width, height)
                    drawings.Box.Position = Vector2.new(hrpPos.X - width / 2, hrpPos.Y - height / 2)
                    drawings.Box.Color = currentColor
                    drawings.Box.Visible = true
                else
                    drawings.Box.Visible = false
                end

                if Settings.ESP.Names then
                    local distance = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude)
                    drawings.Name.Text = string.format("%s [%dm]", player.Name, distance)
                    drawings.Name.Position = Vector2.new(hrpPos.X, hrpPos.Y - height / 2 - 16)
                    drawings.Name.Visible = true
                else
                    drawings.Name.Visible = false
                end

                if Settings.ESP.Tracers then
                    drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    drawings.Tracer.To = Vector2.new(hrpPos.X, hrpPos.Y + height / 2)
                    drawings.Tracer.Color = currentColor
                    drawings.Tracer.Visible = true
                else
                    drawings.Tracer.Visible = false
                end
            else
                drawings.Box.Visible = false
                drawings.Name.Visible = false
                drawings.Tracer.Visible = false
            end
        else
            drawings.Box.Visible = false
            drawings.Name.Visible = false
            drawings.Tracer.Visible = false
        end
    end

    -- 3. SPEED & JUMP
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if Settings.Speed.Enabled then hum.WalkSpeed = Settings.Speed.Value end
        if Settings.Jump.Enabled then
            hum.UseJumpPower = true
            hum.JumpPower = Settings.Jump.Value
        end
    end

    -- 4. FLY
    if Settings.Fly.Enabled then
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if not flyBV or not flyBV.Parent then StartFly() end

            local moveVector = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector - Vector3.new(0, 1, 0) end

            if flyBV then flyBV.Velocity = moveVector * Settings.Fly.Speed end
            if flyBG then flyBG.CFrame = Camera.CFrame end
        end
    else
        StopFly()
    end

    -- 5. FULLBRIGHT
    if Settings.FullBright.Enabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    Settings.Fly.Enabled = false
    StopFly()
end)
