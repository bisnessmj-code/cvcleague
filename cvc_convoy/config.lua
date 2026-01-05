--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                    CONVOI CONTRE CONVOI - CONFIGURATION                   ║
    ║                                                                           ║
    ║  Ce fichier contient TOUTE la configuration du mode de jeu.               ║
    ║  Aucune modification du code principal n'est nécessaire.                  ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
]]

Config = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- PARAMÈTRES GÉNÉRAUX
-- ═══════════════════════════════════════════════════════════════════════════

Config.Debug = true -- Activer les logs de debug
Config.RoutingBucket = 4000 -- ID du routing bucket pour l'instance

-- ═══════════════════════════════════════════════════════════════════════════
-- PED D'ENTRÉE
-- ═══════════════════════════════════════════════════════════════════════════

Config.PedLocation = {
    coords = vector4(-2189.485596, -360.448364, 13.104004, 294.803162),
    model = 's_m_y_blackops_01',
    frozen = true,
    invincible = true,
    blockevents = true,
    interaction = {
        distance = 3.0,
        key = 38, -- E
        label = "Appuyez sur ~INPUT_CONTEXT~ pour accéder au mode Convoi"
    }
}

-- ═══════════════════════════════════════════════════════════════════════════
-- ZONES D'ÉQUIPES
-- ═══════════════════════════════════════════════════════════════════════════

Config.TeamZones = {
    red = {
        coords = vector3(-1421.182373, -2821.081299, 431.114258),
        color = {r = 255, g = 0, b = 0, a = 200},
        radius = 2.0,
        label = "Équipe Rouge",
        blip = {
            sprite = 1,
            color = 1,
            scale = 0.8,
            display = true
        }
    },
    blue = {
        coords = vector3(-1425.112061, -2829.811035, 431.114258),
        color = {r = 0, g = 100, b = 255, a = 200},
        radius = 2.0,
        label = "Équipe Bleue",
        blip = {
            sprite = 1,
            color = 3,
            scale = 0.8,
            display = true
        }
    }
}

-- Position de spawn dans l'instance (entre les deux zones)
Config.InstanceSpawnPoint = vector4(-1423.0, -2825.0, 431.114258, 0.0)

-- ═══════════════════════════════════════════════════════════════════════════
-- TENUES PAR ÉQUIPE
-- ═══════════════════════════════════════════════════════════════════════════

Config.Outfits = {
    red = {
        male = {
            ['tshirt_1'] = 0,   ['tshirt_2'] = 2,
            ['torso_1'] = 3,    ['torso_2'] = 5,
            ['decals_1'] = 0,   ['decals_2'] = 0,
            ['arms'] = 14,
            ['pants_1'] = 3,    ['pants_2'] = 15,
            ['shoes_1'] = 26,   ['shoes_2'] = 1,
            ['helmet_1'] = 2,   ['helmet_2'] = 7,
            ['chain_1'] = 0,    ['chain_2'] = 0,
            ['ears_1'] = -1,    ['ears_2'] = 0,
            ['bags_1'] = 0,     ['bags_2'] = 0,
            ['mask_1'] = 4,     ['mask_2'] = 2,
            ['bproof_1'] = 0,   ['bproof_2'] = 0
        },
        female = {
            ['tshirt_1'] = 15,  ['tshirt_2'] = 0,
            ['torso_1'] = 369,  ['torso_2'] = 2,
            ['decals_1'] = 0,   ['decals_2'] = 0,
            ['arms'] = 0,
            ['pants_1'] = 23,   ['pants_2'] = 7,
            ['shoes_1'] = 11,   ['shoes_2'] = 2,
            ['helmet_1'] = 142, ['helmet_2'] = 3,
            ['chain_1'] = 0,    ['chain_2'] = 0,
            ['ears_1'] = -1,    ['ears_2'] = 0,
            ['bags_1'] = 0,     ['bags_2'] = 0,
            ['mask_1'] = 185,   ['mask_2'] = 0,
            ['bproof_1'] = 0,   ['bproof_2'] = 0
        }
    },
    blue = {
        male = {
            ['tshirt_1'] = 0,   ['tshirt_2'] = 0,
            ['torso_1'] = 3,    ['torso_2'] = 3,
            ['decals_1'] = 0,   ['decals_2'] = 0,
            ['arms'] = 14,
            ['pants_1'] = 3,    ['pants_2'] = 3,
            ['shoes_1'] = 26,   ['shoes_2'] = 4,
            ['helmet_1'] = 142, ['helmet_2'] = 4,
            ['chain_1'] = 0,    ['chain_2'] = 0,
            ['ears_1'] = -1,    ['ears_2'] = 0,
            ['bags_1'] = 0,     ['bags_2'] = 0,
            ['mask_1'] = 169,   ['mask_2'] = 8,
            ['bproof_1'] = 0,   ['bproof_2'] = 0
        },
        female = {
            ['tshirt_1'] = 3,   ['tshirt_2'] = 0,
            ['torso_1'] = 337,  ['torso_2'] = 6,
            ['decals_1'] = 0,   ['decals_2'] = 0,
            ['arms'] = 0,
            ['pants_1'] = 1,    ['pants_2'] = 7,
            ['shoes_1'] = 10,   ['shoes_2'] = 1,
            ['helmet_1'] = 160, ['helmet_2'] = 0,
            ['chain_1'] = 0,    ['chain_2'] = 0,
            ['ears_1'] = -1,    ['ears_2'] = 0,
            ['bags_1'] = 0,     ['bags_2'] = 0,
            ['mask_1'] = 169,   ['mask_2'] = 8,
            ['bproof_1'] = 0,   ['bproof_2'] = 0
        }
    }
}

-- ═══════════════════════════════════════════════════════════════════════════
-- ARMES DE DÉPART
-- ═══════════════════════════════════════════════════════════════════════════

Config.StartWeapon = {
    weapon = 'WEAPON_PISTOL50',
    ammo = 300,
    ammoType = 'pistol_ammo'
}

-- Arme pour la commande /givecallall
Config.GiveAllWeapon = {
    weapon = 'WEAPON_PISTOL50',
    ammo = 350,
    ammoType = 'pistol_ammo'
}

-- ═══════════════════════════════════════════════════════════════════════════
-- VÉHICULES DU CONVOI - CONFIGURATION INDIVIDUELLE PAR VÉHICULE
-- ═══════════════════════════════════════════════════════════════════════════

--[[
    NOUVELLE STRUCTURE :
    Chaque véhicule est maintenant configuré individuellement avec :
    - model : Modèle du véhicule
    - color : Couleur primaire et secondaire
    - coords : Position et rotation (vector4)
    
    EXEMPLE D'UTILISATION :
    {
        model = 'revolter',
        color = {primary = 27, secondary = 27},
        coords = vector4(x, y, z, heading)
    }
    
    AVANTAGES :
    - Chaque véhicule peut avoir un modèle différent
    - Chaque véhicule peut avoir sa propre couleur
    - Facile d'ajouter/retirer des véhicules
    - Configuration claire et lisible
]]

Config.Vehicles = {
    -- ═══════════════════════════════════════════════════════════════════════
    -- ÉQUIPE ROUGE - 7 VÉHICULES
    -- ═══════════════════════════════════════════════════════════════════════
    red = {
        -- Véhicule 1 (Leader)
        {
            model = 'jubilee',
            color = {primary = 111, secondary = 111}, -- Rouge
            coords = vector4(1700.795654, 3262.536377, 40.586060, 283.464569)
        },
        -- Véhicule 2
        {
            model = 'rebla',
            color = {primary = 111, secondary = 111},
            coords = vector4(1699.569214, 3265.767090, 40.602905, 286.299194)
        },
        -- Véhicule 3
        {
            model = 'revolter',
            color = {primary = 111, secondary = 111},
            coords = vector4(1692.698853, 3264.065918, 40.400757, 286.299194)
        },
        -- Véhicule 4
        {
            model = 'rhinehart',
            color = {primary = 111, secondary = 111},
            coords = vector4(1693.476929, 3261.032959, 40.367065, 283.464569)
        },
        -- Véhicule 5
        {
            model = 'buffalo',
            color = {primary = 111, secondary = 111},
            coords = vector4(1684.707642, 3262.021973, 40.265991, 289.133850)
        },
        -- Véhicule 6
        {
            model = 'felon',
            color = {primary = 111, secondary = 111},
            coords = vector4(1685.221924, 3259.147217, 40.333374, 286.299194)
        },
        -- Véhicule 7
        {
            model = 'jugular',
            color = {primary = 111, secondary = 111},
            coords = vector4(1677.758301, 3258.210938, 40.232178, 283.464569)
        },
        -- Véhicule 8
        {
            model = 'bf400',
            color = {primary = 111, secondary = 111},
            coords = vector4(1671.481323, 3256.153809, 40.164795, 291.968506)
        }
        
    },
    
    -- ═══════════════════════════════════════════════════════════════════════
    -- ÉQUIPE BLEUE - 7 VÉHICULES
    -- ═══════════════════════════════════════════════════════════════════════
    blue = {
        -- Véhicule 1 (Leader)
        {
            model = 'jubilee',
            color = {primary = 0, secondary = 0}, -- Bleu
            coords = vector4(1704.382446, 3248.083496, 40.484985, 289.133850)
        },
        -- Véhicule 2
        {
            model = 'rebla',
            color = {primary = 0, secondary = 0},
            coords = vector4(1702.997803, 3251.156006, 40.468140, 283.464569)
        },
        -- Véhicule 3
        {
            model = 'revolter',
            color = {primary = 0, secondary = 0},
            coords = vector4(1695.758301, 3249.230713, 40.417603, 286.299194)
        },
        -- Véhicule 4
        {
            model = 'rhinehart',
            color = {primary = 0, secondary = 0},
            coords = vector4(1696.496704, 3246.065918, 40.417603, 286.299194)
        },
        -- Véhicule 5
        {
            model = 'buffalo',
            color = {primary = 0, secondary = 0},
            coords = vector4(1688.373657, 3247.054932, 40.350220, 286.299194)
        },
        -- Véhicule 6
        {
            model = 'felon',
            color = {primary = 0, secondary = 0},
            coords = vector4(1689.217529, 3244.312012, 40.350220, 289.133850)
        },
        -- Véhicule 7
        {
            model = 'jugular',
            color = {primary = 0, secondary = 0},
            coords = vector4(1682.518677, 3243.903320, 40.299683, 283.464569)
        },
        -- Véhicule 8
        {
            model = 'bf400',
            color = {primary = 0, secondary = 0},
            coords = vector4(1674.553833, 3241.859375, 40.181641, 289.13385)
        }
    }
}

--[[
    EXEMPLE DE CONFIGURATION AVEC VÉHICULES VARIÉS :
    
    Config.Vehicles = {
        red = {
            -- Leader : Insurgent blindé
            {
                model = 'insurgent',
                color = {primary = 27, secondary = 0},
                coords = vector4(1700.795654, 3262.536377, 40.586060, 283.464569)
            },
            -- Escorte 1 : Revolter rapide
            {
                model = 'revolter',
                color = {primary = 27, secondary = 27},
                coords = vector4(1699.569214, 3265.767090, 40.602905, 286.299194)
            },
            -- Escorte 2 : Schafter V12 armé
            {
                model = 'schafter3',
                color = {primary = 27, secondary = 0},
                coords = vector4(1692.698853, 3264.065918, 40.400757, 286.299194)
            },
            -- Support : Rumpo blindé
            {
                model = 'rumpo3',
                color = {primary = 27, secondary = 27},
                coords = vector4(1693.476929, 3261.032959, 40.367065, 283.464569)
            },
            -- Arrière-garde : Sultan RS
            {
                model = 'sultanrs',
                color = {primary = 27, secondary = 0},
                coords = vector4(1684.707642, 3262.021973, 40.265991, 289.133850)
            },
            -- Éclaireur : Kuruma blindé
            {
                model = 'kuruma2',
                color = {primary = 27, secondary = 27},
                coords = vector4(1685.221924, 3259.147217, 40.333374, 286.299194)
            },
            -- Reconnaissance : Baller
            {
                model = 'baller',
                color = {primary = 27, secondary = 0},
                coords = vector4(1677.758301, 3258.210938, 40.232178, 283.464569)
            }
        },
        blue = {
            -- ... même structure pour l'équipe bleue
        }
    }
]]

-- ═══════════════════════════════════════════════════════════════════════════
-- PERMISSIONS & GROUPES
-- ═══════════════════════════════════════════════════════════════════════════

Config.Permissions = {
    -- Groupes autorisés pour les commandes admin
    allowedGroups = {
        'admin',
        'superadmin',
        'organisateur',
        'responsable'
    },
    
    -- Permissions par commande (true = tout le monde autorisé parmi les groupes)
    commands = {
        cvchealall = true,
        cvcequipe = true,
        givecallall = true,
        cvctpall = true,
        cvctpequipe = true,
        cvcrepairall = true,
        cvcspawnvehicule = true,
        cvckickall = true,
        cvckick = true,
        cvcannonce = true
    }
}

-- ═══════════════════════════════════════════════════════════════════════════
-- RAYONS PAR DÉFAUT POUR LES COMMANDES
-- ═══════════════════════════════════════════════════════════════════════════

Config.DefaultRadius = {
    healall = 50.0,
    givecallall = 50.0,
    repairall = 50.0
}

-- ═══════════════════════════════════════════════════════════════════════════
-- TÉLÉPORTATIONS
-- ═══════════════════════════════════════════════════════════════════════════

Config.Teleports = {
    -- Position de TP pour /cvctpall
    all = vector4(-1423.0, -2825.0, 431.114258, 0.0),
    
    -- Position de TP par équipe pour /cvctpequipe
    red = vector4(-1421.182373, -2821.081299, 431.114258, 180.0),
    blue = vector4(-1425.112061, -2829.811035, 431.114258, 0.0)
}

-- ═══════════════════════════════════════════════════════════════════════════
-- NOTIFICATIONS & MESSAGES
-- ═══════════════════════════════════════════════════════════════════════════

Config.Notifications = {
    -- Messages d'entrée/sortie
    enterMode = "Vous êtes entré dans le mode Convoi contre Convoi",
    exitMode = "Vous avez quitté le mode Convoi contre Convoi",
    
    -- Messages d'équipe
    joinedRed = "Vous avez rejoint l'~r~Équipe Rouge~s~",
    joinedBlue = "Vous avez rejoint l'~b~Équipe Bleue~s~",
    alreadyInTeam = "Vous êtes déjà dans une équipe",
    
    -- Messages de commandes
    healed = "Vous avez été soigné et votre armure restaurée",
    weaponGiven = "Vous avez reçu un Pistol .50 avec des munitions",
    vehicleRepaired = "Les véhicules ont été réparés",
    vehiclesSpawned = "Les véhicules du convoi ont été spawnés",
    teleported = "Vous avez été téléporté",
    kicked = "Vous avez été expulsé du mode de jeu",
    
    -- Messages d'erreur
    noPermission = "Vous n'avez pas la permission d'utiliser cette commande",
    notInMode = "Vous n'êtes pas dans le mode de jeu",
    invalidTeam = "Équipe invalide. Utilisez 'rouge' ou 'bleu'",
    playerNotFound = "Joueur non trouvé",
    
    -- Messages admin
    kickedAll = "Tous les joueurs ont été expulsés du mode",
    healedPlayers = "joueurs ont été soignés",
    repairedVehicles = "véhicules ont été réparés",
    givenWeapons = "joueurs ont reçu des armes"
}

-- ═══════════════════════════════════════════════════════════════════════════
-- INTERFACE NUI (Annonces)
-- ═══════════════════════════════════════════════════════════════════════════

Config.Announcement = {
    duration = 8000, -- Durée d'affichage en ms
    fadeIn = 500,    -- Durée du fade in en ms
    fadeOut = 500,   -- Durée du fade out en ms
    position = 'top' -- Position: 'top', 'center', 'bottom'
}