--[[ GUI controller ]]
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Config = require(game.ReplicatedStorage.Shared.Config)
local lib = require(script.Parent.Parent.Lib.HolyTridentFake)

local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")
local screen = Instance.new("ScreenGui")
screen.Name = "FakeSkinController"
screen.Parent = pGui
screen.ResetOnSpawn = false

-- frame utama
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(220, 140)
frame.Position = UDim2.fromScale(.02, .3)
frame.BackgroundColor3 = Color3.fromRGB(25, 27, 32)
frame.BorderSizePixel = 0
frame.Visible = true
frame.Parent = screen
Instance.new("UICorner", frame)

-- title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 24); title.Position = UDim2.fromScale(0, 0)
title.BackgroundTransparency = 1; title.Text = "Holy Trident Fake Skin"; title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1); title.TextScaled = true; title.Parent = frame

-- toggle
local tog = Instance.new("TextButton")
tog.Size = UDim2.new(0, 90, 0, 32); tog.Position = UDim2.new(0.5, -45, 0, 35)
tog.BackgroundColor3 = Color3.fromRGB(0, 170, 255); tog.Text = "OFF"; tog.Font = Enum.Font.GothamSemibold
tog.TextColor3 = Color3.new(1, 1, 1); tog.TextScaled = true; Instance.new("UICorner", tog); tog.Parent = frame
local active = false
tog.MouseButton1Click:Connect(function()
    active = not active
    tog.Text = active and "ON" or "OFF"
    tog.BackgroundColor3 = active and Color3.fromRGB(0, 255, 123) or Color3.fromRGB(0, 170, 255)
    if active then lib.enable() else lib.disable() end
end)

-- speed slider
local lab = Instance.new("TextLabel")
lab.Size = UDim2.new(0, 60, 0, 20); lab.Position = UDim2.new(0, 10, 0, 80)
lab.BackgroundTransparency = 1; lab.Text = "Speed"; lab.Font = Enum.Font.Gotham; lab.TextScaled = true
lab.TextColor3 = Color3.new(1, 1, 1); lab.Parent = frame
local slider = Instance.new("Slider")
slider.Size = UDim2.new(0, 120, 0, 16); slider.Position = UDim2.new(0.5, -10, 0, 80)
slider.Parent = frame; slider.Value = 1; slider.MinValue = .2; slider.MaxValue = 2; slider.Step = .1
slider.Changed:Connect(function() lib.setSpeedMul(slider.Value) end)

-- drag
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = frame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    if dragging and dragInput == input then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- hotkey
UserInputService.InputBegan:Connect(function(inp, g)
    if g then return end
    if inp.KeyCode == Config.HOTKEY then tog.Text = (not active) and "ON" or "OFF"; tog.BackgroundColor3 = (not active) and Color3.fromRGB(0, 255, 123) or Color3.fromRGB(0, 170, 255); active = not active; if active then lib.enable() else lib.disable() end end
end)