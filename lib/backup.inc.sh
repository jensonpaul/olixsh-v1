###
# Librairies pour la gestion des sauvegardes
# ==============================================================================
# @package olixsh
# @author Olivier
# @created 16/05/2014
##


###
# Déplace le fichier backup de /tmp ver le repertoire de backup défini
# @param $1 : Nom du fichier à transferer
# @param $2 : Dossier de backup de destination
##
function backup_moveArchive()
{
	logger_debug "backup_moveArchive ($1, $2)"
    mv $1 $2/ > ${OLIX_LOGGER_FILE_ERR} 2>&1
    stdout_messageReturn $? "Déplacement vers le dossier de backup"
    report_messageReturn $? "Déplacement vers le dossier de backup"
    [[ $? -ne 0 ]] && logger_error
    return $?
}


###
# Compression d'un fichier de sauvegarde
# @param $1 : Type de compression
# @param $2 : Fichier à compresser
# @return OLIX_FUNCTION_RESULT : Nom du fichier compressé
##
function backup_compress()
{
    local FILE
    local RET
    logger_debug "backup_compress ($1, $2)"

    case $1 in
        BZ|bz|BZ2|bz2)  FILE=$(filesystem_compressBZ $2)
                        RET=$?
                        ;;
        GZ|gz)          FILE=$(filesystem_compressGZ $2)
                        RET=$?
                        ;;
        *)              logger_warning "Le type de compression \"$1\" n'est pas disponible"
                        OLIX_FUNCTION_RESULT=$2
                        return 0;;
    esac
    
    stdout_messageReturn ${RET} "Compression du fichier" "$(stdout_getSizeFileHuman ${FILE})"
    report_messageReturn ${RET} "Compression du fichier" "$(stdout_getSizeFileHuman ${FILE})"

    [[ $? -ne 0 ]] && logger_error
    OLIX_FUNCTION_RESULT=${FILE}
}


###
# Purge des anciens fichiers
# @param $1 : Dossier à analyser
# @param $2 : Masque des fichiers à purger
# @param $3 : Retention
##
function backup_purge()
{
    local LIST_FILE_PURGED=$(core_makeTemp)
    logger_debug "backup_purge ($1, $2, $3)"

    filesystem_purgeStandard "$1" "$2" "$3" "${LIST_FILE_PURGED}"

    stdout_messageReturn $? "Purge des anciennes sauvegardes" "$(cat ${LIST_FILE_PURGED} | wc -l)"
    report_messageReturn $? "Purge des anciennes sauvegardes" "$(cat ${LIST_FILE_PURGED} | wc -l)"
    stdout_printFile $? "${LIST_FILE_PURGED}"
    report_printFile $? "${LIST_FILE_PURGED}"
    [[ $? -ne 0 ]] && logger_error

    stdout_messageReturn 0 "Liste des sauvegardes restantes" "$(find $1 -name "$2" | wc -l)"
    report_messageReturn 0 "Liste des sauvegardes restantes" "$(find $1 -name "$2" | wc -l)"
    find $1 -name "$2" -exec basename \{\} \; # > ${LIST_FILE_PURGED}
    stdout_printFile $? "${LIST_FILE_PURGED}"
    report_printFile $? "${LIST_FILE_PURGED}"

    [[ $? -ne 0 ]] && logger_error
    rm -f ${LIST_FILE_PURGED}
}


###
# Fait une sauvegarde d'une base MySQL
# @param $1 : Nom de la base
##
function backup_baseMySQL()
{
	local DUMP="/tmp/dump-$1-${OLIX_SYSTEM_DATE}.sql"

	logger_debug "backup_baseMySQL ($1) -> ${DUMP}"

    mysql_dumpDatabaseLocal "${I}" "${DUMP}"
    stdout_messageReturn $? "Sauvegarde de la base" "$(stdout_getSizeFileHuman ${DUMP})"
    report_messageReturn $? "Sauvegarde de la base" "$(stdout_getSizeFileHuman ${DUMP})"
    [[ $? -ne 0 ]] && logger_error

    backup_compress "${OLIX_CONF_PROJECT_BACKUP_COMPRESS}" "${DUMP}"
    DUMP=${OLIX_FUNCTION_RESULT}
        
    #[ ! -z ${INI_BACKUP_FTP_SYNC} ] && filesystem_transfertFTP "${INI_BACKUP_FTP_SYNC}" "${INI_BACKUP_FTP_HOST}" "${INI_BACKUP_FTP_USER}" "${INI_BACKUP_FTP_PASS}" \
    #                                                           "${INI_BACKUP_FTP_PATH}" "/tmp/${_PB_DUMP_NAME}"

    backup_moveArchive "${DUMP}" "${OLIX_CONF_PROJECT_BACKUP_REPOSITORY}"

    backup_purge "${OLIX_CONF_PROJECT_BACKUP_REPOSITORY}" "dump-$I-*" "${OLIX_CONF_PROJECT_BACKUP_PURGE}"
}


###
# Fait une sauvegarde d'un répertoire
# @param $1 : Nom du dossier
# @param $2 : Code pour le nommage du fichier
# @param $3 : Fichier à exclure
##
function backup_directory()
{
    local FILEBCK="/tmp/backup-$2-${OLIX_SYSTEM_DATE}.tar"

    logger_debug "backup_directory ($1, $2, $3) -> ${FILEBCK}"

    filesystem_makeArchive "$1" "${FILEBCK}" "$3"
    stdout_messageReturn $? "Archivage du dossier" "$(stdout_getSizeFileHuman ${FILEBCK})"
    report_messageReturn $? "Archivage du dossier" "$(stdout_getSizeFileHuman ${FILEBCK})"
    [[ $? -ne 0 ]] && logger_error

    backup_compress "${OLIX_CONF_PROJECT_BACKUP_COMPRESS}" "${FILEBCK}"
    FILEBCK=${OLIX_FUNCTION_RESULT}
        
    #[ ! -z ${INI_BACKUP_FTP_SYNC} ] && filesystem_transfertFTP "${INI_BACKUP_FTP_SYNC}" "${INI_BACKUP_FTP_HOST}" "${INI_BACKUP_FTP_USER}" "${INI_BACKUP_FTP_PASS}" \
    #                                                           "${INI_BACKUP_FTP_PATH}" "/tmp/${_PB_FILEBCK_NAME}"

    backup_moveArchive "${FILEBCK}" "${OLIX_CONF_PROJECT_BACKUP_REPOSITORY}"

    backup_purge "${OLIX_CONF_PROJECT_BACKUP_REPOSITORY}" "backup-$2-*" "${OLIX_CONF_PROJECT_BACKUP_PURGE}"
}