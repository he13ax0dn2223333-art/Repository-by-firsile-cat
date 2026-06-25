-- Проверяем, запущен ли скрипт в Murder Mystery 2
if not game:GetService("ReplicatedStorage"):FindFirstChild("GetPlayerData", true) then
    warn("Скрипт создан специально для Murder Mystery 2!")
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Создание интерфейса
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2_CustomMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

-- Главная панель (Черная с белой рамкой)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 380)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 4
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local InnerStroke = Instance.new("UIStroke")
InnerStroke.Color = Color3.fromRGB(255, 255, 255)
InnerStroke.Thickness = 2
InnerStroke.Parent = MainFrame

-- ЛЕВАЯ ПАНЕЛЬ С КНОПКАМИ
local LeftMenu = Instance.new("Frame")
LeftMenu.Size = UDim2.new(0, 140, 1, -20)
LeftMenu.Position = UDim2.new(0, 10, 0, 10)
LeftMenu.BackgroundTransparency = 1
LeftMenu.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 10)
UIList.Parent = LeftMenu

local function CreateTab(name, textColor)
    local Tab = Instance.new("TextButton")
    Tab.Size = UDim2.new(1, 0, 0, 75)
    Tab.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Tab.BorderColor3 = Color3.fromRGB(255, 255, 255)
    Tab.BorderSizePixel = 3
    Tab.Text = name
    Tab.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)
    Tab.Font = Enum.Font.SourceSansBold
    Tab.TextSize = 26
    Tab.Parent = LeftMenu
    return Tab
end

local TabMurder = CreateTab("Murder", Color3.fromRGB(240, 210, 40)) 
local TabSherif = CreateTab("Sherif")
local TabInnoce = CreateTab("Innoce.")
local TabAll = CreateTab("In/mu/sh")

-- ПРАВАЯ ЧАСТЬ
local RightContent = Instance.new("Frame")
RightContent.Size = UDim2.new(1, -170, 1, -20)
RightContent.Position = UDim2.new(0, 160, 0, 10)
RightContent.BackgroundTransparency = 1
RightContent.Parent = MainFrame

local KillAllText = Instance.new("TextLabel")
KillAllText.Size = UDim2.new(0, 150, 0, 50)
KillAllText.Position = UDim2.new(0, 0, 0, 10)
KillAllText.BackgroundTransparency = 1
KillAllText.Text = "ESP СИСТЕМА"
KillAllText.TextColor3 = Color3.fromRGB(255, 255, 255)
KillAllText.Font = Enum.Font.SourceSans
KillAllText.TextSize = 35
KillAllText.TextXAlignment = Enum.TextXAlignment.Left
KillAllText.Parent = RightContent

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 70, 0, 30)
ToggleButton.Position = UDim2.new(0, 190, 0, 20)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.BorderSizePixel = 2
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 18
ToggleButton.Parent = RightContent

local ToggleCircle = Instance.new("Frame")
ToggleCircle.Size = UDim2.new(0, 22, 0, 22)
ToggleCircle.Position = UDim2.new(0, 4, 0, 4)
ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleCircle.Parent = ToggleButton
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(1, 0)
Corner.Parent = ToggleCircle

local SelectPlayerText = Instance.new("TextLabel")
SelectPlayerText.Size = UDim2.new(1, 0, 0, 40)
SelectPlayerText.Position = UDim2.new(0, 0, 0, 80)
SelectPlayerText.BackgroundTransparency = 1
SelectPlayerText.Text = "Список игроков"
SelectPlayerText.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectPlayerText.Font = Enum.Font.SourceSans
SelectPlayerText.TextSize = 24
SelectPlayerText.TextXAlignment = Enum.TextXAlignment.Left
SelectPlayerText.Parent = RightContent

local PlayerListScroll = Instance.new("ScrollingFrame")
PlayerListScroll.Size = UDim2.new(1, 0, 1, -130)
PlayerListScroll.Position = UDim2.new(0, 0, 0, 120)
PlayerListScroll.BackgroundTransparency = 1
PlayerListScroll.CanvasSize = UDim2.new(0, 0, 2, 0)
PlayerListScroll.ScrollBarThickness = 4
PlayerListScroll.Parent = RightContent

local ScrollListLayout = Instance.new("UIListLayout")
ScrollListLayout.Parent = PlayerListScroll

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = MainFrame
CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local function UpdatePlayerListMenu()
    for _, child in ipairs(PlayerListScroll:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pLabel = Instance.new("TextLabel")
            pLabel.Size = UDim2.new(1, 0, 0, 30)
            pLabel.BackgroundTransparency = 1
            pLabel.Text = " " .. p.Name
            pLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            pLabel.Font = Enum.Font.SourceSans
            pLabel.TextSize = 20
            pLabel.TextXAlignment = Enum.TextXAlignment.Left
            pLabel.Parent = PlayerListScroll
        end
    end
end
Players.PlayerAdded:Connect(UpdatePlayerListMenu)
Players.PlayerRemoving:Connect(UpdatePlayerListMenu)
UpdatePlayerListMenu()

----------------------------------------------------------------------
-- ОПТИМИЗИРОВАННАЯ СИСТЕМА ESP
----------------------------------------------------------------------
local EspEnabled = false
local TrackedRoles = {} 

local function GetPlayerEspColor(player)
    if not player.Character or not player.Character:FindFirstChild("Humanoid") then
        return Color3.fromRGB(128, 128, 128)
    end
    if player.Character.Humanoid.Health <= 0 then
        return Color3.fromRGB(128, 128, 128)
    end

    local hasKnife = player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife")
    local hasGun = player.Backpack:FindFirstChild("Gun") or player.Character:FindFirstChild("Gun")

    if hasKnife then
        TrackedRoles[player.Name] = "Murder"
        return Color3.fromRGB(255, 0, 0) -- Красный
    elseif hasGun then
        -- Проверяем: если он был innocent, но получил пистолет — значит подобрал (Желтый)
        if TrackedRoles[player.Name] == "Innocent" then
            return Color3.fromRGB(255, 255, 0) -- Желтый
        else
            if not TrackedRoles[player.Name] then
                TrackedRoles[player.Name] = "Sheriff"
            end
            return Color3.fromRGB(0, 0, 255) -- Синий
        end
    else
        if not TrackedRoles[player.Name] then
            TrackedRoles[player.Name] = "Innocent"
        end
        return Color3.fromRGB(0, 255, 0) -- Зеленый
    end
end

local function ApplyHighlight(player, color)
    local char = player.Character
    if not char then return end

    local hl = char:FindFirstChild("CustomEspHighlight")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "CustomEspHighlight"
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.Parent = char
    end
    hl.FillColor = color
    hl.OutlineColor = color
    hl.Enabled = EspEnabled
end

-- Быстрый цикл только для обновления позиций/цветов игроков
RunService.Heartbeat:Connect(function()
    if not EspEnabled then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            ApplyHighlight(p, GetPlayerEspColor(p))
        end
    end
end)

-- РАЗГРУЖАЕМ ПРОЦЕССОР: сканируем карту на монеты и пест раз в 1 секунду
task.spawn(function()
    while true do
        task.wait(1)
        if EspEnabled then
            -- Подсветка упавшего пистолета
            local gunDrop = workspace:FindFirstChild("GunDrop")
            if gunDrop then
                local hl = gunDrop:FindFirstChild("GunEsp")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "GunEsp"
                    hl.FillColor = Color3.fromRGB(255, 20, 147) -- Розовый
                    hl.OutlineColor = Color3.fromRGB(255, 20, 147)
                    hl.FillTransparency = 0.3
                    hl.Parent = gunDrop
                end
                hl.Enabled = true
            end

            -- Подсветка монет
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj.Name == "Coin_Container" or obj:FindFirstChild("Coin") or obj.Name == "Coin" then
                    local hl = obj:FindFirstChild("CoinEsp")
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "CoinEsp"
                        hl.FillColor = Color3.fromRGB(255, 165, 0) -- Оранжевый
                        hl.OutlineColor = Color3.fromRGB(255, 165, 0)
                        hl.FillTransparency = 0.4
                        hl.Parent = obj
                    end
                    hl.Enabled = true
                end
            end
        end
    end
end)

-- Сброс ролей при спавне (новый раунд)
LocalPlayer.CharacterAdded:Connect(function()
    TrackedRoles = {}
end)

-- Кнопка TOGGLE
ToggleButton.MouseButton1Click:Connect(function()
    EspEnabled = not EspEnabled
    if EspEnabled then
        ToggleButton.Text = "ON"
        ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 0)
        ToggleCircle:TweenPosition(UDim2.new(0, 44, 0, 4), "Out", "Quad", 0.2, true)
    else
        ToggleButton.Text = "OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 0, 0)
        ToggleCircle:TweenPosition(UDim2.new(0, 4, 0, 4), "Out", "Quad", 0.2, true)
        
        -- Выключаем подсветку у всех
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("CustomEspHighlight") then
                p.Character.CustomEspHighlight.Enabled = false
            end
        end
        local gunDrop = workspace:FindFirstChild("GunDrop")
        if gunDrop and gunDrop:FindFirstChild("GunEsp") then gunDrop.GunEsp.Enabled = false end
        
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:FindFirstChild("CoinEsp") then obj.CoinEsp.Enabled = false end
        end
    end
end)
