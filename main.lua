local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

----------------------------------------------------------------------
-- ГЛОБАЛЬНЫЕ НАСТРОЙКИ И СОСТОЯНИЯ
----------------------------------------------------------------------
local EspEnabled = false
local AimBotEnabled = false
local KillAuraEnabled = false
local SheriffTrackEnabled = false
local SafePickUpEnabled = false

local TrackedRoles = {}
local RoundActive = false
local selectedTargetPlayer = nil

-- Функция для поиска текущей карты MM2
local function GetCurrentMap()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:FindFirstChild("CoinContainer") or obj:FindFirstChild("Spawns") then
            return obj
        end
    end
    return nil
end

-- Функция определения роли/цвета игрока
local function GetPlayerEspColor(player)
    if not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
        return Color3.fromRGB(128, 128, 128) -- Сдохли = Серый
    end

    local bp = player:FindFirstChild("Backpack")
    local char = player.Character
    
    local hasKnife = (bp and (bp:FindFirstChild("Knife") or bp:FindFirstChild("RealKnife"))) or (char and (char:FindFirstChild("Knife") or char:FindFirstChild("RealKnife")))
    local hasGun = (bp and (bp:FindFirstChild("Gun") or bp:FindFirstChild("Python"))) or (char and (char:FindFirstChild("Gun") or char:FindFirstChild("Python")))

    if hasKnife then
        TrackedRoles[player.Name] = "Murder"
        return Color3.fromRGB(255, 0, 0) -- Красный
    elseif hasGun then
        if TrackedRoles[player.Name] == "Innocent" then
            return Color3.fromRGB(255, 255, 0) -- Был мирным, стал с пистолетом = Жёлтый
        end
        TrackedRoles[player.Name] = "Sheriff"
        return Color3.fromRGB(0, 0, 255) -- Синий
    else
        if not TrackedRoles[player.Name] then
            TrackedRoles[player.Name] = "Innocent"
        end
        return Color3.fromRGB(0, 255, 0) -- Зелёный
    end
end

-- Функция поиска Мардера на сервере
local function FindMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and TrackedRoles[p.Name] == "Murder" and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            return p
        end
    end
    return nil
end

----------------------------------------------------------------------
-- ИНТЕРФЕЙС И МЕНЮ
----------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2_Ultimate_Fixed"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 390)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -195)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 3
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local LeftMenu = Instance.new("Frame")
LeftMenu.Size = UDim2.new(0, 140, 1, -20)
LeftMenu.Position = UDim2.new(0, 10, 0, 10)
LeftMenu.BackgroundTransparency = 1
LeftMenu.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 8)
UIList.Parent = LeftMenu

local RightContainer = Instance.new("Frame")
RightContainer.Size = UDim2.new(1, -170, 1, -20)
RightContainer.Position = UDim2.new(0, 160, 0, 10)
RightContainer.BackgroundTransparency = 1
RightContainer.Parent = MainFrame

local Pages = {}
local TabButtons = {}

local function CreatePage(name)
    local Page = Instance.new("Frame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.Parent = RightContainer
    Pages[name] = Page
    return Page
end

local MurderPage = CreatePage("Murder")
local SherifPage = CreatePage("Sherif")
local InnocentPage = CreatePage("Innocent")
local AllPage = CreatePage("In/mu/sh")

local function SwitchToPage(targetName)
    for pName, page in pairs(Pages) do
        if pName == targetName then
            page.Visible = true
            TabButtons[pName].TextColor3 = Color3.fromRGB(240, 210, 40)
        else
            page.Visible = false
            TabButtons[pName].TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
end

local function CreateTabButton(name, displayName)
    local Tab = Instance.new("TextButton")
    Tab.Size = UDim2.new(1, 0, 0, 75)
    Tab.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Tab.BorderColor3 = Color3.fromRGB(255, 255, 255)
    Tab.BorderSizePixel = 2
    Tab.Text = displayName
    Tab.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tab.Font = Enum.Font.SourceSansBold
    Tab.TextSize = 20
    Tab.Parent = LeftMenu
    
    TabButtons[name] = Tab
    Tab.Activated:Connect(function() SwitchToPage(name) end)
end

CreateTabButton("Murder", "Murder")
CreateTabButton("Sherif", "Sheriff")
CreateTabButton("Innocent", "Innocent")
CreateTabButton("In/mu/sh", "ESP / Visuals")
SwitchToPage("In/mu/sh")

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = MainFrame
CloseButton.Activated:Connect(function() ScreenGui:Destroy() end)

local function CreateToggleElement(parent, title, yPos, callback)
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(0, 180, 0, 30)
    TextLabel.Position = UDim2.new(0, 0, 0, yPos)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = title
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.TextSize = 20
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Parent = parent

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 60, 0, 26)
    Btn.Position = UDim2.new(0, 220, 0, yPos + 2)
    Btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Btn.BorderColor3 = Color3.fromRGB(255, 255, 255)
    Btn.BorderSizePixel = 2
    Btn.Text = "OFF"
    Btn.TextColor3 = Color3.fromRGB(255, 0, 0)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 14
    Btn.Parent = parent

    local state = false
    Btn.Activated:Connect(function()
        state = not state
        Btn.Text = state and "ON" or "OFF"
        Btn.TextColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        callback(state)
    end)
end

----------------------------------------------------------------------
-- НАСТРОЙКА ВКЛАДОК И ЛОГИКИ ФУНКЦИЙ
----------------------------------------------------------------------

-- [ВКЛАДКА ESP] --
CreateToggleElement(AllPage, "Включить Глобальный ESP", 20, function(state) EspEnabled = state end)

-- [ВКЛАДКА MURDER] --
CreateToggleElement(MurderPage, "Ближний Legit Аимбот", 20, function(state) AimBotEnabled = state end)
CreateToggleElement(MurderPage, "Массовый ТП-Килл", 60, function(state) KillAuraEnabled = state end)

local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(1, 0, 0, 30)
TargetLabel.Position = UDim2.new(0, 0, 0, 100)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text = "Выбор жертвы для ТП-Килла: Все"
TargetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetLabel.Font = Enum.Font.SourceSans
TargetLabel.TextSize = 18
TargetLabel.TextXAlignment = Enum.TextXAlignment.Left
TargetLabel.Parent = MurderPage

local PlayerListScroll = Instance.new("ScrollingFrame")
PlayerListScroll.Size = UDim2.new(1, 0, 1, -140)
PlayerListScroll.Position = UDim2.new(0, 0, 0, 130)
PlayerListScroll.BackgroundTransparency = 0.9
PlayerListScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
PlayerListScroll.CanvasSize = UDim2.new(0, 0, 3, 0)
PlayerListScroll.ScrollBarThickness = 6
PlayerListScroll.Parent = MurderPage

local ScrollListLayout = Instance.new("UIListLayout")
ScrollListLayout.Parent = PlayerListScroll

local function UpdatePlayerListMenu()
    for _, child in ipairs(PlayerListScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local allBtn = Instance.new("TextButton")
    allBtn.Size = UDim2.new(1, -10, 0, 25)
    allBtn.Text = "  [Убивать Всех]"
    allBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
    allBtn.BackgroundTransparency = 0.8
    allBtn.Parent = PlayerListScroll
    allBtn.Activated:Connect(function()
        selectedTargetPlayer = nil
        TargetLabel.Text = "Выбор жертвы для ТП-Килла: Все"
    end)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, -10, 0, 25)
            pBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            pBtn.Text = "  " .. p.Name
            pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            pBtn.Parent = PlayerListScroll
            pBtn.Activated:Connect(function()
                selectedTargetPlayer = p
                TargetLabel.Text = "Выбранная цель: " .. p.Name
            end)
        end
    end
end
Players.PlayerAdded:Connect(UpdatePlayerListMenu)
Players.PlayerRemoving:Connect(UpdatePlayerListMenu)
UpdatePlayerListMenu()

-- [ВКЛАДКА SHERIFF] --
CreateToggleElement(SherifPage, "Слежка за Мардером", 20, function(state) 
    SheriffTrackEnabled = state 
    if not state then Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid") end
end)

local ShootBtn = Instance.new("TextButton")
ShootBtn.Size = UDim2.new(0, 120, 0, 50)
ShootBtn.Position = UDim2.new(0, 0, 0, 70)
ShootBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
ShootBtn.BorderSizePixel = 2
ShootBtn.Text = "SHOOT"
ShootBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ShootBtn.Font = Enum.Font.SourceSansBold
ShootBtn.TextSize = 22
ShootBtn.Parent = SherifPage

ShootBtn.Activated:Connect(function()
    local target = FindMurderer()
    local character = LocalPlayer.Character
    local gun = character:FindFirstChild("Gun") or character:FindFirstChild("Python")
    
    if gun and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(character.HumanoidRootPart.Position, target.Character.HumanoidRootPart.Position)
        gun:Activate()
    end
end)

-- [ВКЛАДКА INNOCENT] --
CreateToggleElement(InnocentPage, "Безопасный автоподбор", 20, function(state) SafePickUpEnabled = state end)

----------------------------------------------------------------------
-- ПОТОК АВТОМАТИЗАЦИИ (ОСНОВНОЙ ЦИКЛ RUNSERVICE)
----------------------------------------------------------------------
LocalPlayer.CharacterAdded:Connect(function()
    TrackedRoles = {}
    RoundActive = false
    task.wait(5)
    RoundActive = true
end)

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local myRoot = char.HumanoidRootPart

    -----------------------------------------
    -- ЛОГИКА ESP
    -----------------------------------------
    if EspEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hl = p.Character:FindFirstChild("CustomEspHighlight") or Instance.new("Highlight", p.Character)
                hl.Name = "CustomEspHighlight"
                hl.FillTransparency = 0.4
                local clr = GetPlayerEspColor(p)
                hl.FillColor = clr
                hl.OutlineColor = clr
                hl.Enabled = true
            end
        end
        
        -- Подсветка Монет и Оружия
        local map = GetCurrentMap()
        if map then
            local coins = map:FindFirstChild("CoinContainer")
            if coins then
                for _, coin in ipairs(coins:GetChildren()) do
                    local hl = coin:FindFirstChild("CoinEsp") or Instance.new("Highlight", coin)
                    hl.Name = "CoinEsp"
                    hl.FillColor = Color3.fromRGB(255, 165, 0) -- Оранжевый
                    hl.OutlineColor = Color3.fromRGB(255, 165, 0)
                    hl.Enabled = true
                end
            end
        end
        
        -- Поиск упавшего пистолета на земле
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj.Name == "GunDrop" and obj:IsA("BasePart") then
                local hl = obj:FindFirstChild("GunEsp") or Instance.new("Highlight", obj)
                hl.Name = "GunEsp"
                hl.FillColor = Color3.fromRGB(255, 20, 147) -- Розовый
                hl.OutlineColor = Color3.fromRGB(255, 20, 147)
                hl.Enabled = true
            end
        end
    end

    -----------------------------------------
    -- ЛОГИКА MURDER: AIMBOT & KILL AURA
    -----------------------------------------
    if AimBotEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local tRoot = p.Character.HumanoidRootPart
                local dist = (myRoot.Position - tRoot.Position).Magnitude
                if dist < 12 and p.Character.Humanoid.Health > 0 then
                    -- Поворачиваем только персонажа, не камеру
                    myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(tRoot.Position.X, myRoot.Position.Y, tRoot.Position.Z))
                    break
                end
            end
        end
    end

    if KillAuraEnabled then
        local knife = char:FindFirstChild("Knife") or char:FindFirstChild("RealKnife")
        if knife then
            local function stab(targetPlayer)
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and targetPlayer.Character.Humanoid.Health > 0 then
                    local tRoot = targetPlayer.Character.HumanoidRootPart
                    myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3) -- ТП за спину
                    knife:Activate()
                end
            end

            if selectedTargetPlayer then
                stab(selectedTargetPlayer)
            else
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character.Humanoid.Health > 0 then
                        stab(p)
                        task.wait(0.1)
                    end
                end
            end
        end
    end

    -----------------------------------------
    -- ЛОГИКА SHERIFF: КАМЕРА СЛЕЖКИ
    -----------------------------------------
    if SheriffTrackEnabled then
        local mdr = FindMurderer()
        if mdr and mdr.Character and mdr.Character:FindFirstChild("HumanoidRootPart") then
            Camera.CameraSubject = mdr.Character.HumanoidRootPart
        end
    end

    -----------------------------------------
    -- ЛОГИКА INNOCENT: УМНЫЙ АВТОПОДБОР ПИСТОЛЕТА
    -----------------------------------------
    if SafePickUpEnabled then
        local gunDrop = Workspace:FindFirstChild("GunDrop")
        local murderer = FindMurderer()
        
        if gunDrop and gunDrop:IsA("BasePart") then
            local safeToPick = true
            if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
                local mdrDist = (murderer.Character.HumanoidRootPart.Position - gunDrop.Position).Magnitude
                if mdrDist < 25 then -- Если убийца ближе 25 студов, подбирать опасно
                    safeToPick = false
                end
            end
            
            if safeToPick then
                SafePickUpEnabled = false -- Защита от спам-телепорта
                local oldCFrame = myRoot.CFrame
                myRoot.CFrame = gunDrop.CFrame
                task.wait(0.2)
                myRoot.CFrame = oldCFrame
                task.wait(0.5)
                SafePickUpEnabled = true
            end
        end
    end
end)
