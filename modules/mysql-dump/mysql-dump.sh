###
# Sauvegarde d'une base MySQL local
# ==============================================================================
# - Dump
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 15/05/2014
##


###
# Synchronisation de la base 
##
echo
echo -e "${CVIOLET}Dump d'une base de données${CVOID}"

mysql_printMenuListDataBasesLocal "" false

__PATH_DESTINATION=""
__FCACHE="/tmp/cache.$USER.path.dump"
[[ -r ${__FCACHE} ]] && logger_debug "Lecture du cache ${__FCACHE}" && source ${__FCACHE}
echo -en "Fichier de destination ${CJAUNE}[${__PATH_DESTINATION}]${CVOID} ? "
read REPONSE
[ ! -z ${REPONSE} ] && __PATH_DESTINATION=${REPONSE}
echo "__PATH_DESTINATION=${__PATH_DESTINATION}" >> ${__FCACHE}

mysql_dumpDatabaseLocal "${OLIX_FUNCTION_RESULT}" "${__PATH_DESTINATION}"
[[ $? -ne 0 ]] && logger_error "Impossible de faire un dump de la base ${__PATH_DESTINATION}"


###
# FIN
##
echo -e "${CVERT}Dump de ${CVIOLET}${OLIX_FUNCTION_RESULT}${CVERT} terminée${CVOID}"
