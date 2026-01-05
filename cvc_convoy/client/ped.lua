--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                    CONVOI CONTRE CONVOI - PED D'ENTRÉE                    ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
]]

CVC = CVC or {}
CVC.Ped = {}

local entryPed = nil
local pedCreated = false

-- ═══════════════════════════════════════════════════════════════════════════
-- CRÉATION DU PED
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Ped.Create()
    if pedCreated then return end
    
    local pedConfig = Config.PedLocation
    
    -- Chargement du modèle
    if not CVC.Utils.LoadModel(pedConfig.model) then
        CVC.Utils.Debug('Erreur: Impossible de charger le modèle du ped')
        return
    end
    
    -- Création du ped
    entryPed = CreatePed(
        4, -- Type
        GetHashKey(pedConfig.model),
        pedConfig.coords.x,
        pedConfig.coords.y,
        pedConfig.coords.z,
        pedConfig.coords.w,
        false, -- Network
        true   -- Mission entity
    )
    
    if not DoesEntityExist(entryPed) then
        CVC.Utils.Debug('Erreur: Le ped n\'a pas été créé')
        return
    end
    
    -- Configuration du ped
    if pedConfig.frozen then
        FreezeEntityPosition(entryPed, true)
    end
    
    if pedConfig.invincible then
        SetEntityInvincible(entryPed, true)
    end
    
    if pedConfig.blockevents then
        SetBlockingOfNonTemporaryEvents(entryPed, true)
    end
    
    -- Désactivation de l'IA
    SetPedFleeAttributes(entryPed, 0, false)
    SetPedCombatAttributes(entryPed, 17, true)
    SetPedAlertness(entryPed, 0)
    
    -- Libération du modèle
    CVC.Utils.UnloadModel(pedConfig.model)
    
    pedCreated = true
    CVC.Utils.Debug('Ped d\'entrée créé avec succès')
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SUPPRESSION DU PED
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Ped.Delete()
    if entryPed and DoesEntityExist(entryPed) then
        DeleteEntity(entryPed)
        entryPed = nil
        pedCreated = false
        CVC.Utils.Debug('Ped d\'entrée supprimé')
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- VÉRIFICATION PROXIMITÉ
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Ped.IsNearby()
    if not pedCreated or not entryPed then return false end
    
    local playerCoords = GetEntityCoords(PlayerPedId())
    local pedCoords = Config.PedLocation.coords
    local distance = #(playerCoords - vector3(pedCoords.x, pedCoords.y, pedCoords.z))
    
    return distance <= Config.PedLocation.interaction.distance
end

function CVC.Ped.GetDistance()
    if not pedCreated or not entryPed then return 999.0 end
    
    local playerCoords = GetEntityCoords(PlayerPedId())
    local pedCoords = Config.PedLocation.coords
    
    return #(playerCoords - vector3(pedCoords.x, pedCoords.y, pedCoords.z))
end

-- ═══════════════════════════════════════════════════════════════════════════
-- THREAD D'INTERACTION
-- ═══════════════════════════════════════════════════════════════════════════

CreateThread(function()
    -- Attendre que tout soit chargé
    Wait(2000)
    
    -- Créer le ped
    CVC.Ped.Create()
    
    -- Boucle d'interaction optimisée
    while true do
        local sleep = 1000 -- Sleep par défaut (loin du ped)
        
        -- Vérifier si on est dans le mode de jeu
        if not CVC.State.inGameMode then
            local distance = CVC.Ped.GetDistance()
            
            if distance <= 50.0 then
                sleep = 0 -- Proche, on vérifie plus souvent
                
                if distance <= Config.PedLocation.interaction.distance then
                    -- Afficher le texte d'interaction
                    local pedCoords = Config.PedLocation.coords
                    CVC.Utils.DrawText3D(
                        vector3(pedCoords.x, pedCoords.y, pedCoords.z + 1.0),
                        Config.PedLocation.interaction.label
                    )
                    
                    -- Vérifier l'appui sur la touche
                    if IsControlJustReleased(0, Config.PedLocation.interaction.key) then
                        CVC.Utils.Debug('Interaction avec le ped - Entrée dans le mode')
                        TriggerServerEvent('cvc:server:enterGameMode')
                    end
                end
            elseif distance <= 100.0 then
                sleep = 500 -- Distance moyenne
            end
        end
        
        Wait(sleep)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- NETTOYAGE À LA DÉCONNEXION
-- ═══════════════════════════════════════════════════════════════════════════

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        CVC.Ped.Delete()
    end
end)
