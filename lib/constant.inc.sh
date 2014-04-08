###
# Détermination des variables globales et communes
# ==============================================================================
# @package olixsh
# @author Olivier
# @created 23/09/2013
##


###
# Paramètres système NON modifiable
##

# Nom du fichier de l'interpréteur
OLIX_SHELL_NAME="olixsh2"
# Lien vers l'interpréteur olixsh
OLIX_SHELL_LINK="/bin/olixsh2"
# Fichier de config systeme contenant les informations sur l'emplacement de la configuration
OLIX_CONFIG_FILE="/etc/olix2"



###
# Initialisation des paramètres par défaut des options
##
OLIX_OPTION_VERBOSEDEBUG=false
OLIX_OPTION_VERBOSE=false
OLIX_OPTION_WARNINGS=true



# Heure d'ecoute
OLIX_SYSTEM_TIME=$(date '+%X')
# Jour d'ecoute
OLIX_SYSTEM_DATE=$(date '+%F')

# Chargement des variables systèmes
#source etc/system.env.sh

# Chargement des variables de configuration
#source etc/config.env.sh

# Chargement des variables des paramètres
#source etc/param.env.sh



