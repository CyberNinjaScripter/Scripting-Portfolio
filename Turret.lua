--Services

local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

--Objects

local Turret_Handler = script.Parent
local Values = Turret_Handler:WaitForChild("Values")
local Turret = Turret_Handler.Parent

--Values

local Light_Value = Values:WaitForChild("Light")
local Turret_Top = Values:WaitForChild("Turret_Top")
local Turret_Bottom = Values:WaitForChild("Turret_Bottom")
local Disarm = Values:WaitForChild("Disarm")
local Range = Values:WaitForChild("Range")
local Damage = Values:WaitForChild("Damage")
local Cooldown = Values:WaitForChild("Cooldown")
local ShootGun_Bottom = Values:WaitForChild("ShootGun_Bottom")
local ShootGun_Top = Values:WaitForChild("ShootGun_Top")
local TrackMode = Values:WaitForChild("TrackMode")

--Tables

local Admins = {

}

--Variables

local Speed = 50

--Functions

local function SolveTime(Distance)
	local Time = Distance/Speed
	return Time
end

local function TargetIsShootable(Character)
	local CharacterHumanoid = Character:FindFirstChild("Humanoid")
	local CharacterHumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	for i,v in pairs(Admins) do
		if v == Character.Name then
			return false
		end
	end
	if Character and CharacterHumanoid and CharacterHumanoidRootPart and CharacterHumanoid.Health >= 1 and (CharacterHumanoidRootPart.Position - Turret_Top.Value.Position).magnitude <= Range.Value and not Disarm.Value then
		return true
	else
		return false
	end
end

local function MoveTurret(Target)
	local CharacterHumanoid = Target:FindFirstChild("Humanoid")
	local CharacterHumanoidRootPart = Target:FindFirstChild("HumanoidRootPart")
	if CharacterHumanoidRootPart and CharacterHumanoid then
		local Tween = TweenService:Create(Turret_Top.Value,TweenInfo.new(Cooldown.Value,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),{CFrame = CFrame.new(Turret_Top.Value.Position,CharacterHumanoidRootPart.Position)})
		Tween:Play()
	end
	if not Turret_Top.Value.Move.Playing then
		Turret_Top.Value.Move:Play()
	end
end

local function RayCast()
	local RayCastParams = RaycastParams.new()
	RayCastParams.FilterDescendantsInstances = {Turret:GetDescendants()}
	RayCastParams.RespectCanCollide = true
	local RayCast1 = workspace:Raycast(Turret_Top.Value:WaitForChild("Top").Position,Turret_Top.Value:WaitForChild("Top").CFrame.LookVector*Range.Value,RayCastParams)
	local RayCast2 = workspace:Raycast(Turret_Top.Value:WaitForChild("Bottom").Position,Turret_Top.Value:WaitForChild("Bottom").CFrame.LookVector*Range.Value,RayCastParams)
	if RayCast1 then
		return RayCast1
	elseif RayCast2 then
		return RayCast2
	end
end

local function Dispear(Part)
	if Part.Name == "HumanoidRootPart" and Part.Name == "Bullet" and Part.Parent.Name == "Turret" and Part.Parent.Parent.Name == "Turret" then return end
	local Highlight = Instance.new("Highlight")
	Highlight.Parent = Part
	Part.Anchored = false
	Debris:AddItem(Part,2.5)
	wait(1)
end

local function Shoot(Position,Time,Color,Destroy)
	Turret_Top.Value.Reload:Play()
	local Bullet = ServerStorage:WaitForChild("Bullet"):Clone()
	if not Destroy then
		Bullet.CFrame = Turret_Top.Value:WaitForChild("Top").CFrame
	else
		Bullet.CFrame = Turret_Top.Value:WaitForChild("Bottom").CFrame
	end
	Bullet.Color = Color
	Bullet.Parent = workspace:WaitForChild("Bullets")
	wait()
	Turret_Top.Value.Shoot:Play()
	local Tween = TweenService:Create(Bullet,TweenInfo.new(Time*2,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),{Position=Position*2 - Vector3.new(0,5,0)-script.Parent.Parent.Turret_Top.Position})
	Tween:Play()
	Tween.Completed:Connect(function()
		Debris:AddItem(Bullet,0.25)
	end)
	Bullet.Touched:Connect(function(Part)
		local Humanoid = Part.Parent:FindFirstChild("Humanoid")
		if Destroy then
			Dispear(Part)
		else
			Debris:AddItem(Bullet,0)
		end
		if Humanoid then
			Humanoid.Health -= Damage.Value
		end
	end)

	while Bullet.Parent do
		wait()
		local RayCastParams = RaycastParams.new()
		RayCastParams.FilterDescendantsInstances = {Bullet}
		RayCastParams.RespectCanCollide = true
		local RayCast = workspace:Raycast(Bullet.Position,Position*0.07,RayCastParams)
		if RayCast and RayCast.Instance and RayCast.Instance.Parent then
			local Humanoid = RayCast.Instance.Parent:FindFirstChild("Humanoid")
			if Destroy then
				Dispear(RayCast.Instance)
			else
				Debris:AddItem(Bullet,0)
			end
			if Humanoid then
				Humanoid.Health -= Damage.Value
			end
		end
	end
end

local function ChangeLight(Color)
	if Light_Value.Value then 
		for i,v in pairs(Light_Value.Value:GetChildren()) do
			if v.Name == "Light" then
				v.Color = Color
				v.Light.Color = Color
			end
		end
	end
end

local function ResetTurret()
	local Tween = TweenService:Create(Turret_Top.Value,TweenInfo.new(2,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),{CFrame = CFrame.new(Turret_Top.Value.Position)*CFrame.Angles(0,180,0)})
	Tween:Play()
end

Disarm.Changed:Connect(function(Value)
	wait()
	if Value then
		ChangeLight(Color3.new(1, 0.701961, 0))
		ResetTurret()
	else
		ChangeLight(Color3.new(0, 1, 0.14902))
	end
end)

Turret_Top.Value.Switch.Triggered:Connect(function(Player)
	local Character = Player.Character
	if Character then
		local CharacterHumanoid = Character:FindFirstChild("Humanoid")
		local CharacterHumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
		if CharacterHumanoid and CharacterHumanoidRootPart and CharacterHumanoid.Health >= 1 and (CharacterHumanoidRootPart.Position - Turret_Top.Value.Position).magnitude <= 5 then
			Disarm.Value = not Disarm.Value
			if Disarm.Value then
				Turret_Top.Value.Switch.ActionText = "Arm Turret"
			else
				Turret_Top.Value.Switch.ActionText = "Disarm Turret"
			end
		end
	end
end)

Turret:WaitForChild("Humanoid").Died:Connect(function()
	for i,v in pairs(Turret:GetDescendants()) do
		if v:IsA("Part") then
			v.Anchored = false
		end
		if v:IsA("Motor6D") then
			v.Enabled = false
		end
	end
	script.Disabled = true
end)

task.spawn(function()
	while true do
		wait()
		while Disarm.Value do
			wait(1)
		end
		local ClosestTarget = nil
		local DistanceToTarget = 0
		for i,v in pairs(Players:GetPlayers()) do
			if v.Character and TargetIsShootable(v.Character) then
				local CharacterHumanoidRootPart = v.Character:FindFirstChild("HumanoidRootPart")
				if CharacterHumanoidRootPart then
					if DistanceToTarget <= (CharacterHumanoidRootPart.Position - Turret_Top.Value.Position).magnitude then
						ClosestTarget = v.Character
						DistanceToTarget = (CharacterHumanoidRootPart.Position - Turret_Top.Value.Position).magnitude
					end
				end
			end
		end
		for i,v in pairs(workspace:GetDescendants()) do
			if v:FindFirstChild("Humanoid")  then
				if v and TargetIsShootable(v) and v.Parent and v.Name ~= "Turret" then
					local CharacterHumanoidRootPart = v:FindFirstChild("HumanoidRootPart")
					if CharacterHumanoidRootPart then
						if DistanceToTarget <= (CharacterHumanoidRootPart.Position - Turret_Top.Value.Position).magnitude then
							ClosestTarget = v
							DistanceToTarget = (CharacterHumanoidRootPart.Position - Turret_Top.Value.Position).magnitude
						end
					end
				end
			end
		end
		if ClosestTarget ~= nil then
			local RayCastResult = RayCast()
			ChangeLight(Color3.new(1, 0, 0.0156863))
			if RayCastResult and RayCastResult.Instance and ClosestTarget then
				if not TrackMode.Value then
					if ClosestTarget == RayCastResult.Instance or ClosestTarget == RayCastResult.Instance.Parent then
						task.spawn(function()
							Shoot(RayCastResult.Position,SolveTime(RayCastResult.Distance),Color3.new(1, 0.623529, 0.0196078),false)
						end)
					else
						Shoot(RayCastResult.Position,SolveTime(RayCastResult.Distance),Color3.new(1, 0, 0.0156863),true)
					end
				end
			end
			MoveTurret(ClosestTarget)
			wait(Cooldown.Value)
		else
			ChangeLight(Color3.new(0, 1, 0.14902))
		end
	end
end)

task.spawn(function()
	while wait(2.5) do
		if Turret:WaitForChild("Humanoid").Health + 10 >= Turret:WaitForChild("Humanoid").MaxHealth then
			Turret:WaitForChild("Humanoid").Health = Turret:WaitForChild("Humanoid").MaxHealth
		else
			Turret:WaitForChild("Humanoid").Health += 10
		end
	end
end)
