--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                    CONVOI CONTRE CONVOI - COMMANDES ADMIN                 ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
]]

CVC = CVC or {}

-- ═══════════════════════════════════════════════════════════════════════════
-- /cvchealall [radius] - Soigner tous les joueurs dans un rayon
-- ═══════════════════════════════════════════════════════════════════════════

RegisterCommand('cvchealall', function(source, args, rawCommand)
    -- Vérification des permissions
    if not CVC.Utils.HasPermission(source, 'cvchealall') then
        TriggerClientEvent('cvc:client:notify', source, Config.Notifications.noPermission)
        return
    end
    
    local radius = tonumber(args[1]) or Config.DefaultRadius.healall
    local playersHealed = 0
    
    -- Récupérer les joueurs dans le rayon
    local playersInRadius = CVC.Utils.GetPlayersInRadius(source, radius)
    
    for _, playerId in ipairs(playersInRadius) do
        -- Vérifier que le joueur est dans le mode
        if CVC.Players.IsInMode(playerId) then
            TriggerClientEvent('cvc:client:heal', playerId)
            playersHealed = playersHealed + 1
        end
    end
    
    TriggerClientEvent('cvc:client:notify', source, 
        string.format('%d %s', playersHealed, Config.Notifications.healedPlayers))
    
    CVC.Utils.Debug('cvchealall: %d joueurs soignés dans un rayon de %d', playersHealed, radius)
end, false)

-- ═══════════════════════════════════════════════════════════════════════════
-- /cvcequipe - Afficher le nombre de joueurs par équipe
-- ═══════════════════════════════════════════════════════════════════════════

RegisterCommand('cvcequipe', function(source, args, rawCommand)
    -- Vérification des permissions
    if not CVC.Utils.HasPermission(source, 'cvcequipe') then
        TriggerClientEvent('cvc:client:notify', source, Config.Notifications.noPermission)
        return
    end
    
    local redCount, blueCount = CVC.Teams.GetCount()
    TriggerClientEvent('cvc:client:teamCount', source, redCount, blueCount)
    
    CVC.Utils.Debug('cvcequipe: Rouge=%d, Bleu=%d', redCount, blueCount)
end, false)

-- ═══════════════════════════════════════════════════════════════════════════
-- /givecallall [radius] - Donner une arme à tous les joueurs dans un rayon
-- ═══════════════════════════════════════════════════════════════════════════

RegisterCommand('givecallall', function(source, args, rawCommand)
    -- Vérification des permissions
    if not CVC.Utils.HasPermission(source, 'givecallall') then
        TriggerClientEvent('cvc:client:notify', source, Config.Notifications.noPermission)
        return
    end
    
    local radius = tonumber(args[1]) or Config.DefaultRadius.givecallall
    local playersGiven = 0
    
    -- Récupérer les joueurs dans le rayon
    local playersInRadius = CVC.Utils.GetPlayersInRadius(source, radius)
    
    for _, playerId in ipairs(playersInRadius) do
        -- Vérifier que le joueur est dans le mode
        if CVC.Players.IsInMode(playerId) then
            -- Donner l'arme via qs-inventory
            local success = CVC.Utils.GiveWeapon(
                playerId,
                Config.GiveAllWeapon.weapon,
                Config.GiveAllWeapon.ammo,
                Config.GiveAllWeapon.ammoType
            )
            
            if success then
                TriggerClientEvent('cvc:client:weaponReceived', playerId)
                playersGiven = playersGiven + 1
            end
        end
    end
    
    TriggerClientEvent('cvc:client:notify', source, 
        string.format('%d %s', playersGiven, Config.Notifications.givenWeapons))
    
    CVC.Utils.Debug('givecallall: %d joueurs ont reçu des armes dans un rayon de %d', playersGiven, radius)
end, false)

-- ═══════════════════════════════════════════════════════════════════════════
-- /cvctpall - Téléporter tous les joueurs EN ÉQUIPE vers l'admin
-- MODIFIÉ : Téléporte vers la position de l'admin
-- ═══════════════════════════════════════════════════════════════════════════

RegisterCommand('cvctpall', function(source, args, rawCommand)
    -- Vérification des permissions
    if not CVC.Utils.HasPermission(source, 'cvctpall') then
        TriggerClientEvent('cvc:client:notify', source, Config.Notifications.noPermission)
        return
    end
    
    -- Récupérer la position de l'admin
    local adminCoords = CVC.Utils.GetPlayerCoords(source)
    if not adminCoords then
        TriggerClientEvent('cvc:client:notify', source, 'Erreur: Impossible de récupérer votre position')
        return
    end
    
    -- Créer un vector4 avec heading
    local ped = GetPlayerPed(source)
    local heading = GetEntityHeading(ped)
    local teleportCoords = vector4(adminCoords.x, adminCoords.y, adminCoords.z, heading)
    
    local playersTeleported = 0
    local allPlayers = CVC.Players.GetAllInMode()
    
    for _, playerId in ipairs(allPlayers) do
        local team = CVC.Teams.GetPlayerTeam(playerId)
        -- Ne téléporter que les joueurs qui ont une équipe (et pas l'admin lui-même)
        if team and playerId ~= source then
            TriggerClientEvent('cvc:client:teleport', playerId, teleportCoords)
            playersTeleported = playersTeleported + 1
        end
    end
    
    TriggerClientEvent('cvc:client:notify', source, 
        string.format('%d joueurs téléportés vers vous', playersTeleported))
    
    CVC.Utils.Debug('cvctpall: %d joueurs téléportés vers l\'admin (ID: %d)', playersTeleported, source)
end, false)

-- ═══════════════════════════════════════════════════════════════════════════
-- /cvctpequipe [rouge/bleu] - Téléporter une équipe spécifique vers l'admin
-- MODIFIÉ : Téléporte l'équipe vers la position de l'admin
-- ═══════════════════════════════════════════════════════════════════════════

RegisterCommand('cvctpequipe', function(source, args, rawCommand)
    -- Vérification des permissions
    if not CVC.Utils.HasPermission(source, 'cvctpequipe') then
        TriggerClientEvent('cvc:client:notify', source, Config.Notifications.noPermission)
        return
    end
    
    local teamArg = args[1] and args[1]:lower() or nil
    
    -- Convertir 'rouge' en 'red' et 'bleu' en 'blue'
    local team = nil
    if teamArg == 'rouge' or teamArg == 'red' then
        team = 'red'
    elseif teamArg == 'bleu' or teamArg == 'blue' then
        team = 'blue'
    end
    
    if not team then
        TriggerClientEvent('cvc:client:notify', source, Config.Notifications.invalidTeam)
        return
    end
    
    -- Récupérer la position de l'admin
    local adminCoords = CVC.Utils.GetPlayerCoords(source)
    if not adminCoords then
        TriggerClientEvent('cvc:client:notify', source, 'Erreur: Impossible de récupérer votre position')
        return
    end
    
    -- Créer un vector4 avec heading
    local ped = GetPlayerPed(source)
    local heading = GetEntityHeading(ped)
    local teleportCoords = vector4(adminCoords.x, adminCoords.y, adminCoords.z, heading)
    
    local playersTeleported = 0
    local teamPlayers = CVC.Teams.GetTeamPlayers(team)
    
    for _, playerId in ipairs(teamPlayers) do
        -- Ne pas téléporter l'admin lui-même s'il est dans l'équipe
        if playerId ~= source then
            TriggerClientEvent('cvc:client:teleport', playerId, teleportCoords)
            playersTeleported = playersTeleported + 1
        end
    end
    
    local teamLabel = team == 'red' and 'Rouge' or 'Bleue'
    TriggerClientEvent('cvc:client:notify', source, 
        string.format('Équipe %s: %d joueurs téléportés vers vous', teamLabel, playersTeleported))
    
    CVC.Utils.Debug('cvctpequipe: %d joueurs de l\'équipe %s téléportés vers l\'admin (ID: %d)', playersTeleported, team, source)
end, false)

-- ═══════════════════════════════════════════════════════════════════════════
-- /cvcrepairall [radius] - Réparer tous les véhicules dans un rayon
-- ═══════════════════════════════════════════════════════════════════════════

RegisterCommand('cvcrepairall', function(source, args, rawCommand)
    -- Vérification des permissions
    if not CVC.Utils.HasPermission(source, 'cvcrepairall') then
        TriggerClientEvent('cvc:client:notify', source, Config.Notifications.noPermission)
        return
    end
    
    local radius = tonumber(args[1]) or Config.DefaultRadius.repairall
    
    -- Déclencher la réparation côté client (car les véhicules sont gérés client-side)
    TriggerClientEvent('cvc:client:repairVehicles', source, radius)
    
    CVC.Utils.Debug('cvcrepairall: Demande de réparation dans un rayon de %d', radius)
end, false)

-- Callback pour le retour de la réparation
RegisterNetEvent('cvc:server:vehiclesRepaired', function(count)
    local source = source
    TriggerClientEvent('cvc:client:notify', source, 
        string.format('%d %s', count, Config.Notifications.repairedVehicles))
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- /cvcspawnvehicule - Spawn les véhicules du convoi
-- ═══════════════════════════════════════════════════════════════════════════

RegisterCommand('cvcspawnvehicule', function(source, args, rawCommand)
    -- Vérification des permissions
    if not CVC.Utils.HasPermission(source, 'cvcspawnvehicule') then
        TriggerClientEvent('cvc:client:notify', source, Config.Notifications.noPermission)
        return
    end
    
    -- Déclencher le spawn côté client
    TriggerClientEvent('cvc:client:spawnVehicles', source)
    
    CVC.Utils.Debug('cvcspawnvehicule: Demande de spawn des véhicules')
end, false)

-- Callback pour le retour du spawn
RegisterNetEvent('cvc:server:vehiclesSpawned', function(count)
    local source = source
    CVC.Utils.Log('Véhicules spawnés: %d', count)
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- /cvckickall - Expulser tous les joueurs du mode
-- ═══════════════════════════════════════════════════════════════════════════

RegisterCommand('cvckickall', function(source, args, rawCommand)
    -- Vérification des permissions
    if not CVC.Utils.HasPermission(source, 'cvckickall') then
        TriggerClientEvent('cvc:client:notify', source, Config.Notifications.noPermission)
        return
    end
    
    -- Supprimer les véhicules d'abord (broadcast à tous les clients dans le mode)
    local allPlayers = CVC.Players.GetAllInMode()
    for _, playerId in ipairs(allPlayers) do
        TriggerClientEvent('cvc:client:deleteVehicles', playerId)
    end
    
    -- Kick tous les joueurs
    local kickedCount = CVC.Players.KickAll()
    
    TriggerClientEvent('cvc:client:notify', source, 
        string.format('%s (%d joueurs)', Config.Notifications.kickedAll, kickedCount))
    
    CVC.Utils.Debug('cvckickall: %d joueurs expulsés', kickedCount)
end, false)

-- ═══════════════════════════════════════════════════════════════════════════
-- /cvckick [id] - Expulser un joueur spécifique
-- ═══════════════════════════════════════════════════════════════════════════

RegisterCommand('cvckick', function(source, args, rawCommand)
    -- Vérification des permissions
    if not CVC.Utils.HasPermission(source, 'cvckick') then
        TriggerClientEvent('cvc:client:notify', source, Config.Notifications.noPermission)
        return
    end
    
    local targetId = tonumber(args[1])
    
    if not targetId then
        TriggerClientEvent('cvc:client:notify', source, 'Usage: /cvckick [id]')
        return
    end
    
    -- Vérifier si le joueur existe et est dans le mode
    if not CVC.Players.IsInMode(targetId) then
        TriggerClientEvent('cvc:client:notify', source, Config.Notifications.playerNotFound)
        return
    end
    
    -- Supprimer les véhicules pour ce joueur
    TriggerClientEvent('cvc:client:deleteVehicles', targetId)
    
    -- Kick le joueur
    local success = CVC.Players.Kick(targetId)
    
    if success then
        TriggerClientEvent('cvc:client:notify', source, 
            string.format('Joueur %d expulsé du mode', targetId))
        CVC.Utils.Debug('cvckick: Joueur %d expulsé', targetId)
    else
        TriggerClientEvent('cvc:client:notify', source, Config.Notifications.playerNotFound)
    end
end, false)

-- ═══════════════════════════════════════════════════════════════════════════
-- /cvcannonce [texte] - Afficher une annonce
-- ═══════════════════════════════════════════════════════════════════════════

RegisterCommand('cvcannonce', function(source, args, rawCommand)
    -- Vérification des permissions
    if not CVC.Utils.HasPermission(source, 'cvcannonce') then
        TriggerClientEvent('cvc:client:notify', source, Config.Notifications.noPermission)
        return
    end
    
    -- Récupérer le texte complet
    local text = table.concat(args, ' ')
    
    if text == '' then
        TriggerClientEvent('cvc:client:notify', source, 'Usage: /cvcannonce [texte]')
        return
    end
    
    -- Envoyer l'annonce à tous les joueurs dans le mode
    local allPlayers = CVC.Players.GetAllInMode()
    
    for _, playerId in ipairs(allPlayers) do
        TriggerClientEvent('cvc:client:showAnnouncement', playerId, text)
    end
    
    TriggerClientEvent('cvc:client:notify', source, 
        string.format('Annonce envoyée à %d joueurs', #allPlayers))
    
    CVC.Utils.Debug('cvcannonce: "%s" envoyée à %d joueurs', text, #allPlayers)
end, false)

-- ═══════════════════════════════════════════════════════════════════════════
-- SUGGESTIONS DE COMMANDES (pour l'autocomplétion)
-- ═══════════════════════════════════════════════════════════════════════════

-- Note: Ces suggestions ne fonctionnent que si vous utilisez un framework 
-- qui supporte TriggerClientEvent('chat:addSuggestion', ...)

CreateThread(function()
    Wait(1000)
    
    -- Ajouter les suggestions pour tous les joueurs
    TriggerClientEvent('chat:addSuggestion', -1, '/cvchealall', 'Soigner tous les joueurs dans un rayon', {
        { name = 'radius', help = 'Rayon en mètres (défaut: 50)' }
    })
    
    TriggerClientEvent('chat:addSuggestion', -1, '/cvcequipe', 'Afficher le nombre de joueurs par équipe', {})
    
    TriggerClientEvent('chat:addSuggestion', -1, '/givecallall', 'Donner des armes aux joueurs dans un rayon', {
        { name = 'radius', help = 'Rayon en mètres (défaut: 50)' }
    })
    
    TriggerClientEvent('chat:addSuggestion', -1, '/cvctpall', 'Téléporter tous les joueurs en équipe vers vous', {})
    
    TriggerClientEvent('chat:addSuggestion', -1, '/cvctpequipe', 'Téléporter une équipe spécifique vers vous', {
        { name = 'équipe', help = 'rouge ou bleu' }
    })
    
    TriggerClientEvent('chat:addSuggestion', -1, '/cvcrepairall', 'Réparer les véhicules dans un rayon', {
        { name = 'radius', help = 'Rayon en mètres (défaut: 50)' }
    })
    
    TriggerClientEvent('chat:addSuggestion', -1, '/cvcspawnvehicule', 'Spawn les véhicules du convoi', {})
    
    TriggerClientEvent('chat:addSuggestion', -1, '/cvckickall', 'Expulser tous les joueurs du mode', {})
    
    TriggerClientEvent('chat:addSuggestion', -1, '/cvckick', 'Expulser un joueur du mode', {
        { name = 'id', help = 'ID du joueur' }
    })
    
    TriggerClientEvent('chat:addSuggestion', -1, '/cvcannonce', 'Envoyer une annonce à tous les joueurs', {
        { name = 'texte', help = 'Message à afficher' }
    })
end)