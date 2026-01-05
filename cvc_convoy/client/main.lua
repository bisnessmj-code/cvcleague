--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                    CONVOI CONTRE CONVOI - MAIN CLIENT                     ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
]]

CVC = CVC or {}

-- ═══════════════════════════════════════════════════════════════════════════
-- ÉTAT DU JOUEUR
-- ═══════════════════════════════════════════════════════════════════════════

CVC.State = {
    inGameMode = false,
    currentTeam = nil,
    savedOutfit = nil,
    savedWeapons = {},
    originalBucket = 0
}

-- ═══════════════════════════════════════════════════════════════════════════
-- ENTRÉE DANS LE MODE DE JEU
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.EnterGameMode()
    if CVC.State.inGameMode then return end
    
    CVC.Utils.Debug('Entrée dans le mode de jeu')
    
    -- Sauvegarder la tenue actuelle
    CVC.State.savedOutfit = CVC.Utils.SaveCurrentOutfit()
    
    -- Marquer comme dans le mode
    CVC.State.inGameMode = true
    
    -- Téléporter vers le point de spawn de l'instance
    CVC.Utils.TeleportPlayer(Config.InstanceSpawnPoint)
    
    -- Démarrer la vérification des zones d'équipe
    CVC.Teams.StartZoneCheck()
    
    -- Notification
    CVC.Utils.Notify(Config.Notifications.enterMode)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SORTIE DU MODE DE JEU
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.ExitGameMode()
    if not CVC.State.inGameMode then return end
    
    CVC.Utils.Debug('Sortie du mode de jeu')
    
    -- Arrêter la vérification des zones
    CVC.Teams.StopZoneCheck()
    
    -- Restaurer la tenue originale
    if CVC.State.savedOutfit then
        CVC.Utils.RestoreOutfit(CVC.State.savedOutfit)
        CVC.State.savedOutfit = nil
    end
    
    -- Retirer toutes les armes
    CVC.Utils.RemoveAllWeapons()
    
    -- Reset de l'état
    CVC.State.inGameMode = false
    CVC.State.currentTeam = nil
    
    -- Téléporter vers le ped d'entrée
    local pedCoords = Config.PedLocation.coords
    CVC.Utils.TeleportPlayer(vector4(pedCoords.x, pedCoords.y, pedCoords.z, pedCoords.w))
    
    -- Notification
    CVC.Utils.Notify(Config.Notifications.exitMode)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- EVENTS SERVEUR
-- ═══════════════════════════════════════════════════════════════════════════

-- Confirmation d'entrée dans le mode
RegisterNetEvent('cvc:client:enterGameMode', function()
    CVC.EnterGameMode()
end)

-- Sortie du mode (kick ou fin de partie)
RegisterNetEvent('cvc:client:exitGameMode', function()
    CVC.ExitGameMode()
end)

-- Téléportation
RegisterNetEvent('cvc:client:teleport', function(coords)
    CVC.Utils.TeleportPlayer(coords)
    CVC.Utils.Notify(Config.Notifications.teleported)
end)

-- Heal & Armor
RegisterNetEvent('cvc:client:heal', function()
    CVC.Utils.RevivePlayer()
    CVC.Utils.Notify(Config.Notifications.healed)
end)

-- Donner une arme (via qs-inventory côté serveur, cette event est pour le feedback)
RegisterNetEvent('cvc:client:weaponReceived', function()
    CVC.Utils.Notify(Config.Notifications.weaponGiven)
end)

-- Annonce NUI
RegisterNetEvent('cvc:client:showAnnouncement', function(text)
    SendNUIMessage({
        action = 'showAnnouncement',
        text = text,
        duration = Config.Announcement.duration,
        position = Config.Announcement.position
    })
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- CALLBACKS NUI
-- ═══════════════════════════════════════════════════════════════════════════

RegisterNUICallback('closeAnnouncement', function(data, cb)
    cb('ok')
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- VÉRIFICATION DE L'ÉTAT AU DÉMARRAGE
-- ═══════════════════════════════════════════════════════════════════════════

CreateThread(function()
    Wait(1000)
    -- Demander au serveur l'état actuel du joueur
    TriggerServerEvent('cvc:server:requestState')
end)

-- Réponse du serveur avec l'état
RegisterNetEvent('cvc:client:syncState', function(state)
    if state.inGameMode then
        CVC.State.inGameMode = true
        CVC.State.currentTeam = state.team
        CVC.Teams.StartZoneCheck()
        
        if state.team then
            CVC.Teams.ApplyTeamOutfit(state.team)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- NETTOYAGE À LA DÉCONNEXION
-- ═══════════════════════════════════════════════════════════════════════════

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if CVC.State.inGameMode then
            CVC.ExitGameMode()
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- DEBUG COMMAND (dev only)
-- ═══════════════════════════════════════════════════════════════════════════

if Config.Debug then
    RegisterCommand('cvc_debug', function()
        print('=== CVC Debug Info ===')
        print('In Game Mode:', CVC.State.inGameMode)
        print('Current Team:', CVC.State.currentTeam or 'None')
        print('Has Saved Outfit:', CVC.State.savedOutfit ~= nil)
    end, false)
end
