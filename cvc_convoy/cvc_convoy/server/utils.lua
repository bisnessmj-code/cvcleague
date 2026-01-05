--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                    CONVOI CONTRE CONVOI - SERVER UTILS                    ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
]]

CVC = CVC or {}
CVC.Utils = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- DEBUG & LOGGING
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Utils.Debug(message, ...)
    if Config.Debug then
        print(string.format('[CVC-Server] ' .. message, ...))
    end
end

function CVC.Utils.Log(message, ...)
    print(string.format('[CVC] ' .. message, ...))
end

-- ═══════════════════════════════════════════════════════════════════════════
-- PERMISSIONS
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Utils.HasPermission(source, command)
    -- Vérifier si la commande nécessite une permission spécifique
    if not Config.Permissions.commands[command] then
        return false
    end
    
    -- Récupérer le groupe du joueur (compatible ESX/QBCore/standalone)
    local playerGroup = CVC.Utils.GetPlayerGroup(source)
    
    -- Vérifier si le groupe est autorisé
    for _, allowedGroup in ipairs(Config.Permissions.allowedGroups) do
        if playerGroup == allowedGroup then
            return true
        end
    end
    
    return false
end

function CVC.Utils.GetPlayerGroup(source)
    -- Essayer ESX
    if GetResourceState('es_extended') == 'started' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            return xPlayer.getGroup()
        end
    end
    
    -- Essayer QBCore
    if GetResourceState('qb-core') == 'started' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            return Player.PlayerData.job.name -- ou permission group
        end
    end
    
    -- Fallback: utiliser les ACE permissions
    if IsPlayerAceAllowed(source, 'cvc.admin') then
        return 'admin'
    elseif IsPlayerAceAllowed(source, 'cvc.organisateur') then
        return 'organisateur'
    elseif IsPlayerAceAllowed(source, 'cvc.responsable') then
        return 'responsable'
    end
    
    return 'user'
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ROUTING BUCKET (INSTANCE)
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Utils.SetPlayerBucket(source, bucket)
    SetPlayerRoutingBucket(source, bucket)
    CVC.Utils.Debug('Joueur %d déplacé vers le bucket %d', source, bucket)
end

function CVC.Utils.GetPlayerBucket(source)
    return GetPlayerRoutingBucket(source)
end

function CVC.Utils.ResetPlayerBucket(source)
    SetPlayerRoutingBucket(source, 0) -- Retour au bucket principal
    CVC.Utils.Debug('Joueur %d retourné au bucket principal', source)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- QS-INVENTORY INTEGRATION
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Utils.GiveWeapon(source, weapon, ammo, ammoType)
    -- Utilisation de qs-inventory
    local success = false
    
    -- Export qs-inventory pour donner une arme
    if GetResourceState('qs-inventory') == 'started' then
        -- Méthode 1: AddItem pour l'arme
        exports['qs-inventory']:AddItem(source, weapon:lower(), 1)
        
        -- Méthode 2: AddItem pour les munitions
        if ammoType and ammo > 0 then
            exports['qs-inventory']:AddItem(source, ammoType, ammo)
        end
        
        success = true
        CVC.Utils.Debug('Arme donnée via qs-inventory: %s (ammo: %d)', weapon, ammo)
    else
        CVC.Utils.Log('ERREUR: qs-inventory n\'est pas démarré!')
    end
    
    return success
end

function CVC.Utils.RemoveWeapon(source, weapon)
    if GetResourceState('qs-inventory') == 'started' then
        exports['qs-inventory']:RemoveItem(source, weapon:lower(), 1)
        CVC.Utils.Debug('Arme retirée: %s', weapon)
        return true
    end
    return false
end

-- ═══════════════════════════════════════════════════════════════════════════
-- JOUEURS & COORDONNÉES
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Utils.GetPlayerCoords(source)
    local ped = GetPlayerPed(source)
    if ped and DoesEntityExist(ped) then
        return GetEntityCoords(ped)
    end
    return nil
end

function CVC.Utils.GetPlayersInRadius(centerSource, radius)
    local centerCoords = CVC.Utils.GetPlayerCoords(centerSource)
    if not centerCoords then return {} end
    
    local playersInRadius = {}
    local players = GetPlayers()
    
    for _, playerId in ipairs(players) do
        local playerCoords = CVC.Utils.GetPlayerCoords(playerId)
        if playerCoords then
            local distance = #(centerCoords - playerCoords)
            if distance <= radius then
                table.insert(playersInRadius, tonumber(playerId))
            end
        end
    end
    
    return playersInRadius
end

function CVC.Utils.GetPlayersInBucket(bucket)
    local playersInBucket = {}
    local players = GetPlayers()
    
    for _, playerId in ipairs(players) do
        if GetPlayerRoutingBucket(playerId) == bucket then
            table.insert(playersInBucket, tonumber(playerId))
        end
    end
    
    return playersInBucket
end

-- ═══════════════════════════════════════════════════════════════════════════
-- NOTIFICATIONS SERVEUR
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Utils.NotifyPlayer(source, message)
    TriggerClientEvent('cvc:client:notify', source, message)
end

function CVC.Utils.NotifyAllInMode(message)
    local players = CVC.Players.GetAllInMode()
    for _, playerId in ipairs(players) do
        CVC.Utils.NotifyPlayer(playerId, message)
    end
end
