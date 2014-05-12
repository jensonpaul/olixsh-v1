###
# Configuration du système en UTF-8
# ==============================================================================
# Mettre la variable d'environnement LANG=fr_FR.UTF-8
# - dans /etc/default/locale
# - dans /etc/environment
# ------------------------------------------------------------------------------
# @package olixsh
# @subpackage install
# @author Olivier
# @created 24/08/2013
##


echo
echo -e "${CVIOLET} Configuration en UTF-8 ${CVOID}"
echo -e "${CBLANC}===============================================================================${CVOID}"


###
# Affichage de LANG courante
##
echo -en "LANG=${LANG}  : "
if [[ "${LANG}" == "fr_FR.UTF-8" ]]; then 
    echo -e "${CVERT}OK ...${CVOID}"
else
    echo -e "${CROUGE}NOK${CVOID}"
fi



###
# Si pas en utf8 alors on le modifie
##
if [[ "${LANG}" != "fr_FR.UTF-8" ]]; then

    # Recherche la ligne LANG= à remplacer dans le fichier /etc/default/locale
    if [ ! -f /etc/default/locale.original ]; then
        logger_debug "Sauvegarde de l'original /etc/default/locale"
        cp /etc/default/locale /etc/default/locale.original
        [[ $? -ne 0 ]] && logger_error "Sauvegarde de l'original /etc/default/locale"
    fi
    logger_debug "Remise de l'original de /etc/default/locale"
    cp /etc/default/locale.original /etc/default/locale

    echo -en "Modification de UTF-8 dans ${CCYAN}/etc/default/locale${CVOID} : "
    sed -i 's/^LANG=.*/LANG="fr_FR.UTF-8"/g' /etc/default/locale
    echo -e "${CVERT}OK ...${CVOID}"
    echo -e "--- Contenu du fichier ${CCYAN}/etc/default/locale${CVOID} ---${Cgris}"
    cat /etc/default/locale
    echo "${CVOID}--- Fin ---"
    sleep 1
    
    # Recherche la ligne LANG= à remplacer dans le fichier /etc/environment
    if [ ! -f /etc/environment.original ]; then
        logger_debug "Sauvegarde de l'original /etc/environment"
        cp /etc/environment /etc/environment.original
        [[ $? -ne 0 ]] && logger_error "Sauvegarde de l'original /etc/environment"
    fi
    logger_debug "Remise de l'original de /etc/environment"
    cp /etc/environment.original /etc/environment

    if grep "LANG=" /etc/environment > /dev/null; then
        echo -en "Modification de UTF-8 dans ${CCYAN}/etc/environment${CVOID} : "
        sed -i 's/^LANG=.*/LANG="fr_FR.UTF-8"/g' /etc/environment
        echo -e "${CVERT}OK ...${CVOID}"
    else
        echo -en "Ajout de UTF-8 dans ${CCYAN}/etc/environment${CVOID} : "
        echo "LANG=\"fr_FR.UTF-8\"" >> /etc/environment
        echo -e "${CVERT}OK ...${CVOID}"
    fi
    echo -e "--- Contenu du fichier ${CCYAN}/etc/environment${CVOID} ---${Cgris}"
    cat /etc/environment
    echo "${CVOID}--- Fin ---"
    sleep 1
    
fi
