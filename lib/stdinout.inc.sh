###
# Librairies d'entrées / sorties et d'affichage
# ==============================================================================
# @package olixsh
# @author Olivier
# @created 06/04/2014
##


###
# Affiche l'usage de la commande
##
function stdinout_printUsage()
{
    echo -e "${CBLANC} Usage : ${CBLEU}olixsh ${Ccyan}[OPTIONS] ${CJAUNE}COMMAND ${Cviolet}[PARAMETER]${CVOID}"

    echo ""
    echo -e "${Ccyan}OPTIONS${CVOID}"
    echo -en "${CBLANC}  --help|-h          ${CVOID} : "; echo "Affiche l'aide."
    echo -en "${CBLANC}  --version          ${CVOID} : "; echo "Affiche le numéro de version."
    echo -en "${CBLANC}  --verbose|-v       ${CVOID} : "; echo "Mode verbeux."
    echo -en "${CBLANC}  --debug|-d         ${CVOID} : "; echo "Mode debug très verbeux."
    echo -en "${CBLANC}  --no-warnings      ${CVOID} : "; echo "Désactive les messages d'alerte."

    

    core_exit 0
}


###
# Affiche la version
##
function stdinout_printVersion()
{
    local VERSION
    VERSION="Ver ${CVIOLET}${OLIX_VERSION}${CVOID}"
    if [[ "${OLIX_RELEASE}" == "true" ]]; then    
        VERSION="${VERSION} Release"
    else
        VERSION="${VERSION}.${OLIX_REVISION}"
    fi
    echo -e "${CCYAN}oliXsh${CVOID} ${VERSION}, for Linux"
}


###
# Affiche le menu des fonctionnalités
##
function stdinout_printListModule() {
    
    #echo -e "${CJAUNE} is${CVOID} - ${Cjaune}install:source${CVOID}   : Installer les sources olixsh sur un serveur distant"
    echo -e "${CJAUNE} io${CVOID} - ${Cjaune}install:olixsh${CVOID}    : Installer oliXsh sur le serveur"
    echo -e "${CJAUNE} ic${CVOID} - ${Cjaune}install:config${CVOID}    : Installer les fichiers de configuration sur le serveur"
    echo -e "${CJAUNE} is${CVOID} - ${Cjaune}install:server${CVOID}    : Configuration du systeme Ubuntu"
    echo -e "${CJAUNE} ip${CVOID} - ${Cjaune}install:package${CVOID}   : Installation d'un package"
    #echo -e "${CJAUNE} im${CVOID} - ${Cjaune}install:mysql${CVOID}    : Configurer le serveur MySQL en connexion automatique"
    #echo -e "${CJAUNE} it${CVOID} - ${Cjaune}install:test${CVOID}     : Tester olixsh et sa configuration"
    #echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"
    #echo -e "${CJAUNE} -${CVOID}  - ${Cjaune}maint${CVOID}            : Activation du serveur Apache en mode maintenance"
}


###
# Affiche le menu des fonctionnalités de olixsh
# @return OLIX_MODULE : choix de la fonctionnalité
##
function stdinout_readChoiceModule()
{
    while true; do
        stdinout_printVersion
        echo -e "Copyright (c) 2013, $(date '+%Y') Olivier Pitois. All rights reserved."
        echo
        echo -e "${CVIOLET} Menu des fonctionnalités ${CCYAN}oliXsh${CVOID}"
        echo -e "${CBLANC}===============================================================================${CVOID}"
        stdinout_printListModule
        echo -e "${CJAUNE} q${CVOID}  - ${Cjaune}quit${CVOID}             : Quitter"
        echo -en "${Cjaune}Ton choix ${CJAUNE}[q]${CVOID} : "
        read OLIX_MODULE
        case ${OLIX_MODULE} in
            io|install:olixsh)   OLIX_MODULE="install:olixsh"; break;;
            ic|install:config)   OLIX_MODULE="install:config"; break;;
            is|install:server)   OLIX_MODULE="install:server"; break;;
            ip|install:package)  OLIX_MODULE="install:package"; break;;
            q|quit)              OLIX_MODULE="quit"; break;;
            *)                   [ "${OLIX_MODULE}" == "" ] && OLIX_MODULE="quit" && break;;
        esac
    done
}