local CurrentAction	= nil

RegisterNetEvent('coffee_tirechange:udskift')
AddEventHandler('coffee_tirechange:udskift', function()
	exports['mythic_notify']:SendAlert('inform', 'Gå til det beskadige dæk', 5000)
	changeThisShit()
end)

function ClosestTire(vehicle)
	local tireBones = {"wheel_lf", "wheel_rf", "wheel_lm1", "wheel_rm1", "wheel_lm2", "wheel_rm2", "wheel_lm3", "wheel_rm3", "wheel_lr", "wheel_rr"}
	local tireIndex = {
		["wheel_lf"] = 0,
		["wheel_rf"] = 1,
		["wheel_lm1"] = 2,
		["wheel_rm1"] = 3,
		["wheel_lm2"] = 45,
		["wheel_rm2"] = 47,
		["wheel_lm3"] = 46,
		["wheel_rm3"] = 48,
		["wheel_lr"] = 4,
		["wheel_rr"] = 5,
	}
	local player = PlayerId()
	local plyPed = GetPlayerPed(player)
	local plyPos = GetEntityCoords(plyPed, false)
	local minDistance = 1.5
	local closestTire = nil
	
	for a = 1, #tireBones do
		local bonePos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, tireBones[a]))
		local distance = Vdist(plyPos.x, plyPos.y, plyPos.z, bonePos.x, bonePos.y, bonePos.z)

		if closestTire == nil then
			if distance <= minDistance then
				closestTire = {bone = tireBones[a], boneDist = distance, bonePos = bonePos, tireIndex = tireIndex[tireBones[a]]}
			end
		else
			if distance < closestTire.boneDist then
				closestTire = {bone = tireBones[a], boneDist = distance, bonePos = bonePos, tireIndex = tireIndex[tireBones[a]]}
			end
		end
	end

	return closestTire
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local vehicle = ClosestVehicle()
		if vehicle ~= 0 then
			local closestTire = ClosestTire(vehicle)
			if closestTire ~= nil then
				if IsVehicleTyreBurst(vehicle, closestTire.tireIndex, 0) == false then
					Citizen.Wait(1500)
				else
					Draw3DText(closestTire.bonePos.x, closestTire.bonePos.y, closestTire.bonePos.z, "~r~Dette dæk skal repareres!")
				end
			end
		end
	end
end)

function ClosestVehicle()
	local plyPed = GetPlayerPed(-1)
	local plyPos = GetEntityCoords(plyPed, false)
	local plyOffset = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 1.0, 0.0)
	local radius = 0.3
	local rayHandle = StartShapeTestCapsule(plyPos.x, plyPos.y, plyPos.z, plyOffset.x, plyOffset.y, plyOffset.z, radius, 10, plyPed, 7)
	local _, _, _, _, vehicle = GetShapeTestResult(rayHandle)
	return vehicle
end

function changeThisShit()
	FreezeEntityPosition(GetPlayerPed(-1), false)
	changingTire = true
	local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
	prop = CreateObject(GetHashKey('prop_rub_tyre_01'), x, y, z+0.2,  true,  true, true)
	AttachEntityToEntity(prop, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 60309), 0.025, 0.11, 0.255, -145.0, 290.0, 0.0, true, true, false, true, 1, true)
	while changingTire do
		Citizen.Wait(250)
		local vehicle   = ClosestVehicle()
		local coords    = GetEntityCoords(GetPlayerPed(-1))
		LoadDict('anim@heists@box_carry@')
	
		if not IsEntityPlayingAnim(GetPlayerPed(-1), "anim@heists@box_carry@", "idle", 3 ) and changingTire == true then
			TaskPlayAnim(GetPlayerPed(-1), 'anim@heists@box_carry@', "idle", 3.0, -8, -1, 63, 0, 0, 0, 0 )
		end
		
		if DoesEntityExist(vehicle) then
			changingTire = false
			TaskStartScenarioInPlace(GetPlayerPed(-1), "CODE_HUMAN_MEDIC_KNEEL", 0, false)
			ClearPedTasks(GetPlayerPed(-1))
			TriggerServerEvent('coffee_tirechange:tagItem')
	
				Citizen.CreateThread(function()
	
					CurrentAction = 'skift'

					exports["progressbar"]:StartDelayedFunction("Udskifter dækket", 10000, function()
					end)
	
					Citizen.Wait(10000)
					DeleteEntity(prop)
	
					if CurrentAction ~= nil then
						local closestTire = ClosestTire(vehicle)
						if closestTire ~= nil then
							SetVehicleTyreFixed(vehicle, closestTire.tireIndex)
							ClearPedTasksImmediately(GetPlayerPed(-1))

							exports['mythic_notify']:SendAlert('success', 'Dæk udskiftet', 5000)
						end
					end
	
					CurrentAction = nil
				end)
		end
	end
end

function LoadDict(dict)
    RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
	  	Citizen.Wait(100)
    end
end

function Draw3DText(x, y, z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
    local scale = (1/dist)*0.85
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
   
    if onScreen then
        SetTextScale(0.0*scale, 0.55*scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end