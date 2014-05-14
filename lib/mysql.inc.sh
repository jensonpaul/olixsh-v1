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
# @param $1 : Nom du rôle
# @param $2 : Mot de passe du rôle
# @param $3 : Nom de la base du rôle
##
function mysql_createRole()
{
	logger_debug "MySQL -- GRANT ALL PRIVILEGES ON $3.* TO '$1'@'localhost' IDENTIFIED BY '$2'"
	mysql --host=${OLIX_CONF_SERVER_MYSQL_HOST} --port=${OLIX_CONF_SERVER_MYSQL_PORT} \
		--user=${OLIX_CONF_SERVER_MYSQL_USER} --password=${OLIX_CONF_SERVER_MYSQL_PASS} \
		--execute="GRANT ALL PRIVILEGES ON $3.* TO '$1'@'localhost' IDENTIFIED BY '$2';" \
		> ${OLIX_LOGGER_FILE_ERR} 2>&1
	[[ $? -ne 0 ]] && return 1
	return 0
}


###
# Crée une nouvelle base de données
# @param $1 : Nom de la base à créer
##
function mysql_createDatabase()
{
    logger_debug "MySQL -- CREATE DATABASE $1"
    mysql --host=${OLIX_CONF_SERVER_MYSQL_HOST} --port=${OLIX_CONF_SERVER_MYSQL_PORT} \
    	  --user=${OLIX_CONF_SERVER_MYSQL_USER} --password=${OLIX_CONF_SERVER_MYSQL_PASS} \
    	  --execute="CREATE DATABASE $1;" \
		  > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && return 1
	return 0
}


###
# Supprime une base de données
# @param $1 : Nom de la base à supprimer
##
function mysql_dropDatabase()
{
    logger_debug "MySQL -- DROP DATABASE IF EXISTS $1"
    mysql --host=${OLIX_CONF_SERVER_MYSQL_HOST} --port=${OLIX_CONF_SERVER_MYSQL_PORT} \
    	  --user=${OLIX_CONF_SERVER_MYSQL_USER} --password=${OLIX_CONF_SERVER_MYSQL_PASS} \
    	  --execute="DROP DATABASE IF EXISTS $1;" \
		  > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && return 1
	return 0
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
