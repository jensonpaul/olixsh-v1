###
# Librairies pour la gestion des projets
# ==============================================================================
# @package olixsh
# @author Olivier
# @created 12/05/2014
##


OLIX_PROJECT_UBUNTU_VERSION_RELEASE=$(lsb_release -sr)
OLIX_PROJECT_PATH_CONFIG="${OLIX_CONFIG_PATH}/project"
OLIX_PROJECT_NAME_CONFIG="project.conf"
OLIX_PROJECT_CODE=""


###
# Affiche le choix du projet
# @return OLIX_PROJECT_CODE
##
function project_printChoiceProject()
{
    logger_debug "project_printChoiceProject ()"
    local PROJECT_LIST
    local PROJECT
    local NAME
    echo -e "${CBLANC}Choix du projet${CVOID}"
    
    PROJECT_LIST=$(find ${OLIX_PROJECT_PATH_CONFIG} -maxdepth 1 -mindepth 1 -type d)
    for I in ${PROJECT_LIST}; do
        if project_isExist $(basename $I); then
            source ${I}/${OLIX_PROJECT_NAME_CONFIG}
            echo -e " ${CJAUNE}$(basename $I)${CVOID} : Projet ${OLIX_CONF_PROJECT_NAME}"
        else
            echo -e " ${CJAUNE}$(basename $I)${CVOID} : Projet ${CROUGE}inconnu${CVOID}"
        fi
    done
    while true; do
        echo -en "${Cjaune}Ton choix ${CJAUNE}[]${CVOID} : "
        read PROJECT
        if project_isExist ${PROJECT} ]; then break; fi
    done
    OLIX_PROJECT_CODE=${PROJECT}
}


###
# Test si un projet existe
# @param $1 : Code du projet
##
function project_isExist()
{
    logger_debug "project_isExist ()"
    [[ -r ${OLIX_PROJECT_PATH_CONFIG}/$1/${OLIX_PROJECT_NAME_CONFIG} ]] && return 0
    return 1
}


###
# Vérifie et charge le fichier de conf du projet
# @param $1 : Code du projet
##
function project_loadConfiguration()
{
    logger_debug "project_loadConfiguration ($1)"
    local FILECFG="${OLIX_PROJECT_PATH_CONFIG}/$1/${OLIX_PROJECT_NAME_CONFIG}"
    logger_info "Vérification de la présence de fichier de conf ${FILECFG}"
    if [[ ! -r ${FILECFG} ]]; then
        logger_warning "${FILECFG} absent"
        logger_error "Impossible de charger le fichier de configuration ${FILECFG}"
    fi
    OLIX_PROJECT_PATH_CONFIG="${OLIX_PROJECT_PATH_CONFIG}/$1"

    logger_info "Chargement de ${FILECFG}"
    source ${FILECFG}
}


###
# Chercher un fichier de conf du projet en fonction de la version d'ubuntu et de l'environnement
# @param $1 : Préfixe de l'emplacement du fichier de conf
# @param $2 : Suffixe ou extension
# @return le fichier de conf trouvé
##
function project_getFileConf()
{
    logger_debug "project_getFileConf ($1, $2)"
    local FILECFG
    FILECFG="$1.${OLIX_PROJECT_UBUNTU_VERSION_RELEASE}.${OLIX_CONF_SERVER_ENVIRONNEMENT}$2"
    if [[ -f ${FILECFG} ]]; then echo "${FILECFG}"; return; fi
    FILECFG="$1.${OLIX_CONF_SERVER_ENVIRONNEMENT}$2"
    if [[ -f ${FILECFG} ]]; then echo "${FILECFG}"; return; fi
    FILECFG="$1.${OLIX_PROJECT_UBUNTU_VERSION_RELEASE}$2"
    if [[ -f ${FILECFG} ]]; then echo "${FILECFG}"; return; fi
    FILECFG="$1$2"
    if [[ -f ${FILECFG} ]]; then echo "${FILECFG}"; return; fi
    echo ""
}


###
# Vérifie les arguments dans la ligne de commande
# @return OLIX_PROJECT_CODE
##
function project_checkArguments()
{
    logger_debug "project_checkArguments ()"
    if [[ ! -z "${OLIX_ARGS}" ]]; then
        OLIX_ARGS=$(echo "${OLIX_ARGS}" | sed -e 's/^ *//' -e 's/ *$//' | awk '{print $1}')
        if project_isExist ${OLIX_ARGS}; then
            OLIX_PROJECT_CODE=${OLIX_ARGS}
        else
            logger_error "Le projet ${OLIX_ARGS} n'existe pas"
        fi
    else
        project_printChoiceProject
    fi
}
