###
# Librairies contenant les fonctions de base necessaire au shell
# ==============================================================================
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 07/04/2014
##



###
# Sortie du programme shell avec nettoyage
# @param $1 : Code de sortie
# @param $2 : Raison du pourquoi de la sortie
##
function core_exit()
{
    local CODE="$1"
    local REASON="$2"

    rm -rf ${OLIX_LOGGER_FILE_ERR} > /dev/null 2>&1

    if [[ -n "${REASON}" ]]; then 
        logger_info "EXIT : ${REASON}"
    fi
    exit ${CODE}
}


###
# Vérifie que ce soit root qui puisse exécuter le script
##
function core_checkIfRoot()
{
    [[ $(id -u) != 0 ]] && return 1
    return 0
}


###
# Vérifie si l'installation de oliXsh est complète
##
function core_checkInstall()
{
    logger_debug "Vérification de la présence de lien ${OLIX_SHELL_LINK}"
    if [[ ! -x ${OLIX_SHELL_LINK} ]]; then
        logger_warning "${OLIX_SHELL_LINK} absent"
        logger_error "oliXsh n'a pas été installé correctement. Relancer le script 'olixsh install:olixsh'"
    fi

    logger_debug "Vérification de la présence de fichier de conf ${OLIX_CONFIG_FILE}"
    if [[ ! -f ${OLIX_CONFIG_FILE} ]]; then
        logger_warning "${OLIX_CONFIG_FILE} absent"
        logger_error "oliXsh n'a pas été installé correctement. Relancer le script 'olixsh install:olixsh'"
    fi

    source ${OLIX_CONFIG_FILE}

    logger_debug "Vérification de la présence de chemin de configuration ${OLIX_CONFIG_PATH}"
    if [[ ! -d "${OLIX_CONFIG_PATH}" ]]; then
        logger_warning "${OLIX_CONFIG_PATH} absent"
        logger_error "oliXsh n'a pas été installé correctement. Relancer le script 'olixsh install:olixsh'"
    fi

    logger_debug "Vérification de la présence de fichier de configuration server ${OLIX_CONFIG_SERVER}"
    if [[ ! -r "${OLIX_CONFIG_SERVER}" ]]; then
        logger_warning "${OLIX_CONFIG_SERVER} absent"
        logger_error "oliXsh n'a pas été installé correctement. Relancer le script 'olixsh install:olixsh'"
    fi
}