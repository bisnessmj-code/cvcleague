--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                    CONVOI CONTRE CONVOI - VÉHICULES (CLIENT)              ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
]]

CVC = CVC or {}
CVC.Vehicles = {}

local spawnedVehicles = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- SPAWN DES VÉHICULES
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Vehicles.SpawnConvoy()
    -- Supprimer les véhicules existants d'abord
    CVC.Vehicles.DeleteAll()
    
    local totalSpawned = 0
    
    for teamName, teamConfig in pairs(Config.Vehicles) do
        CVC.Utils.Debug('Spawn des véhicules pour l\'équipe: %s', teamName)
        
        for i, coords in ipairs(teamConfig.spawns) do
            local vehicle = CVC.Utils.SpawnVehicle(
                teamConfig.model,
                coords,
                teamConfig.color
            )
            
            if vehicle then
                table.insert(spawnedVehicles, {
                    entity = vehicle,
                    team = teamName,
                    netId = NetworkGetNetworkIdFromEntity(vehicle)
                })
                totalSpawned = totalSpawned + 1
                CVC.Utils.Debug('Véhicule spawné: %s #%d', teamName, i)
            end
        end
    end
    
    CVC.Utils.Debug('Total véhicules spawnés: %d', totalSpawned)
    return totalSpawned
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SUPPRESSION DES VÉHICULES
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Vehicles.DeleteAll()
    for _, vehicleData in ipairs(spawnedVehicles) do
        if vehicleData.entity and DoesEntityExist(vehicleData.entity) then
            CVC.Utils.DeleteVehicle(vehicleData.entity)
        end
    end
    spawnedVehicles = {}
    CVC.Utils.Debug('Tous les véhicules ont été supprimés')
end

-- ═══════════════════════════════════════════════════════════════════════════
-- RÉPARATION DES VÉHICULES
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Vehicles.RepairAllInRadius(radius)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local repairedCount = 0
    
    -- Réparer les véhicules spawnés par le script
    for _, vehicleData in ipairs(spawnedVehicles) do
        if vehicleData.entity and DoesEntityExist(vehicleData.entity) then
            local vehCoords = GetEntityCoords(vehicleData.entity)
            if #(playerCoords - vehCoords) <= radius then
                CVC.Utils.RepairVehicle(vehicleData.entity)
                repairedCount = repairedCount + 1
            end
        end
    end
    
    -- Réparer aussi tous les véhicules dans le rayon (pour les véhicules des joueurs)
    local vehicles = GetGamePool('CVehicle')
    for _, vehicle in ipairs(vehicles) do
        local vehCoords = GetEntityCoords(vehicle)
        if #(playerCoords - vehCoords) <= radius then
            CVC.Utils.RepairVehicle(vehicle)
            repairedCount = repairedCount + 1
        end
    end
    
    return repairedCount
end

-- ═══════════════════════════════════════════════════════════════════════════
-- RÉCUPÉRATION DES VÉHICULES PAR ÉQUIPE
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Vehicles.GetByTeam(team)
    local teamVehicles = {}
    
    for _, vehicleData in ipairs(spawnedVehicles) do
        if vehicleData.team == team and DoesEntityExist(vehicleData.entity) then
            table.insert(teamVehicles, vehicleData)
        end
    end
    
    return teamVehicles
end

function CVC.Vehicles.GetAll()
    return spawnedVehicles
end

-- ═══════════════════════════════════════════════════════════════════════════
-- EVENTS
-- ═══════════════════════════════════════════════════════════════════════════

-- Spawn des véhicules (commande admin)
RegisterNetEvent('cvc:client:spawnVehicles', function()
    local count = CVC.Vehicles.SpawnConvoy()
    CVC.Utils.Notify(Config.Notifications.vehiclesSpawned)
    TriggerServerEvent('cvc:server:vehiclesSpawned', count)
end)

-- Suppression des véhicules
RegisterNetEvent('cvc:client:deleteVehicles', function()
    CVC.Vehicles.DeleteAll()
end)

-- Réparation des véhicules dans un rayon
RegisterNetEvent('cvc:client:repairVehicles', function(radius)
    local count = CVC.Vehicles.RepairAllInRadius(radius)
    CVC.Utils.Notify(Config.Notifications.vehicleRepaired)
    TriggerServerEvent('cvc:server:vehiclesRepaired', count)
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- NETTOYAGE
-- ═══════════════════════════════════════════════════════════════════════════

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        CVC.Vehicles.DeleteAll()
    end
end)
