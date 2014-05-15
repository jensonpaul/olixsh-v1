###
# Librairies d'entrées / sorties et d'affichage
# ==============================================================================
# @package olixsh
# @author Olivier
# @created 06/04/2014
##


###
# Paramètres
##
OLIX_STDINOUT_SERVER_HOST=""
OLIX_STDINOUT_SERVER_PORT=""
OLIX_STDINOUT_SERVER_USER=""
OLIX_STDINOUT_SERVER_PATH=""
OLIX_STDINOUT_SERVER_BASE=""


###
# Affiche l'usage de la commande
##
function stdinout_printUsage()
{
    echo -e "${CBLANC} Usage : ${CBLEU}olixsh ${Ccyan}[OPTIONS] ${CJAUNE}COMMAND ${Cviolet}[PARAMETER]${CVOID}"

    echo ""
    echo -e "${Ccyan}OPTIONS${CVOID}"
    echo -en "${CBLANC}  --help|-h          ${CVOID} : "; echo "Affiche l'aide."
    echo -en "${CBLANC}  --version          ${CVOID} : "; echo "Affiche le numéro de version."
    echo -en "${CBLANC}  --verbose|-v       ${CVOID} : "; echo "Mode verbeux."
    echo -en "${CBLANC}  --debug|-d         ${CVOID} : "; echo "Mode debug très verbeux."
    echo -en "${CBLANC}  --no-warnings      ${CVOID} : "; echo "Désactive les messages d'alerte."

    

    core_exit 0
}


###
# Affiche la version
##
function stdinout_printVersion()
{
    local VERSION
    VERSION="Ver ${CVIOLET}${OLIX_VERSION}${CVOID}"
    if [[ "${OLIX_RELEASE}" == "true" ]]; then    
        VERSION="${VERSION} Release"
    else
        VERSION="${VERSION}.${OLIX_REVISION}"
    fi
    echo -e "${CCYAN}oliXsh${CVOID} ${VERSION}, for Linux"
}


###
# Affiche le menu des fonctionnalités
##
function stdinout_printListModule()
{
    echo -e "${CJAUNE} io${CVOID} - ${Cjaune}install:olixsh${CVOID}    : Installer oliXsh sur le serveur"
    echo -e "${CJAUNE} ic${CVOID} - ${Cjaune}install:config${CVOID}    : Installer les fichiers de configuration sur le serveur"
    echo -e "${CJAUNE} is${CVOID} - ${Cjaune}install:server${CVOID}    : Configuration du systeme Ubuntu"
    echo -e "${CJAUNE} ip${CVOID} - ${Cjaune}install:package${CVOID}   : Installation d'un package"
    echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"
    echo -e "${CJAUNE} pi${CVOID} - ${Cjaune}project:install${CVOID}  : Installation d'un projet"
    echo -e "${CJAUNE} ps${CVOID} - ${Cjaune}project:syncfile${CVOID} : Synchronisation des fichiers d'un projet"
}


###
# Affiche le menu des fonctionnalités de olixsh
# @return OLIX_MODULE : choix de la fonctionnalité
##
function stdinout_readChoiceModule()
{
    while true; do
        stdinout_printVersion
        echo -e "Copyright (c) 2013, $(date '+%Y') Olivier Pitois. All rights reserved."
        echo
        echo -e "${CVIOLET} Menu des fonctionnalités ${CCYAN}oliXsh${CVOID}"
        echo -e "${CBLANC}===============================================================================${CVOID}"
        stdinout_printListModule
        echo -e "${CJAUNE} q${CVOID}  - ${Cjaune}quit${CVOID}             : Quitter"
        echo -en "${Cjaune}Ton choix ${CJAUNE}[q]${CVOID} : "
        read OLIX_MODULE
        case ${OLIX_MODULE} in
            io|install:olixsh)   OLIX_MODULE="install:olixsh"; break;;
            ic|install:config)   OLIX_MODULE="install:config"; break;;
            is|install:server)   OLIX_MODULE="install:server"; break;;
            ip|install:package)  OLIX_MODULE="install:package"; break;;
            q|quit)              OLIX_MODULE="quit"; break;;
            *)                   [ "${OLIX_MODULE}" == "" ] && OLIX_MODULE="quit" && break;;
        esac
    done
}


###
# Demande des infos d'un connexion distante en SSH
# @param $1 : Type de connexion mysql ou ssh
# @param $2 : Code pour le cache
# @param @return OLIX_STDINOUT_SERVER_HOST : Host du serveur
# @param @return OLIX_STDINOUT_SERVER_PORT : Port du serveur
# @param @return OLIX_STDINOUT_SERVER_USER : User du serveur
# @param @return OLIX_STDINOUT_SERVER_PATH : Chemin du serveur
# @param @return OLIX_STDINOUT_SERVER_BASE : Base du serveur
##
function stdinout_readConnexionServer()
{
    local REPONSE
    OLIX_STDINOUT_SERVER_HOST=$3
    OLIX_STDINOUT_SERVER_PORT=$4
    OLIX_STDINOUT_SERVER_USER=$5
    OLIX_STDINOUT_SERVER_PATH=$6
    OLIX_STDINOUT_SERVER_BASE=$6
    
    # Verifie si un cache existe pour éviter de resaisir
    local FCACHE="/tmp/cache.$USER.$2.$1"
    [[ -r ${FCACHE} ]] && logger_debug "Lecture du cache ${FCACHE}" && source ${FCACHE}
    
    echo > ${FCACHE}
    echo -en "Host du serveur ${CJAUNE}[${OLIX_STDINOUT_SERVER_HOST}]${CVOID} ? "
    read REPONSE
    [ ! -z ${REPONSE} ] && OLIX_STDINOUT_SERVER_HOST=${REPONSE}
    echo "OLIX_STDINOUT_SERVER_HOST=${OLIX_STDINOUT_SERVER_HOST}" >> ${FCACHE}
    echo -en "Port du serveur ${CJAUNE}[${OLIX_STDINOUT_SERVER_PORT}]${CVOID} ? "
    read REPONSE
    [ ! -z ${REPONSE} ] && OLIX_STDINOUT_SERVER_PORT=${REPONSE}
    echo "OLIX_STDINOUT_SERVER_PORT=${OLIX_STDINOUT_SERVER_PORT}" >> ${FCACHE}
    echo -en "Utilisateur de connexion ${CJAUNE}[${OLIX_STDINOUT_SERVER_USER}]${CVOID} ? "
    read REPONSE
    [ ! -z ${REPONSE} ] && OLIX_STDINOUT_SERVER_USER=${REPONSE}
    echo "OLIX_STDINOUT_SERVER_USER=${OLIX_STDINOUT_SERVER_USER}" >> ${FCACHE}
    if [[ "$1" == "ssh" ]]; then
        echo -en "Emplacement du chemin source ${CJAUNE}[${OLIX_STDINOUT_SERVER_PATH}]${CVOID} ? "
        read REPONSE
        [ ! -z ${REPONSE} ] && OLIX_STDINOUT_SERVER_PATH=${REPONSE}
        echo "OLIX_STDINOUT_SERVER_PATH=${OLIX_STDINOUT_SERVER_PATH}" >> ${FCACHE}
    fi
    if [[ "$1" == "mysql" ]]; then
        echo -en "Nom de la base source ${CJAUNE}[${OLIX_STDINOUT_SERVER_BASE}]${CVOID} ? "
        read REPONSE
        [ ! -z ${REPONSE} ] && OLIX_STDINOUT_SERVER_BASE=${REPONSE}
        echo "OLIX_STDINOUT_SERVER_BASE=${OLIX_STDINOUT_SERVER_BASE}" >> ${FCACHE}
    fi
}


###
# Demande d'infos d'une connexion distance à un serveur SSH
# @param $1 : Code pour differencier la connexion dans le cache
##
function stdinout_readConnexionServerSSH()
{
    local CODE=$1
    [[ -z ${CODE} ]] && CODE="default"
    logger_debug "Demande des infos de connexion distante SSH"
    stdinout_readConnexionServer "ssh" "${CODE}" \
        "${OLIX_STDINOUT_SERVER_HOST}" "22" "${OLIX_STDINOUT_SERVER_USER}" "${OLIX_STDINOUT_SERVER_BASE}"
}


###
# Demande d'infos d'une connexion distance à un serveur MySQL
# @param $1 : Code pour differencier la connexion dans le cache
##
function stdinout_readConnexionServerMySQL()
{
    local CODE=$1
    [[ -z ${CODE} ]] && CODE="default"
    logger_debug "Demande des infos de connexion distante MySQL"
    stdinout_readConnexionServer "mysql" "${CODE}" \
        "${OLIX_STDINOUT_SERVER_HOST}" "3306" "${OLIX_STDINOUT_SERVER_USER}" "${OLIX_STDINOUT_SERVER_BASE}"
}