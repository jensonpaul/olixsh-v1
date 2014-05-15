###
# Synchronisation d'une base de données distante vers une locale
# ==============================================================================
# - Demande du serveur distant
# - Synchro
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 15/05/2014
##


###
# Synchronisation de la base 
##
echo
echo -e "${CVIOLET}Synchronisation d'une base de données${CVOID}"

stdinout_readConnexionServerMySQL "syncbase"

mysql_printMenuListDataBasesLocal "" true

mysql_synchronizeDatabase "${OLIX_STDINOUT_SERVER_HOST}" "${OLIX_STDINOUT_SERVER_PORT}" \
    					  "${OLIX_STDINOUT_SERVER_USER}" "${OLIX_STDINOUT_SERVER_BASE}" "${OLIX_FONCTION_RESULT}"
[[ $? -ne 0 ]] && logger_error "Impossible de synchroniser la base ${OLIX_FONCTION_RESULT}"


###
# FIN
##
echo -e "${CVERT}Synchronisation vers ${CVIOLET}${OLIX_FONCTION_RESULT}${CVERT} terminée${CVOID}"
