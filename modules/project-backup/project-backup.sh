###
# Sauvegarde d'un projet
# ==============================================================================
# - Sauvegarde des bases
# - Sauvegarde des dossiers
# - Synchro FTP
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 15/05/2014
##


source lib/project.inc.sh
source lib/backup.inc.sh
source lib/ftp.inc.sh


###
# Chargement du fichier de conf
##
project_checkArguments
project_loadConfiguration ${OLIX_PROJECT_CODE}


###
# Déclaration et initialisation des variables par defaut
##

config_require2 "OLIX_CONF_PROJECT_BACKUP_PURGE" "OLIX_CONF_SERVER_BACKUP_PURGE" "5"
config_require2 "OLIX_CONF_PROJECT_BACKUP_COMPRESS" "OLIX_CONF_SERVER_BACKUP_COMPRESS" "gz"
config_require2 "OLIX_CONF_PROJECT_BACKUP_REPOSITORY" "OLIX_CONF_SERVER_BACKUP_REPOSITORY" "/var/backups"
if [[ ! -d ${OLIX_CONF_PROJECT_BACKUP_REPOSITORY} ]]; then
	logger_warning "Création du dossier inexistant OLIX_CONF_PROJECT_BACKUP_REPOSITORY: \"${OLIX_CONF_PROJECT_BACKUP_REPOSITORY}\""
    mkdir ${OLIX_CONF_PROJECT_BACKUP_REPOSITORY} || logger_error "Impossible de créer OLIX_CONF_PROJECT_BACKUP_REPOSITORY: \"${OLIX_CONF_PROJECT_BACKUP_REPOSITORY}\""
elif [[ ! -w ${OLIX_CONF_PROJECT_BACKUP_REPOSITORY} ]]; then
	logger_error "Le dossier ${OLIX_CONF_PROJECT_BACKUP_REPOSITORY} n'a pas les droits en écriture"
fi
config_require2 "OLIX_CONF_PROJECT_BACKUP_REPORT_TYPE" "OLIX_CONF_SERVER_BACKUP_REPORT_TYPE" "text"
config_require2 "OLIX_CONF_PROJECT_BACKUP_REPORT_REPO" "OLIX_CONF_SERVER_BACKUP_REPORT_REPO" "/tmp"
config_require2 "OLIX_CONF_PROJECT_BACKUP_REPORT_MAIL" "OLIX_CONF_SERVER_BACKUP_REPORT_MAIL" ""

config_require2 "OLIX_CONF_PROJECT_BACKUP_FTP_SYNC" "OLIX_CONF_SERVER_BACKUP_FTP_SYNC" false
if [[ "${OLIX_CONF_PROJECT_BACKUP_FTP_SYNC}" != "false" ]]; then
	ftp_isInstalled ${OLIX_CONF_PROJECT_BACKUP_FTP_SYNC}
	config_require2 "OLIX_CONF_PROJECT_BACKUP_FTP_HOST" "OLIX_CONF_SERVER_BACKUP_FTP_HOST" "localhost"
	config_require2 "OLIX_CONF_PROJECT_BACKUP_FTP_USER" "OLIX_CONF_SERVER_BACKUP_FTP_USER" "${USER}"
	config_require2 "OLIX_CONF_PROJECT_BACKUP_FTP_PASS" "OLIX_CONF_SERVER_BACKUP_FTP_PASS" ""
	[[ -z ${OLIX_CONF_PROJECT_BACKUP_FTP_PASS} ]] && logger_error "La configuration OLIX_CONF_PROJECT_BACKUP_FTP_PASS n'est pas définie"
	config_require2 "OLIX_CONF_PROJECT_BACKUP_FTP_PATH" "OLIX_CONF_SERVER_BACKUP_FTP_PATH" "/"
fi

config_require "OLIX_CONF_SERVER_MYSQL_HOST" "localhost"
config_require "OLIX_CONF_SERVER_MYSQL_PORT" "3306"
config_require "OLIX_CONF_SERVER_MYSQL_HOST" "olix"
config_require "OLIX_CONF_SERVER_MYSQL_HOST" "olix52"



###
# Mise en place du rapport
##
source lib/report.inc.sh
report_initialize 	"${OLIX_CONF_PROJECT_BACKUP_REPORT_TYPE}" \
					"${OLIX_CONF_PROJECT_BACKUP_REPORT_REPO}/rapport-backup-${OLIX_PROJECT_CODE}-${OLIX_SYSTEM_DATE}" \
					"${OLIX_CONF_PROJECT_BACKUP_REPORT_MAIL}"

stdout_printHead1 "Sauvegarde du projet %s le %s à %s" "${OLIX_PROJECT_CODE}" "${OLIX_SYSTEM_DATE}" "${OLIX_SYSTEM_TIME}"
report_printHead1 "Sauvegarde du projet %s le %s à %s" "${OLIX_PROJECT_CODE}" "${OLIX_SYSTEM_DATE}" "${OLIX_SYSTEM_TIME}"



###
# Sauvegarde des bases de données
##

# Liste des bases à sauvegarder
for I in ${OLIX_CONF_PROJECT_MYSQL_BASE}; do
    if [[ "|${OLIX_CONF_PROJECT_BACKUP_BASE_EXCLUDE// /|}|" =~ "|${I}|" ]]; then continue; fi
    _PB_LIST_BASE="${_PB_LIST_BASE} $I"
done
_PB_LIST_BASE="${_PB_LIST_BASE} ${OLIX_CONF_PROJECT_BACKUP_BASE_INCLUDE}"

# Traitement
for I in ${_PB_LIST_BASE}; do

	stdout_printHead2 "Dump de la base %s" "${I}"
	report_printHead2 "Dump de la base %s" "${I}"

    backup_baseMySQL ${I}

done


###
# Sauvegarde du dossier du projet
##
stdout_printHead2 "Sauvegarde du dossier projet %s" "${OLIX_CONF_PROJECT_PATH}"
report_printHead2 "Sauvegarde du dossier projet %s" "${OLIX_CONF_PROJECT_PATH}"

backup_directory "${OLIX_CONF_PROJECT_PATH}" "${OLIX_PROJECT_CODE}" "${OLIX_CONF_PROJECT_BACKUP_FILE_EXCLUDE}"


###
# Sauvegarde des dossiers supplémentaires
##
for I in ${OLIX_CONF_PROJECT_BACKUP_PATH_EXTRA}; do

	stdout_printHead2 "Sauvegarde du dossier %s" "${I}"
	report_printHead2 "Sauvegarde du dossier projet %s" "${I}"

	backup_directory "${I}" "${I//\//_}"

done


###
# Synchronisation avec le serveur FTP
##
if [[ ${OLIX_CONF_PROJECT_BACKUP_FTP_SYNC} != false ]]; then
	stdout_printHead2 "Synchronisation avec le serveur FTP %s" "${OLIX_CONF_PROJECT_BACKUP_FTP_HOST}"
	report_printHead2 "Synchronisation avec le serveur FTP %s" "${OLIX_CONF_PROJECT_BACKUP_FTP_HOST}"
	START=${SECONDS}

	ftp_synchronize "${OLIX_CONF_PROJECT_BACKUP_FTP_SYNC}" "${OLIX_CONF_PROJECT_BACKUP_FTP_HOST}" \
		"${OLIX_CONF_PROJECT_BACKUP_FTP_USER}" "${OLIX_CONF_PROJECT_BACKUP_FTP_PASS}" \
        "${OLIX_CONF_PROJECT_BACKUP_FTP_PATH}" "${OLIX_CONF_PROJECT_BACKUP_REPOSITORY}"

    stdout_printMessageReturn $? "Synchronisation avec le serveur FTP" "" "$((SECONDS-START))"
    report_printMessageReturn $? "Synchronisation avec le serveur FTP" "" "$((SECONDS-START))"
    [[ $? -ne 0 ]] && report_error && logger_error

    report_printFile "${OLIX_FUNCTION_RESULT}" "font-size:0.8em;"
fi


###
# Fin
##
stdout_print
stdout_printLine
stdout_print "Sauvegarde terminée en $(core_getTimeExec) secondes"
report_print
report_printLine
report_print "Sauvegarde terminée en $(core_getTimeExec) secondes"

report_terminate "${OLIX_CONF_PROJECT_BACKUP_REPORT_TYPE}" "Rapport de backup du projet ${OLIX_PROJECT_CODE}"
