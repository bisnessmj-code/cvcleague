--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                    CONVOI CONTRE CONVOI - VÉHICULES (CLIENT)              ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
]]

CVC = CVC or {}
CVC.Vehicles = {}

local spawnedVehicles = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- SPAWN DES VÉHICULES - MODIFIÉ POUR CONFIGURATION INDIVIDUELLE
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Vehicles.SpawnConvoy()
    -- Supprimer les véhicules existants d'abord
    CVC.Vehicles.DeleteAll()
    
    local totalSpawned = 0
    
    for teamName, vehicleList in pairs(Config.Vehicles) do
        CVC.Utils.Debug('Spawn des véhicules pour l\'équipe: %s', teamName)
        
        -- Parcourir chaque configuration de véhicule
        for vehicleIndex, vehicleConfig in ipairs(vehicleList) do
            -- Vérifier que la configuration est valide
            if vehicleConfig.model and vehicleConfig.coords then
                local vehicle = CVC.Utils.SpawnVehicle(
                    vehicleConfig.model,
                    vehicleConfig.coords,
                    vehicleConfig.color
                )
                
                if vehicle then
                    table.insert(spawnedVehicles, {
                        entity = vehicle,
                        team = teamName,
                        model = vehicleConfig.model,
                        netId = NetworkGetNetworkIdFromEntity(vehicle),
                        index = vehicleIndex
                    })
                    totalSpawned = totalSpawned + 1
                    CVC.Utils.Debug('Véhicule spawné: %s [%s] #%d', teamName, vehicleConfig.model, vehicleIndex)
                else
                    CVC.Utils.Debug('ERREUR: Impossible de spawner le véhicule %s #%d', vehicleConfig.model, vehicleIndex)
                end
            else
                CVC.Utils.Debug('ERREUR: Configuration invalide pour le véhicule #%d de l\'équipe %s', vehicleIndex, teamName)
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
    local deletedCount = 0
    
    for _, vehicleData in ipairs(spawnedVehicles) do
        if vehicleData.entity and DoesEntityExist(vehicleData.entity) then
            CVC.Utils.DeleteVehicle(vehicleData.entity)
            deletedCount = deletedCount + 1
        end
    end
    
    spawnedVehicles = {}
    CVC.Utils.Debug('Tous les véhicules ont été supprimés (%d véhicules)', deletedCount)
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
                CVC.Utils.Debug('Véhicule réparé: %s [%s]', vehicleData.team, vehicleData.model)
            end
        end
    end
    
    -- Réparer aussi tous les véhicules dans le rayon (pour les véhicules des joueurs)
    local vehicles = GetGamePool('CVehicle')
    for _, vehicle in ipairs(vehicles) do
        local vehCoords = GetEntityCoords(vehicle)
        if #(playerCoords - vehCoords) <= radius then
            -- Vérifier si ce n'est pas déjà un véhicule spawné (pour éviter de compter 2 fois)
            local alreadyCounted = false
            for _, vehicleData in ipairs(spawnedVehicles) do
                if vehicleData.entity == vehicle then
                    alreadyCounted = true
                    break
                end
            end
            
            if not alreadyCounted then
                CVC.Utils.RepairVehicle(vehicle)
                repairedCount = repairedCount + 1
            end
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
-- STATISTIQUES DES VÉHICULES (DEBUG)
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Vehicles.GetStats()
    local stats = {
        total = 0,
        byTeam = {
            red = 0,
            blue = 0
        },
        byModel = {}
    }
    
    for _, vehicleData in ipairs(spawnedVehicles) do
        if DoesEntityExist(vehicleData.entity) then
            stats.total = stats.total + 1
            
            -- Comptage par équipe
            if vehicleData.team then
                stats.byTeam[vehicleData.team] = (stats.byTeam[vehicleData.team] or 0) + 1
            end
            
            -- Comptage par modèle
            local model = vehicleData.model or 'unknown'
            stats.byModel[model] = (stats.byModel[model] or 0) + 1
        end
    end
    
    return stats
end

-- ═══════════════════════════════════════════════════════════════════════════
-- EVENTS
-- ═══════════════════════════════════════════════════════════════════════════

-- Spawn des véhicules (commande admin)
RegisterNetEvent('cvc:client:spawnVehicles', function()
    local count = CVC.Vehicles.SpawnConvoy()
    
    -- Afficher les statistiques en mode debug
    if Config.Debug then
        local stats = CVC.Vehicles.GetStats()
        CVC.Utils.Debug('=== Statistiques des véhicules ===')
        CVC.Utils.Debug('Total: %d', stats.total)
        CVC.Utils.Debug('Équipe Rouge: %d', stats.byTeam.red)
        CVC.Utils.Debug('Équipe Bleue: %d', stats.byTeam.blue)
        CVC.Utils.Debug('Par modèle:')
        for model, count in pairs(stats.byModel) do
            CVC.Utils.Debug('  - %s: %d', model, count)
        end
    end
    
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

-- ═══════════════════════════════════════════════════════════════════════════
-- COMMANDE DEBUG (si Config.Debug = true)
-- ═══════════════════════════════════════════════════════════════════════════

if Config.Debug then
    RegisterCommand('cvc_vehiclestats', function()
        local stats = CVC.Vehicles.GetStats()
        print('=== CVC - Statistiques des véhicules ===')
        print('Total véhicules actifs: ' .. stats.total)
        print('Équipe Rouge: ' .. stats.byTeam.red)
        print('Équipe Bleue: ' .. stats.byTeam.blue)
        print('Répartition par modèle:')
        for model, count in pairs(stats.byModel) do
            print(string.format('  - %s: %d véhicule(s)', model, count))
        end
    end, false)
end