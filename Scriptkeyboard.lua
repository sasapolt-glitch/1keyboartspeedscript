local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--------------------------------------------------------------------------------
-- 1. НАСТРОЙКИ ЭТАПОВ (Имя, Требуемая скорость, Множитель клика, Координаты)
--------------------------------------------------------------------------------
local STAGES = {
	[1] = {Name = "Этап 1", Required = 0, Multiplier = 1, Spawn = Vector3.new(0, 5, 0)},
	[2] = {Name = "Этап 2", Required = 50, Multiplier = 2, Spawn = Vector3.new(0, 5, 100)},
	[3] = {Name = "Этап 3", Required = 200, Multiplier = 5, Spawn = Vector3.new(0, 5, 200)},
	[4] = {Name = "Этап 4", Required = 1000, Multiplier = 10, Spawn = Vector3.new(0, 5, 300)},
}

--------------------------------------------------------------------------------
-- 2. СОЗДАНИЕ СТАТИСТИКИ (LEADERBOARD)
--------------------------------------------------------------------------------
local leaderstats = Instance.new("Folder")
leaderstats.Name = "leaderstats"
leaderstats.Parent = player

local speedStat = Instance.new("IntValue")
speedStat.Name = "Speed"
speedStat.Value = 0
speedStat.Parent = leaderstats

local maxStage = 1

--------------------------------------------------------------------------------
-- 3. ОБНОВЛЕНИЕ ФИЗИЧЕСКОЙ СКОРОСТИ
--------------------------------------------------------------------------------
local function updateSpeed()
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		-- Базовая скорость 16 + набранные очки
		player.Character.Humanoid.WalkSpeed = 16 + speedStat.Value
	end
end

player.CharacterAdded:Connect(function(character)
	character:WaitForChild("Humanoid")
	updateSpeed()
end)

--------------------------------------------------------------------------------
-- 4. АВТОМАТИЧЕСКОЕ СОЗДАНИЕ ИНТЕРФЕЙСА (GUI)
--------------------------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedGameGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 230)
frame.Position = UDim2.new(0, 20, 0.5, -115)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "Выбор Этапа"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = frame

local buttons = {}

for i, stageData in ipairs(STAGES) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9, 0, 0, 38)
	btn.Position = UDim2.new(0.05, 0, 0, 40 + (i - 1) * 44)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 14
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Parent = frame

	btn.MouseButton1Click:Connect(function()
		if i <= maxStage and player.Character then
			player.Character:PivotTo(CFrame.new(stageData.Spawn))
		end
	end)

	buttons[i] = btn
end

local function updateUI()
	for i, stageData in ipairs(STAGES) do
		local btn = buttons[i]
		if i <= maxStage then
			btn.Text = stageData.Name .. " (Открыт)"
			btn.BackgroundColor3 = Color3.fromRGB(46, 139, 87) -- Зеленый цвет
		else
			btn.Text = stageData.Name .. " (" .. stageData.Required .. " Скорости)"
			btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100) -- Серый цвет
		end
	end
end

--------------------------------------------------------------------------------
-- 5. ОТСЛЕЖИВАНИЕ ПРОГРЕССА СКОРОСТИ
--------------------------------------------------------------------------------
speedStat.Changed:Connect(function(newSpeed)
	updateSpeed()

	for i, stageData in ipairs(STAGES) do
		if newSpeed >= stageData.Required and i > maxStage then
			maxStage = i
		end
	end
	updateUI()
end)

--------------------------------------------------------------------------------
-- 6. ОБРАБОТКА НАЖАТИЙ КЛАВИАТУРЫ И МЫШИ
--------------------------------------------------------------------------------
local cooldown = 0.03
local lastClick = 0

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	-- Пропускаем, если открыт чат
	if gameProcessed then return end

	if input.UserInputType == Enum.UserInputType.Keyboard or input.UserInputType == Enum.UserInputType.MouseButton1 then
		if tick() - lastClick >= cooldown then
			lastClick = tick()

			-- Прибавляем +1, умноженное на коэффициент текущего этапа
			local currentMultiplier = STAGES[maxStage].Multiplier
			speedStat.Value += currentMultiplier
		end
	end
end)

-- Инициализация при запуске
updateSpeed()
updateUI()
