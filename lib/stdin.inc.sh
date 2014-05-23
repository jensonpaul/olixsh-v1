###
# Librairies d'entrées
# ==============================================================================
# @package olixsh
# @author Olivier
# @created 06/04/2014
##


###
# Paramètres
##
OLIX_STDIN_SERVER_HOST=""
OLIX_STDIN_SERVER_PORT=""
OLIX_STDIN_SERVER_USER=""
OLIX_STDIN_SERVER_PATH=""
OLIX_STDIN_SERVER_BASE=""



###
# Demande des infos d'un connexion distante en SSH
# @param $1 : Type de connexion mysql ou ssh
# @param $2 : Code pour le cache
# @param @return OLIX_STDIN_SERVER_HOST : Host du serveur
# @param @return OLIX_STDIN_SERVER_PORT : Port du serveur
# @param @return OLIX_STDIN_SERVER_USER : User du serveur
# @param @return OLIX_STDIN_SERVER_PATH : Chemin du serveur
# @param @return OLIX_STDIN_SERVER_BASE : Base du serveur
##
function stdin_readConnexionServer()
{
    logger_debug "stdin_readConnexionServer ($1, $2, $3, $4, $5, $6)"
    local REPONSE
    OLIX_STDIN_SERVER_HOST=$3
    OLIX_STDIN_SERVER_PORT=$4
    OLIX_STDIN_SERVER_USER=$5
    OLIX_STDIN_SERVER_PATH=$6
    OLIX_STDIN_SERVER_BASE=$6
    
    # Verifie si un cache existe pour éviter de resaisir
    local FCACHE="/tmp/cache.$USER.$2.$1"
    [[ -r ${FCACHE} ]] && logger_debug "Lecture du cache ${FCACHE}" && source ${FCACHE}
    
    echo > ${FCACHE}
    echo -en "Host du serveur ${CJAUNE}[${OLIX_STDIN_SERVER_HOST}]${CVOID} ? "
    read REPONSE
    [ ! -z ${REPONSE} ] && OLIX_STDIN_SERVER_HOST=${REPONSE}
    echo "OLIX_STDIN_SERVER_HOST=${OLIX_STDIN_SERVER_HOST}" >> ${FCACHE}
    echo -en "Port du serveur ${CJAUNE}[${OLIX_STDIN_SERVER_PORT}]${CVOID} ? "
    read REPONSE
    [ ! -z ${REPONSE} ] && OLIX_STDIN_SERVER_PORT=${REPONSE}
    echo "OLIX_STDIN_SERVER_PORT=${OLIX_STDIN_SERVER_PORT}" >> ${FCACHE}
    echo -en "Utilisateur de connexion ${CJAUNE}[${OLIX_STDIN_SERVER_USER}]${CVOID} ? "
    read REPONSE
    [ ! -z ${REPONSE} ] && OLIX_STDIN_SERVER_USER=${REPONSE}
    echo "OLIX_STDIN_SERVER_USER=${OLIX_STDIN_SERVER_USER}" >> ${FCACHE}
    if [[ "$1" == "ssh" ]]; then
        echo -en "Emplacement du chemin source ${CJAUNE}[${OLIX_STDIN_SERVER_PATH}]${CVOID} ? "
        read REPONSE
        [ ! -z ${REPONSE} ] && OLIX_STDIN_SERVER_PATH=${REPONSE}
        echo "OLIX_STDIN_SERVER_PATH=${OLIX_STDIN_SERVER_PATH}" >> ${FCACHE}
    fi
    if [[ "$1" == "mysql" ]]; then
        echo -en "Nom de la base source ${CJAUNE}[${OLIX_STDIN_SERVER_BASE}]${CVOID} ? "
        read REPONSE
        [ ! -z ${REPONSE} ] && OLIX_STDIN_SERVER_BASE=${REPONSE}
        echo "OLIX_STDIN_SERVER_BASE=${OLIX_STDIN_SERVER_BASE}" >> ${FCACHE}
    fi
}


###
# Demande d'infos d'une connexion distance à un serveur SSH
# @param $1 : Code pour differencier la connexion dans le cache
##
function stdin_readConnexionServerSSH()
{
    logger_debug "stdin_readConnexionServerSSH ($1)"
    local CODE=$1
    [[ -z ${CODE} ]] && CODE="default"
    stdin_readConnexionServer "ssh" "${CODE}" \
        "${OLIX_STDIN_SERVER_HOST}" "22" "${OLIX_STDIN_SERVER_USER}" "${OLIX_STDIN_SERVER_BASE}"
}


###
# Demande d'infos d'une connexion distance à un serveur MySQL
# @param $1 : Code pour differencier la connexion dans le cache
##
function stdin_readConnexionServerMySQL()
{
    logger_debug "stdin_readConnexionServerMySQL ($1)"
    local CODE=$1
    [[ -z ${CODE} ]] && CODE="default"
    stdin_readConnexionServer "mysql" "${CODE}" \
        "${OLIX_STDIN_SERVER_HOST}" "3306" "${OLIX_STDIN_SERVER_USER}" "${OLIX_STDIN_SERVER_BASE}"
}