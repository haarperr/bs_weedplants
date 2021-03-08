RSCore = nil
TriggerEvent('RSCore:GetObject', function(obj) RSCore = obj end)

local PlantsLoaded = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if PlantsLoaded then
            TriggerClientEvent('orp:weed:client:updateWeedData', -1, Config.Plants)
        end
    end
end)

Citizen.CreateThread(function()
    TriggerEvent('orp:weed:server:getWeedPlants')
    PlantsLoaded = true
end)

RSCore.Functions.CreateUseableItem("weed_og-kush_seed", function(source, item)
    local src = source
    local Player = RSCore.Functions.GetPlayer(src)
    TriggerClientEvent('orp:weed:client:plantNewSeed', src, 'og_kush')
    Player.Functions.RemoveItem('weed_og-kush_seed', 1)
    TriggerClientEvent('inventory:client:ItemBox', source, RSCore.Shared.Items['weed_og-kush_seed'], "remove")
end)

RSCore.Functions.CreateUseableItem('weed_bananakush_seed', function(source, item)
    local src = source
    local Player = RSCore.Functions.GetPlayer(src)
    TriggerClientEvent('orp:weed:client:plantNewSeed', src, 'banana_kush')
    Player.Functions.RemoveItem('weed_bananakush_seed', 1)
    TriggerClientEvent('inventory:client:ItemBox', source, RSCore.Shared.Items['weed_bananakush_seed'], "remove")
end)

RSCore.Functions.CreateUseableItem('weed_bluedream_seed', function(source, item)
    local src = source
    local Player = RSCore.Functions.GetPlayer(src)
    TriggerClientEvent('orp:weed:client:plantNewSeed', src, 'blue_dream')
    Player.Functions.RemoveItem('weed_bluedream_seed', 1)
    TriggerClientEvent('inventory:client:ItemBox', source, RSCore.Shared.Items['weed_bluedream_seed'], "remove")
end)

RSCore.Functions.CreateUseableItem('weed_purple-haze_seed', function(source, item)
    local src = source
    local Player = RSCore.Functions.GetPlayer(src)
    TriggerClientEvent('orp:weed:client:plantNewSeed', src, 'purplehaze')
    Player.Functions.RemoveItem('weed_purple-haze_seed', 1)
    TriggerClientEvent('inventory:client:ItemBox', source, RSCore.Shared.Items['weed_purple-haze_seed'], "remove")
end)

RegisterServerEvent('orp:weed:server:saveWeedPlant')
AddEventHandler('orp:weed:server:saveWeedPlant', function(data, plantId)
    local data = json.encode(data)

    RSCore.Functions.ExecuteSql(false, 'INSERT INTO weed_plants (properties, plantid) VALUES (@properties, @plantid)', {
        ['@properties'] = data,
        ['@plantid'] = plantId
    })
end)

RegisterServerEvent('orp:server:checkPlayerHasThisItem')
AddEventHandler('orp:server:checkPlayerHasThisItem', function(item, cb)
    local src = source
    local xPlayer = RSCore.Functions.GetPlayer(src)

    if xPlayer.Functions.GetItemByName(item).amount > 0 then
        TriggerClientEvent(cb, src)
    else
        TriggerClientEvent('orp:weed:client:notify', src, 'You are missing ' .. item)
    end
end)

RegisterServerEvent('orp:weed:server:giveShittySeed')
AddEventHandler('orp:weed:server:giveShittySeed', function()
    local src = source
    local xPlayer = RSCore.Functions.GetPlayer(src)
    xPlayer.Functions.AddItem(Config.BadSeedReward, math.random(1, 2))
    TriggerClientEvent('inventory:client:ItemBox', src, RSCore.Shared.Items[Config.BadSeedReward], "add")
end)

RegisterServerEvent('orp:weed:server:plantNewSeed')
AddEventHandler('orp:weed:server:plantNewSeed', function(type, location)
    local src = source
    local plantId = math.random(111111, 999999)
    local xPlayer = RSCore.Functions.GetPlayer(src)
    local ident = xPlayer.PlayerData.citizenid
    local SeedData = {id = plantId, type = type, x = location.x, y = location.y, z = location.z, hunger = Config.StartingHunger, thirst = Config.StartingThirst, growth = 0.0, quality = 100.0, stage = 1, grace = true, beingHarvested = false, planter = ident}

    local PlantCount = 0

    for k, v in pairs(Config.Plants) do
        if v.planter == ident then
            PlantCount = PlantCount + 1
        end
    end

    if PlantCount >= Config.MaxPlantCount then
        TriggerClientEvent('orp:weed:client:notify', src, 'You already have ' .. Config.MaxPlantCount .. ' plants down')
    else
        table.insert(Config.Plants, SeedData)
        TriggerClientEvent('orp:weed:client:plantSeedConfirm', src)
        TriggerEvent('orp:weed:server:saveWeedPlant', SeedData, plantId)
        TriggerEvent('orp:weed:server:updatePlants')
    end
end)

RegisterServerEvent('orp:weed:plantHasBeenHarvested')
AddEventHandler('orp:weed:plantHasBeenHarvested', function(plantId)
    for k, v in pairs(Config.Plants) do
        if v.id == plantId then
            v.beingHarvested = true
        end
    end

    TriggerEvent('orp:weed:server:updatePlants')
end)

RegisterServerEvent('orp:weed:destroyPlant')
AddEventHandler('orp:weed:destroyPlant', function(plantId)
    local src = source
    local xPlayer = RSCore.Functions.GetPlayer(src)

    for k, v in pairs(Config.Plants) do
        if v.id == plantId then
            table.remove(Config.Plants, k)
        end
    end

    TriggerClientEvent('orp:weed:client:removeWeedObject', -1, plantId)
    TriggerEvent('orp:weed:server:weedPlantRemoved', plantId)
    TriggerEvent('orp:weed:server:updatePlants')
    TriggerClientEvent('orp:weed:client:notify', src, 'You destroy the weed plant')
end)

RegisterServerEvent('orp:weed:harvestWeed')
AddEventHandler('orp:weed:harvestWeed', function(plantId)
    local src = source
    local xPlayer = RSCore.Functions.GetPlayer(src)
    local amount
    local label
    local item
    local goodQuality = false
    local hasFound = false

    for k, v in pairs(Config.Plants) do
        if v.id == plantId then
            for y = 1, #Config.YieldRewards do
                if v.type == Config.YieldRewards[y].type then
                    label = Config.YieldRewards[y].label
                    item = Config.YieldRewards[y].item
                    amount = math.random(Config.YieldRewards[y].rewardMin, Config.YieldRewards[y].rewardMax)
                    local quality = math.ceil(v.quality)
                    hasFound = true
                    table.remove(Config.Plants, k)
                    if quality > 94 then
                        goodQuality = true
                    end
                    amount = math.ceil(amount * (quality / 35))
                end
            end
        end
    end

    if hasFound then
        TriggerClientEvent('orp:weed:client:removeWeedObject', -1, plantId)
        TriggerEvent('orp:weed:server:weedPlantRemoved', plantId)
        TriggerEvent('orp:weed:server:updatePlants')
        if label ~= nil then
            TriggerClientEvent('orp:weed:client:notify', src, 'You harvest x' .. amount .. ' ' .. label)
        end
        xPlayer.Functions.AddItem(item, amount)
        TriggerClientEvent('inventory:client:ItemBox', source, RSCore.Shared.Items[item], "add")
        if goodQuality then
            if math.random(1, 10) > 3 then
                local seed = math.random(1, #Config.GoodSeedRewards)
                xPlayer.Functions.AddItem(Config.GoodSeedRewards[seed], math.random(2, 4))
                TriggerClientEvent('inventory:client:ItemBox', source, RSCore.Shared.Items[Config.GoodSeedRewards[seed]], "add")
            end
        else
            xPlayer.Functions.AddItem(Config.BadSeedRewards, math.random(1, 2))
            TriggerClientEvent('inventory:client:ItemBox', source, RSCore.Shared.Items[Config.BadSeedRewards], "add")
        end
    end
end)

RegisterServerEvent('orp:weed:server:updatePlants')
AddEventHandler('orp:weed:server:updatePlants', function()
    TriggerClientEvent('orp:weed:client:updateWeedData', -1, Config.Plants)
end)

RegisterServerEvent('orp:weed:server:waterPlant')
AddEventHandler('orp:weed:server:waterPlant', function(plantId)
    local src = source
    local xPlayer = RSCore.Functions.GetPlayer(src)

    for k, v in pairs(Config.Plants) do
        if v.id == plantId then
            Config.Plants[k].thirst = Config.Plants[k].thirst + Config.ThirstIncrease
            if Config.Plants[k].thirst > 100.0 then
                Config.Plants[k].thirst = 100.0
            end
        end
    end

    xPlayer.Functions.RemoveItem('water_bottle', 1)
    TriggerClientEvent('inventory:client:ItemBox', source, RSCore.Shared.Items['water_bottle'], "remove")
    TriggerEvent('orp:weed:server:updatePlants')
end)

RegisterServerEvent('orp:weed:server:feedPlant')
AddEventHandler('orp:weed:server:feedPlant', function(plantId)
    local src = source
    local xPlayer = RSCore.Functions.GetPlayer(src)

    for k, v in pairs(Config.Plants) do
        if v.id == plantId then
            Config.Plants[k].hunger = Config.Plants[k].hunger + Config.HungerIncrease
            if Config.Plants[k].hunger > 100.0 then
                Config.Plants[k].hunger = 100.0
            end
        end
    end

    xPlayer.Functions.RemoveItem('fertilizer', 1)
    TriggerClientEvent('inventory:client:ItemBox', source, RSCore.Shared.Items['fertilizer'], "remove")
    TriggerEvent('orp:weed:server:updatePlants')
end)

RegisterServerEvent('orp:weed:server:updateWeedPlant')
AddEventHandler('orp:weed:server:updateWeedPlant', function(id, data)
    local result = RSCore.Functions.ExecuteSql(true, 'SELECT * FROM weed_plants WHERE plantid = @plantid', {
        ['@plantid'] = id
    })

    if result[1] then
        local newData = json.encode(data)
        RSCore.Functions.ExecuteSql(false, 'UPDATE weed_plants SET properties = @properties WHERE plantid = @id', {
            ['@properties'] = newData,
            ['@id'] = id
        })
    end
end)

RegisterServerEvent('orp:weed:server:weedPlantRemoved')
AddEventHandler('orp:weed:server:weedPlantRemoved', function(plantId)
    local result = RSCore.Functions.ExecuteSql(true, 'SELECT * FROM weed_plants')

    if result then
        for i = 1, #result do
            local plantData = json.decode(result[i].properties)
            if plantData.id == plantId then

                RSCore.Functions.ExecuteSql(false, 'DELETE FROM weed_plants WHERE id = @id', {
                    ['@id'] = result[i].id
                })

                for k, v in pairs(Config.Plants) do
                    if v.id == plantId then
                        table.remove(Config.Plants, k)
                    end
                end
            end
        end
    end
end)

RegisterServerEvent('orp:weed:server:getWeedPlants')
AddEventHandler('orp:weed:server:getWeedPlants', function()
    local data = {}
    local result = RSCore.Functions.ExecuteSql(true, 'SELECT * FROM weed_plants')

    if result[1] then
        for i = 1, #result do
            local plantData = json.decode(result[i].properties)
            print(plantData.id)
            table.insert(Config.Plants, plantData)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        -- Citizen.Wait(math.random(65000, 75000))
        Citizen.Wait(math.random(20000, 25000))
        -- Citizen.Wait(300)
        for i = 1, #Config.Plants do
            if Config.Plants[i].growth < 100 then
                if Config.Plants[i].grace then
                    Config.Plants[i].grace = false
                else
                    Config.Plants[i].thirst = Config.Plants[i].thirst - math.random(Config.Degrade.min, Config.Degrade.max) / 10
                    Config.Plants[i].hunger = Config.Plants[i].hunger - math.random(Config.Degrade.min, Config.Degrade.max) / 10
                    Config.Plants[i].growth = Config.Plants[i].growth + math.random(Config.GrowthIncrease.min, Config.GrowthIncrease.max) / 10

                    if Config.Plants[i].growth > 100 then
                        Config.Plants[i].growth = 100
                    end

                    if Config.Plants[i].hunger < 0 then
                        Config.Plants[i].hunger = 0
                    end

                    if Config.Plants[i].thirst < 0 then
                        Config.Plants[i].thirst = 0
                    end

                    if Config.Plants[i].quality < 25 then
                        Config.Plants[i].quality = 25
                    end

                    if Config.Plants[i].thirst < 75 or Config.Plants[i].hunger < 75 then
                        Config.Plants[i].quality = Config.Plants[i].quality - math.random(Config.QualityDegrade.min, Config.QualityDegrade.max) / 10
                    end

                    if Config.Plants[i].stage == 1 and Config.Plants[i].growth >= 55 then
                        Config.Plants[i].stage = 2
                    elseif Config.Plants[i].stage == 2 and Config.Plants[i].growth >= 90 then
                        Config.Plants[i].stage = 3
                    end
                end
            end
            TriggerEvent('orp:weed:server:updateWeedPlant', Config.Plants[i].id, Config.Plants[i])
        end
        TriggerEvent('orp:weed:server:updatePlants')
    end
end)
