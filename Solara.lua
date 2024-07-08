repeat task.wait() until game:IsLoaded()

if game.PlaceId ~= 142823291 then
  return
end

if getgenv().Running then
    return
end
getgenv().Running = true

local shootOffset = 2.5
local playerData = {}

game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Gameplay"):WaitForChild("PlayerDataChanged").OnClientEvent:Connect(function(data)
	playerData = data
end)

game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Gameplay").Fade.OnClientEvent:Connect(function()
    task.wait(10)
    game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = 17
end)
 
function CreateHighlight()
	for i, v in pairs(game.Players:GetPlayers()) do
		if v ~= game:GetService("Players").LocalPlayer and v.Character ~= nil and v.Character:FindFirstChild("HumanoidRootPart") and not v.Character:FindFirstChild("ESP_Highlight") then
			local esphigh = Instance.new("Highlight", v.Character)
            esphigh.Name = "ESP_Highlight"
            esphigh.FillColor = Color3.fromRGB(160, 160, 160)
            esphigh.OutlineTransparency = 1
            esphigh.FillTransparency = 0.5   
        end
	end
end
 
function UpdateHighlights()
	for _, v in pairs(game.Players:GetPlayers()) do
		if v ~= game:GetService("Players").LocalPlayer and v.Character ~= nil and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("ESP_Highlight") then
			local Highlight = v.Character:FindFirstChild("ESP_Highlight")
			if v.Name == Sheriff and IsAlive(v) then
				Highlight.FillColor = Color3.fromRGB(0, 0, 225)
				Highlight.OutlineTransparency = 1
                Highlight.FillTransparency = 0.5
			elseif v.Name == Murder and IsAlive(v) then
				Highlight.FillColor = Color3.fromRGB(225, 0, 0)
				Highlight.OutlineTransparency = 1
                Highlight.FillTransparency = 0.5
			elseif v.Name == Hero and IsAlive(v) and v.Backpack:FindFirstChild("Gun") then
				Highlight.FillColor = Color3.fromRGB(255, 255, 0)
				Highlight.OutlineTransparency = 1
                Highlight.FillTransparency = 0.5
			elseif v.Name == Hero and IsAlive(v) and v.Character:FindFirstChild("Gun") then
				Highlight.FillColor = Color3.fromRGB(255, 255, 0)
				Highlight.OutlineTransparency = 1
                Highlight.FillTransparency = 0.5
			elseif not IsAlive(v) then
				Highlight.OutlineTransparency = 1
                Highlight.FillTransparency = 1
			else
				Highlight.FillColor = Color3.fromRGB(0, 225, 0)
				Highlight.OutlineTransparency = 1
                Highlight.FillTransparency = 0.5
			end
		end
	end
end	
 
function IsAlive(Player)
	for i, v in pairs(roles) do
		if Player.Name == i then
			if not v.Killed and not v.Dead then
				return true
			else
				return false
			end
		end
	end
end
 
function HideHighlights()
	for _, v in pairs(game.Players:GetPlayers()) do
		if v ~= game:GetService("Players").LocalPlayer and v.Character ~= nil and v.Character:FindFirstChild("ESP_Highlight") then
			v.Character:FindFirstChild("ESP_Highlight"):Destroy()
		end
	end
end

function findMurderer()
    for _, i in ipairs(game:GetService("Players"):GetPlayers()) do
        if i.Backpack:FindFirstChild("Knife") then
            return i
        end
    end

    for _, i in ipairs(game:GetService("Players"):GetPlayers()) do
        if not i.Character then continue end
        if i.Character:FindFirstChild("Knife") then
            return i
        end
    end

    if playerData then
        for player, data in playerData do
            if data.Role == "Murderer" then
                if game:GetService("Players"):FindFirstChild(player) then
                    return game:GetService("Players"):FindFirstChild(player)
                end
            end
        end
    end
    return nil
end

function findSheriff()
    for _, i in ipairs(game:GetService("Players"):GetPlayers()) do
        if i.Backpack:FindFirstChild("Gun") then
            return i
        end
    end

    for _, i in ipairs(game:GetService("Players"):GetPlayers()) do
        if not i.Character then continue end
        if i.Character:FindFirstChild("Gun") then
            return i
        end
    end

    if playerData then
        for player, data in playerData do
            if data.Role == "Sheriff" then
                if game:GetService("Players"):FindFirstChild(player) then
                    return game:GetService("Players"):FindFirstChild(player)
                end
            end
        end
    end
    return nil
end

function getPredictedPosition(player, shootOffset)
    pcall(function()
        player = player.Character
        if not player.Character then return end
    end)
    local playerHRP = player:FindFirstChild("UpperTorso")
    local playerHum = player:FindFirstChild("Humanoid")
    if not playerHRP or not playerHum then
        return Vector3.new(0,0,0), "Could not find the player's HumanoidRootPart."
    end

    local playerPosition = playerHRP.Position
    local velocity = Vector3.new()
    velocity = playerHRP.AssemblyLinearVelocity
    local playerMoveDirection = playerHum.MoveDirection
    local playerLookVec = playerHRP.CFrame.LookVector
    local yVelFactor = velocity.Y > 0 and -1 or 0.5
    local predictedPosition
    predictedPosition = playerHRP.Position + ((velocity * Vector3.new(0, 0.5, 0))) * (shootOffset / 15) +playerMoveDirection * shootOffset

    return predictedPosition
end
 
function shootMurder()
    if findSheriff() ~= game:GetService("Players").LocalPlayer then 
	game:GetService("StarterGui"):SetCore("SendNotification",{
        	Title = "Error!",
        	Text = "No Gun",
           	Duration = 3
        })
	return 
    end

    local murderer = findMurderer()
    if not murderer then return end
    if not game:GetService("Players").LocalPlayer.Character:FindFirstChild("Gun") then
        local hum = game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid")
        if game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Gun") then
            hum:EquipTool(game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Gun"))
         else
            return
        end
    end

    local murdererHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
    if not murdererHRP then return end

    local predictedPosition = getPredictedPosition(murderer, shootOffset)

    local args = {
        [1] = 1,
        [2] = predictedPosition,
        [3] = "AH2"
    }

    game:GetService("Players").LocalPlayer.Character.Gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(unpack(args))
end

function GunHighlight()
    for i, v in pairs(wworkspace:GetDescendants()) do
        if v.Name == "GunDrop" then 
            local espgun = Instance.new("Highlight", v)
            espgun.Name = "ESP_Highlight"
            espgun.FillColor = Color3.fromRGB(255, 255, 0)
            espgun.OutlineTransparency = 1
            espgun.FillTransparency = 0.5   
        end
    end
end

task.spawn(function()
	while task.wait() do
        roles = game:GetService("ReplicatedStorage"):FindFirstChild("GetPlayerData", true):InvokeServer()
        for i, v in pairs(roles) do
            if v.Role == "Murderer" then
                Murder = i
            elseif v.Role == "Sheriff" then
                Sheriff = i
            elseif v.Role == "Hero" then
                Hero = i
            end
        end
        CreateHighlight()
        UpdateHighlights()
    end
end)
 
workspace.DescendantAdded:Connect(function(GunESP)
	if GunESP.Name == "GunDrop" then
        game:GetService("StarterGui"):SetCore("SendNotification",{
        	Title = "@stupidzero.",
        	Text = "Gun Dropped",
           Duration = 3
        })
        GunHighlight()
    end
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.T then
        if game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Trap") then return end
        if game.Players.LocalPlayer.Character ~= nil then
            local mouse = game.Players.LocalPlayer:GetMouse()
            tool = Instance.new("Tool")
            tool.RequiresHandle = false
            tool.Name = "Trap"
            tool.Activated:connect(function()
                local pos = mouse.Hit+Vector3.new(0,0,0)
                game:GetService("ReplicatedStorage").TrapSystem.PlaceTrap:InvokeServer(pos)
            end)
            tool.Parent = game.Players.LocalPlayer.Backpack
        end
    end

    if input.KeyCode == Enum.KeyCode.C then
        shootMurder()
    end
end)
 
game:GetService("StarterGui"):SetCore("SendNotification",{
	Title = "MM2 Solara",
	Text = "Loaded.  @stupidzero.",
    Duration = 5
})

game:GetService("StarterGui"):SetCore("SendNotification",{
	Title = "Sheriff Shoot",
	Text = "Keybind: C",
    Duration = 5
})
