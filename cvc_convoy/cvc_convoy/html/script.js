/**
 * ╔═══════════════════════════════════════════════════════════════════════════╗
 * ║                    CONVOI CONTRE CONVOI - NUI SCRIPT                      ║
 * ╚═══════════════════════════════════════════════════════════════════════════╝
 */

// ═══════════════════════════════════════════════════════════════════════════
// VARIABLES GLOBALES
// ═══════════════════════════════════════════════════════════════════════════

let announcementTimeout = null;
let fadeTimeout = null;

// ═══════════════════════════════════════════════════════════════════════════
// ÉLÉMENTS DOM
// ═══════════════════════════════════════════════════════════════════════════

const container = document.getElementById('announcement-container');
const textElement = document.getElementById('announcement-text');
const box = document.querySelector('.announcement-box');

// ═══════════════════════════════════════════════════════════════════════════
// FONCTIONS D'AFFICHAGE
// ═══════════════════════════════════════════════════════════════════════════

/**
 * Affiche une annonce
 * @param {string} text - Le texte de l'annonce
 * @param {number} duration - Durée d'affichage en ms
 * @param {string} position - Position: 'top', 'center', 'bottom'
 * @param {string} team - Optionnel: 'red' ou 'blue' pour le thème
 */
function showAnnouncement(text, duration = 8000, position = 'top', team = null) {
    // Annuler les timeouts précédents
    if (announcementTimeout) clearTimeout(announcementTimeout);
    if (fadeTimeout) clearTimeout(fadeTimeout);
    
    // Reset des classes
    container.className = '';
    box.className = 'announcement-box';
    
    // Appliquer la position
    container.classList.add(`position-${position}`);
    
    // Appliquer le thème d'équipe si spécifié
    if (team === 'red' || team === 'blue') {
        box.classList.add(`team-${team}`);
    }
    
    // Définir le texte
    textElement.textContent = text;
    
    // Afficher le container
    container.classList.remove('hidden');
    box.classList.remove('fade-out');
    
    // Programmer la disparition
    announcementTimeout = setTimeout(() => {
        hideAnnouncement();
    }, duration);
}

/**
 * Cache l'annonce avec animation
 */
function hideAnnouncement() {
    box.classList.add('fade-out');
    
    fadeTimeout = setTimeout(() => {
        container.classList.add('hidden');
        box.classList.remove('fade-out');
        
        // Callback vers le client
        fetch(`https://${GetParentResourceName()}/closeAnnouncement`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }, 500); // Durée de l'animation fade-out
}

// ═══════════════════════════════════════════════════════════════════════════
// LISTENER NUI
// ═══════════════════════════════════════════════════════════════════════════

window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.action) {
        case 'showAnnouncement':
            showAnnouncement(
                data.text,
                data.duration || 8000,
                data.position || 'top',
                data.team || null
            );
            break;
            
        case 'hideAnnouncement':
            hideAnnouncement();
            break;
            
        default:
            break;
    }
});

// ═══════════════════════════════════════════════════════════════════════════
// UTILITAIRES
// ═══════════════════════════════════════════════════════════════════════════

/**
 * Récupère le nom de la ressource parente
 * @returns {string}
 */
function GetParentResourceName() {
    return window.GetParentResourceName ? window.GetParentResourceName() : 'cvc_convoy';
}

// ═══════════════════════════════════════════════════════════════════════════
// INITIALISATION
// ═══════════════════════════════════════════════════════════════════════════

document.addEventListener('DOMContentLoaded', function() {
    // S'assurer que le container est caché au démarrage
    container.classList.add('hidden');
    
    console.log('[CVC-NUI] Interface chargée');
});

// ═══════════════════════════════════════════════════════════════════════════
// DEBUG (désactivé en production)
// ═══════════════════════════════════════════════════════════════════════════

// Pour tester dans un navigateur:
// showAnnouncement('Test d\'annonce pour le mode Convoi contre Convoi!', 5000, 'top');
