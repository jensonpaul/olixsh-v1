###
# Librairies de gestions des transferts FTP
# ==============================================================================
# @package olixsh
# @author Olivier
# @created 21/05/2014
##


###
# Vérifie si le binaire est installé
# @param $1 : Nom du binaire
##
function ftp_isInstalled()
{
	logger_debug "ftp_isInstalled ($1)"
	which $1 > /dev/null 2>&1
	return  $?
}


###
# Transfert d'un fichier sur un serveur FTP
# $1 : Type de FTP
# $2 : Host du serveur FTP
# $3 : Utilisateur du serveur FTP
# $4 : Mot de passe du serveur FTP
# $5 : Dossier de dépôt du serveur FTP
# $6 : Nom du fichier à transferer
##
function ftp_put()
{
	logger_debug "ftp_put ($1, $2, $3, $4, $5, $6)"
	case $1 in
		LFTP|lftp)		ftp_putLFTP "$2" "$3" "$4" "$5" "$6";;
		NCFTP|ncftp)	ftp_putNCFTP "$2" "$3" "$4" "$5" "$6";;
		*)				logger_warning "Le type de transfert FTP \"$1\" n'existe pas"
	esac
    return $?
}


###
# Transfert d'un fichier sur un serveur FTP par LFTP
# $1 : Host du serveur FTP
# $2 : Utilisateur du serveur FTP
# $3 : Mot de passe du serveur FTP
# $4 : Dossier de dépôt du serveur FTP
# $5 : Nom du fichier à transferer
##
function ftp_putLFTP()
{
	logger_debug "ftp_putLFTP ($1, $2, $3, $4, $5)"
	lftp ftp://$2:$3@$1 -e "put -O $4 $5; quit" > /dev/null 2>> ${OLIX_LOGGER_FILE_ERR}
	return $?
}


###
# Transfert d'un fichier sur un serveur FTP par NCFTP
# $1 : Host du serveur FTP
# $2 : Utilisateur du serveur FTP
# $3 : Mot de passe du serveur FTP
# $4 : Dossier de dépôt du serveur FTP
# $5 : Nom du fichier à transferer
##
function ftp_putNCFTP()
{
	logger_debug "ftp_putNCFTP ($1, $2, $3, $4, $5)"
	ncftpput -C -u $2 -p $3 $1 $5 .$4/$(basename $5) > /dev/null 2>> ${OLIX_LOGGER_FILE_ERR}
	return $?
}


###
# Synchronisation par mirroir d'un serveur FTP depuis le dépot local
# $1 : Type de FTP
# $2 : Host du serveur FTP
# $3 : Utilisateur du serveur FTP
# $4 : Mot de passe du serveur FTP
# $5 : Dossier de dépôt du serveur FTP
# $6 : Dossier local
##
function ftp_synchronize()
{
	logger_debug "ftp_synchronize ($1, $2, $3, $4, $5, $6)"
	case $1 in
		LFTP|lftp)		ftp_synchronizeLFTP "$2" "$3" "$4" "$5" "$6";;
		NCFTP|ncftp)	ftp_synchronizeNCFTP "$2" "$3" "$4" "$5" "$6";;
		*)				logger_warning "Le type de transfert FTP \"$1\" n'existe pas"
	esac
    return $?
}


###
# Synchronisation par mirroir d'un serveur FTP depuis le dépot local par LFTP
# $1 : Host du serveur FTP
# $2 : Utilisateur du serveur FTP
# $3 : Mot de passe du serveur FTP
# $4 : Dossier de dépôt du serveur FTP
# $5 : Dossier local
##
function ftp_synchronizeLFTP()
{
	logger_debug "ftp_synchronizeLFTP ($1, $2, $3, $4, $5)"
	lftp ftp://$2:$3@$1 -e "mirror -e --only-missing -v -R $5 $4; quit" > /dev/null 2>> ${OLIX_LOGGER_FILE_ERR}
	return $?
}


###
# Synchronisation par mirroir d'un serveur FTP depuis le dépot local par NCFTP
# $1 : Host du serveur FTP
# $2 : Utilisateur du serveur FTP
# $3 : Mot de passe du serveur FTP
# $4 : Dossier de dépôt du serveur FTP
# $5 : Nom du fichier à transferer
##
function ftp_synchronizeNCFTP()
{
	logger_debug "ftp_synchronizeNCFTP ($1, $2, $3, $4, $5)"

	local LISTFTP=$(ncftpls -l -u $2 -p $3 ftp://$1$4)
    local LISTLOCAL=$(ls $5)

    # Ajoute les fichiers manquants sur le serveur FTP
    for J in ${LISTLOCAL}; do
    	if ! echo "${LISTFTP}" | grep "$J" > /dev/null; then
    		#logger_info "Transfert du fichier $J"
    		ncftpput -C -u $2 -p $3 $1 $5/$J .$4/$J > /dev/null 2>> ${OLIX_LOGGER_FILE_ERR}
        fi
    done

    # Supprime les fichiers en trop sur le serveur FTP
    while IFS='\n' read LINE; do
    	J=$(echo ${LINE} | awk '{print $9}')
    	if ! echo ${LISTLOCAL} | grep "$J" > /dev/null; then
    		#logger_info "Suppression de l'ancien fichier $J"
    		ncftp -u $2 -p $3 ftp://$1 > /dev/null 2>> ${OLIX_LOGGER_FILE_ERR} <<EOF
                delete $4/$J
                bye
EOF
        fi
    done < <(echo "${LISTFTP}")

	return 0
}