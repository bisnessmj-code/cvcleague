--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                    CONVOI CONTRE CONVOI - CLIENT UTILS                    ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
]]

CVC = CVC or {}
CVC.Utils = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- DEBUG & LOGGING
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Utils.Debug(message, ...)
    if Config.Debug then
        print(string.format('[CVC-Client] ' .. message, ...))
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- NOTIFICATIONS
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Utils.Notify(message, type)
    type = type or 'info'
    
    -- Utilisation de la notification native GTA
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, true)
end

function CVC.Utils.DrawText3D(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry('STRING')
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- MARQUEURS & ZONES
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Utils.DrawMarker(coords, radius, color)
    DrawMarker(
        1,                          -- Type (cercle)
        coords.x, coords.y, coords.z - 1.0,
        0.0, 0.0, 0.0,              -- Direction
        0.0, 0.0, 0.0,              -- Rotation
        radius * 2, radius * 2, 1.0, -- Scale
        color.r, color.g, color.b, color.a,
        false, false, 2, false, nil, nil, false
    )
end

function CVC.Utils.IsInZone(playerCoords, zoneCoords, radius)
    return #(playerCoords - zoneCoords) <= radius
end

-- ═══════════════════════════════════════════════════════════════════════════
-- PED & PLAYER UTILITIES
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Utils.GetPlayerGender()
    local ped = PlayerPedId()
    local model = GetEntityModel(ped)
    
    if model == GetHashKey('mp_m_freemode_01') then
        return 'male'
    else
        return 'female'
    end
end

function CVC.Utils.LoadModel(model)
    local hash = type(model) == 'string' and GetHashKey(model) or model
    
    if not IsModelValid(hash) then
        CVC.Utils.Debug('Modèle invalide: %s', model)
        return false
    end
    
    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end
    
    return HasModelLoaded(hash)
end

function CVC.Utils.UnloadModel(model)
    local hash = type(model) == 'string' and GetHashKey(model) or model
    SetModelAsNoLongerNeeded(hash)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- TENUES (OUTFITS)
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Utils.SaveCurrentOutfit()
    local ped = PlayerPedId()
    local outfit = {}
    
    -- Sauvegarde de tous les composants
    for i = 0, 11 do
        outfit['component_' .. i] = {
            drawable = GetPedDrawableVariation(ped, i),
            texture = GetPedTextureVariation(ped, i)
        }
    end
    
    -- Sauvegarde des props
    for i = 0, 9 do
        outfit['prop_' .. i] = {
            drawable = GetPedPropIndex(ped, i),
            texture = GetPedPropTextureIndex(ped, i)
        }
    end
    
    return outfit
end

function CVC.Utils.ApplyOutfit(outfit)
    local ped = PlayerPedId()
    
    -- Mapping des clés de config vers les composants GTA
    local componentMap = {
        ['tshirt_1'] = 8, ['tshirt_2'] = 8,
        ['torso_1'] = 11, ['torso_2'] = 11,
        ['decals_1'] = 10, ['decals_2'] = 10,
        ['arms'] = 3,
        ['pants_1'] = 4, ['pants_2'] = 4,
        ['shoes_1'] = 6, ['shoes_2'] = 6,
        ['chain_1'] = 7, ['chain_2'] = 7,
        ['bags_1'] = 5, ['bags_2'] = 5,
        ['bproof_1'] = 9, ['bproof_2'] = 9
    }
    
    local propMap = {
        ['helmet_1'] = 0, ['helmet_2'] = 0,
        ['ears_1'] = 2, ['ears_2'] = 2,
        ['mask_1'] = 1, ['mask_2'] = 1 -- Mask est en fait un component (1)
    }
    
    -- Application des composants
    if outfit['arms'] then
        SetPedComponentVariation(ped, 3, outfit['arms'], 0, 0)
    end
    
    if outfit['tshirt_1'] then
        SetPedComponentVariation(ped, 8, outfit['tshirt_1'], outfit['tshirt_2'] or 0, 0)
    end
    
    if outfit['torso_1'] then
        SetPedComponentVariation(ped, 11, outfit['torso_1'], outfit['torso_2'] or 0, 0)
    end
    
    if outfit['decals_1'] then
        SetPedComponentVariation(ped, 10, outfit['decals_1'], outfit['decals_2'] or 0, 0)
    end
    
    if outfit['pants_1'] then
        SetPedComponentVariation(ped, 4, outfit['pants_1'], outfit['pants_2'] or 0, 0)
    end
    
    if outfit['shoes_1'] then
        SetPedComponentVariation(ped, 6, outfit['shoes_1'], outfit['shoes_2'] or 0, 0)
    end
    
    if outfit['chain_1'] then
        SetPedComponentVariation(ped, 7, outfit['chain_1'], outfit['chain_2'] or 0, 0)
    end
    
    if outfit['bags_1'] then
        SetPedComponentVariation(ped, 5, outfit['bags_1'], outfit['bags_2'] or 0, 0)
    end
    
    if outfit['bproof_1'] then
        SetPedComponentVariation(ped, 9, outfit['bproof_1'], outfit['bproof_2'] or 0, 0)
    end
    
    -- Mask est le composant 1
    if outfit['mask_1'] then
        SetPedComponentVariation(ped, 1, outfit['mask_1'], outfit['mask_2'] or 0, 0)
    end
    
    -- Props (helmet, ears)
    if outfit['helmet_1'] then
        if outfit['helmet_1'] == -1 then
            ClearPedProp(ped, 0)
        else
            SetPedPropIndex(ped, 0, outfit['helmet_1'], outfit['helmet_2'] or 0, true)
        end
    end
    
    if outfit['ears_1'] then
        if outfit['ears_1'] == -1 then
            ClearPedProp(ped, 2)
        else
            SetPedPropIndex(ped, 2, outfit['ears_1'], outfit['ears_2'] or 0, true)
        end
    end
end

function CVC.Utils.RestoreOutfit(savedOutfit)
    local ped = PlayerPedId()
    
    -- Restauration des composants
    for i = 0, 11 do
        local comp = savedOutfit['component_' .. i]
        if comp then
            SetPedComponentVariation(ped, i, comp.drawable, comp.texture, 0)
        end
    end
    
    -- Restauration des props
    for i = 0, 9 do
        local prop = savedOutfit['prop_' .. i]
        if prop then
            if prop.drawable == -1 then
                ClearPedProp(ped, i)
            else
                SetPedPropIndex(ped, i, prop.drawable, prop.texture, true)
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ARMES
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Utils.RemoveAllWeapons()
    local ped = PlayerPedId()
    RemoveAllPedWeapons(ped, true)
end

function CVC.Utils.GiveWeapon(weapon, ammo)
    local ped = PlayerPedId()
    local weaponHash = GetHashKey(weapon)
    GiveWeaponToPed(ped, weaponHash, ammo, false, true)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SANTÉ & ARMURE - MODIFIÉ
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Utils.HealPlayer()
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    SetPedArmour(ped, 100)
end

-- FONCTION CORRIGÉE : Réanimation complète du joueur
function CVC.Utils.RevivePlayer()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    -- Si le joueur est mort, le réanimer
    if IsEntityDead(ped) then
        -- Méthode 1 : NetworkResurrectLocalPlayer (recommandée pour FiveM)
        NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
        Wait(100)
    end
    
    -- Si le joueur est ragdoll (au sol mais pas mort)
    if IsPedRagdoll(ped) then
        -- Forcer le joueur à se relever
        SetPedToRagdoll(ped, 0, 0, 0, false, false, false)
    end
    
    -- Réinitialiser l'état du ped
    ClearPedTasksImmediately(ped)
    ClearPedSecondaryTask(ped)
    
    -- Donner la santé et l'armure complètes
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    SetPedArmour(ped, 100)
    
    -- S'assurer que le joueur est debout et conscient
    SetEntityInvincible(ped, false)
    ResetPedMovementClipset(ped, 0)
    ResetPedWeaponMovementClipset(ped)
    ResetPedStrafeClipset(ped)
    
    CVC.Utils.Debug('Joueur réanimé avec succès')
end

-- ═══════════════════════════════════════════════════════════════════════════
-- VÉHICULES
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Utils.SpawnVehicle(model, coords, color)
    if not CVC.Utils.LoadModel(model) then
        CVC.Utils.Debug('Impossible de charger le modèle: %s', model)
        return nil
    end
    
    local vehicle = CreateVehicle(
        GetHashKey(model),
        coords.x, coords.y, coords.z, coords.w,
        true, false
    )
    
    if color then
        SetVehicleColours(vehicle, color.primary, color.secondary)
    end
    
    SetVehicleOnGroundProperly(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    
    CVC.Utils.UnloadModel(model)
    
    return vehicle
end

function CVC.Utils.RepairVehicle(vehicle)
    if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
        SetVehicleFixed(vehicle)
        SetVehicleEngineOn(vehicle, true, true, false)
        SetVehicleDirtLevel(vehicle, 0.0)
    end
end

function CVC.Utils.DeleteVehicle(vehicle)
    if DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- TÉLÉPORTATION
-- ═══════════════════════════════════════════════════════════════════════════

function CVC.Utils.TeleportPlayer(coords)
    local ped = PlayerPedId()
    
    -- Fade out
    DoScreenFadeOut(500)
    Wait(500)
    
    -- Téléportation
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(ped, coords.w or 0.0)
    
    -- Fade in
    Wait(200)
    DoScreenFadeIn(500)
end