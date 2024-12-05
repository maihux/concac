-- Tải thư viện UI
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
local Window = OrionLib:MakeWindow({Name = "Blox Fruits - Auto Farm (Song Đao, Bounty, Rương)", HidePremium = false, SaveConfig = true, ConfigFolder = "AutoFarmBloxFruits"})

-- Biến trạng thái
local autoFarm = false
local autoBounty = false
local autoChest = false
local flySpeed = 200 -- Tốc độ bay
local attackSpeed = 0.1 -- Tốc độ tấn công
local godMode = false

-- Tab chính
local FarmTab = Window:MakeTab({
    Name = "Auto Farm Song Đao",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local BountyTab = Window:MakeTab({
    Name = "Auto Farm Bounty",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local ChestTab = Window:MakeTab({
    Name = "Auto Teleport Rương",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Hàm Bay
function flyTo(destination)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if rootPart then
        while (rootPart.Position - destination.Position).magnitude > 5 do
            wait(0.1)
            rootPart.CFrame = CFrame.new(rootPart.Position, destination.Position) * CFrame.new(0, 0, -flySpeed * 0.1)
        end
    end
end

-- God Mode
function enableGodMode()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()

    character.Humanoid:UnequipTools() -- Tháo vũ khí để tránh lỗi
    character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false) -- Chặn chết
    character.Humanoid.Health = math.huge -- Tăng máu vô hạn
end

-- Auto Farm Song Đao
FarmTab:AddToggle({
    Name = "Auto Farm Song Đao",
    Default = false,
    Callback = function(Value)
        autoFarm = Value
        while autoFarm do
            wait(1)

            -- 1. Tìm NPC Nhiệm Vụ
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local questNPC = workspace:FindFirstChild("QuestGiverNPCName") -- Thay bằng tên NPC nhận nhiệm vụ
            if questNPC and questNPC:FindFirstChild("HumanoidRootPart") then
                flyTo(questNPC.HumanoidRootPart) -- Bay đến NPC
                wait(1)
                fireproximityprompt(questNPC.ProximityPrompt) -- Nhận nhiệm vụ
            end

            -- 2. Tìm Quái để Farm
            for _, mob in pairs(workspace.Enemies:GetChildren()) do
                if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                    flyTo(mob.HumanoidRootPart) -- Bay đến quái
                    wait(0.5)

                    -- Tấn công quái
                    local tool = character:FindFirstChildOfClass("Tool") -- Tìm vũ khí
                    if tool then
                        tool:Activate() -- Tấn công quái
                    end
                end
            end

            -- 3. Kiểm tra hoàn thành nhiệm vụ
            if player.PlayerGui.Quest.Status.Text == "Completed" then
                print("Nhiệm vụ hoàn thành, nhận nhiệm vụ tiếp theo!")
            end
        end
    end
})

-- Auto Farm Bounty
BountyTab:AddToggle({
    Name = "Auto Farm Bounty",
    Default = false,
    Callback = function(Value)
        autoBounty = Value
        enableGodMode() -- Kích hoạt God Mode khi bật
        while autoBounty do
            wait(attackSpeed)

            -- 1. Tìm Người Chơi Khác
            for _, otherPlayer in pairs(game.Players:GetChildren()) do
                if otherPlayer ~= game.Players.LocalPlayer and otherPlayer.Team ~= game.Players.LocalPlayer.Team then
                    local player = game.Players.LocalPlayer
                    local character = player.Character or player.CharacterAdded:Wait()
                    local tool = character:FindFirstChildOfClass("Tool") -- Lấy vũ khí

                    if tool and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        flyTo(otherPlayer.Character.HumanoidRootPart) -- Bay đến người chơi
                        tool:Activate() -- Tấn công
                    end
                end
            end
        end
    end
})

-- Auto Teleport Rương
ChestTab:AddToggle({
    Name = "Auto Teleport Rương",
    Default = false,
    Callback = function(Value)
        autoChest = Value
        while autoChest do
            wait(1)

            -- 1. Tìm Rương
            for _, chest in pairs(workspace:GetDescendants()) do
                if chest.Name == "Chest" and chest:FindFirstChild("HumanoidRootPart") then
                    flyTo(chest.HumanoidRootPart) -- Bay đến rương
                    wait(0.5)
                end
            end
        end
    end
})

-- Slider Tốc độ Bay
ChestTab:AddSlider({
    Name = "Tốc độ bay",
    Min = 50,
    Max = 300,
    Default = 200,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 10,
    ValueName = "Speed",
    Callback = function(Value)
        flySpeed = Value
    end
})

-- Hiển thị giao diện
OrionLib:Init()
