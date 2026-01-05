--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                    CONVOI CONTRE CONVOI - MAIN SERVER                     ║
    ║                                                                           ║
    ║  Script principal serveur - Initialisation et gestion globale            ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
]]

CVC = CVC or {}

-- ═══════════════════════════════════════════════════════════════════════════
-- INITIALISATION
-- ═══════════════════════════════════════════════════════════════════════════

CreateThread(function()
    -- Attendre que toutes les ressources soient chargées
    Wait(2000)
    
    -- Vérifier les dépendances
    CVC.CheckDependencies()
    
    -- Log de démarrage
    print('^2[CVC]^0 Convoi contre Convoi - Script chargé avec succès')
    print('^2[CVC]^0 Routing Bucket: ' .. Config.RoutingBucket)
    print('^2[CVC]^0 Debug Mode: ' .. (Config.Debug and 'Activé' or 'Désactivé'))
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- VÉRIFICATION DES DÉPENDANCES
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.CheckDependencies()
    -- Vérifier qs-inventory
    if GetResourceState('qs-inventory') ~= 'started' then
        print('^1[CVC] ERREUR: qs-inventory n\'est pas démarré!^0')
        print('^1[CVC] Le script nécessite qs-inventory pour fonctionner.^0')
    else
        print('^2[CVC]^0 qs-inventory détecté')
    end
    
    -- Vérifier ESX ou QBCore (optionnel, pour les permissions)
    local framework = 'standalone'
    
    if GetResourceState('es_extended') == 'started' then
        framework = 'ESX'
    elseif GetResourceState('qb-core') == 'started' then
        framework = 'QBCore'
    end
    
    print('^2[CVC]^0 Framework détecté: ' .. framework)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- GESTION DES JOUEURS CONNECTÉS
-- ═══════════════════════════════════════════════════════════════════════════

-- Quand un joueur se connecte
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    CVC.Utils.Debug('Joueur %s (%d) en cours de connexion', name, source)
end)

-- Quand un joueur est complètement connecté
RegisterNetEvent('cvc:server:playerLoaded', function()
    local source = source
    CVC.Utils.Debug('Joueur %d chargé', source)
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- EXPORTS POUR INTÉGRATION EXTERNE
-- ═══════════════════════════════════════════════════════════════════════════

-- Vérifier si un joueur est dans le mode
exports('IsPlayerInMode', function(source)
    return CVC.Players.IsInMode(source)
end)

-- Récupérer l'équipe d'un joueur
exports('GetPlayerTeam', function(source)
    return CVC.Teams.GetPlayerTeam(source)
end)

-- Récupérer le compte des équipes
exports('GetTeamCount', function()
    return CVC.Teams.GetCount()
end)

-- Récupérer tous les joueurs dans le mode
exports('GetAllPlayersInMode', function()
    return CVC.Players.GetAllInMode()
end)

-- Forcer l'entrée d'un joueur dans le mode
exports('ForceEnterMode', function(source)
    if not CVC.Players.IsInMode(source) then
        CVC.Players.Add(source)
        TriggerClientEvent('cvc:client:enterGameMode', source)
        return true
    end
    return false
end)

-- Forcer la sortie d'un joueur du mode
exports('ForceExitMode', function(source)
    return CVC.Players.Kick(source)
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- EVENTS INTERNES
-- ═══════════════════════════════════════════════════════════════════════════

-- Event de notification client
RegisterNetEvent('cvc:client:notify', function(message)
    -- Cet event est déclenché par le serveur, pas besoin de le traiter ici
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- GESTION DES ERREURS
-- ═══════════════════════════════════════════════════════════════════════════

-- Capture des erreurs pour le debug
AddEventHandler('onResourceError', function(resource, error)
    if resource == GetCurrentResourceName() then
        print('^1[CVC] ERREUR: ' .. error .. '^0')
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- COMMANDES DE DEBUG (uniquement si Debug = true)
-- ═══════════════════════════════════════════════════════════════════════════

if Config.Debug then
    -- Afficher l'état du serveur
    RegisterCommand('cvc_status', function(source, args, rawCommand)
        local redCount, blueCount = CVC.Teams.GetCount()
        local totalPlayers = #CVC.Players.GetAllInMode()
        
        print('=== CVC Server Status ===')
        print('Total joueurs dans le mode: ' .. totalPlayers)
        print('Équipe Rouge: ' .. redCount)
        print('Équipe Bleue: ' .. blueCount)
        print('Routing Bucket: ' .. Config.RoutingBucket)
    end, true) -- restricted = true (console only)
    
    -- Forcer l'entrée d'un joueur
    RegisterCommand('cvc_forceenter', function(source, args, rawCommand)
        local targetId = tonumber(args[1])
        if targetId then
            exports[GetCurrentResourceName()]:ForceEnterMode(targetId)
            print('Joueur ' .. targetId .. ' forcé dans le mode')
        end
    end, true)
    
    -- Forcer la sortie d'un joueur
    RegisterCommand('cvc_forceexit', function(source, args, rawCommand)
        local targetId = tonumber(args[1])
        if targetId then
            exports[GetCurrentResourceName()]:ForceExitMode(targetId)
            print('Joueur ' .. targetId .. ' forcé hors du mode')
        end
    end, true)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- MESSAGE DE FIN DE CHARGEMENT
-- ═══════════════════════════════════════════════════════════════════════════

print('^2═══════════════════════════════════════════════════════════════^0')
print('^2  CONVOI CONTRE CONVOI - Serveur initialisé                    ^0')
print('^2═══════════════════════════════════════════════════════════════^0')
