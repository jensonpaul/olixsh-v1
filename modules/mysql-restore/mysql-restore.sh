###
# Restauration d'une base MySQL local
# ==============================================================================
# - Restore
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 15/05/2014
##


###
# Synchronisation de la base 
##
echo
echo -e "${CVIOLET}Restauration d'une base de données${CVOID}"

__PATH_DUMP=""
__FCACHE="/tmp/cache.$USER.path.restore"
[[ -r ${__FCACHE} ]] && logger_debug "Lecture du cache ${__FCACHE}" && source ${__FCACHE}
echo -en "Fichier de destination ${CJAUNE}[${__PATH_DUMP}]${CVOID} ? "
read REPONSE
[ ! -z ${REPONSE} ] && __PATH_DUMP=${REPONSE}
echo "__PATH_DUMP=${__PATH_DUMP}" >> ${__FCACHE}

mysql_printMenuListDataBasesLocal "" true

mysql_restoreDatabaseLocal "${__PATH_DUMP}" "${OLIX_FUNCTION_RESULT}"
[[ $? -ne 0 ]] && logger_error "Impossible de faire un dump de la base ${__PATH_DESTINATION}"


###
# FIN
##
echo -e "${CVERT}Restauration de ${CVIOLET}${OLIX_FUNCTION_RESULT}${CVERT} terminée${CVOID}"
