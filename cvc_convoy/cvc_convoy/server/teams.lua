--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                    CONVOI CONTRE CONVOI - GESTION ÉQUIPES (SERVER)        ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
]]

CVC = CVC or {}
CVC.Players = {}
CVC.Teams = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- DONNÉES DES JOUEURS
-- ═══════════════════════════════════════════════════════════════════════════

local playerData = {} -- [source] = { inGameMode = bool, team = string }

-- ═══════════════════════════════════════════════════════════════════════════
-- GESTION DES JOUEURS
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Players.Add(source)
    playerData[source] = {
        inGameMode = true,
        team = nil
    }
    
    -- Déplacer vers le routing bucket du mode
    CVC.Utils.SetPlayerBucket(source, Config.RoutingBucket)
    
    CVC.Utils.Debug('Joueur %d ajouté au mode de jeu', source)
end

function CVC.Players.Remove(source)
    if playerData[source] then
        -- Retirer du routing bucket
        CVC.Utils.ResetPlayerBucket(source)
        
        playerData[source] = nil
        CVC.Utils.Debug('Joueur %d retiré du mode de jeu', source)
    end
end

function CVC.Players.IsInMode(source)
    return playerData[source] ~= nil and playerData[source].inGameMode
end

function CVC.Players.GetData(source)
    return playerData[source]
end

function CVC.Players.GetAllInMode()
    local players = {}
    for source, data in pairs(playerData) do
        if data.inGameMode then
            table.insert(players, source)
        end
    end
    return players
end

-- ═══════════════════════════════════════════════════════════════════════════
-- GESTION DES ÉQUIPES
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Teams.Join(source, team)
    if not playerData[source] then
        CVC.Utils.Debug('Joueur %d n\'est pas dans le mode', source)
        return false
    end
    
    if playerData[source].team then
        TriggerClientEvent('cvc:client:alreadyInTeam', source)
        return false
    end
    
    if team ~= 'red' and team ~= 'blue' then
        CVC.Utils.Debug('Équipe invalide: %s', team)
        return false
    end
    
    playerData[source].team = team
    TriggerClientEvent('cvc:client:teamJoined', source, team)
    
    CVC.Utils.Debug('Joueur %d a rejoint l\'équipe %s', source, team)
    return true
end

function CVC.Teams.GetPlayerTeam(source)
    if playerData[source] then
        return playerData[source].team
    end
    return nil
end

function CVC.Teams.GetTeamPlayers(team)
    local players = {}
    for source, data in pairs(playerData) do
        if data.team == team then
            table.insert(players, source)
        end
    end
    return players
end

function CVC.Teams.GetCount()
    local redCount = 0
    local blueCount = 0
    
    for _, data in pairs(playerData) do
        if data.team == 'red' then
            redCount = redCount + 1
        elseif data.team == 'blue' then
            blueCount = blueCount + 1
        end
    end
    
    return redCount, blueCount
end

function CVC.Teams.ResetPlayer(source)
    if playerData[source] then
        playerData[source].team = nil
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- NETTOYAGE COMPLET
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Players.KickAll()
    local kicked = 0
    
    for source, _ in pairs(playerData) do
        TriggerClientEvent('cvc:client:exitGameMode', source)
        CVC.Utils.ResetPlayerBucket(source)
        kicked = kicked + 1
    end
    
    playerData = {}
    CVC.Utils.Log('Tous les joueurs ont été expulsés du mode (%d joueurs)', kicked)
    
    return kicked
end

function CVC.Players.Kick(source)
    if playerData[source] then
        TriggerClientEvent('cvc:client:exitGameMode', source)
        CVC.Utils.ResetPlayerBucket(source)
        playerData[source] = nil
        CVC.Utils.Debug('Joueur %d expulsé du mode', source)
        return true
    end
    return false
end

-- ═══════════════════════════════════════════════════════════════════════════
-- EVENTS
-- ═══════════════════════════════════════════════════════════════════════════

-- Entrée dans le mode de jeu
RegisterNetEvent('cvc:server:enterGameMode', function()
    local source = source
    
    if CVC.Players.IsInMode(source) then
        CVC.Utils.Debug('Joueur %d déjà dans le mode', source)
        return
    end
    
    CVC.Players.Add(source)
    TriggerClientEvent('cvc:client:enterGameMode', source)
end)

-- Rejoindre une équipe
RegisterNetEvent('cvc:server:joinTeam', function(team)
    local source = source
    CVC.Teams.Join(source, team)
end)

-- Demande d'état (reconnexion)
RegisterNetEvent('cvc:server:requestState', function()
    local source = source
    local data = CVC.Players.GetData(source)
    
    if data then
        TriggerClientEvent('cvc:client:syncState', source, {
            inGameMode = data.inGameMode,
            team = data.team
        })
    else
        TriggerClientEvent('cvc:client:syncState', source, {
            inGameMode = false,
            team = nil
        })
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- NETTOYAGE À LA DÉCONNEXION
-- ═══════════════════════════════════════════════════════════════════════════

AddEventHandler('playerDropped', function(reason)
    local source = source
    CVC.Players.Remove(source)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        -- Kick tous les joueurs proprement
        CVC.Players.KickAll()
    end
end)
