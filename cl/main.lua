local QBCore = exports['qb-core']:GetCoreObject()

isLoggedIn = false
PlayerJob = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

local SpawnedPlants = {}
local InteractedPlant = nil
local HarvestedPlants = {}
local canHarvest = true
local closestPlant = nil
local isDoingAction = false

Citizen.CreateThread(function()
    while true do
    Citizen.Wait(150)

    local ped = GetPlayerPed(-1)
    local pos = GetEntityCoords(ped)
    local inRange = false

    for i = 1, #Config.Plants do
        local dist = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.Plants[i].x, Config.Plants[i].y, Config.Plants[i].z, true)

        -- if Config.Plants[i].growth < 100 then
            if dist < 50.0 then
                inRange = true
                local hasSpawned = false
                local needsUpgrade = false
                local upgradeId = nil
                local tableRemove = nil
    
                for z = 1, #SpawnedPlants do
                    local p = SpawnedPlants[z]
    
                    if p.id == Config.Plants[i].id then
                        hasSpawned = true
                        if p.stage ~= Config.Plants[i].stage then
                            needsUpgrade = true
                            upgradeId = p.id
                            tableRemove = z
                        end
                    end
                end
    
                if not hasSpawned then
                    local hash = GetHashKey(Config.WeedStages[Config.Plants[i].stage])
                    RequestModel(hash)
                    local data = {}
                    data.id = Config.Plants[i].id
                    data.stage = Config.Plants[i].stage
    
                    while not HasModelLoaded(hash) do
                        Citizen.Wait(10)
                        RequestModel(hash)
                    end
    
                    data.obj = CreateObject(hash, Config.Plants[i].x, Config.Plants[i].y, Config.Plants[i].z + GetPlantZ(Config.Plants[i].stage), false, false, false) 
                    SetEntityAsMissionEntity(data.obj, true)
                    FreezeEntityPosition(data.obj, true)
                    table.insert(SpawnedPlants, data)
                    hasSpawned = false
                end
    
                if needsUpgrade then
                    for o = 1, #SpawnedPlants do
                        local u = SpawnedPlants[o]
    
                        if u.id == upgradeId then
                            SetEntityAsMissionEntity(u.obj, false)
                            FreezeEntityPosition(u.obj, false)
                            DeleteObject(u.obj)
    
                            local hash = GetHashKey(Config.WeedStages[Config.Plants[i].stage])
                            RequestModel(hash)
                            local data = {}
                            data.id = Config.Plants[i].id
                            data.stage = Config.Plants[i].stage
    
                            while not HasModelLoaded(hash) do
                                Citizen.Wait(10)
                                RequestModel(hash)
                            end
    
                            data.obj = CreateObject(hash, Config.Plants[i].x, Config.Plants[i].y, Config.Plants[i].z + GetPlantZ(Config.Plants[i].stage), false, false, false) 
                            SetEntityAsMissionEntity(data.obj, true)
                            FreezeEntityPosition(data.obj, true)
                            table.remove(SpawnedPlants, o)
                            table.insert(SpawnedPlants, data)
                            needsUpgrade = false
                        end
                    end
                end
            end
        -- end
    end
    if not InRange then
        Citizen.Wait(5000)
    end
    end

end)

function DestroyPlant()
    local plant = GetClosestPlant()
    local hasDone = false

    for k, v in pairs(HarvestedPlants) do
        if v == plant.id then
            hasDone = true
        end
    end

    if not hasDone then
        table.insert(HarvestedPlants, plant.id)
        local ped = GetPlayerPed(-1)
        isDoingAction = true
        TriggerServerEvent('orp:weed:plantHasBeenHarvested', plant.id)

        RequestAnimDict('amb@prop_human_bum_bin@base')
        while not HasAnimDictLoaded('amb@prop_human_bum_bin@base') do
            Citizen.Wait(0)
        end

        TaskPlayAnim(ped, 'amb@prop_human_bum_bin@base', 'base', 8.0, 8.0, -1, 1, 1, 0, 0, 0)
        FreezeEntityPosition(ped, true)
        QBCore.Functions.Progressbar("destroying_weed", "Destroying...", 5000, false, false, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Done
            TriggerServerEvent('orp:weed:destroyPlant', plant.id)
            isDoingAction = false
            canHarvest = true
            FreezeEntityPosition(ped, false)
            ClearPedTasksImmediately(ped)
        end)
    else
        QBCore.Functions.Notify("Error", "error")
    end
end

function HarvestWeedPlant()
    local plant = GetClosestPlant()
    local hasDone = false

    for k, v in pairs(HarvestedPlants) do
        if v == plant.id then
            hasDone = true
        end
    end

    if not hasDone then
        table.insert(HarvestedPlants, plant.id)
        local ped = GetPlayerPed(-1)
        isDoingAction = true
        TriggerServerEvent('orp:weed:plantHasBeenHarvested', plant.id)

        RequestAnimDict('amb@prop_human_bum_bin@base')
        while not HasAnimDictLoaded('amb@prop_human_bum_bin@base') do
            Citizen.Wait(0)
        end

        TaskPlayAnim(ped, 'amb@prop_human_bum_bin@base', 'base', 8.0, 8.0, -1, 1, 1, 0, 0, 0)
        FreezeEntityPosition(ped, true)
        QBCore.Functions.Progressbar("harvesting_weed", "Harvesting...", 5000, false, false, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Done
            TriggerServerEvent('orp:weed:harvestWeed', plant.id)
            isDoingAction = false
            canHarvest = true
            FreezeEntityPosition(ped, false)
            ClearPedTasksImmediately(ped)
        end)
    else
        QBCore.Functions.Notify("Error", "error")
    end
end

function RemovePlantFromTable(plantId)
    for k, v in pairs(Config.Plants) do
        if v.id == plantId then
            table.remove(Config.Plants, k)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
            local InRange = false
            local ped = GetPlayerPed(-1)
            local pos = GetEntityCoords(ped)

            for k, v in pairs(Config.Plants) do
                if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, v.x, v.y, v.z, true) < 1.3 and not isDoingAction and not v.beingHarvested and not IsPedInAnyVehicle(GetPlayerPed(-1), false) then
                    if PlayerJob.name == 'police' then
                        local plant = GetClosestPlant()
                        DrawText3D(v.x, v.y, v.z, 'Thirst: ' .. v.thirst .. '% - Hunger: ' .. v.hunger .. '% - Growth: ' ..  v.growth .. '% -  Quality: ' .. v.quality)
                        DrawText3D(v.x, v.y, v.z - 0.18, '~b~G~w~ - Destroy Plant')
                        if IsControlJustReleased(0, Keys["G"]) then
                            if v.id == plant.id then
                                DestroyPlant()
                            end
                        end
                    else
                        if v.growth < 100 then
                            local plant = GetClosestPlant()
                            DrawText3D(v.x, v.y, v.z, 'Thirst: ' .. v.thirst .. '% - Hunger: ' .. v.hunger .. '% - Growth: ' ..  v.growth .. '% -  Quality: ' .. v.quality)
                            DrawText3D(v.x, v.y, v.z - 0.18, '~b~G~w~ - Water      ~y~H~w~ - Feed')
                            if IsControlJustReleased(0, Keys["G"]) then
                                if v.id == plant.id then
                                    if not QBCore.Functions.HasItem("water_bottle", 1) then
                                        QBCore.Functions.Notify("You are missing a water bottle", "error") 
                                    else
                                        TriggerEvent("orp:weed:client:waterPlant") 
                                    end
                                end
                            elseif IsControlJustReleased(0, Keys["H"]) then
                                if v.id == plant.id then
                                    if not QBCore.Functions.HasItem("weed_nutrition", 1) then
                                        QBCore.Functions.Notify("You are missing a weed nutrition", "error") 
                                    else
                                        TriggerEvent("orp:weed:client:feedPlant") 
                                    end
                                end
                            end
                        else
                            DrawText3D(v.x, v.y, v.z, '[Quality: ' .. v.quality .. ']')
                            DrawText3D(v.x, v.y, v.z - 0.18, '~g~E~w~ - Harvest')
                            if IsControlJustReleased(0, Keys["E"]) and canHarvest then
                                local plant = GetClosestPlant()
                                if v.id == plant.id then
                                    if QBCore.Functions.HasItem("empty_weed_bag", 1) then
                                        HarvestWeedPlant() 
                                    else
                                        QBCore.Functions.Notify("You need an empty weed bag for harvest this", "error") 
                                    end
                                end
                            end
                        end
                    end
                end
            end
    end
end)

local IsSearching = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
            local ped = GetPlayerPed(-1)
            local pos = GetEntityCoords(ped)
            local InRange = false

            for k, v in pairs(Config.SeedLocations) do
                if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, v.x, v.y, v.z) < 1.5 then
                    InRange = true
                end
            end

            if InRange and not IsSearching and not IsPedInAnyVehicle(GetPlayerPed(-1), false) then
                DrawText3D(pos.x, pos.y, pos.z, '~y~G~w~ - Search')
                if IsControlJustReleased(0, Keys["G"]) then
                    IsSearching = true
                    RequestAnimDict('amb@prop_human_bum_bin@base')
                    while not HasAnimDictLoaded('amb@prop_human_bum_bin@base') do
                        Citizen.Wait(0)
                    end

                    TaskPlayAnim(ped, 'amb@prop_human_bum_bin@base', 'base', 8.0, 8.0, -1, 1, 1, 0, 0, 0)
                    FreezeEntityPosition(ped, true)
                    QBCore.Functions.Progressbar("searching_seed", "Searching...", 10000, false, false, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    }, {}, {}, {}, function() -- Done
                        FreezeEntityPosition(ped, false)
                        IsSearching = false
                        ClearPedTasksImmediately(ped)
                    end)

                    if math.random(1, 10) == 7 then
                        TriggerServerEvent('orp:weed:server:giveShittySeed')
                    end
                end
            else
                Citizen.Wait(3000)
            end
    end
end)

function GetClosestPlant()
    local dist = 1000
    local ped = GetPlayerPed(-1)
    local pos = GetEntityCoords(ped)
    local plant = {}

    for i = 1, #Config.Plants do
        local xd = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.Plants[i].x, Config.Plants[i].y, Config.Plants[i].z, true)
        if xd < dist then
            dist = xd
            plant = Config.Plants[i]
        end
    end

    return plant
end

RegisterNetEvent('orp:weed:client:removeWeedObject')
AddEventHandler('orp:weed:client:removeWeedObject', function(plant)
    for i = 1, #SpawnedPlants do
        local o = SpawnedPlants[i]
        if o.id == plant then
            SetEntityAsMissionEntity(o.obj, false)
            FreezeEntityPosition(o.obj, false)
            DeleteObject(o.obj)
        end
    end
end)

RegisterNetEvent('orp:weed:client:notify')
AddEventHandler('orp:weed:client:notify', function(msg)
    QBCore.Functions.Notify(msg, "primary")
end)

RegisterNetEvent('orp:weed:client:waterPlant')
AddEventHandler('orp:weed:client:waterPlant', function()
    local entity = nil
    local plant = GetClosestPlant()
    local ped = GetPlayerPed(-1)
    isDoingAction = true

    for k, v in pairs(SpawnedPlants) do
        if v.id == plant.id then
            entity = v.obj
        end
    end

    TaskTurnPedToFaceEntity(GetPlayerPed(-1), entity, -1)

    RequestAnimDict('amb@prop_human_bum_bin@base')
    while not HasAnimDictLoaded('amb@prop_human_bum_bin@base') do
        Citizen.Wait(0)
    end

    TaskPlayAnim(ped, 'amb@prop_human_bum_bin@base', 'base', 8.0, 8.0, -1, 1, 1, 0, 0, 0)
    FreezeEntityPosition(ped, true)
    QBCore.Functions.Progressbar("watering_weed", "Watering...", 2000, false, false, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        FreezeEntityPosition(ped, false)
        TriggerServerEvent('orp:weed:server:waterPlant', plant.id)
        ClearPedTasksImmediately(GetPlayerPed(-1))
        isDoingAction = false
    end)
end)

RegisterNetEvent('orp:weed:client:feedPlant')
AddEventHandler('orp:weed:client:feedPlant', function()
    local entity = nil
    local plant = GetClosestPlant()
    local ped = GetPlayerPed(-1)
    isDoingAction = true

    for k, v in pairs(SpawnedPlants) do
        if v.id == plant.id then
            entity = v.obj
        end
    end

    TaskTurnPedToFaceEntity(GetPlayerPed(-1), entity, -1)

    RequestAnimDict('amb@prop_human_bum_bin@base')
    while not HasAnimDictLoaded('amb@prop_human_bum_bin@base') do
        Citizen.Wait(0)
    end

    TaskPlayAnim(ped, 'amb@prop_human_bum_bin@base', 'base', 8.0, 8.0, -1, 1, 1, 0, 0, 0)
    FreezeEntityPosition(ped, false)
    QBCore.Functions.Progressbar("fertilizing_weed", "Fertilizing...", 2000, false, false, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        FreezeEntityPosition(ped, false)
        TriggerServerEvent('orp:weed:server:feedPlant', plant.id)
        ClearPedTasksImmediately(GetPlayerPed(-1))
        isDoingAction = false
    end)
end)

RegisterNetEvent('orp:weed:client:updateWeedData')
AddEventHandler('orp:weed:client:updateWeedData', function(data)
    Config.Plants = data
end)

RegisterNetEvent('orp:weed:client:plantNewSeed')
AddEventHandler('orp:weed:client:plantNewSeed', function(type)
    local pos = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 1.0, 0.0)

    if CanPlantSeedHere(pos) and not IsPedInAnyVehicle(GetPlayerPed(-1), false) then
        QBCore.Functions.Progressbar("planting_weed", "Planting...", math.random(1000, 2000), false, false, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Done
            TriggerServerEvent('orp:weed:server:plantNewSeed', type, pos)
        end)
    else
        QBCore.Functions.Notify("Too close to another plant", "error")
    end
end)

RegisterNetEvent('orp:weed:client:plantSeedConfirm')
AddEventHandler('orp:weed:client:plantSeedConfirm', function()
    RequestAnimDict("pickup_object")
    while not HasAnimDictLoaded("pickup_object") do
        Citizen.Wait(7)
    end
    TaskPlayAnim(GetPlayerPed(-1), "pickup_object" ,"pickup_low" ,8.0, -8.0, -1, 1, 0, false, false, false)
    Citizen.Wait(1800)
    ClearPedTasks(GetPlayerPed(-1))
end)

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function CanPlantSeedHere(pos)
    local canPlant = true

    for i = 1, #Config.Plants do
        if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.Plants[i].x, Config.Plants[i].y, Config.Plants[i].z, true) < 1.3 then
            canPlant = false
        end
    end

    return canPlant
end

function GetPlantZ(stage)
    if stage == 1 then
        return -1.0
    else
        return -3.5
    end
end
