###
# Gestion du serveur de base de données MySQL
# ==============================================================================
# @package olixsh
# @author Olivier
# @created 08/04/2014
##


###
# Test si MySQL est installé
##
function mysql_isInstalled()
{
	[[ ! -f /etc/mysql/my.cnf ]] && return 1
	return 0
}


###
# Test si MySQL est en execution
##
function mysql_isRunning()
{
	netstat -ntpul | grep mysql > /dev/null 2>&1
	[[ $? -ne 0 ]] && return 1
	return 0
}


###
# Retroune la liste des bases de données
# @param $1 : Host du serveur MySQL
# @param $2 : Port du serveur
# @param $3 : Utilisateur mysql
# @param $4 : Mot de passe
# @return : Liste
##
function mysql_getListDatabases()
{
    local DATABASES
    logger_debug "Retourne la liste des bases de $1"
    if [[ -z $4 ]]; then
        DATABASES=$(mysql --host=$1 --port=$2 --user=$3 -p --execute='SHOW DATABASES' | grep -vE "(Database|information_schema|performance_schema|mysql|lost\+found)")
    else
        DATABASES=$(mysql --host=$1 --port=$2 --user=$3 --password=$4 --execute='SHOW DATABASES' | grep -vE "(Database|information_schema|performance_schema|mysql|lost\+found)")
    fi
    [[ $? -ne 0 ]] && return 1
	echo -n ${DATABASES}
	return 0
}


###
# Retroune la liste des bases de données localement
# @return : Liste
##
function mysql_getListDatabasesLocal()
{
    echo -n $(mysql_getListDatabases ${OLIX_CONF_SERVER_MYSQL_HOST} ${OLIX_CONF_SERVER_MYSQL_PORT} ${OLIX_CONF_SERVER_MYSQL_USER} ${OLIX_CONF_SERVER_MYSQL_PASS})
    [[ $? -ne 0 ]] && return 1
	return 0
}


###
# Affiche le menu du choix de la base de données
# @param $1 : Host du serveur MySQL
# @param $2 : Port du serveur
# @param $3 : Utilisateur mysql
# @param $4 : Mot de passe
# @param $5 : Base par défaut
# @param $6 : Possibilité de créer une nouvelle base
# @return $OLIX_FONCTION_RESULT : Nom de la base
##
function mysql_printMenuListDataBases()
{
    local BASE
    local LIST_BASE
    LIST_BASE=$(mysql_getListDatabases $1 $2 $3 $4)
    [[ $? -ne 0 ]] && return 1
    while true; do
        echo -e "${CBLANC}Choix de la base de donnée${CVOID}";
        for I in ${LIST_BASE}; do
            echo -e "${CJAUNE} $I${CVOID} : Base ${I}"
        done
        [[ "$6" == "true" ]] && echo -e "${CJAUNE} nouveau${CVOID} : Nouvelle base"
        echo -en "${Cjaune}Ton choix ${CJAUNE}[$5]${CVOID} : "
        read BASE
        [[ -z $BASE ]] && BASE=$5
        [[ "|${LIST_BASE// /|}|" =~ "|${BASE}|" ]] && break
        [[ "${BASE}" == "nouveau" ]] && break
    done
    OLIX_FONCTION_RESULT=${BASE}
    # Si nouveau, on crée la base
    if [[ "${BASE}" == "nouveau" ]]; then
        echo -en "${Cjaune}Nom de la base à créer ? ${CVOID}"
        read BASE
        OLIX_FONCTION_RESULT=${BASE}
        mysql_createDatabase $1 $2 $3 $4 ${BASE}
        [[ $? -ne 0 ]] && return 1
    fi
    return 0
}


###
# Affiche le menu du choix de la base de données locale
# @param $1 : Base par défaut
# @param $2 : Possibilité de créer une nouvelle base
# @return $OLIX_FONCTION_RESULT : Nom de la base
##
function mysql_printMenuListDataBasesLocal()
{
    mysql_printMenuListDataBases "${OLIX_CONF_SERVER_MYSQL_HOST}" "${OLIX_CONF_SERVER_MYSQL_PORT}" \
								 "${OLIX_CONF_SERVER_MYSQL_USER}" "${OLIX_CONF_SERVER_MYSQL_PASS}" \
								 "$1" "$2"
    return $?
}


###
# Crée le rôle olix qui permettra à olixsh de se connecter directement
# @param $1 : Host du serveur MySQL
# @param $2 : Port du serveur
# @param $3 : Utilisateur mysql
# @param $4 : Nom du rôle
# @param $5 : Mot de passe du rôle
##
function mysql_createRoleOliX()
{
	logger_debug "MySQL -- GRANT ALL PRIVILEGES ON *.* TO '$4'@'localhost' IDENTIFIED BY '$5' WITH GRANT OPTION"
	echo -en "Mot de passe à la base avec l'utilisateur ${CCYAN}root${CVOID} "
	mysql --host=$1 --port=$2 --user=$3 -p \
		--execute="GRANT ALL PRIVILEGES ON *.* TO '$4'@'localhost' IDENTIFIED BY '$5' WITH GRANT OPTION;" \
		> ${OLIX_LOGGER_FILE_ERR} 2>&1
	[[ $? -ne 0 ]] && return 1
	return 0
}


###
# Crée un rôle
# @param $1 : Host du serveur MySQL
# @param $2 : Port du serveur
# @param $3 : Utilisateur mysql
# @param $4 : Mot de passe
# @param $5 : Nom du rôle
# @param $6 : Mot de passe du rôle
# @param $7 : Nom de la base du rôle
##
function mysql_createRole()
{
	logger_debug "MySQL - $1 -- GRANT ALL PRIVILEGES ON $7.* TO '$5'@'localhost' IDENTIFIED BY '$6'"
	if [[ -z $4 ]]; then
    	mysql --host=$1 --port=$2 --user=$3 -p --execute="GRANT ALL PRIVILEGES ON $7.* TO '$5'@'localhost' IDENTIFIED BY '$6';" > ${OLIX_LOGGER_FILE_ERR} 2>&1
	else
    	mysql --host=$1 --port=$2 --user=$3 --password=$4 --execute="GRANT ALL PRIVILEGES ON $7.* TO '$5'@'localhost' IDENTIFIED BY '$6';" > ${OLIX_LOGGER_FILE_ERR} 2>&1
    fi
	[[ $? -ne 0 ]] && return 1
	return 0
}


###
# Crée un rôle localement
# @param $1 : Nom du rôle
# @param $2 : Mot de passe du rôle
# @param $3 : Nom de la base du rôle
##
function mysql_createRoleLocal()
{
	mysql_createRole "${OLIX_CONF_SERVER_MYSQL_HOST}" "${OLIX_CONF_SERVER_MYSQL_PORT}" \
					 "${OLIX_CONF_SERVER_MYSQL_USER}" "${OLIX_CONF_SERVER_MYSQL_PASS}" \
					 "$1" "$2" "$3"
	return $?
}


###
# Crée une nouvelle base de données
# @param $1 : Host du serveur MySQL
# @param $2 : Port du serveur
# @param $3 : Utilisateur mysql
# @param $4 : Mot de passe
# @param $5 : Nom de la base à créer
##
function mysql_createDatabase()
{
    logger_debug "MySQL - $1 -- CREATE DATABASE $5"
    if [[ -z $4 ]]; then
    	mysql --host=$1 --port=$2 --user=$3 -p --execute="CREATE DATABASE $5;" > ${OLIX_LOGGER_FILE_ERR} 2>&1
	else
    	mysql --host=$1 --port=$2 --user=$3 --password=$4 --execute="CREATE DATABASE $5;" > ${OLIX_LOGGER_FILE_ERR} 2>&1
    fi
    [[ $? -ne 0 ]] && return 1
	return 0
}


###
# Crée une nouvelle base de données localement
# @param $1 : Nom de la base à créer
##
function mysql_createDatabaseLocal()
{
    mysql_createDatabase "${OLIX_CONF_SERVER_MYSQL_HOST}" "${OLIX_CONF_SERVER_MYSQL_PORT}" \
						 "${OLIX_CONF_SERVER_MYSQL_USER}" "${OLIX_CONF_SERVER_MYSQL_PASS}" \
						 "$1"
	return $?
}


###
# Supprime une base de données
# @param $1 : Host du serveur MySQL
# @param $2 : Port du serveur
# @param $3 : Utilisateur mysql
# @param $4 : Mot de passe
# @param $5 : Nom de la base à supprimer
##
function mysql_dropDatabase()
{
	logger_debug "MySQL - $1 -- DROP DATABASE IF EXISTS $5"
    if [[ -z $4 ]]; then
    	mysql --host=$1 --port=$2 --user=$3 -p --execute="DROP DATABASE IF EXISTS $5;" > ${OLIX_LOGGER_FILE_ERR} 2>&1
	else
    	mysql --host=$1 --port=$2 --user=$3 --password=$4 --execute="DROP DATABASE IF EXISTS $5;" > ${OLIX_LOGGER_FILE_ERR} 2>&1
    fi
    [[ $? -ne 0 ]] && return 1
	return 0
}


###
# Supprime une base de données localement
# @param $1 : Nom de la base à supprimer
##
function mysql_dropDatabaseLocal()
{
	mysql_dropDatabase "${OLIX_CONF_SERVER_MYSQL_HOST}" "${OLIX_CONF_SERVER_MYSQL_PORT}" \
					   "${OLIX_CONF_SERVER_MYSQL_USER}" "${OLIX_CONF_SERVER_MYSQL_PASS}" \
					   "$1"
	return $?
}


###
# Synchronise une base distante vers une localement
# @param $1 : Host du serveur MySQL distant
# @param $2 : Port du serveur distant
# @param $3 : Utilisateur mysql distant
# @param $4 : Nom de la base source
# @param $5 : Nom de la base destination
##
function mysql_synchronizeDatabase() {
	logger_debug "MySQL -- Synchronisation de $1:$4 vers localhost:$5"
	echo -en "Mot de passe MySQL de ${CCYAN}$3@$1${CVOID} "
	for J in 1 2 3; do
		mysqldump -v --opt --host=$1 --port=$2 --user=$3 -p $4 | \
    	mysql --host=${OLIX_CONF_SERVER_MYSQL_HOST} --port=${OLIX_CONF_SERVER_MYSQL_PORT} \
    		  --user=${OLIX_CONF_SERVER_MYSQL_USER} --password=${OLIX_CONF_SERVER_MYSQL_PASS} \
    	  	  $5
    	[[ $? -eq 0 && ${PIPESTATUS} -eq 0 ]] && return 0
   	done
	return 1
}


###
# Fait un dump d'une base
# @param $1  : Host du serveur MySQL
# @param $2  : Port du serveur
# @param $3  : Utilisateur mysql
# @param $4  : Mot de passe
# @param $5  : Nom de la base
# @param $6  : Fichier de dump
##
function mysql_dumpDatabase()
{
	logger_debug "MySQL -- Dump de la base $1:$5 vers $6"
    if [[ -z $4 ]]; then
        mysqldump --opt --host=$1 --port=$2 --user=$3 -p $5 > $6 2>> ${OLIX_LOGGER_FILE_ERR}
    else
        mysqldump --opt --host=$1 --port=$2 --user=$3 --password=$4 $5 > $6 2>> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
	return 0
}


###
# Fait un dump d'une base locale
# @param $1 : Nom de la base
# @param $2 : Fichier de dump
##
function mysql_dumpDatabaseLocal()
{
	mysql_dumpDatabase "${OLIX_CONF_SERVER_MYSQL_HOST}" "${OLIX_CONF_SERVER_MYSQL_PORT}" \
					   "${OLIX_CONF_SERVER_MYSQL_USER}" "${OLIX_CONF_SERVER_MYSQL_PASS}" \
					   "$1" "$2"
	return $?
}


###
# Restaure un dump d'une base
# @param $1  : Host du serveur MySQL
# @param $2  : Port du serveur
# @param $3  : Utilisateur mysql
# @param $4  : Mot de passe
# @param $5  : Fichier de dump
# @param $6  : Nom de la base
##
function mysql_restoreDatabase() {
	logger_debug "MySQL -- Restauration du dump $5 vers la base $1:$6"
    if [[ -z $4 ]]; then
        mysql --host=$1 --port=$2 --user=$3 -p $6 < $5 2>> ${OLIX_LOGGER_FILE_ERR}
    else
        mysql --host=$1 --port=$2 --user=$3 --password=$4 $6 < $5 2>> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
	return 0
}


###
# Restaure un dump d'une base eb local
# @param $1 : Fichier de dump
# @param $2 : Nom de la base
##
function mysql_restoreDatabaseLocal()
{
	mysql_restoreDatabase "${OLIX_CONF_SERVER_MYSQL_HOST}" "${OLIX_CONF_SERVER_MYSQL_PORT}" \
					      "${OLIX_CONF_SERVER_MYSQL_USER}" "${OLIX_CONF_SERVER_MYSQL_PASS}" \
					      "$1" "$2"
	return $?
}
