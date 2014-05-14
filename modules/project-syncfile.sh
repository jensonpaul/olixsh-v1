###
# Synchronisation des fichiers d'un projet avec un serveur distant
# ==============================================================================
# - Demande du serveur distant
# - rsync
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 12/05/2014
##


source lib/project.inc.sh



###
# Chargement du fichier de conf
##
project_checkArguments
project_loadConfiguration ${OLIX_PROJECT_CODE}



###
# Synchronisation du dossier 
##
echo
echo -e "${CVIOLET} Copie des fichiers dans ${CCYAN}${OLIX_CONF_PROJECT_PATH}${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"

stdinout_readConnexionServerSSH ${OLIX_PROJECT_CODE}

filesystem_synchronize "${OLIX_STDINOUT_SERVER_PORT}" \
                       "${OLIX_STDINOUT_SERVER_USER}@${OLIX_STDINOUT_SERVER_HOST}:${OLIX_STDINOUT_SERVER_PATH}" \
                       "${OLIX_CONF_PROJECT_PATH}" \
                       "${OLIX_CONF_PROJECT_SYNCFILE_EXCLUDE}"
[[ $? -ne 0 ]] && logger_error


###
# FIN
##
echo -e "${CVERT}Synchronisation de ${CVIOLET}${OLIX_PROJECT_CODE}${CVERT} terminée${CVOID}"
