--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                    CONVOI CONTRE CONVOI - GESTION ÉQUIPES (CLIENT)        ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
]]

CVC = CVC or {}
CVC.Teams = {}

local teamZonesActive = false
local lastZoneCheck = nil

-- ═══════════════════════════════════════════════════════════════════════════
-- GESTION DES ZONES D'ÉQUIPE
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Teams.StartZoneCheck()
    if teamZonesActive then return end
    teamZonesActive = true
    
    CVC.Utils.Debug('Démarrage de la vérification des zones d\'équipe')
    
    CreateThread(function()
        while teamZonesActive and CVC.State.inGameMode do
            local sleep = 0
            local playerCoords = GetEntityCoords(PlayerPedId())
            local currentZone = nil
            
            -- Dessiner les marqueurs des zones
            for teamName, zone in pairs(Config.TeamZones) do
                CVC.Utils.DrawMarker(zone.coords, zone.radius, zone.color)
                
                -- Afficher le label au-dessus de la zone
                CVC.Utils.DrawText3D(
                    vector3(zone.coords.x, zone.coords.y, zone.coords.z + 0.5),
                    zone.label
                )
                
                -- Vérifier si le joueur est dans la zone
                if CVC.Utils.IsInZone(playerCoords, zone.coords, zone.radius) then
                    currentZone = teamName
                end
            end
            
            -- Si le joueur entre dans une nouvelle zone et n'a pas encore d'équipe
            if currentZone and currentZone ~= lastZoneCheck and not CVC.State.currentTeam then
                lastZoneCheck = currentZone
                CVC.Utils.Debug('Joueur entré dans la zone: %s', currentZone)
                TriggerServerEvent('cvc:server:joinTeam', currentZone)
            elseif not currentZone then
                lastZoneCheck = nil
            end
            
            Wait(sleep)
        end
        
        CVC.Utils.Debug('Arrêt de la vérification des zones d\'équipe')
    end)
end

function CVC.Teams.StopZoneCheck()
    teamZonesActive = false
    lastZoneCheck = nil
end

-- ═══════════════════════════════════════════════════════════════════════════
-- APPLICATION DE LA TENUE D'ÉQUIPE
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Teams.ApplyTeamOutfit(team)
    if not team or not Config.Outfits[team] then
        CVC.Utils.Debug('Équipe invalide pour la tenue: %s', tostring(team))
        return
    end
    
    local gender = CVC.Utils.GetPlayerGender()
    local outfit = Config.Outfits[team][gender]
    
    if not outfit then
        CVC.Utils.Debug('Pas de tenue trouvée pour: %s/%s', team, gender)
        return
    end
    
    CVC.Utils.Debug('Application de la tenue: %s/%s', team, gender)
    CVC.Utils.ApplyOutfit(outfit)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- EVENTS
-- ═══════════════════════════════════════════════════════════════════════════

-- Confirmation de l'équipe rejointe
RegisterNetEvent('cvc:client:teamJoined', function(team)
    CVC.State.currentTeam = team
    CVC.Teams.ApplyTeamOutfit(team)
    
    local notification = team == 'red' and Config.Notifications.joinedRed or Config.Notifications.joinedBlue
    CVC.Utils.Notify(notification)
    
    CVC.Utils.Debug('Équipe rejointe: %s', team)
end)

-- Notification déjà dans une équipe
RegisterNetEvent('cvc:client:alreadyInTeam', function()
    CVC.Utils.Notify(Config.Notifications.alreadyInTeam)
end)

-- Mise à jour du compteur d'équipe (pour l'admin)
RegisterNetEvent('cvc:client:teamCount', function(redCount, blueCount)
    local message = string.format(
        "~r~Équipe Rouge: %d~s~ | ~b~Équipe Bleue: %d~s~",
        redCount, blueCount
    )
    CVC.Utils.Notify(message)
end)
