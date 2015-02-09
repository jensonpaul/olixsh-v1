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
    local START=${SECONDS}

    mv $1 $2/ > ${OLIX_LOGGER_FILE_ERR} 2>&1

    stdout_printMessageReturn $? "Déplacement vers le dossier de backup" "" "$((SECONDS-START))"
    report_printMessageReturn $? "Déplacement vers le dossier de backup" "" "$((SECONDS-START))"
    [[ $? -ne 0 ]] && report_warning && logger_warning && return 1
    return 0
}


###
# Compression d'un fichier de sauvegarde
# @param $1 : Type de compression
# @param $2 : Fichier à compresser
# @return OLIX_FUNCTION_RESULT : Nom du fichier compressé
##
function backup_compress()
{
    logger_debug "backup_compress ($1, $2)"
    local FILE RET
    local START=${SECONDS}

    case $1 in
        BZ|bz|BZ2|bz2)  FILE=$(filesystem_compressBZ2 $2)
                        RET=$?
                        ;;
        GZ|gz)          FILE=$(filesystem_compressGZ $2)
                        RET=$?
                        ;;
        *)              logger_warning "Le type de compression \"$1\" n'est pas disponible"
                        OLIX_FUNCTION_RESULT=$2
                        return 0;;
    esac
    
    stdout_printMessageReturn ${RET} "Compression du fichier" "$(stdout_getSizeFileHuman ${FILE})" "$((SECONDS-START))"
    report_printMessageReturn ${RET} "Compression du fichier" "$(stdout_getSizeFileHuman ${FILE})" "$((SECONDS-START))"

    [[ $? -ne 0 ]] && report_warning && logger_warning && return 1
    OLIX_FUNCTION_RESULT=${FILE}
    return 0
}


###
# Transfert le fichier backup vers un serveur FTP
# $1 : Type de FTP
# $2 : Host du serveur FTP
# $3 : Utilisateur du serveur FTP
# $4 : Mot de passe du serveur FTP
# $5 : Dossier de dépôt du serveur FTP
# $6 : Nom du fichier à transferer
##
function backup_transfertFTP()
{
    logger_debug "backup_transfertFTP ($1, $2, $3, $4, $5, $6)"
    local START=${SECONDS}

    ftp_put "$1" "$2" "$3" "$4" "$5" "$6"

    stdout_printMessageReturn $? "Transfert vers le serveur de backup" "" "$((SECONDS-START))"
    report_printMessageReturn $? "Transfert vers le serveur de backup" "" "$((SECONDS-START))"
    [[ $? -ne 0 ]] && report_warning && logger_warning && return 1
    return 0
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
    local RET

    case $3 in
        LOG|log)    filesystem_purgeLogarithmic "$1" "$2" "${LIST_FILE_PURGED}"
                    RET=$?;;
        *)          filesystem_purgeStandard "$1" "$2" "$3" "${LIST_FILE_PURGED}"
                    RET=$?;;
    esac

    stdout_printInfo "Purge des anciennes sauvegardes" "$(cat ${LIST_FILE_PURGED} | wc -l)"
    report_printInfo "Purge des anciennes sauvegardes" "$(cat ${LIST_FILE_PURGED} | wc -l)"
    stdout_printFile "${LIST_FILE_PURGED}"
    report_printFile "${LIST_FILE_PURGED}" "font-size:0.8em;color:Olive;"
    [[ ${RET} -ne 0 ]] && report_error && logger_error

    stdout_printInfo "Liste des sauvegardes restantes" "$(find $1 -name "$2" | wc -l)"
    report_printInfo "Liste des sauvegardes restantes" "$(find $1 -name "$2" | wc -l)"
    find $1 -name "$2" -printf "%f\n" |sort > ${LIST_FILE_PURGED}
    RET=$?
    stdout_printFile "${LIST_FILE_PURGED}"
    report_printFile "${LIST_FILE_PURGED}" "font-size:0.8em;color:SteelBlue;"

    [[ $? -ne 0 ]] && report_warning && logger_warning && return 1
    rm -f ${LIST_FILE_PURGED}
    return 0
}


###
# Fait une sauvegarde d'une base MySQL
# @param $1 : Nom de la base
##
function backup_baseMySQL()
{
	local DUMP="/tmp/dump-$1-${OLIX_SYSTEM_DATE}.sql"

	logger_debug "backup_baseMySQL ($1) -> ${DUMP}"

    local START=${SECONDS}
    mysql_dumpDatabaseLocal "${I}" "${DUMP}"
    stdout_printMessageReturn $? "Sauvegarde de la base" "$(stdout_getSizeFileHuman ${DUMP})" "$((SECONDS-START))"
    report_printMessageReturn $? "Sauvegarde de la base" "$(stdout_getSizeFileHuman ${DUMP})" "$((SECONDS-START))"
    [[ $? -ne 0 ]] && report_warning && logger_warning && return 1

    backup_compress "${OLIX_CONF_PROJECT_BACKUP_COMPRESS}" "${DUMP}"
    [[ $? -ne 0 ]] && return 1
    DUMP=${OLIX_FUNCTION_RESULT}
        
    if [[ ${OLIX_CONF_PROJECT_BACKUP_FTP_SYNC} != false ]]; then
        backup_transfertFTP "${OLIX_CONF_PROJECT_BACKUP_FTP_SYNC}" \
            "${OLIX_CONF_PROJECT_BACKUP_FTP_HOST}" "${OLIX_CONF_PROJECT_BACKUP_FTP_USER}" "${OLIX_CONF_PROJECT_BACKUP_FTP_PASS}" \
            "${OLIX_CONF_PROJECT_BACKUP_FTP_PATH}" "${DUMP}"
        [[ $? -ne 0 ]] && return 1
    fi

    backup_moveArchive "${DUMP}" "${OLIX_CONF_PROJECT_BACKUP_REPOSITORY}"
    [[ $? -ne 0 ]] && return 1

    backup_purge "${OLIX_CONF_PROJECT_BACKUP_REPOSITORY}" "dump-$I-*" "${OLIX_CONF_PROJECT_BACKUP_PURGE}"
    [[ $? -ne 0 ]] && return 1

    return 0
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

    local START=${SECONDS}
    filesystem_makeArchive "$1" "${FILEBCK}" "$3"
    stdout_printMessageReturn $? "Archivage du dossier" "$(stdout_getSizeFileHuman ${FILEBCK})" "$((SECONDS-START))"
    report_printMessageReturn $? "Archivage du dossier" "$(stdout_getSizeFileHuman ${FILEBCK})" "$((SECONDS-START))"
    [[ $? -ne 0 ]] && report_warning && logger_warning && return 1

    backup_compress "${OLIX_CONF_PROJECT_BACKUP_COMPRESS}" "${FILEBCK}"
    [[ $? -ne 0 ]] && return 1
    FILEBCK=${OLIX_FUNCTION_RESULT}
    
    if [[ ${OLIX_CONF_PROJECT_BACKUP_FTP_SYNC} != false ]]; then
        backup_transfertFTP "${OLIX_CONF_PROJECT_BACKUP_FTP_SYNC}" \
            "${OLIX_CONF_PROJECT_BACKUP_FTP_HOST}" "${OLIX_CONF_PROJECT_BACKUP_FTP_USER}" "${OLIX_CONF_PROJECT_BACKUP_FTP_PASS}" \
            "${OLIX_CONF_PROJECT_BACKUP_FTP_PATH}" "${FILEBCK}"
        [[ $? -ne 0 ]] && return 1
    fi

    backup_moveArchive "${FILEBCK}" "${OLIX_CONF_PROJECT_BACKUP_REPOSITORY}"
    [[ $? -ne 0 ]] && return 1

    backup_purge "${OLIX_CONF_PROJECT_BACKUP_REPOSITORY}" "backup-$2-*" "${OLIX_CONF_PROJECT_BACKUP_PURGE}"
    [[ $? -ne 0 ]] && return 1

    return 0
}
