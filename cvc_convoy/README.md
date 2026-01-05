# 🚗 Convoi contre Convoi - Mode de Jeu FiveM

Un mode de jeu instancié pour FiveM permettant d'organiser des affrontements entre deux équipes (Rouge vs Bleue) avec gestion complète des véhicules, tenues, armes et instances.

---

## 📋 Table des matières

- [Fonctionnalités](#-fonctionnalités)
- [Prérequis](#-prérequis)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Commandes](#-commandes)
- [Permissions](#-permissions)
- [Structure des fichiers](#-structure-des-fichiers)
- [API / Exports](#-api--exports)
- [FAQ](#-faq)

---

## ✨ Fonctionnalités

### Système d'instance
- ✅ Routing bucket dédié pour isoler les joueurs du mode
- ✅ Les joueurs hors mode ne voient pas ceux en mode
- ✅ Nettoyage automatique à la sortie

### Gestion des équipes
- ✅ Zones de sélection visuelles (cercles au sol)
- ✅ Tenues automatiques par équipe et par sexe
- ✅ Compteur de joueurs par équipe

### Véhicules
- ✅ Spawn de 14 véhicules (7 par équipe)
- ✅ Positions et couleurs configurables
- ✅ Réparation en masse

### Armes
- ✅ Intégration **qs-inventory** uniquement
- ✅ Distribution d'armes via commandes admin

### Interface
- ✅ Système d'annonces HTML/CSS/JS
- ✅ Notifications en jeu
- ✅ Animations fluides

---

## 📦 Prérequis

| Ressource | Version | Obligatoire |
|-----------|---------|-------------|
| [qs-inventory](https://github.com/quasar-store/qs-inventory) | Dernière | ✅ Oui |
| ESX ou QBCore | Dernière | ❌ Non (pour permissions) |
| OneSync | Infinity | ✅ Oui |

---

## 🔧 Installation

1. **Télécharger** le dossier `cvc_convoy`

2. **Placer** dans votre dossier `resources`

3. **Ajouter** dans votre `server.cfg` :
```cfg
ensure qs-inventory
ensure cvc_convoy
```

4. **Configurer** les permissions ACE (optionnel) :
```cfg
add_ace group.admin cvc.admin allow
add_ace group.moderator cvc.organisateur allow
add_ace group.staff cvc.responsable allow
```

5. **Redémarrer** votre serveur

---

## ⚙️ Configuration

Toute la configuration se fait dans le fichier `config.lua`. **Aucune modification du code principal n'est nécessaire.**

### Paramètres généraux

```lua
Config.Debug = false          -- Activer les logs de debug
Config.RoutingBucket = 100    -- ID du routing bucket
```

### Ped d'entrée

```lua
Config.PedLocation = {
    coords = vector4(-2658.369141, -765.599976, 5.993408, 85.039368),
    model = 's_m_y_blackops_01',
    frozen = true,
    invincible = true,
    blockevents = true,
    interaction = {
        distance = 3.0,
        key = 38, -- Touche E
        label = "Appuyez sur ~INPUT_CONTEXT~ pour accéder au mode Convoi"
    }
}
```

### Zones d'équipes

```lua
Config.TeamZones = {
    red = {
        coords = vector3(-1421.182373, -2821.081299, 431.114258),
        color = {r = 255, g = 0, b = 0, a = 200},
        radius = 2.0,
        label = "Équipe Rouge"
    },
    blue = {
        coords = vector3(-1425.112061, -2829.811035, 431.114258),
        color = {r = 0, g = 100, b = 255, a = 200},
        radius = 2.0,
        label = "Équipe Bleue"
    }
}
```

### Véhicules

```lua
Config.Vehicles = {
    red = {
        model = 'revolter',
        color = {primary = 27, secondary = 27},
        spawns = {
            vector4(1700.795654, 3262.536377, 40.586060, 283.464569),
            -- ... autres positions
        }
    },
    blue = {
        model = 'revolter',
        color = {primary = 64, secondary = 64},
        spawns = {
            vector4(1704.382446, 3248.083496, 40.484985, 289.133850),
            -- ... autres positions
        }
    }
}
```

---

## 🎮 Commandes

### Support & Combat

| Commande | Description | Exemple |
|----------|-------------|---------|
| `/cvchealall [radius]` | Soigne et donne l'armure à tous les joueurs dans le rayon | `/cvchealall 50` |
| `/givecallall [radius]` | Donne un Pistol .50 + 350 munitions | `/givecallall 100` |
| `/cvcrepairall [radius]` | Répare tous les véhicules dans le rayon | `/cvcrepairall 50` |

### Véhicules

| Commande | Description |
|----------|-------------|
| `/cvcspawnvehicule` | Spawn les 14 véhicules du convoi |

### Téléportations

| Commande | Description | Exemple |
|----------|-------------|---------|
| `/cvctpall` | Téléporte tous les joueurs en équipe | `/cvctpall` |
| `/cvctpequipe [équipe]` | Téléporte une équipe spécifique | `/cvctpequipe rouge` |

### Informations

| Commande | Description |
|----------|-------------|
| `/cvcequipe` | Affiche le nombre de joueurs par équipe |

### Communication

| Commande | Description | Exemple |
|----------|-------------|---------|
| `/cvcannonce [texte]` | Envoie une annonce à tous les joueurs | `/cvcannonce La partie commence!` |

### Gestion

| Commande | Description | Exemple |
|----------|-------------|---------|
| `/cvckickall` | Expulse tous les joueurs du mode | `/cvckickall` |
| `/cvckick [id]` | Expulse un joueur spécifique | `/cvckick 5` |

---

## 🔐 Permissions

### Groupes autorisés par défaut

```lua
Config.Permissions = {
    allowedGroups = {
        'admin',
        'superadmin',
        'organisateur',
        'responsable'
    }
}
```

### ACE Permissions (Standalone)

Si vous n'utilisez pas ESX/QBCore :

```cfg
# server.cfg
add_ace group.admin cvc.admin allow
add_ace group.moderator cvc.organisateur allow
add_ace group.staff cvc.responsable allow
```

---

## 📁 Structure des fichiers

```
cvc_convoy/
├── fxmanifest.lua          # Manifeste FiveM
├── config.lua              # Configuration complète
├── client/
│   ├── main.lua            # Logique principale client
│   ├── utils.lua           # Fonctions utilitaires
│   ├── ped.lua             # Gestion du ped d'entrée
│   ├── teams.lua           # Gestion des équipes
│   └── vehicles.lua        # Gestion des véhicules
├── server/
│   ├── main.lua            # Logique principale serveur
│   ├── utils.lua           # Fonctions utilitaires
│   ├── teams.lua           # Gestion des équipes
│   └── commands.lua        # Commandes admin
└── html/
    ├── index.html          # Structure NUI
    ├── style.css           # Styles
    └── script.js           # Logique JavaScript
```

---

## 🔌 API / Exports

### Côté Serveur

```lua
-- Vérifier si un joueur est dans le mode
local isInMode = exports['cvc_convoy']:IsPlayerInMode(source)

-- Récupérer l'équipe d'un joueur
local team = exports['cvc_convoy']:GetPlayerTeam(source)

-- Récupérer le compte des équipes
local redCount, blueCount = exports['cvc_convoy']:GetTeamCount()

-- Récupérer tous les joueurs dans le mode
local players = exports['cvc_convoy']:GetAllPlayersInMode()

-- Forcer l'entrée d'un joueur
exports['cvc_convoy']:ForceEnterMode(source)

-- Forcer la sortie d'un joueur
exports['cvc_convoy']:ForceExitMode(source)
```

---

## ❓ FAQ

### Le ped n'apparaît pas
- Vérifiez que les coordonnées dans `Config.PedLocation` sont correctes
- Assurez-vous que le modèle de ped existe

### Les armes ne sont pas données
- Vérifiez que `qs-inventory` est bien démarré **avant** `cvc_convoy`
- Vérifiez les noms des items dans votre configuration qs-inventory

### Les joueurs ne sont pas isolés
- Vérifiez que OneSync Infinity est activé
- Vérifiez que le routing bucket n'est pas utilisé par un autre script

### Les tenues ne s'appliquent pas
- Vérifiez les IDs des composants dans `Config.Outfits`
- Testez avec un personnage mp_m_freemode_01 ou mp_f_freemode_01

---

## 📝 Changelog

### v1.0.0
- Version initiale
- Système d'instance complet
- Gestion des équipes
- 14 véhicules configurables
- Intégration qs-inventory
- Interface d'annonces NUI

---

## 📄 Licence

Ce script est fourni tel quel. Vous êtes libre de le modifier pour votre serveur.

---

## 🤝 Support

Pour tout problème ou suggestion, créez une issue sur le repository.
