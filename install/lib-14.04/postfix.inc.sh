###
# Installation et Configuration de POSTFIX
# ==============================================================================
# - Installation des APT
# - Lancement du configurateur
# - Modification du hostname
# ------------------------------------------------------------------------------
# OLIX_INSTALL_POSTFIX     : true pour l'installation
# OLIX_INSTALL_POSTFIX_RELAY   : Relai SMTP
# OLIX_INSTALL_POSTFIX_AUTH    : Authentification Login:Password
# ------------------------------------------------------------------------------
# @modified 11/05/2014
# Plus besoin de changer le hostname du postix : utilisation du FQDN du système
# @modified 16/06/2014
# sendmail obselete -> postfix obligatoire
# Permettre un relai SMTP avec authentification
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 11/05/2014
##



###
# Test si Postfix doit être installé
##
[[ "${OLIX_INSTALL_POSTFIX}" != "true" ]] && logger_warning "Installation de POSTFIX ignorée" && return


echo
echo -e "${CVIOLET} Configuration de POSTFIX ${CVOID}"
echo -e "${CBLANC}===============================================================================${CVOID}"

__PATH_CONFIG="${OLIX_INSTALL_PATH_CONFIG}/postfix"



###
# Installation
##
logger_debug "Installation des packages Postfix"
apt-get --yes install mailutils postfix libsasl2-modules sasl2-bin



###
# Lancement du configurateur
##
#echo -e "Configurer en mode ${CCYAN}Internet avec un smarthost${CVOID}"; sleep 3
#dpkg-reconfigure postfix
logger_debug "Changement du relay =  ${OLIX_INSTALL_POSTFIX_RELAY}"
postconf -e "relayhost = ${OLIX_INSTALL_POSTFIX_RELAY}"


###
# Modification de la conf en mode authentification
##
if [[ ! -z ${OLIX_INSTALL_POSTFIX_AUTH} ]]; then
	logger_debug "Modification de la conf postfix"
	postconf -e 'smtpd_sasl_auth_enable = no'
	postconf -e 'smtp_sasl_auth_enable = yes'
	postconf -e 'smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd'
	postconf -e 'smtpd_sasl_local_domain = $myhostname'
	postconf -e 'smtp_sasl_security_options = noanonymous'
	postconf -e 'smtp_sasl_tls_security_options = noanonymous'
	logger_debug "Création du fichier d'authentification sasl_passwd"
	echo "${OLIX_INSTALL_POSTFIX_RELAY}    ${OLIX_INSTALL_POSTFIX_AUTH}" > /etc/postfix/sasl_passwd
	postmap /etc/postfix/sasl_passwd > ${OLIX_LOGGER_FILE_ERR} 2>&1
	[[ $? -ne 0 ]] && logger_error
	rm -f /etc/postfix/sasl_passwd
	echo -e "Authentification sur ${CCYAN}${OLIX_INSTALL_POSTFIX_RELAY}${CVOID} : ${CVERT}OK ...${CVOID}"
fi


###
# Redémarrage du service
##
logger_debug "Redémarrage du service Postfix"
service postfix restart

