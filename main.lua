-- DonMenu client-only
-- LocalScript dành cho Executor / Roblox Client

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Cấu hình chung
local MENU_KEY = Enum.KeyCode.M
local GUI_NAME = "DonMenuGuiV5"
local RENDER_BINDING_NAME = "DonMenuEspBoxesV5"
local MENU_ACTION_NAME = "ToggleDonMenu"

-- Cấu hình ESP
local PLAYER_ESP_MAX_DISTANCE = 5000
local PLAYER_ESP_COLOR = Color3.fromRGB(0, 255, 163)
local MONSTER_ESP_MAX_DISTANCE = 5000
local MONSTER_ESP_COLOR = Color3.fromRGB(255, 91, 66)
local ESP_BOX_THICKNESS = 3
local ESP_BOX_FILL_TRANSPARENCY = 0.91
local TARGETABLE_ATTRIBUTE = "Targetable"

-- Cách nhận diện quái
local MONSTER_TAG = "Monster"
local MONSTER_FOLDER_NAME = "Monsters"
local MONSTER_ATTRIBUTE = "IsMonster"
local MONSTER_TYPE_ATTRIBUTE = "MonsterType"
local AUTO_DETECT_NPC_HUMANOIDS = true
local MONSTER_SCAN_INTERVAL = 1

-- AutoFarm client-only
local FARM_HOVER_CLEARANCE = 4
local FARM_HORIZONTAL_OFFSET = 2.5
local FARM_MOVE_SPEED = 85
local AUTO_ATTACK_DISTANCE = 20
local AUTO_ATTACK_INTERVAL = 0.25
local AUTO_ATTACK_RELEASE_DELAY = 0.10
local NOCLIP_WHILE_AUTOFARM = true
local BASIC_ATTACK_TOOL_NAME = nil
local BASIC_ATTACK_ATTRIBUTE = "BasicAttack"

-- Speed client-only
local SPEED_DEFAULT = 50
local SPEED_MIN = 10
local SPEED_MAX = 200
local SPEED_STEP = 10
local SPEED_COLOR = Color3.fromRGB(255, 181, 71)

-- Fix Lag client-only
local FIX_LAG_COLOR = Color3.fromRGB(91, 214, 146)
local FIX_LAG_BATCH_SIZE = 300

-- Aim Assist client-only
local AIM_MAX_DISTANCE = 1000
local AIM_FOV_RADIUS = 220
local AIM_SMOOTH_SPEED = 12
local AIM_COLOR = Color3.fromRGB(181, 105, 255)
local AIM_RENDER_BINDING_NAME = "DonMenuAimAssistV5"

local menuOpen = false
local currentPage = "ESP"
local playerEspEnabled = false
local monsterEspEnabled = false
local autoFarmEnabled = false
local selectedMonsterType = nil
local speedEnabled = false
local selectedSpeed = SPEED_DEFAULT
local originalWalkSpeed = nil
local fixLagEnabled = false
local fixLagGeneration = 0
local fixLagOriginals = {}
local fixLagConnections = {}
local aimEnabled = false
local aimTargetMode = "Monster"
local currentAimTarget = nil

local playerEntries = {}
local monsterEntries = {}
local monsterCandidates = {}
local monsterTypeSignature = nil
local currentFarmTarget = nil
local lastAutoAttackTime = 0
local basicAttackTool = nil
local originalCollision = {}

-- Dọn các phiên bản cũ
local legacyGuiNames = {
	"PlayerEspGui",
	"PlayerMonsterEspGuiV4",
	GUI_NAME,
}

for _, guiName in ipairs(legacyGuiNames) do
	local oldGui = playerGui:FindFirstChild(guiName)
	if oldGui then
		oldGui:Destroy()
	end
end

-- Màu giao diện
local COLORS = {
	panel = Color3.fromRGB(16, 21, 34),
	panelAlt = Color3.fromRGB(22, 29, 45),
	card = Color3.fromRGB(28, 36, 54),
	cardHover = Color3.fromRGB(34, 44, 65),
	border = Color3.fromRGB(64, 80, 113),
	text = Color3.fromRGB(240, 245, 255),
	muted = Color3.fromRGB(154, 168, 195),
	accent = Color3.fromRGB(93, 103, 255),
	accent2 = Color3.fromRGB(37, 200, 224),
	success = Color3.fromRGB(35, 175, 112),
	danger = Color3.fromRGB(212, 75, 62),
}

local function addCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
	return corner
end

local function addStroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness or 1
	stroke.Parent = parent
	return stroke
end

local function addGradient(parent, colorA, colorB, rotation)
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(colorA, colorB)
	gradient.Rotation = rotation or 0
	gradient.Parent = parent
	return gradient
end

local function makeLabel(parent, name, text, position, size, textSize, zIndex)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Position = position
	label.Size = size
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.Text = text
	label.TextColor3 = COLORS.text
	label.TextSize = textSize
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = zIndex or 102
	label.Parent = parent
	return label
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = GUI_NAME
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 50
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local menuButton = Instance.new("TextButton")
menuButton.Name = "OpenDonMenu"
menuButton.AnchorPoint = Vector2.new(1, 0.5)
menuButton.Position = UDim2.new(1, -18, 0.22, 0)
menuButton.Size = UDim2.fromOffset(82, 64)
menuButton.AutoButtonColor = false
menuButton.BackgroundColor3 = COLORS.accent
menuButton.Font = Enum.Font.GothamBold
menuButton.Text = "DON\nMENU"
menuButton.TextColor3 = Color3.new(1, 1, 1)
menuButton.TextSize = 15
menuButton.TextStrokeTransparency = 0.65
menuButton.ZIndex = 100
menuButton.Parent = screenGui
addCorner(menuButton, 17)
local menuButtonStroke = addStroke(menuButton, Color3.fromRGB(135, 205, 255), 2)
addGradient(menuButton, COLORS.accent, COLORS.accent2, 45)

local mainPanel = Instance.new("Frame")
mainPanel.Name = "Hub"
mainPanel.AnchorPoint = Vector2.new(0.5, 0.5)
mainPanel.Position = UDim2.fromScale(0.66, 0.5)
mainPanel.Size = UDim2.fromOffset(560, 370)
mainPanel.BackgroundColor3 = COLORS.panel
mainPanel.Visible = false
mainPanel.ZIndex = 100
mainPanel.Parent = screenGui
addCorner(mainPanel, 18)
addStroke(mainPanel, COLORS.border, 2)

local hubScale = Instance.new("UIScale")
hubScale.Name = "ResponsiveScale"
hubScale.Scale = 1
hubScale.Parent = mainPanel

local cameraViewportConnection = nil
local function updateHubScale()
	local camera = Workspace.CurrentCamera
	if not camera then return end
	local viewport = camera.ViewportSize
	hubScale.Scale = math.clamp(math.min(viewport.X / 720, viewport.Y / 500), 0.66, 1)
end

local function connectCameraScale()
	if cameraViewportConnection then
		cameraViewportConnection:Disconnect()
	end
	local camera = Workspace.CurrentCamera
	if camera then
		cameraViewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateHubScale)
	end
	updateHubScale()
end

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(connectCameraScale)
connectCameraScale()

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 58)
header.BackgroundColor3 = COLORS.panelAlt
header.Active = true
header.ZIndex = 101
header.Parent = mainPanel
addCorner(header, 18)
addGradient(header, Color3.fromRGB(31, 40, 70), Color3.fromRGB(22, 30, 48), 0)

local headerMask = Instance.new("Frame")
headerMask.Position = UDim2.new(0, 0, 1, -18)
headerMask.Size = UDim2.new(1, 0, 0, 18)
headerMask.BorderSizePixel = 0
headerMask.BackgroundColor3 = Color3.fromRGB(25, 33, 57)
headerMask.ZIndex = 101
headerMask.Parent = header

local hubTitle = makeLabel(header, "Title", "DonMenu", UDim2.fromOffset(18, 8), UDim2.fromOffset(220, 26), 22, 102)
hubTitle.Font = Enum.Font.GothamBold

local hubSubtitle = makeLabel(header, "Subtitle", "ESP • AUTOFARM • SPEED • FIX LAG • AIM", UDim2.fromOffset(19, 34), UDim2.fromOffset(310, 16), 10, 102)
hubSubtitle.TextColor3 = COLORS.muted

local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.AnchorPoint = Vector2.new(1, 0.5)
closeButton.Position = UDim2.new(1, -14, 0.5, 0)
closeButton.Size = UDim2.fromOffset(36, 36)
closeButton.AutoButtonColor = false
closeButton.BackgroundColor3 = Color3.fromRGB(49, 59, 82)
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "×"
closeButton.TextColor3 = COLORS.text
closeButton.TextSize = 19
closeButton.ZIndex = 103
closeButton.Parent = header
addCorner(closeButton, 10)

local sidebar = Instance.new("Frame")
sidebar.Name = "Navigation"
sidebar.Position = UDim2.fromOffset(0, 58)
sidebar.Size = UDim2.new(0, 142, 1, -58)
sidebar.BorderSizePixel = 0
sidebar.BackgroundColor3 = Color3.fromRGB(18, 25, 40)
sidebar.ZIndex = 101
sidebar.Parent = mainPanel

local content = Instance.new("Frame")
content.Name = "Content"
content.Position = UDim2.fromOffset(142, 58)
content.Size = UDim2.new(1, -142, 1, -58)
content.BackgroundTransparency = 1
content.ClipsDescendants = true
content.ZIndex = 101
content.Parent = mainPanel

local function createNavButton(name, text, y)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Position = UDim2.fromOffset(10, y)
	button.Size = UDim2.new(1, -20, 0, 46)
	button.AutoButtonColor = false
	button.BackgroundColor3 = COLORS.card
	button.Font = Enum.Font.GothamSemibold
	button.Text = text
	button.TextColor3 = COLORS.muted
	button.TextSize = 14
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.ZIndex = 102
	button.Parent = sidebar
	addCorner(button, 11)

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 14)
	padding.Parent = button

	return button
end

local espNavButton = createNavButton("EspNav", "◈  ESP", 16)
local farmNavButton = createNavButton("FarmNav", "⚡  AutoFarm", 72)
local speedNavButton = createNavButton("SpeedNav", "»  Speed", 128)
local fixLagNavButton = createNavButton("FixLagNav", "◇  Fix Lag", 184)
local aimNavButton = createNavButton("AimNav", "◎  Aim", 240)

local espPage = Instance.new("Frame")
espPage.Name = "EspPage"
espPage.Size = UDim2.fromScale(1, 1)
espPage.BackgroundTransparency = 1
espPage.ZIndex = 102
espPage.Parent = content

local farmPage = Instance.new("Frame")
farmPage.Name = "AutoFarmPage"
farmPage.Size = UDim2.fromScale(1, 1)
farmPage.BackgroundTransparency = 1
farmPage.Visible = false
farmPage.ZIndex = 102
farmPage.Parent = content

local speedPage = Instance.new("Frame")
speedPage.Name = "SpeedPage"
speedPage.Size = UDim2.fromScale(1, 1)
speedPage.BackgroundTransparency = 1
speedPage.Visible = false
speedPage.ZIndex = 102
speedPage.Parent = content

local fixLagPage = Instance.new("Frame")
fixLagPage.Name = "FixLagPage"
fixLagPage.Size = UDim2.fromScale(1, 1)
fixLagPage.BackgroundTransparency = 1
fixLagPage.Visible = false
fixLagPage.ZIndex = 102
fixLagPage.Parent = content

local aimPage = Instance.new("Frame")
aimPage.Name = "AimPage"
aimPage.Size = UDim2.fromScale(1, 1)
aimPage.BackgroundTransparency = 1
aimPage.Visible = false
aimPage.ZIndex = 102
aimPage.Parent = content

local function createPageTitle(parent, titleText, subtitleText)
	local titleLabel = makeLabel(parent, "PageTitle", titleText, UDim2.fromOffset(18, 14), UDim2.new(1, -36, 0, 26), 20, 103)
	titleLabel.Font = Enum.Font.GothamBold

	local subtitleLabel = makeLabel(parent, "PageSubtitle", subtitleText, UDim2.fromOffset(18, 40), UDim2.new(1, -36, 0, 18), 11, 103)
	subtitleLabel.TextColor3 = COLORS.muted
end

createPageTitle(espPage, "ESP", "Khung bao mục tiêu theo thời gian thực")
createPageTitle(farmPage, "AutoFarm", "Chọn quái, tiếp cận và tự động tấn công")
createPageTitle(speedPage, "Speed", "Điều chỉnh tốc độ di chuyển của nhân vật")
createPageTitle(fixLagPage, "Fix Lag", "Giảm hiệu ứng và đơn giản hóa đồ họa")
createPageTitle(aimPage, "Aim", "Aim-assist mượt cho mục tiêu đang hiển thị")

local function createToggleCard(parent, name, titleText, descriptionText, y, accent)
	local card = Instance.new("Frame")
	card.Name = name
	card.Position = UDim2.fromOffset(18, y)
	card.Size = UDim2.new(1, -36, 0, 78)
	card.BackgroundColor3 = COLORS.card
	card.ZIndex = 103
	card.Parent = parent
	addCorner(card, 14)
	addStroke(card, COLORS.border, 1)

	local titleLabel = makeLabel(card, "Title", titleText, UDim2.fromOffset(15, 12), UDim2.new(1, -130, 0, 23), 15, 104)
	titleLabel.Font = Enum.Font.GothamBold

	local descriptionLabel = makeLabel(card, "Description", descriptionText, UDim2.fromOffset(15, 40), UDim2.new(1, -125, 0, 20), 11, 104)
	descriptionLabel.TextColor3 = COLORS.muted

	local toggle = Instance.new("TextButton")
	toggle.Name = "Toggle"
	toggle.AnchorPoint = Vector2.new(1, 0.5)
	toggle.Position = UDim2.new(1, -14, 0.5, 0)
	toggle.Size = UDim2.fromOffset(96, 38)
	toggle.AutoButtonColor = false
	toggle.BackgroundColor3 = Color3.fromRGB(53, 63, 84)
	toggle.Font = Enum.Font.GothamBold
	toggle.Text = "TẮT"
	toggle.TextColor3 = COLORS.muted
	toggle.TextSize = 13
	toggle.ZIndex = 105
	toggle.Parent = card
	addCorner(toggle, 12)
	local toggleStroke = addStroke(toggle, COLORS.border, 1)

	return toggle, toggleStroke, accent
end

local playerEspToggle, playerEspStroke = createToggleCard(espPage, "PlayerEspCard", "Player ESP", "Khung xanh, tên và khoảng cách người chơi", 72, PLAYER_ESP_COLOR)
local monsterEspToggle, monsterEspStroke = createToggleCard(espPage, "MonsterEspCard", "Monster ESP", "Khung đỏ, tên và khoảng cách quái", 160, MONSTER_ESP_COLOR)

local espStatusLabel = makeLabel(espPage, "EspStatus", "Người chơi: TẮT  •  Quái: TẮT", UDim2.fromOffset(20, 258), UDim2.new(1, -40, 0, 30), 12, 103)
espStatusLabel.TextColor3 = COLORS.muted

-- Trang AutoFarm
local selectLabel = makeLabel(farmPage, "SelectLabel", "LOẠI QUÁI", UDim2.fromOffset(18, 72), UDim2.new(1, -36, 0, 18), 11, 103)
selectLabel.Font = Enum.Font.GothamBold
selectLabel.TextColor3 = COLORS.muted

local monsterSelectButton = Instance.new("TextButton")
monsterSelectButton.Name = "MonsterSelect"
monsterSelectButton.Position = UDim2.fromOffset(18, 94)
monsterSelectButton.Size = UDim2.new(1, -36, 0, 48)
monsterSelectButton.AutoButtonColor = false
monsterSelectButton.BackgroundColor3 = COLORS.card
monsterSelectButton.Font = Enum.Font.GothamSemibold
monsterSelectButton.Text = "Chọn loại quái  ▾"
monsterSelectButton.TextColor3 = COLORS.text
monsterSelectButton.TextSize = 13
monsterSelectButton.TextXAlignment = Enum.TextXAlignment.Left
monsterSelectButton.ZIndex = 106
monsterSelectButton.Parent = farmPage
addCorner(monsterSelectButton, 12)
addStroke(monsterSelectButton, COLORS.border, 1)
local selectPadding = Instance.new("UIPadding")
selectPadding.PaddingLeft = UDim.new(0, 15)
selectPadding.Parent = monsterSelectButton

local monsterList = Instance.new("ScrollingFrame")
monsterList.Name = "MonsterList"
monsterList.Position = UDim2.fromOffset(18, 147)
monsterList.Size = UDim2.new(1, -36, 0, 128)
monsterList.BackgroundColor3 = Color3.fromRGB(21, 28, 43)
monsterList.BorderSizePixel = 0
monsterList.ScrollBarImageColor3 = COLORS.accent2
monsterList.ScrollBarThickness = 4
monsterList.AutomaticCanvasSize = Enum.AutomaticSize.Y
monsterList.CanvasSize = UDim2.new()
monsterList.Visible = false
monsterList.ZIndex = 130
monsterList.Parent = farmPage
addCorner(monsterList, 12)
addStroke(monsterList, COLORS.accent, 1)

local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0, 7)
listPadding.PaddingBottom = UDim.new(0, 7)
listPadding.PaddingLeft = UDim.new(0, 7)
listPadding.PaddingRight = UDim.new(0, 7)
listPadding.Parent = monsterList

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = monsterList

local autoFarmButton = Instance.new("TextButton")
autoFarmButton.Name = "AutoFarmToggle"
autoFarmButton.Position = UDim2.fromOffset(18, 156)
autoFarmButton.Size = UDim2.new(1, -36, 0, 52)
autoFarmButton.AutoButtonColor = false
autoFarmButton.BackgroundColor3 = Color3.fromRGB(53, 63, 84)
autoFarmButton.Font = Enum.Font.GothamBold
autoFarmButton.Text = "BẮT ĐẦU AUTOFARM"
autoFarmButton.TextColor3 = COLORS.text
autoFarmButton.TextSize = 14
autoFarmButton.ZIndex = 104
autoFarmButton.Parent = farmPage
addCorner(autoFarmButton, 13)
local autoFarmStroke = addStroke(autoFarmButton, COLORS.border, 1)

local autoFarmStatusLabel = makeLabel(farmPage, "FarmStatus", "Trạng thái: chưa chọn loại quái", UDim2.fromOffset(20, 222), UDim2.new(1, -40, 0, 38), 12, 103)
autoFarmStatusLabel.TextColor3 = COLORS.muted
autoFarmStatusLabel.TextWrapped = true
autoFarmStatusLabel.TextYAlignment = Enum.TextYAlignment.Top

local farmInfoLabel = makeLabel(farmPage, "FarmInfo", "Bay lên trên quái và đánh ngay khi cách cơ thể quái không quá 20 studs.", UDim2.fromOffset(20, 270), UDim2.new(1, -40, 0, 36), 10, 103)
farmInfoLabel.TextColor3 = Color3.fromRGB(118, 135, 165)
farmInfoLabel.TextWrapped = true

-- Trang Speed
local speedToggle, speedToggleStroke = createToggleCard(speedPage, "SpeedToggleCard", "Speed", "Bật hoặc tắt tốc độ di chuyển nhanh", 72, SPEED_COLOR)

local speedControlCard = Instance.new("Frame")
speedControlCard.Name = "SpeedControl"
speedControlCard.Position = UDim2.fromOffset(18, 160)
speedControlCard.Size = UDim2.new(1, -36, 0, 118)
speedControlCard.BackgroundColor3 = COLORS.card
speedControlCard.ZIndex = 103
speedControlCard.Parent = speedPage
addCorner(speedControlCard, 14)
addStroke(speedControlCard, COLORS.border, 1)

local speedControlTitle = makeLabel(speedControlCard, "Title", "TỐC ĐỘ MONG MUỐN", UDim2.fromOffset(15, 12), UDim2.new(1, -30, 0, 20), 11, 104)
speedControlTitle.Font = Enum.Font.GothamBold
speedControlTitle.TextColor3 = COLORS.muted

local function createSpeedAdjustButton(name, text, position)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Position = position
	button.Size = UDim2.fromOffset(92, 50)
	button.AutoButtonColor = false
	button.BackgroundColor3 = Color3.fromRGB(48, 59, 81)
	button.Font = Enum.Font.GothamBold
	button.Text = text
	button.TextColor3 = COLORS.text
	button.TextSize = 15
	button.ZIndex = 105
	button.Parent = speedControlCard
	addCorner(button, 12)
	addStroke(button, COLORS.border, 1)
	return button
end

local speedMinusButton = createSpeedAdjustButton("Decrease", "− " .. SPEED_STEP, UDim2.fromOffset(15, 48))
local speedPlusButton = createSpeedAdjustButton("Increase", "+ " .. SPEED_STEP, UDim2.new(1, -107, 0, 48))

local speedValueLabel = makeLabel(speedControlCard, "Value", tostring(selectedSpeed), UDim2.new(0.5, -66, 0, 48), UDim2.fromOffset(132, 50), 23, 105)
speedValueLabel.BackgroundTransparency = 0
speedValueLabel.BackgroundColor3 = Color3.fromRGB(31, 40, 59)
speedValueLabel.Font = Enum.Font.GothamBold
speedValueLabel.TextColor3 = SPEED_COLOR
speedValueLabel.TextXAlignment = Enum.TextXAlignment.Center
addCorner(speedValueLabel, 12)
addStroke(speedValueLabel, Color3.fromRGB(72, 84, 110), 1)

local speedStatusLabel = makeLabel(speedPage, "SpeedStatus", "Speed đang tắt • tốc độ đã chọn: " .. selectedSpeed, UDim2.fromOffset(20, 287), UDim2.new(1, -40, 0, 20), 11, 103)
speedStatusLabel.TextColor3 = COLORS.muted

-- Trang Fix Lag
local fixLagToggle, fixLagToggleStroke = createToggleCard(fixLagPage, "FixLagToggleCard", "Fix Lag", "Tắt hiệu ứng và giảm độ phức tạp đồ họa", 72, FIX_LAG_COLOR)

local fixLagInfoCard = Instance.new("Frame")
fixLagInfoCard.Name = "FixLagInfo"
fixLagInfoCard.Position = UDim2.fromOffset(18, 160)
fixLagInfoCard.Size = UDim2.new(1, -36, 0, 118)
fixLagInfoCard.BackgroundColor3 = COLORS.card
fixLagInfoCard.ZIndex = 103
fixLagInfoCard.Parent = fixLagPage
addCorner(fixLagInfoCard, 14)
addStroke(fixLagInfoCard, COLORS.border, 1)

local fixLagInfoTitle = makeLabel(fixLagInfoCard, "Title", "CHẾ ĐỘ ĐỒ HỌA ĐƠN GIẢN", UDim2.fromOffset(15, 12), UDim2.new(1, -30, 0, 20), 11, 104)
fixLagInfoTitle.Font = Enum.Font.GothamBold
fixLagInfoTitle.TextColor3 = FIX_LAG_COLOR

local fixLagInfoText = makeLabel(fixLagInfoCard, "Description", "• Tắt particle, trail, beam và ánh sáng\n• Tắt hậu kỳ, bóng đổ và texture\n• Đơn giản hóa vật liệu, nước và địa hình", UDim2.fromOffset(15, 39), UDim2.new(1, -30, 0, 67), 11, 104)
fixLagInfoText.TextColor3 = COLORS.muted
fixLagInfoText.TextWrapped = true
fixLagInfoText.TextYAlignment = Enum.TextYAlignment.Top

local fixLagStatusLabel = makeLabel(fixLagPage, "FixLagStatus", "Fix Lag đang tắt • đồ họa bình thường", UDim2.fromOffset(20, 287), UDim2.new(1, -40, 0, 20), 11, 103)
fixLagStatusLabel.TextColor3 = COLORS.muted

-- Trang Aim
local aimToggle, aimToggleStroke = createToggleCard(aimPage, "AimToggleCard", "Aim Assist", "Khóa mượt vào mục tiêu gần tâm màn hình", 72, AIM_COLOR)

local aimModeCard = Instance.new("Frame")
aimModeCard.Name = "AimMode"
aimModeCard.Position = UDim2.fromOffset(18, 160)
aimModeCard.Size = UDim2.new(1, -36, 0, 102)
aimModeCard.BackgroundColor3 = COLORS.card
aimModeCard.ZIndex = 103
aimModeCard.Parent = aimPage
addCorner(aimModeCard, 14)
addStroke(aimModeCard, COLORS.border, 1)

local aimModeTitle = makeLabel(aimModeCard, "Title", "LOẠI MỤC TIÊU", UDim2.fromOffset(15, 11), UDim2.new(1, -30, 0, 20), 11, 104)
aimModeTitle.Font = Enum.Font.GothamBold
aimModeTitle.TextColor3 = COLORS.muted

local function createAimModeButton(name, text, position)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Position = position
	button.Size = UDim2.new(0.5, -22, 0, 44)
	button.AutoButtonColor = false
	button.BackgroundColor3 = Color3.fromRGB(48, 59, 81)
	button.Font = Enum.Font.GothamBold
	button.Text = text
	button.TextColor3 = COLORS.muted
	button.TextSize = 13
	button.ZIndex = 105
	button.Parent = aimModeCard
	addCorner(button, 12)
	addStroke(button, COLORS.border, 1)
	return button
end

local aimPlayerButton = createAimModeButton("PlayerMode", "PLAYER", UDim2.fromOffset(15, 45))
local aimMonsterButton = createAimModeButton("MonsterMode", "MONSTER", UDim2.new(0.5, 7, 0, 45))

local aimStatusLabel = makeLabel(aimPage, "AimStatus", "Aim đang tắt • mục tiêu: Monster", UDim2.fromOffset(20, 274), UDim2.new(1, -40, 0, 31), 11, 103)
aimStatusLabel.TextColor3 = COLORS.muted
aimStatusLabel.TextWrapped = true

local function updateToggleVisual(button, stroke, enabled, accent)
	if enabled then
		button.Text = "BẬT"
		button.TextColor3 = Color3.new(1, 1, 1)
		button.BackgroundColor3 = accent
		stroke.Color = accent
	else
		button.Text = "TẮT"
		button.TextColor3 = COLORS.muted
		button.BackgroundColor3 = Color3.fromRGB(53, 63, 84)
		stroke.Color = COLORS.border
	end
end

local function getLocalHumanoid()
	local character = localPlayer.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function updateSpeedVisual()
	updateToggleVisual(speedToggle, speedToggleStroke, speedEnabled, SPEED_COLOR)
	speedValueLabel.Text = tostring(selectedSpeed)
	speedValueLabel.TextColor3 = speedEnabled and Color3.new(1, 1, 1) or SPEED_COLOR
	speedStatusLabel.Text = speedEnabled and ("Speed đang bật • tốc độ: " .. selectedSpeed) or ("Speed đang tắt • tốc độ đã chọn: " .. selectedSpeed)
end

local function applySelectedSpeed()
	local humanoid = getLocalHumanoid()
	if not humanoid then return end

	if originalWalkSpeed == nil then
		originalWalkSpeed = humanoid.WalkSpeed
	end
	humanoid.WalkSpeed = selectedSpeed
end

local function setSpeedEnabled(newValue)
	if speedEnabled == newValue then return end

	speedEnabled = newValue
	local humanoid = getLocalHumanoid()

	if speedEnabled then
		if humanoid then
			originalWalkSpeed = humanoid.WalkSpeed
		end
		applySelectedSpeed()
	else
		if humanoid and originalWalkSpeed ~= nil then
			humanoid.WalkSpeed = originalWalkSpeed
		end
		originalWalkSpeed = nil
	end

	updateSpeedVisual()
end

local function setSelectedSpeed(newValue)
	selectedSpeed = math.clamp(math.round(newValue), SPEED_MIN, SPEED_MAX)
	if speedEnabled then
		applySelectedSpeed()
	end
	updateSpeedVisual()
end

local function updateFixLagVisual()
	updateToggleVisual(fixLagToggle, fixLagToggleStroke, fixLagEnabled, FIX_LAG_COLOR)
	if fixLagEnabled then
		fixLagStatusLabel.Text = "Fix Lag đang bật • đang dùng đồ họa tối giản"
	else
		fixLagStatusLabel.Text = "Fix Lag đang tắt • đồ họa bình thường"
	end
end

local function rememberAndSet(instance, propertyName, newValue)
	local properties = fixLagOriginals[instance]
	local storedValue = properties and properties[propertyName]

	if not storedValue then
		local readSucceeded, currentValue = pcall(function()
			return instance[propertyName]
		end)
		if not readSucceeded then return end

		if not properties then
			properties = {}
			fixLagOriginals[instance] = properties
		end
		properties[propertyName] = { value = currentValue }
	end

	pcall(function()
		instance[propertyName] = newValue
	end)
end

local function simplifyVisualInstance(instance)
	if instance:IsA("BasePart") then
		rememberAndSet(instance, "Material", Enum.Material.Plastic)
		rememberAndSet(instance, "MaterialVariant", "")
		rememberAndSet(instance, "Reflectance", 0)
		rememberAndSet(instance, "CastShadow", false)
	end

	if instance:IsA("MeshPart") then
		rememberAndSet(instance, "TextureID", "")
	end

	if instance:IsA("SpecialMesh") then
		rememberAndSet(instance, "TextureId", "")
	end

	if instance:IsA("Decal") or instance:IsA("Texture") then
		rememberAndSet(instance, "Transparency", 1)
	end

	if instance:IsA("SurfaceAppearance") then
		rememberAndSet(instance, "ColorMap", "")
		rememberAndSet(instance, "MetalnessMap", "")
		rememberAndSet(instance, "NormalMap", "")
		rememberAndSet(instance, "RoughnessMap", "")
	end

	if instance:IsA("ParticleEmitter")
		or instance:IsA("Trail")
		or instance:IsA("Beam")
		or instance:IsA("Smoke")
		or instance:IsA("Fire")
		or instance:IsA("Sparkles")
		or instance:IsA("Light")
		or instance:IsA("PostEffect")
	then
		rememberAndSet(instance, "Enabled", false)
	end

	if instance:IsA("Explosion") then
		rememberAndSet(instance, "Visible", false)
	end

	if instance:IsA("Atmosphere") then
		rememberAndSet(instance, "Density", 0)
		rememberAndSet(instance, "Haze", 0)
		rememberAndSet(instance, "Glare", 0)
	end

	if instance:IsA("Clouds") then
		rememberAndSet(instance, "Enabled", false)
	end

	if instance:IsA("Terrain") then
		rememberAndSet(instance, "Decoration", false)
		rememberAndSet(instance, "WaterWaveSize", 0)
		rememberAndSet(instance, "WaterWaveSpeed", 0)
		rememberAndSet(instance, "WaterReflectance", 0)
		rememberAndSet(instance, "WaterTransparency", 1)
	end
end

local function simplifyLighting()
	rememberAndSet(Lighting, "GlobalShadows", false)
	rememberAndSet(Lighting, "EnvironmentDiffuseScale", 0)
	rememberAndSet(Lighting, "EnvironmentSpecularScale", 0)
	rememberAndSet(Lighting, "ShadowSoftness", 0)
	rememberAndSet(Lighting, "FogEnd", 100000)
end

local function disconnectFixLagConnections()
	for _, connection in ipairs(fixLagConnections) do
		connection:Disconnect()
	end
	table.clear(fixLagConnections)
end

local function restoreNormalGraphics()
	for instance, properties in pairs(fixLagOriginals) do
		for propertyName, storedValue in pairs(properties) do
			pcall(function()
				instance[propertyName] = storedValue.value
			end)
		end
	end
	table.clear(fixLagOriginals)
end

local function applyFixLagInBatches(generation)
	simplifyLighting()
	simplifyVisualInstance(Workspace.Terrain)

	local worldDescendants = Workspace:GetDescendants()
	for index, instance in ipairs(worldDescendants) do
		if not fixLagEnabled or generation ~= fixLagGeneration then return end
		simplifyVisualInstance(instance)
		if index % FIX_LAG_BATCH_SIZE == 0 then
			task.wait()
		end
	end

	local lightingDescendants = Lighting:GetDescendants()
	for index, instance in ipairs(lightingDescendants) do
		if not fixLagEnabled or generation ~= fixLagGeneration then return end
		simplifyVisualInstance(instance)
		if index % FIX_LAG_BATCH_SIZE == 0 then
			task.wait()
		end
	end

	if fixLagEnabled and generation == fixLagGeneration then
		fixLagStatusLabel.Text = string.format("Fix Lag đang bật • đã tối ưu %d đối tượng", #worldDescendants + #lightingDescendants)
	end
end

local function setFixLagEnabled(newValue)
	if fixLagEnabled == newValue then return end

	fixLagEnabled = newValue
	fixLagGeneration += 1
	disconnectFixLagConnections()

	if fixLagEnabled then
		table.insert(fixLagConnections, Workspace.DescendantAdded:Connect(function(instance)
			if fixLagEnabled then simplifyVisualInstance(instance) end
		end))
		table.insert(fixLagConnections, Lighting.DescendantAdded:Connect(function(instance)
			if fixLagEnabled then simplifyVisualInstance(instance) end
		end))

		local generation = fixLagGeneration
		task.spawn(function()
			applyFixLagInBatches(generation)
		end)
	else
		restoreNormalGraphics()
	end

	updateFixLagVisual()
end

local function updateAimVisual()
	updateToggleVisual(aimToggle, aimToggleStroke, aimEnabled, AIM_COLOR)

	local playerActive = aimTargetMode == "Player"
	aimPlayerButton.BackgroundColor3 = playerActive and AIM_COLOR or Color3.fromRGB(48, 59, 81)
	aimPlayerButton.TextColor3 = playerActive and Color3.new(1, 1, 1) or COLORS.muted
	aimMonsterButton.BackgroundColor3 = playerActive and Color3.fromRGB(48, 59, 81) or AIM_COLOR
	aimMonsterButton.TextColor3 = playerActive and COLORS.muted or Color3.new(1, 1, 1)

	aimStatusLabel.Text = aimEnabled and ("Aim đang bật • đang tìm " .. aimTargetMode) or ("Aim đang tắt • mục tiêu: " .. aimTargetMode)
end

local function setAimEnabled(newValue)
	aimEnabled = newValue
	currentAimTarget = nil
	updateAimVisual()
end

local function setAimTargetMode(newMode)
	if newMode ~= "Player" and newMode ~= "Monster" then return end
	aimTargetMode = newMode
	currentAimTarget = nil
	updateAimVisual()
end

local function updateAutoFarmVisual()
	if autoFarmEnabled then
		autoFarmButton.Text = "DỪNG AUTOFARM"
		autoFarmButton.BackgroundColor3 = COLORS.danger
		autoFarmStroke.Color = Color3.fromRGB(255, 133, 117)
	else
		autoFarmButton.Text = "BẮT ĐẦU AUTOFARM"
		autoFarmButton.BackgroundColor3 = COLORS.success
		autoFarmStroke.Color = Color3.fromRGB(100, 239, 176)
	end
end

local function setMenuOpen(newValue)
	menuOpen = newValue
	mainPanel.Visible = menuOpen

	if menuOpen then
		menuButtonStroke.Color = Color3.new(1, 1, 1)
	else
		menuButtonStroke.Color = Color3.fromRGB(135, 205, 255)
		monsterList.Visible = false
	end
end

local function setPage(pageName)
	currentPage = pageName
	espPage.Visible = pageName == "ESP"
	farmPage.Visible = pageName == "AutoFarm"
	speedPage.Visible = pageName == "Speed"
	fixLagPage.Visible = pageName == "FixLag"
	aimPage.Visible = pageName == "Aim"
	monsterList.Visible = false

	local espActive = pageName == "ESP"
	local farmActive = pageName == "AutoFarm"
	local speedActive = pageName == "Speed"
	local fixLagActive = pageName == "FixLag"
	local aimActive = pageName == "Aim"
	espNavButton.BackgroundColor3 = espActive and COLORS.accent or COLORS.card
	espNavButton.TextColor3 = espActive and COLORS.text or COLORS.muted
	farmNavButton.BackgroundColor3 = farmActive and COLORS.accent or COLORS.card
	farmNavButton.TextColor3 = farmActive and COLORS.text or COLORS.muted
	speedNavButton.BackgroundColor3 = speedActive and COLORS.accent or COLORS.card
	speedNavButton.TextColor3 = speedActive and COLORS.text or COLORS.muted
	fixLagNavButton.BackgroundColor3 = fixLagActive and COLORS.accent or COLORS.card
	fixLagNavButton.TextColor3 = fixLagActive and COLORS.text or COLORS.muted
	aimNavButton.BackgroundColor3 = aimActive and COLORS.accent or COLORS.card
	aimNavButton.TextColor3 = aimActive and COLORS.text or COLORS.muted
end

menuButton.Activated:Connect(function()
	setMenuOpen(not menuOpen)
end)

closeButton.Activated:Connect(function()
	setMenuOpen(false)
end)

espNavButton.Activated:Connect(function() setPage("ESP") end)
farmNavButton.Activated:Connect(function() setPage("AutoFarm") end)
speedNavButton.Activated:Connect(function() setPage("Speed") end)
fixLagNavButton.Activated:Connect(function() setPage("FixLag") end)
aimNavButton.Activated:Connect(function() setPage("Aim") end)

playerEspToggle.Activated:Connect(function()
	playerEspEnabled = not playerEspEnabled
	updateToggleVisual(playerEspToggle, playerEspStroke, playerEspEnabled, PLAYER_ESP_COLOR)
end)

monsterEspToggle.Activated:Connect(function()
	monsterEspEnabled = not monsterEspEnabled
	updateToggleVisual(monsterEspToggle, monsterEspStroke, monsterEspEnabled, MONSTER_ESP_COLOR)
end)

monsterSelectButton.Activated:Connect(function()
	monsterList.Visible = not monsterList.Visible
end)

speedToggle.Activated:Connect(function()
	setSpeedEnabled(not speedEnabled)
end)

speedMinusButton.Activated:Connect(function()
	setSelectedSpeed(selectedSpeed - SPEED_STEP)
end)

speedPlusButton.Activated:Connect(function()
	setSelectedSpeed(selectedSpeed + SPEED_STEP)
end)

fixLagToggle.Activated:Connect(function()
	setFixLagEnabled(not fixLagEnabled)
end)

aimToggle.Activated:Connect(function()
	setAimEnabled(not aimEnabled)
end)

aimPlayerButton.Activated:Connect(function()
	setAimTargetMode("Player")
end)

aimMonsterButton.Activated:Connect(function()
	setAimTargetMode("Monster")
end)

local function handleMenuAction(_actionName, inputState, _inputObject)
	if inputState == Enum.UserInputState.Begin then
		setMenuOpen(not menuOpen)
	end
	return Enum.ContextActionResult.Sink
end

ContextActionService:BindAction(MENU_ACTION_NAME, handleMenuAction, false, MENU_KEY)

-- Kéo hub bằng chuột hoặc cảm ứng
local dragging = false
local dragStart = nil
local panelStart = nil
local dragInput = nil

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		panelStart = mainPanel.Position
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and dragInput and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		mainPanel.Position = UDim2.new(
			panelStart.X.Scale,
			panelStart.X.Offset + delta.X,
			panelStart.Y.Scale,
			panelStart.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
		dragInput = nil
	end
end)

-- Hộp ESP dùng chung
local function createBoxEntry(boxName, displayName, color)
	local box = Instance.new("Frame")
	box.Name = boxName
	box.BackgroundColor3 = color
	box.BackgroundTransparency = ESP_BOX_FILL_TRANSPARENCY
	box.BorderSizePixel = 0
	box.Visible = false
	box.ZIndex = 20
	box.Parent = screenGui

	local boxStroke = Instance.new("UIStroke")
	boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	boxStroke.Color = color
	boxStroke.Thickness = ESP_BOX_THICKNESS
	boxStroke.Parent = box

	local nameLabel = makeLabel(box, "TargetName", displayName, UDim2.new(0.5, 0, 0, -26), UDim2.new(1, 140, 0, 22), 14, 21)
	nameLabel.AnchorPoint = Vector2.new(0.5, 0)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextColor3 = color
	nameLabel.TextXAlignment = Enum.TextXAlignment.Center
	nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	nameLabel.TextStrokeTransparency = 0

	local distanceLabel = makeLabel(box, "Distance", "0 studs", UDim2.new(0.5, 0, 1, 5), UDim2.new(1, 100, 0, 20), 13, 21)
	distanceLabel.AnchorPoint = Vector2.new(0.5, 0)
	distanceLabel.Font = Enum.Font.GothamSemibold
	distanceLabel.TextColor3 = color
	distanceLabel.TextXAlignment = Enum.TextXAlignment.Center
	distanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	distanceLabel.TextStrokeTransparency = 0

	return {
		box = box,
		stroke = boxStroke,
		nameLabel = nameLabel,
		distanceLabel = distanceLabel,
	}
end

local function destroyEntry(entry)
	if entry and entry.box then
		entry.box:Destroy()
	end
end

local BOX_CORNERS = {
	Vector3.new(-1, -1, -1),
	Vector3.new(-1, -1, 1),
	Vector3.new(-1, 1, -1),
	Vector3.new(-1, 1, 1),
	Vector3.new(1, -1, -1),
	Vector3.new(1, -1, 1),
	Vector3.new(1, 1, -1),
	Vector3.new(1, 1, 1),
}

local function getModelScreenRect(model, camera)
	local boundingCFrame, boundingSize = model:GetBoundingBox()
	local halfSize = boundingSize * 0.5
	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge

	for _, corner in ipairs(BOX_CORNERS) do
		local localCorner = Vector3.new(corner.X * halfSize.X, corner.Y * halfSize.Y, corner.Z * halfSize.Z)
		local worldCorner = boundingCFrame:PointToWorldSpace(localCorner)
		local viewportPoint = camera:WorldToViewportPoint(worldCorner)

		if viewportPoint.Z <= 0 then
			return nil
		end

		minX = math.min(minX, viewportPoint.X)
		minY = math.min(minY, viewportPoint.Y)
		maxX = math.max(maxX, viewportPoint.X)
		maxY = math.max(maxY, viewportPoint.Y)
	end

	local viewportSize = camera.ViewportSize
	if maxX < 0 or maxY < 0 or minX > viewportSize.X or minY > viewportSize.Y then
		return nil
	end

	minX = math.clamp(minX, 0, viewportSize.X)
	minY = math.clamp(minY, 0, viewportSize.Y)
	maxX = math.clamp(maxX, 0, viewportSize.X)
	maxY = math.clamp(maxY, 0, viewportSize.Y)

	local width, height = maxX - minX, maxY - minY
	if width < 3 or height < 3 then
		return nil
	end

	return minX, minY, width, height
end

local function getMonsterModel(instance)
	if instance:IsA("Model") then
		return instance
	end
	return instance:FindFirstAncestorOfClass("Model")
end

local function getMonsterType(monster)
	return tostring(monster:GetAttribute(MONSTER_TYPE_ATTRIBUTE) or monster:GetAttribute("DisplayName") or monster.Name)
end

local function refreshMonsterCandidates()
	local refreshed = {}

	local function addCandidate(instance)
		local model = getMonsterModel(instance)
		if model and model:IsDescendantOf(Workspace) and Players:GetPlayerFromCharacter(model) == nil then
			refreshed[model] = true
		end
	end

	for _, taggedInstance in ipairs(CollectionService:GetTagged(MONSTER_TAG)) do
		addCandidate(taggedInstance)
	end

	local monsterFolder = Workspace:FindFirstChild(MONSTER_FOLDER_NAME)
	if monsterFolder then
		for _, descendant in ipairs(monsterFolder:GetDescendants()) do
			if descendant:IsA("Model") then
				addCandidate(descendant)
			end
		end
	end

	for _, descendant in ipairs(Workspace:GetDescendants()) do
		if descendant:IsA("Model") and (descendant:GetAttribute(MONSTER_ATTRIBUTE) == true or (AUTO_DETECT_NPC_HUMANOIDS and descendant:FindFirstChildOfClass("Humanoid") ~= nil)) then
			addCandidate(descendant)
		end
	end

	monsterCandidates = refreshed
end

local function refreshMonsterTypeButtons()
	local typeCounts = {}
	for monster in pairs(monsterCandidates) do
		local humanoid = monster:FindFirstChildOfClass("Humanoid")
		if monster:IsDescendantOf(Workspace) and (humanoid == nil or humanoid.Health > 0) then
			local monsterType = getMonsterType(monster)
			typeCounts[monsterType] = (typeCounts[monsterType] or 0) + 1
		end
	end

	local types = {}
	for monsterType in pairs(typeCounts) do
		table.insert(types, monsterType)
	end
	table.sort(types)

	local signatureParts = {}
	for _, monsterType in ipairs(types) do
		table.insert(signatureParts, monsterType .. ":" .. tostring(typeCounts[monsterType]))
	end
	local signature = table.concat(signatureParts, "|")
	if signature == monsterTypeSignature then
		return
	end
	monsterTypeSignature = signature

	for _, child in ipairs(monsterList:GetChildren()) do
		if child:IsA("GuiButton") or child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	if #types == 0 then
		local emptyLabel = makeLabel(monsterList, "Empty", "Chưa phát hiện quái", UDim2.new(), UDim2.new(1, -4, 0, 34), 12, 132)
		emptyLabel.LayoutOrder = 1
		emptyLabel.TextColor3 = COLORS.muted
		emptyLabel.TextXAlignment = Enum.TextXAlignment.Center
		return
	end

	for index, monsterType in ipairs(types) do
		local button = Instance.new("TextButton")
		button.Name = "MonsterType_" .. index
		button.Size = UDim2.new(1, -4, 0, 36)
		button.AutoButtonColor = false
		button.BackgroundColor3 = COLORS.card
		button.Font = Enum.Font.GothamSemibold
		button.Text = string.format("%s  (%d)", monsterType, typeCounts[monsterType])
		button.TextColor3 = COLORS.text
		button.TextSize = 12
		button.LayoutOrder = index
		button.ZIndex = 132
		button.Parent = monsterList
		addCorner(button, 9)

		button.Activated:Connect(function()
			selectedMonsterType = monsterType
			currentFarmTarget = nil
			monsterSelectButton.Text = "Đã chọn: " .. monsterType .. "  ▾"
			monsterList.Visible = false
			autoFarmStatusLabel.Text = "Sẵn sàng farm: " .. monsterType
		end)
	end
end

local function getRootPart(model)
	return model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChildWhichIsA("BasePart", true)
end

local function isAimPartVisible(part)
	return part and part:IsA("BasePart") and part.Transparency < 0.95 and part.LocalTransparencyModifier < 0.95
end

local function getAimPart(model)
	local head = model:FindFirstChild("Head")
	if isAimPartVisible(head) then
		return head
	end

	local rootPart = getRootPart(model)
	if isAimPartVisible(rootPart) then
		return rootPart
	end

	for _, descendant in ipairs(model:GetDescendants()) do
		if isAimPartVisible(descendant) then
			return descendant
		end
	end
	return nil
end

local function evaluateAimCandidate(model, camera, raycastParams)
	if not model or not model:IsDescendantOf(Workspace) or model:GetAttribute(TARGETABLE_ATTRIBUTE) == false then
		return nil
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return nil
	end

	local aimPart = getAimPart(model)
	if not aimPart then
		return nil
	end

	local cameraPosition = camera.CFrame.Position
	local worldDistance = (aimPart.Position - cameraPosition).Magnitude
	if worldDistance > AIM_MAX_DISTANCE then
		return nil
	end

	local viewportPoint, onScreen = camera:WorldToViewportPoint(aimPart.Position)
	if not onScreen or viewportPoint.Z <= 0 then
		return nil
	end

	local screenCenter = camera.ViewportSize * 0.5
	local screenDistance = (Vector2.new(viewportPoint.X, viewportPoint.Y) - screenCenter).Magnitude
	if screenDistance > AIM_FOV_RADIUS then
		return nil
	end

	local rayResult = Workspace:Raycast(cameraPosition, aimPart.Position - cameraPosition, raycastParams)
	if rayResult and not rayResult.Instance:IsDescendantOf(model) then
		return nil
	end

	return aimPart, screenDistance
end

local function findBestAimTarget(camera, raycastParams)
	local bestModel = nil
	local bestPart = nil
	local bestScreenDistance = math.huge

	local function consider(model)
		local aimPart, screenDistance = evaluateAimCandidate(model, camera, raycastParams)
		if aimPart and screenDistance < bestScreenDistance then
			bestModel = model
			bestPart = aimPart
			bestScreenDistance = screenDistance
		end
	end

	if aimTargetMode == "Player" then
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= localPlayer and player.Character then
				consider(player.Character)
			end
		end
	else
		for monster in pairs(monsterCandidates) do
			if Players:GetPlayerFromCharacter(monster) == nil then
				consider(monster)
			end
		end
	end

	return bestModel, bestPart
end

local function updateAimAssist(deltaTime)
	if not aimEnabled then return end

	local camera = Workspace.CurrentCamera
	if not camera then return end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	local localCharacter = localPlayer.Character
	raycastParams.FilterDescendantsInstances = localCharacter and { localCharacter } or {}

	local aimPart = nil
	if currentAimTarget then
		aimPart = evaluateAimCandidate(currentAimTarget, camera, raycastParams)
	end

	if not aimPart then
		currentAimTarget, aimPart = findBestAimTarget(camera, raycastParams)
	end

	if not currentAimTarget or not aimPart then
		currentAimTarget = nil
		aimStatusLabel.Text = "Aim đang bật • chưa thấy " .. aimTargetMode
		return
	end

	local desiredCamera = CFrame.lookAt(camera.CFrame.Position, aimPart.Position, camera.CFrame.UpVector)
	local alpha = 1 - math.exp(-AIM_SMOOTH_SPEED * deltaTime)
	camera.CFrame = camera.CFrame:Lerp(desiredCamera, alpha)
	aimStatusLabel.Text = string.format("Aim đang theo %s • %s", currentAimTarget.Name, aimTargetMode)
end

local function updateEntry(entry, model, displayName, color, maxDistance, camera)
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local rootPart = getRootPart(model)
	local canShow = model:IsDescendantOf(Workspace)
		and model:GetAttribute(TARGETABLE_ATTRIBUTE) ~= false
		and (humanoid == nil or humanoid.Health > 0)
		and rootPart ~= nil
		and rootPart:IsA("BasePart")

	local distance = 0
	if canShow then
		distance = (rootPart.Position - camera.CFrame.Position).Magnitude
		canShow = distance <= maxDistance
	end

	local minX, minY, width, height
	if canShow then
		minX, minY, width, height = getModelScreenRect(model, camera)
		canShow = minX ~= nil
	end

	entry.box.Visible = canShow
	if not canShow then
		return false
	end

	entry.box.Position = UDim2.fromOffset(minX, minY)
	entry.box.Size = UDim2.fromOffset(width, height)
	entry.box.BackgroundColor3 = color
	entry.stroke.Color = color
	entry.nameLabel.TextColor3 = color
	entry.nameLabel.Text = displayName
	entry.distanceLabel.TextColor3 = color
	entry.distanceLabel.Text = string.format("%d studs", math.floor(distance + 0.5))
	return true
end

local function updateEspBoxes()
	local camera = Workspace.CurrentCamera
	if not camera then return end

	local currentPlayers = {}
	local totalPlayers, shownPlayers = 0, 0

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= localPlayer then
			currentPlayers[targetPlayer] = true
			totalPlayers += 1

			local entry = playerEntries[targetPlayer]
			if not entry then
				entry = createBoxEntry("PlayerEsp_" .. tostring(targetPlayer.UserId), targetPlayer.DisplayName, PLAYER_ESP_COLOR)
				playerEntries[targetPlayer] = entry
			end

			local character = targetPlayer.Character
			if playerEspEnabled and character then
				local visible = updateEntry(
					entry,
					character,
					string.format("%s (@%s)", targetPlayer.DisplayName, targetPlayer.Name),
					PLAYER_ESP_COLOR,
					PLAYER_ESP_MAX_DISTANCE,
					camera
				)
				if visible then
					shownPlayers += 1
				end
			else
				entry.box.Visible = false
			end
		end
	end

	for targetPlayer, entry in pairs(playerEntries) do
		if not currentPlayers[targetPlayer] then
			destroyEntry(entry)
			playerEntries[targetPlayer] = nil
		end
	end

	local currentMonsters = {}
	local totalMonsters, shownMonsters = 0, 0

	for monster in pairs(monsterCandidates) do
		if monster:IsDescendantOf(Workspace) and Players:GetPlayerFromCharacter(monster) == nil then
			currentMonsters[monster] = true
			totalMonsters += 1

			local entry = monsterEntries[monster]
			if not entry then
				entry = createBoxEntry("MonsterEsp_" .. monster.Name, getMonsterType(monster), MONSTER_ESP_COLOR)
				monsterEntries[monster] = entry
			end

			if monsterEspEnabled then
				local visible = updateEntry(entry, monster, getMonsterType(monster), MONSTER_ESP_COLOR, MONSTER_ESP_MAX_DISTANCE, camera)
				if visible then
					shownMonsters += 1
				end
			else
				entry.box.Visible = false
			end
		end
	end

	for monster, entry in pairs(monsterEntries) do
		if not currentMonsters[monster] then
			destroyEntry(entry)
			monsterEntries[monster] = nil
		end
	end

	local playerStatus = playerEspEnabled and string.format("%d/%d", shownPlayers, totalPlayers) or "TẮT"
	local monsterStatus = monsterEspEnabled and string.format("%d/%d", shownMonsters, totalMonsters) or "TẮT"
	espStatusLabel.Text = string.format("Người chơi: %s  •  Quái: %s", playerStatus, monsterStatus)
end

local function isFarmTargetValid(monster)
	if not monster or not monsterCandidates[monster] or not monster:IsDescendantOf(Workspace) or getMonsterType(monster) ~= selectedMonsterType then
		return false
	end

	local humanoid = monster:FindFirstChildOfClass("Humanoid")
	local rootPart = getRootPart(monster)
	return humanoid ~= nil and humanoid.Health > 0 and rootPart ~= nil
end

local function findNearestFarmTarget(origin)
	local nearest = nil
	local nearestDistance = math.huge

	for monster in pairs(monsterCandidates) do
		if isFarmTargetValid(monster) then
			local rootPart = getRootPart(monster)
			local distance = (rootPart.Position - origin).Magnitude
			if distance < nearestDistance then
				nearestDistance = distance
				nearest = monster
			end
		end
	end

	return nearest
end

local function findToolByName(container, toolName)
	if not container or not toolName then return nil end
	local tool = container:FindFirstChild(toolName)
	if tool and tool:IsA("Tool") then
		return tool
	end
	return nil
end

local function findBasicAttackTool(character)
	local backpack = localPlayer:FindFirstChildOfClass("Backpack")

	if BASIC_ATTACK_TOOL_NAME then
		return findToolByName(character, BASIC_ATTACK_TOOL_NAME) or findToolByName(backpack, BASIC_ATTACK_TOOL_NAME)
	end

	for _, container in ipairs({ character, backpack }) do
		if container then
			for _, child in ipairs(container:GetChildren()) do
				if child:IsA("Tool") and child:GetAttribute(BASIC_ATTACK_ATTRIBUTE) == true then
					return child
				end
			end
		end
	end

	return character:FindFirstChildOfClass("Tool")
end

local function captureBasicAttackTool(character, humanoid)
	basicAttackTool = findBasicAttackTool(character)
	if basicAttackTool and basicAttackTool.Parent ~= character then
		humanoid:EquipTool(basicAttackTool)
	end
	return basicAttackTool
end

local function applyAutoFarmNoclip()
	if not NOCLIP_WHILE_AUTOFARM then return end

	local character = localPlayer.Character
	if not character then return end

	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			if originalCollision[descendant] == nil then
				originalCollision[descendant] = descendant.CanCollide
			end
			descendant.CanCollide = false
		end
	end
end

local function restoreAutoFarmCollision()
	for part, wasCollidable in pairs(originalCollision) do
		if part.Parent then
			part.CanCollide = wasCollidable
		end
	end
	table.clear(originalCollision)
end

local function restoreLocalCharacter()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local rootPart = character and getRootPart(character)

	restoreAutoFarmCollision()

	if humanoid then
		humanoid.AutoRotate = true
	end
	if rootPart then
		rootPart.AssemblyLinearVelocity = Vector3.zero
		rootPart.AssemblyAngularVelocity = Vector3.zero
	end
end

local function setAutoFarmEnabled(newValue)
	if newValue and not selectedMonsterType then
		autoFarmStatusLabel.Text = "Hãy chọn một loại quái trước"
		return
	end

	autoFarmEnabled = newValue
	currentFarmTarget = nil
	lastAutoAttackTime = 0
	basicAttackTool = nil

	if autoFarmEnabled then
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if character and humanoid then
			captureBasicAttackTool(character, humanoid)
		end
	end

	updateAutoFarmVisual()

	if autoFarmEnabled then
		autoFarmStatusLabel.Text = "Đang tìm " .. selectedMonsterType .. "..."
	else
		restoreLocalCharacter()
		autoFarmStatusLabel.Text = "AutoFarm đã dừng"
	end
end

autoFarmButton.Activated:Connect(function()
	setAutoFarmEnabled(not autoFarmEnabled)
end)

local function updateClientAutoFarm(deltaTime)
	if not autoFarmEnabled then return end

	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local rootPart = character and getRootPart(character)

	if not character or not humanoid or humanoid.Health <= 0 or not rootPart then
		autoFarmStatusLabel.Text = "Đang chờ nhân vật hồi sinh..."
		return
	end

	if not isFarmTargetValid(currentFarmTarget) then
		currentFarmTarget = findNearestFarmTarget(rootPart.Position)
	end

	local target = currentFarmTarget
	if not target then
		humanoid.AutoRotate = true
		autoFarmStatusLabel.Text = "Không tìm thấy " .. tostring(selectedMonsterType)
		return
	end

	local targetHumanoid = target:FindFirstChildOfClass("Humanoid")
	local targetRoot = getRootPart(target)
	if not targetHumanoid or not targetRoot then
		currentFarmTarget = nil
		return
	end

	local boundingCFrame, boundingSize = target:GetBoundingBox()
	local targetTopY = boundingCFrame.Position.Y + boundingSize.Y * 0.5
	local flatLook = Vector3.new(targetRoot.CFrame.LookVector.X, 0, targetRoot.CFrame.LookVector.Z)
	if flatLook.Magnitude < 0.01 then
		flatLook = Vector3.zAxis
	else
		flatLook = flatLook.Unit
	end

	local desiredPosition = Vector3.new(targetRoot.Position.X, targetTopY + FARM_HOVER_CLEARANCE, targetRoot.Position.Z) - flatLook * FARM_HORIZONTAL_OFFSET
	local flatTargetPosition = Vector3.new(targetRoot.Position.X, desiredPosition.Y, targetRoot.Position.Z)
	local desiredRootCFrame = CFrame.lookAt(desiredPosition, flatTargetPosition)

	local travelDistance = (rootPart.Position - desiredPosition).Magnitude
	local alpha = (travelDistance <= 0.01) and 1 or math.min(1, FARM_MOVE_SPEED * deltaTime / travelDistance)

	local rootToPivot = rootPart.CFrame:ToObjectSpace(character:GetPivot())
	local nextRootCFrame = rootPart.CFrame:Lerp(desiredRootCFrame, alpha)

	humanoid.AutoRotate = false
	character:PivotTo(nextRootCFrame * rootToPivot)
	rootPart.AssemblyLinearVelocity = Vector3.zero
	rootPart.AssemblyAngularVelocity = Vector3.zero

	local rootInTargetBounds = boundingCFrame:PointToObjectSpace(rootPart.Position)
	local halfTargetSize = boundingSize * 0.5
	local closestPointInBounds = Vector3.new(
		math.clamp(rootInTargetBounds.X, -halfTargetSize.X, halfTargetSize.X),
		math.clamp(rootInTargetBounds.Y, -halfTargetSize.Y, halfTargetSize.Y),
		math.clamp(rootInTargetBounds.Z, -halfTargetSize.Z, halfTargetSize.Z)
	)
	local attackDistance = (rootInTargetBounds - closestPointInBounds).Magnitude
	local positionError = (rootPart.Position - desiredPosition).Magnitude
	local readyToAttack = attackDistance <= AUTO_ATTACK_DISTANCE

	if readyToAttack then
		local tool = basicAttackTool
		local backpack = localPlayer:FindFirstChildOfClass("Backpack")
		local toolStillOwned = tool and (tool:IsDescendantOf(character) or (backpack and tool:IsDescendantOf(backpack)))

		if not toolStillOwned then
			tool = captureBasicAttackTool(character, humanoid)
		elseif tool.Parent ~= character then
			humanoid:EquipTool(tool)
		end

		local attackTime = os.clock()
		local attackTriggered = false

		if tool and tool.Enabled and tool.Parent == character and attackTime - lastAutoAttackTime >= AUTO_ATTACK_INTERVAL then
			lastAutoAttackTime = attackTime
			attackTriggered = pcall(function()
				tool:Activate()
			end)

			if attackTriggered then
				task.delay(AUTO_ATTACK_RELEASE_DELAY, function()
					if tool.Parent then
						pcall(function()
							tool:Deactivate()
						end)
					end
				end)
			end
		end

		if tool then
			local attackState = tool.Enabled and "Đang tự động đánh" or "Tool đang hồi"
			autoFarmStatusLabel.Text = string.format("%s %s bằng %s • %.1f studs", attackState, target.Name, tool.Name, attackDistance)
		else
			autoFarmStatusLabel.Text = "Chưa giữ đòn đánh thường • hãy cầm nắm đấm rồi bật lại"
		end
	else
		autoFarmStatusLabel.Text = string.format("Đang bay tới %s • %.1f studs", target.Name, positionError)
	end
end

local function updateAutoFarmNoclip()
	if autoFarmEnabled then
		applyAutoFarmNoclip()
	elseif next(originalCollision) then
		restoreAutoFarmCollision()
	end
end

local function updateClientSpeed()
	if speedEnabled then
		applySelectedSpeed()
	end
end

task.spawn(function()
	while screenGui.Parent do
		refreshMonsterCandidates()
		refreshMonsterTypeButtons()
		task.wait(MONSTER_SCAN_INTERVAL)
	end
end)

updateToggleVisual(playerEspToggle, playerEspStroke, false, PLAYER_ESP_COLOR)
updateToggleVisual(monsterEspToggle, monsterEspStroke, false, MONSTER_ESP_COLOR)
updateAutoFarmVisual()
updateSpeedVisual()
updateFixLagVisual()
updateAimVisual()
setPage("ESP")

localPlayer.CharacterAdded:Connect(function(character)
	restoreAutoFarmCollision()
	currentFarmTarget = nil
	lastAutoAttackTime = 0
	basicAttackTool = nil
	currentAimTarget = nil
	originalWalkSpeed = nil

	if speedEnabled then
		task.spawn(function()
			local humanoid = character:WaitForChild("Humanoid", 5)
			if humanoid and speedEnabled and localPlayer.Character == character then
				originalWalkSpeed = humanoid.WalkSpeed
				humanoid.WalkSpeed = selectedSpeed
				updateSpeedVisual()
			end
		end)
	end
end)

RunService.Stepped:Connect(updateAutoFarmNoclip)
RunService.Heartbeat:Connect(updateClientAutoFarm)
RunService.Heartbeat:Connect(updateClientSpeed)

RunService:UnbindFromRenderStep(RENDER_BINDING_NAME)
RunService:BindToRenderStep(RENDER_BINDING_NAME, Enum.RenderPriority.Camera.Value + 1, updateEspBoxes)

RunService:UnbindFromRenderStep(AIM_RENDER_BINDING_NAME)
RunService:BindToRenderStep(AIM_RENDER_BINDING_NAME, Enum.RenderPriority.Camera.Value + 2, updateAimAssist)
