-- sUNC Compatible (V2)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

-- GUI Injection
local parent = gethui and gethui() or CoreGui
pcall(function()
    local old = parent:FindFirstChild("WFYB_Hub")
    if old then old:Destroy() end
end)

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "WFYB_Hub"
gui.ResetOnSpawn = false
gui.Parent = parent

StarterGui:SetCore("SendNotification", {
    Title = "Teleport Script Loaded",
    Text = "Press buttons to toggle features"
})

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 400)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderColor3 = Color3.fromRGB(170, 0, 255)
mainFrame.BorderSizePixel = 2
mainFrame.Parent = gui
mainFrame.Active = true
mainFrame.Draggable = true

-- Top Bar
local topBar = Instance.new("TextLabel")
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
topBar.BorderColor3 = Color3.fromRGB(170, 0, 255)
topBar.BorderSizePixel = 1
topBar.Text = "    WFYB.GG [V2]"
topBar.Font = Enum.Font.SourceSansBold
topBar.TextSize = 18
topBar.TextColor3 = Color3.fromRGB(255, 255, 255)
topBar.TextXAlignment = Enum.TextXAlignment.Left
topBar.Parent = mainFrame

-- Tabs
local tabNames = {"Combat", "Misc"}
for i, name in ipairs(tabNames) do
    local tab = Instance.new("TextLabel")
    tab.Size = UDim2.new(0, 60, 0, 20)
    tab.Position = UDim2.new(0, 10 + (i - 1) * 70, 0, 35)
    tab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tab.BorderColor3 = Color3.fromRGB(170, 0, 255)
    tab.BorderSizePixel = 1
    tab.Text = name
    tab.Font = Enum.Font.SourceSansBold
    tab.TextSize = 14
    tab.TextColor3 = Color3.fromRGB(255, 255, 255)
    tab.Parent = mainFrame
end

local function createSectionLabel(text, posY)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, posY)
    label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    label.BorderColor3 = Color3.fromRGB(170, 0, 255)
    label.BorderSizePixel = 1
    label.Font = Enum.Font.SourceSansBold
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = mainFrame
end

local function createButton(text, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.BorderColor3 = Color3.fromRGB(170, 0, 255)
    btn.BorderSizePixel = 1
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.SourceSans
    btn.Text = text
    btn.Parent = mainFrame
    return btn
end

-- Labels
createSectionLabel(" Automation:", 60)
local tpFlingButton = createButton("Start Auto Fling", 85)
local swordButton = createButton("Enable Kill Aura", 120)
local unloadButton = createButton("Unload Script", 155)

createSectionLabel(" Teleportation Status:", 190)
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, 215)
statusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
statusLabel.BorderSizePixel = 0
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextSize = 14
statusLabel.Text = "Status: Idle"
statusLabel.Parent = mainFrame

local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(1, -20, 0, 20)
targetLabel.Position = UDim2.new(0, 10, 0, 245)
targetLabel.BackgroundTransparency = 1
targetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
targetLabel.Font = Enum.Font.SourceSans
targetLabel.TextSize = 14
targetLabel.Text = "Target: None"
targetLabel.Parent = mainFrame

-- HUD
local hudLabel = Instance.new("TextLabel")
hudLabel.Parent = gui
hudLabel.Size = UDim2.new(0, 350, 0, 20)
hudLabel.Position = UDim2.new(0, 10, 0, 10)
hudLabel.BackgroundTransparency = 1
hudLabel.TextColor3 = Color3.fromRGB(200, 150, 255)
hudLabel.Font = Enum.Font.SourceSansBold
hudLabel.TextSize = 14
hudLabel.Text = "Distances: Loading..."

-- Teleport Logic
local teleportCooldown = 10
local lastTeleport, currentHighlight = {}, nil
local function clearHighlight() if currentHighlight then currentHighlight:Destroy() end currentHighlight = nil end
local function highlightTarget(part)
    clearHighlight()
    if part and part:IsA("BasePart") then
        local sel = Instance.new("SelectionBox")
        sel.Adornee = part
        sel.Color3 = Color3.new(1, 0, 0)
        sel.LineThickness = 0.05
        sel.Parent = gui
        currentHighlight = sel
    end
end
local function canTeleportTo(name)
    local t = tick()
    if not lastTeleport[name] or (t - lastTeleport[name]) >= teleportCooldown then
        lastTeleport[name] = t
        return true
    end
    return false
end
local function getPriorityBoatPart(model)
    local seatPart, spawnPart, fallbackPart = nil, nil, nil
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            local name = part.Name:lower()
            if not seatPart and name:find("seat") then
                seatPart = part
            elseif not spawnPart and name:find("spawn") then
                spawnPart = part
            elseif not fallbackPart then
                fallbackPart = part
            end
        end
    end
    return seatPart or spawnPart or fallbackPart or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
end

local isTeleporting, flingEnabled, swordBuffEnabled = false, false, false
local cycleIndex = 1

spawn(function()
    while true do
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHRP and myHRP.Position.Y < -25 then
            myHRP.CFrame = CFrame.new(0, 10000, 0)
        end

        if isTeleporting then
            if not myHRP then task.wait(0.1) continue end

            local function tryValidTarget(targets)
                for _ = 1, #targets do
                    if cycleIndex > #targets then cycleIndex = 1 end
                    local tgt = targets[cycleIndex]
                    cycleIndex += 1

                    local part, dist = tgt.part, (tgt.part.Position - Vector3.zero).Magnitude
                    hudLabel.Text = "Cycle: " .. tgt.type .. ": " .. tgt.name .. " @ " .. math.floor(dist)
                    if part.Position.Y > -100 and dist < 1e6 and (dist < 50000 or canTeleportTo(tgt.name)) then
                        myHRP.CFrame = part.CFrame
                        highlightTarget(part)
                        statusLabel.Text = "Status: Teleported"
                        targetLabel.Text = "Target: " .. tgt.type .. ": " .. tgt.name
                        task.wait(0.3)
                        myHRP.CFrame = CFrame.new(0, 10, 0)
                        return true
                    else
                        clearHighlight()
                        statusLabel.Text = "Status: Skipped"
                        targetLabel.Text = "Target: " .. tgt.name
                    end
                end
                return false
            end

            local boats, players = {}, {}
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name:lower():find("boat") then
                    local boatData = obj:FindFirstChild("BoatData")
                    local ownerValue = boatData and boatData:FindFirstChild("Owner")
                    if ownerValue and ownerValue:IsA("ObjectValue") and ownerValue.Value == LocalPlayer then
                        continue
                    end
                    local part = getPriorityBoatPart(obj)
                    if part then table.insert(boats, {part = part, name = obj.Name, type = "Boat"}) end
                end
            end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then table.insert(players, {part = hrp, name = plr.Name, type = "Player"}) end
                end
            end

            local found = tryValidTarget(boats) or tryValidTarget(players)

            if not found then
                clearHighlight()
                hudLabel.Text = "No Targets"
                statusLabel.Text = "Status: Hovering"
                targetLabel.Text = "Target: None"
                if myHRP then myHRP.CFrame = CFrame.new(0, 10000, 0) end
            end
        end
        task.wait(0.1)
    end
end)

-- Kill Aura
local function startKillAura()
    spawn(function()
        local tool = LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Sword")
        if not tool then return end
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        if not humanoid then return end
        humanoid:EquipTool(tool)
        task.wait(0.5)
        local handle = tool:FindFirstChild("Handle")
        if handle then
            handle.Size = Vector3.new(200, 200, 1000)
            handle.Massless = true
            handle.Anchored = false
            handle.CanCollide = false
            handle.Transparency = 0.5
            handle.BrickColor = BrickColor.new("Bright red")
        end
        while swordBuffEnabled and tool and tool.Parent == LocalPlayer.Character do
            pcall(function() tool:Activate() end)
            task.wait(0.5)
        end
    end)
end

-- Button Logic
tpFlingButton.MouseButton1Click:Connect(function()
    isTeleporting = not isTeleporting
    flingEnabled = isTeleporting
    tpFlingButton.Text = isTeleporting and "Stop Fling" or "Start Fling"
    if flingEnabled then
        spawn(function()
            local movel = 0.1
            while flingEnabled do
                RunService.Heartbeat:Wait()
                local c = LocalPlayer.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local vel = hrp.Velocity
                    hrp.Velocity = vel * 100000 + Vector3.new(0, 100000, 0)
                    RunService.RenderStepped:Wait()
                    hrp.Velocity = vel
                    RunService.Stepped:Wait()
                    hrp.Velocity = vel + Vector3.new(0, movel, 0)
                    movel = -movel
                end
            end
        end)
    end
end)

swordButton.MouseButton1Click:Connect(function()
    swordBuffEnabled = not swordBuffEnabled
    swordButton.Text = swordBuffEnabled and "Disable Kill Aura" or "Enable Kill Aura"
    if swordBuffEnabled then
        startKillAura()
        LocalPlayer.CharacterAdded:Connect(function()
            if swordBuffEnabled then task.wait(1) startKillAura() end
        end)
    end
end)

unloadButton.MouseButton1Click:Connect(function()
    isTeleporting = false
    flingEnabled = false
    swordBuffEnabled = false
    clearHighlight()
    gui:Destroy()
end)
