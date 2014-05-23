###
# Synchronisation d'un dossier avec un serveur distant
# ==============================================================================
# - Demande du serveur distant
# - rsync
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 15/05/2014
##



###
# Synchronisation du dossier 
##
echo
echo -e "${CVIOLET}Synchronisation d'un dossier distant${CVOID}"

stdin_readConnexionServerSSH 'syncdir'

__PATH_DESTINATION=""
__FCACHE="/tmp/cache.$USER.path.syncdir"
[[ -r ${__FCACHE} ]] && logger_debug "Lecture du cache ${__FCACHE}" && source ${__FCACHE}
echo -en "Dossier de destination ${CJAUNE}[${__PATH_DESTINATION}]${CVOID} ? "
read REPONSE
[ ! -z ${REPONSE} ] && __PATH_DESTINATION=${REPONSE}
echo "__PATH_DESTINATION=${__PATH_DESTINATION}" >> ${__FCACHE}

filesystem_synchronize "${OLIX_STDIN_SERVER_PORT}" \
                       "${OLIX_STDIN_SERVER_USER}@${OLIX_STDIN_SERVER_HOST}:${OLIX_STDIN_SERVER_PATH}" \
                       "${__PATH_DESTINATION}"
[[ $? -ne 0 ]] && logger_error


###
# FIN
##
echo -e "${CVERT}Synchronisation vers ${CVIOLET}${__PATH_DESTINATION}${CVERT} terminée${CVOID}"
