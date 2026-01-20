-- GANTI SELURUH BAGIAN "STATE" DENGAN KODE BARU INI:
---------------------------------------------------------------- STATE
local tool, fakeModel, enabled = nil, nil, false

local function doEquip(t)
    if not t or not t:IsA("Tool") then return end
    if not t.Name:lower():find("rod") then return end
    tool = t; enabled = true
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid"); loadAnims(hum)

    -- buat model
    if fakeModel then fakeModel:Destroy() end
    fakeModel = buildTrident()
    local rh = char:FindFirstChild("RightHand")
    if rh then
        local w = weld(fakeModel.Handle, rh)
        w.C0 = CFrame.new(0,-1.2,0)*CFrame.Angles(math.rad(-20),0,0)
    end
    fakeModel.Parent = char; idleTrack:Play()
end

local function onEquip() -- panggil saat tool masuk character
    local char = player.Character or player.CharacterAdded:Wait()
    local t = char:FindFirstChildOfClass("Tool")
    if t then doEquip(t) end
end

local function checkBackpack()
    -- kadang tool di backpack, equip paksa
    local b = player:FindFirstChildOfClass("Backpack")
    if b then
        for _,t in ipairs(b:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():find("rod") then
                local hum = (player.Character or player.CharacterAdded:Wait()):WaitForChild("Humanoid")
                hum:EquipTool(t) -- paksa equip
                break
            end
        end
    end
end

local function onUnequip()
    enabled = false; tool = nil
    if idleTrack then idleTrack:Stop() end; if castTrack then castTrack:Stop() end
    if fakeModel then fakeModel:Destroy(); fakeModel = nil end
end

-- event
player.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(c) if c:IsA("Tool") then onEquip() end end)
    checkBackpack() -- saat spawn baru
end)
if player.Character then onEquip(); checkBackpack() end
player.Backpack.ChildAdded:Connect(function(t) if t:IsA("Tool") then checkBackpack() end end)
