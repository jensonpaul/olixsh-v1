###
# Librairies de la gestion de système de fichiers
# ==============================================================================
# @package olixsh
# @author Olivier
# @created 09/04/2014
##


###
# Crée le fichier d'exclusion pour la synchronisation
# @param $1 : Nom du fichier exclude
# @param $2 : Liste des exclusions
##
function filesystem_createFileExclude()
{
	logger_debug "filesystem_createFileExclude($1, $2)"
	echo "" > $1
	for I in $2; do
		echo $I >> $1
	done
	sed -i "s/\\\//g" $1
}


###
# Fait une synchronisation depuis un serveur distant
# @param $1 : Port
# @param $2 : Chemin source (path | host+path)
# @param $3 : Chemin destination (path | host+path)
# @param $4 : Exclusion
##
function filesystem_synchronize()
{
	local FILE_EXCLUDE
    FILE_EXCLUDE=$(core_makeTemp)
    filesystem_createFileExclude "${FILE_EXCLUDE}" "$4"
	logger_debug "Synchronisation port $1 de $2 vers $3"
    rsync --rsh="ssh -p $1" --archive --compress --progress --delete --exclude-from=${FILE_EXCLUDE} $2/ $3/ 2> ${OLIX_LOGGER_FILE_ERR}
    RET=$?
	rm -f ${FILE_EXCLUDE}
	[[ $RET -ne 0 ]] && return 1
	return 0
}


###
# Compression au format GZ d'un fichier
# @param $1 : Nom du fichier
# @return   : Nom du fichier compressé
##
function filesystem_compressGZ()
{
	logger_debug "Compression GZIP de $1"
	gzip --force $1 > ${OLIX_LOGGER_FILE_ERR} 2>&1
	[[ $? -ne 0 ]] && return 1
	echo "$1.gz"
	return 0
}


###
# Compression au format BZ2 d'un fichier
# @param $1 : Nom du fichier
# @return   : Nom du fichier compressé
##
function filesystem_compressBZ2()
{
	logger_debug "Compression BZIP2 de $1"
	bzip2 --force $1 > ${OLIX_LOGGER_FILE_ERR} 2>&1
	[[ $? -ne 0 ]] && return 1
	echo "$1.bz2"
	return 0
}


###
# Purge normal correspondant aux derniers jours
# @param $1 : Emplacement des fichiers à purger
# @param $2 : Masque correspondant aux fichiers à effacer
# @param $3 : Nombre de jours de retention
# @param $4 : Fichier qui contiendra la liste des fichiers purgés
##
function filesystem_purgeStandard()
{
	local FREDIRECT
	[[ -z $4 ]] && FREDIRECT="/dev/null" || FREDIRECT=$4
	logger_debug "filesystem_purgeStandard ($1, $2, $3, $FREDIRECT)"
    find $1 -name "$2*" -mtime +$3 -delete -print > ${FREDIRECT} 2> ${OLIX_LOGGER_FILE_ERR}
    return $?
}


###
# Archive un repertoire
# @param $1 : Nom du repertoire
# @param $2 : Nom de l'archive
# @param $3 : Exclusion
##
function filesystem_makeArchive()
{
	local PWDTMP
	local FILE_EXCLUDE=$(core_makeTemp)
	logger_debug "filesystem_makeArchive ($1, $2, $3)"

    filesystem_createFileExclude "${FILE_EXCLUDE}" "$3"
    
    PWDTMP=$(pwd)
    cd $1 2>> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && cd ${PWDTMP} && return 1
    
    tar --create --file $2 --exclude-from ${FILE_EXCLUDE} . 2>> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && cd ${PWDTMP} && return 1
    
    rm -f ${FILE_EXCLUDE}
    return 0
}