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
    FILE_EXCLUDE=$(mktemp)
    logger_debug "Création du fichier exclude ${FILE_EXCLUDE}"
	filesystem_createFileExclude "${FILE_EXCLUDE}" "$4"
	logger_debug "Synchronisation port $1 de $2 vers $3"
    rsync --rsh="ssh -p $1" --archive --compress --progress --delete --exclude-from=${FILE_EXCLUDE} $2/ $3/ 2> ${OLIX_LOGGER_FILE_ERR}
    RET=$?
	rm -f ${FILE_EXCLUDE}
	[[ $RET -ne 0 ]] && return 1
	return 0
}

