###
# Librairies contenant les fonctions de base necessaire au shell
# ==============================================================================
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 07/04/2014
##


# Pointeur de temps de départ du script
OLIX_CORE_EXEC_START=${SECONDS}


###
# Sortie du programme shell avec nettoyage
# @param $1 : Code de sortie
# @param $2 : Raison du pourquoi de la sortie
##
function core_exit()
{
    local CODE="$1"
    local REASON="$2"

    logger_debug "core_exit ($1)"

    logger_debug "Effacement des fichiers temporaires"
    rm -f /tmp/olix.* > /dev/null 2>&1

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
    logger_debug "core_checkIfRoot ()"
    [[ $(id -u) != 0 ]] && return 1
    return 0
}


###
# Vérifie si l'installation de oliXsh est complète
##
function core_checkInstall()
{
    logger_debug "core_checkInstall ()"

    logger_info "Vérification de la présence de lien ${OLIX_SHELL_LINK}"
    if [[ ! -x ${OLIX_SHELL_LINK} ]]; then
        logger_warning "${OLIX_SHELL_LINK} absent"
        logger_error "oliXsh n'a pas été installé correctement. Relancer le script 'olixsh install:olixsh'"
    fi

    logger_info "Vérification de la présence de fichier de conf ${OLIX_CONFIG_FILE}"
    if [[ ! -f ${OLIX_CONFIG_FILE} ]]; then
        logger_warning "${OLIX_CONFIG_FILE} absent"
        logger_error "oliXsh n'a pas été installé correctement. Relancer le script 'olixsh install:olixsh'"
    fi

    source ${OLIX_CONFIG_FILE}

    logger_info "Vérification de la présence de chemin de configuration ${OLIX_CONFIG_PATH}"
    if [[ ! -d "${OLIX_CONFIG_PATH}" ]]; then
        logger_warning "${OLIX_CONFIG_PATH} absent"
        logger_error "oliXsh n'a pas été installé correctement. Relancer le script 'olixsh install:olixsh'"
    fi

    logger_info "Vérification de la présence de fichier de configuration server ${OLIX_CONFIG_SERVER}"
    if [[ ! -r "${OLIX_CONFIG_SERVER}" ]]; then
        logger_warning "${OLIX_CONFIG_SERVER} absent"
        logger_error "oliXsh n'a pas été installé correctement. Relancer le script 'olixsh install:olixsh'"
    fi
}


###
# Charge la configuration principale
##
function core_loadConfiguration()
{
    logger_debug "core_loadConfiguration ()"
    source ${OLIX_CONFIG_SERVER}
}


###
# Créer un fichier temporaire
##
function core_makeTemp()
{
    echo -n $(mktemp /tmp/olix.XXXXXXXXXX.tmp)
}


###
# Envoi d'un mail
# @param $1 : Format html ou text
# @param $2 : Email
# @param $3 : Chemin du fichier contenant le contenu du mail
# @param $4 : Sujet du mail
##
function core_sendMail()
{
    logger_debug "core_sendMail ($1, $2, $3, $4)"

    local SUBJECT SERVER
    SERVER="${OLIX_CONF_SERVER_NAME}"
    [[ -z ${SERVER} ]] && SERVER=${HOSTNAME}
    SUBJECT="[${SERVER}:${OLIX_MODULE}] $4"

    if [[ "$1" == "html" || "$1" == "HTML" ]]; then
        mailx -s "${SUBJECT}" -a "Content-type: text/html; charset=UTF-8" $2 < $3
    else
        mailx -s "${SUBJECT}" $2 < $3
    fi
    return $?
}


function core_getTimeExec()
{
    echo -n $((SECONDS-OLIX_CORE_EXEC_START))
}