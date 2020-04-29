local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP", "coffee_tirechange")

vRP.defInventoryItem({"dæk", "Reservedæk", "Bruges til at udskifte et beskadiget dæk", function(args) -- Hvad dit item skal hedde
	local choices = {}
    
    choices["> Brug"] = {function(source,choice)
        local user_id = vRP.getUserId({source})
		if user_id then
            TriggerClientEvent("coffee_tirechange:udskift", source)
            vRP.closeMenu({source})
        end
    end}

    return choices
end, 1.5}) -- Vægt på dit item

RegisterNetEvent('coffee_tirechange:tagItem')
AddEventHandler('coffee_tirechange:tagItem', function()
	local _source = source
	local user_id = vRP.getUserId({source})

	vRP.tryGetInventoryItem({user_id,"dæk",1, false}) -- Tager item
	TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = 'Du brugte et reservedæk' })
end)