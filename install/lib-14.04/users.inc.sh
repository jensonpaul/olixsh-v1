###
# Création des utilisateurs
# ==============================================================================
# - Création ou modification de l'utilisateur
# - Changement du prompt
# - Création des clés public et privée
# ------------------------------------------------------------------------------
# OLIX_INSTALL_USER_NAME[x]  : Nom de l'utilisateur
# OLIX_INSTALL_USER_PARAM[x] : Paramètres de l'utilisateur pour la création
# ------------------------------------------------------------------------------
# @package olixsh
# @author Olivier
# @created 09/05/2014
##


echo
echo -e "${CVIOLET} Création et configuration du profile des utilisateurs ${CVOID}"
echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"


###
# ROOT
##
logger_debug "Couleur du prompt de root"
sed -i "s/\#force_color_prompt/force_color_prompt/g" /root/.bashrc
sed -i "s/\;32m/;31m/g" /root/.bashrc

if [ ! -f /root/.ssh/id_dsa ]; then
	logger_debug "Génération des clés publiques de root"
    ssh-keygen -q -t dsa -f ~/.ssh/id_dsa -N ""
    [[ $? -ne 0 ]] && logger_error "Génération des clés publiques de root"
fi
echo -e "Configuration de l'utilisateur ${CCYAN}root${CVOID} : ${CVERT}OK ...${CVOID}"


###
# Création des users définis dans le tableau
##
for I in $(seq 1 $((${#OLIX_INSTALL_USER_NAME[@]}))); do

    UTILISATEUR=${OLIX_INSTALL_USER_NAME[$I]}
    # Test si l'utilisateur existe deja
    if cut -d : -f 1 /etc/passwd | grep ^${UTILISATEUR}$ > /dev/null; then
    	  logger_debug "Modification de l'utilisateur ${UTILISATEUR}"
        usermod ${OLIX_INSTALL_USER_PARAM[$I]} ${UTILISATEUR} > ${OLIX_LOGGER_FILE_ERR} 2>&1
        [[ $? -ne 0 ]] && logger_error "Modification de l'utilisateur ${UTILISATEUR}"
    else
        logger_debug "Création de l'utilisateur ${UTILISATEUR}"
        useradd ${OLIX_INSTALL_USER_PARAM[$I]} ${UTILISATEUR} > ${OLIX_LOGGER_FILE_ERR} 2>&1
        [[ $? -ne 0 ]] && logger_error "Création de l'utilisateur ${UTILISATEUR}"
        echo -e "Mode de passe pour ${CCYAN}${UTILISATEUR}${CVOID}"
        passwd ${UTILISATEUR}
   fi
   
   # Customisation
   if su ${UTILISATEUR} -c "ls ~/.bashrc" > /dev/null 2>&1 ; then
       logger_debug "Couleur du prompt de ${UTILISATEUR}"
       su - ${UTILISATEUR} -c "sed -i 's/\#force_color_prompt/force_color_prompt/g' ~/.bashrc" > ${OLIX_LOGGER_FILE_ERR} 2>&1
       [[ $? -ne 0 ]] && logger_error "Couleur du prompt de ${UTILISATEUR}"
       
       if [ ! -f /home/${UTILISATEUR}/.ssh/id_dsa ]; then
       		logger_debug "Génération de la clé publique et privée de ${UTILISATEUR}"
     	    su - ${UTILISATEUR} -c "ssh-keygen -q -t dsa -f ~/.ssh/id_dsa -N ''" > ${OLIX_LOGGER_FILE_ERR} 2>&1
            [[ $? -ne 0 ]] && logger_error "Génération de la clé publique et privée de ${UTILISATEUR}"
        fi
    fi

    echo -e "Configuration de l'utilisateur ${CCYAN}${UTILISATEUR}${CVOID} : ${CVERT}OK ...${CVOID}"
    
done


###
# Place les bons droits sur le répertoire de configuration
##
logger_debug "chown -R ${OLIX_CONF_SERVER_INSTALL_PERMISSION} ${OLIX_CONFIG_PATH}"
chown -R ${OLIX_CONF_SERVER_INSTALL_PERMISSION} ${OLIX_CONFIG_PATH}  > ${OLIX_LOGGER_FILE_ERR} 2>&1
[[ $? -ne 0 ]] && logger_error "Permissions des droit sur ${OLIX_CONFIG_PATH}"
echo -e "Permissions sur ${CCYAN}${OLIX_CONFIG_PATH}${CVOID} : ${CVERT}OK ...${CVOID}"
