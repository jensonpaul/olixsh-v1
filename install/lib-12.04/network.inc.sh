###
# Configuration du réseau
# ==============================================================================
# - Changement de l'adresse IP
# - Ajout d'autre adresse IP
# - Modification du host en 127.0.1.1
# ------------------------------------------------------------------------------
# OLIX_INSTALL_NETWORK_ADDRIP    : Valeur de l'adresse IP à ajouter
# OLIX_INSTALL_NETWORK_NETMASK   : Masque réseau de cette IP
# OLIX_INSTALL_NETWORK_NETWORK   : Adresse du réseau
# OLIX_INSTALL_NETWORK_BROADCAST : Adresse du broadcast
# OLIX_INSTALL_NETWORK_GATEWAY   : Adresse de la passerelle
# OLIX_INSTALL_NETWORK_RESOLV    : Liste des serveurs DNS
# OLIX_INSTALL_NETWORK_ADD_IP[x] : Adresse IP supplémentaire
# ------------------------------------------------------------------------------
# @package olixsh
# @subpackage install
# @author Olivier
# @created 24/08/2013
##


echo
echo -e "${CVIOLET} Configuration réseau ${CVOID}"
echo -e "${CBLANC}===============================================================================${CVOID}"


###
# Affichage des infos
##
echo -en "Adresse IP courante : "
IP=`ifconfig eth0 | sed -n '/^[A-Za-z0-9]/ {N;/dr:/{;s/.*dr://;s/ .*//;p;}}'`
IP=`ifconfig eth0 | awk 'NR==2 {print $2}'| awk -F: '{print $2}'`
echo -e "${CBLEU}${IP}${CVOID}"

echo -en "Adresse IP à modifier : "
if [[ -z ${OLIX_INSTALL_NETWORK_ADDRIP} ]]; then
    echo -e "${CBLEU}-${CVOID}"
else
    echo -e "${CBLEU}${OLIX_INSTALL_NETWORK_ADDRIP}${CVOID}"
fi

for I in $(seq 0 $((${#OLIX_INSTALL_NETWORK_ADD_IP[@]} - 1))); do
    ADDRESS=${OLIX_INSTALL_NETWORK_ADD_IP[$I]}
    echo -en "Adresse IP à ajouter : "
    echo -e "${CBLEU}${ADDRESS}${CVOID}"
done


echo -en "Confirmer pour la modification de la conf réseau ${CJAUNE}[o/N]${CVOID} : "
read REPONSE


###
# Traitement
##
if [[ "${REPONSE}" == "o" ]]; then

    ###
    # Modification de l'IP
    ##
    if [[ ! -z ${OLIX_INSTALL_NETWORK_ADDRIP} ]]; then
        if [ ! -f /etc/network/interfaces.original ]; then
            logger_debug "Sauvegarde de l'original /etc/network/interfaces"
	        cp /etc/network/interfaces /etc/network/interfaces.original
            [[ $? -ne 0 ]] && logger_error "Sauvegarde de l'original /etc/network/interfaces"
        fi
        logger_debug "Remise de l'original de /etc/network/interfaces"
        cp /etc/network/interfaces.original /etc/network/interfaces
        [[ $? -ne 0 ]] && logger_error "Copie de l'original /etc/network/interfaces"
        # Ecrit dans le fichier de configuration /etc/network/interfaces
        echo -en "Adresse ${CCYAN}${OLIX_INSTALL_NETWORK_ADDRIP}${CVOID} à modifier : "
        echo "# The loopback network interface" > /etc/network/interfaces
        echo "auto lo" >> /etc/network/interfaces
        echo "iface lo inet loopback" >> /etc/network/interfaces
        echo "" >> /etc/network/interfaces
        echo "# The primary network interface" >> /etc/network/interfaces
        echo "auto eth0" >> /etc/network/interfaces
        echo "iface eth0 inet static" >> /etc/network/interfaces
        echo "	address ${OLIX_INSTALL_NETWORK_ADDRIP}" >> /etc/network/interfaces
        echo "	netmask ${OLIX_INSTALL_NETWORK_NETMASK}" >> /etc/network/interfaces
        echo "	network ${OLIX_INSTALL_NETWORK_NETWORK}" >> /etc/network/interfaces
        echo "	broadcast ${OLIX_INSTALL_NETWORK_BROADCAST}" >> /etc/network/interfaces
        echo "	gateway ${OLIX_INSTALL_NETWORK_GATEWAY}" >> /etc/network/interfaces
        echo "  dns-nameservers ${OLIX_INSTALL_NETWORK_RESOLV}" >> /etc/network/interfaces
        echo -e "${CVERT}OK ...${CVOID}"
    fi

    ###
    # Ajout d'autres IP
    ##
    for I in $(seq 0 $((${#OLIX_INSTALL_NETWORK_ADD_IP[@]} - 1))); do
        ADDRESS=${NETWORK_ADD_IP[$I]}
        echo -en "Ajout de l'adresse ${CCYAN}${ADDRESS}${CVOID} : "
        echo "" >> /etc/network/interfaces
        echo "auto eth0:$I" >> /etc/network/interfaces
        echo "iface eth0:$I inet static" >> /etc/network/interfaces
        echo "	address ${ADDRESS}" >> /etc/network/interfaces
        echo "	netmask 255.255.255.255" >> /etc/network/interfaces
        echo -e "${CVERT}OK ...${CVOID}"
    done

    ###
    # Redemarrage du service
    ##
    echo "-------------------------------------------------------------------------------"
    echo -e "${CBLANC}Redémarrage du service Réseau${CVOID}"
    /etc/init.d/networking restart

fi

###
# Modification du haost 127.0.1.1
##
#echo -en "Sauvegarde de l'original ${CCYAN}/etc/hosts${CVOID} : "; sleep 1
#if [ ! -f /etc/hosts.original ]; then
#    cp /etc/hosts /etc/hosts.original
#    echo -e "${CVERT}OK ...${CVOID}"
#else
#    echo -e "${CBLEU}Déjà effectué${CVOID}"
#fi
#cp /etc/hosts.original /etc/hosts
#echo -en "Suppression de l'IP ${CCYAN}127.0.1.1${CVOID} : "; sleep 1
#sed -i "/127\.0\.1\.1/d" /etc/hosts > ${OLIX_ERROR_FILE} 2>&1
#if [ $? -ne 0 ]; then core_handlerError; fi
#echo -e "${CVERT}OK ...${CVOID}"
#if [ ! -z "${NETWORK_LOCALHOST}" ]; then
#    echo -en "Ajout de ${CCYAN}${NETWORK_LOCALHOST}${CVOID} en 127.0.0.1 : "; sleep 1
#    sed -i "s/127\.0\.0\.1/127\.0\.0\.1 ${NETWORK_LOCALHOST}/g" /etc/hosts > ${OLIX_ERROR_FILE} 2>&1
#    if [ $? -ne 0 ]; then core_handlerError; fi
#    echo -e "${CVERT}OK ...${CVOID}"
#fi
#sleep 1