###
# Librairies de log
# ==============================================================================
# @package olixsh
# @author Olivier
# @created 07/04/2014
##


###
# Paramètres par défaut
##
OLIX_LOGGER=false            # Si on enregistre le log dans un fichier syslog
OLIX_LOGGER_LEVEL="debug"    # Niveau de log
OLIX_LOGGER_FACILITY="user" # Origine de l'erreur

###
# Paramètres par défaut NON modifiable
##
OLIX_LOGGER_FILE="/tmp/olix.log" # Fichier de log principal
OLIX_LOGGER_BUFFER=""       # Buffer du log
OLIX_LOGGER_FILE_ERR=$(mktemp --dry-run /tmp/olix.XXXXXXXXXX.err) # Fichier de sortie d'erreur



###
# Vérifie si le daemon logger existe
##
function logger_checkLogger()
{
    if [[ ! -x /usr/bin/logger ]]; then
        OLIX_LOGGER=false
    fi
}


###
# Sauvegarde les messages dans le syslog
# @param $1 : Niveau du log
# @param $2 : Message
##
function logger_syslog()
{
	local LEVEL="$1"
    local MESSAGE="$2"
    if [[ "${OLIX_LOGGER}" == "true" ]]; then
        /usr/bin/logger -t "oliXsh[$$]" -p "${OLIX_LOGGER_FACILITY}.${LEVEL}" -- "${LEVEL} * ${MESSAGE}"  
    fi
}


###
# Log le message et l'affiche eventuellement
# @param $1 : Niveau de log (debug info warning error)
# @param $2 : Message
##
function logger_log() 
{
	local SWITCH
	local LEVEL=$1
	shift
	local MESSAGE="$@"

    # Affecte le niveau d'erreur par défaut
    if [[ "${LEVEL}" != "debug" ]]\
    && [[ "${LEVEL}" != "info" ]]\
    && [[ "${LEVEL}" != "warning" ]]\
    && [[ "${LEVEL}" != "error" ]]; then
        LEVEL="info"
    fi
    
    # Determine s'il y aura affichage ou pas
    case "${LEVEL}" in
    	debug)   SWITCH=${OLIX_OPTION_VERBOSEDEBUG};;
        info)    SWITCH=${OLIX_OPTION_VERBOSE};;
        warning) SWITCH=${OLIX_OPTION_WARNINGS};;
        *)       SWITCH=true;;
    esac
    
    # Affiche le message sur la sortie standard
    if [[ ${SWITCH} == true ]]; then
        logger_print "${LEVEL}" "${MESSAGE}"
    fi
    # Log dans un fichier
    logger_syslog "${LEVEL}" "${OLIX_LOGGER_BUFFER}${MESSAGE}"
    # Purge le buffer
    OLIX_LOGGER_BUFFER=""
}


function logger_print()
{
	local LEVEL=$1
	shift
	local MESSAGE="$@"

	case "${LEVEL}" in
		debug) 		echo -e "${CGRIS}${MESSAGE}${CVOID}" >&2;;
		info)		echo -e "${Ccyan}${MESSAGE}${CVOID}";;
		warning)	echo -e "${Cjaune}${MESSAGE}${CVOID}";;
		error)		echo -e "${Crouge}${MESSAGE}${CVOID}";;
	esac
}


###
# Mode DEBUG
##
function logger_debug()
{
    if [[ "${OLIX_LOGGER_LEVEL}" == "debug" ]]; then
        logger_log "debug" "DEBUG: $@"
    fi
}


###
# Mode INFO
##
function logger_info()
{
    if [[ "${OLIX_LOGGER_LEVEL}" == "debug" ]]\
    || [[ "${OLIX_LOGGER_LEVEL}" == "info" ]]; then
        logger_log "info" "$@"
    fi
}


###
# Mode WARNING
##
function logger_warning()
{
    if [[ "${OLIX_LOGGER_LEVEL}" == "debug" ]]\
    || [[ "${OLIX_LOGGER_LEVEL}" == "info" ]]\
    || [[ "${OLIX_LOGGER_LEVEL}" == "warning" ]]; then
        logger_log "warning" "$@"
    fi
}


###
# Mode ERROR
# Tous les erreurs sont envoyés dans le syslog
##
function logger_error()
{
    local ERRFILE
    if [[ -s ${OLIX_LOGGER_FILE_ERR} ]]; then
    	ERRFILE=$(cat ${OLIX_LOGGER_FILE_ERR})
    	logger_log "error" "${ERRFILE}"
    else
    	logger_log "error" "$@"
    fi
    core_exit 1 "$@"
}

