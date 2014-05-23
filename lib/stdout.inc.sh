###
# Librairies des sorties d'affichage
# ==============================================================================
# @package olixsh
# @author Olivier
# @created 16/05/2014
##



###
# Affiche un texte avec une taille fixe complétée par des caratères
# @param $1 : Texte de début
# @param $2 : Taille de la chaine
# @param $3 : Caractère à compléter
# @param $4 : Texte de fin
##
function stdout_strpad()
{
	logger_debug "stdout_strpad ($1, $2, $3, $4)"
    echo -en "$1"
    for (( J=${#1} ; J<=$2 ; J++ )); do 
        echo -en "$3"
    done
    echo -en "$4"
}


###
# Affiche la taille d'un fichier en mode compréhensible
# @param $1 : Nom du fichier
##
function stdout_getSizeFileHuman()
{
	logger_debug "stdout_getSizeFileHuman ($1)"
    [[ ! -f $1 ]] && echo -n "ERROR" && return
    echo -n $(du -h $1 | awk '{print $1}')
}


###
# Affiche l'usage de la commande
# @param $1 : Nom du module
# @param $2 : Description
##
function stdout_printUsage()
{
    logger_debug "stdout_printUsage ($1)"
    local MODULE="MODULE"
    [[ ! -z $1 ]] && MODULE=$1
    stdout_printVersion
    echo
    echo -e "${CBLANC} Usage : ${CBLEU}olixsh ${Ccyan}[OPTIONS] ${CJAUNE}${MODULE} ${Cviolet}[PARAMETER]${CVOID}"
    [[ ! -z $2 ]] && echo && echo -e "$2"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    echo -en "${CBLANC}  --help|-h          ${CVOID} : "; echo "Affiche l'aide."
    echo -en "${CBLANC}  --version          ${CVOID} : "; echo "Affiche le numéro de version."
    echo -en "${CBLANC}  --verbose|-v       ${CVOID} : "; echo "Mode verbeux."
    echo -en "${CBLANC}  --debug|-d         ${CVOID} : "; echo "Mode debug très verbeux."
    echo -en "${CBLANC}  --no-warnings      ${CVOID} : "; echo "Désactive les messages d'alerte."
}


###
# Affiche la version
##
function stdout_printVersion()
{
    logger_debug "stdout_printVersion ()"
    local VERSION
    VERSION="Ver ${CVIOLET}${OLIX_VERSION}${CVOID}"
    if [[ "${OLIX_RELEASE}" == "true" ]]; then    
        VERSION="${VERSION} Release"
    else
        VERSION="${VERSION}.${OLIX_REVISION}"
    fi
    echo -e "${CCYAN}oliXsh${CVOID} ${VERSION}, for Linux"
    echo -e "Copyright (c) 2013, $(date '+%Y') Olivier Pitois. All rights reserved."
}


###
# Affiche un message d'en-tête de niveau 1
# @param $1     : Message
# @param $2..$9 : Valeurs à inclure dans le message
##
function stdout_printHead1()
{
    local MSG=$1
    shift
    logger_debug "stdout_printHead1 ($MSG, $*)"
    echo
    echo -e "${CVIOLET}$(printf "$MSG" "${CCYAN}$1${CVIOLET}" "${CCYAN}$2${CVIOLET}" "${CCYAN}$3${CVIOLET}")${CVOID}"
    echo -e "${CBLANC}===============================================================================${CVOID}"
}


###
# Affiche un message d'en-tête de niveau 2
# @param $1 : Message
# @param $2 : Valeur à inclure dans le message
##
function stdout_printHead2()
{
    logger_debug "stdout_printHead2 ($1, $2)"
    echo
    echo -e "${CVIOLET}$(printf "$1" "${CCYAN}$2${CVIOLET}")${CVOID}"
    echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"
}


###
# Afficher une ligne
##
function stdout_printLine()
{
    logger_debug "stdout_printLine ()"
    echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"
}


###
# Affiche un message standard
# @param $1 : Message à afficher
# @param $2 : Couleur du message
##
function stdout_print()
{
    logger_debug "stdout_print ($1)"
    echo -e "$2$1${CVOID}"
}


###
# Affiche le message d'information de retour d'un traitement
# @param $1 : Valeur de retour
# @param $2 : Message
# @param $3 : Message de retour
# @param $4 : Temps d'execution
##
function stdout_printMessageReturn()
{
	logger_debug "stdout_printMessageReturn ($1, $2, $3, $4)"
    echo -en $(stdout_strpad "$2" 64 "." " :")
    if [[ $1 -ne 0 ]]; then
        echo -e " ${CROUGE}ERROR${CVOID}"
    elif [[ -z $3 ]]; then
        echo -en " ${CVERT}OK${CVOID}"
        [[ ! -z $4 ]] && echo -e " ${Cvert}($4s)${CVOID}" || echo
    else
        echo -en " ${CVERT}$3${CVOID}"
        [[ ! -z $4 ]] && echo -e " ${Cvert}($4s)${CVOID}" || echo
    fi
    return $1
}


###
# Affiche un message d'information simple
# @param $1 : Message
# @param $2 : Valeur
##
function stdout_printInfo()
{
    logger_debug "stdout_printInfo ($1, $2)"
    echo -en $(stdout_strpad "$1" 64 "." " :")
    echo -e " ${CBLEU}$2${CVOID}"
}


###
# Affiche le contenu d'un fichier
# @param $1 : Nom du fichier
##
function stdout_printFile()
{
    logger_debug "stdout_printFile ($1)"
    cat $1
}
