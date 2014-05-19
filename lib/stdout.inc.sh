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
        echo -n $3
    done
    echo -en "$4"
}


###
# Affiche la taille d'un fichier en mode compréhensible
# @param $1 : Nom du fichier
##
function stdout_getSizeFileHuman()
{
	logger_debug "stdout_getSizeFileHuman($1)"
    [[ ! -f $1 ]] && echo -n "ERROR" && return
    echo -n $(du -h $1 | awk '{print $1}')
}


###
# Affiche un message d'en-tête de niveau 1
# @param $1     : Message
# @param $2..$9 : Valeurs à inclure dans le message
##
function stdout_head1()
{
    local MSG=$1
    shift
    logger_debug "stdout_head1 ($MSG, $*)"
    echo
    echo -e "${CVIOLET}$(printf "$MSG" "${CCYAN}$1${CVIOLET}" "${CCYAN}$2${CVIOLET}" "${CCYAN}$3${CVIOLET}")${CVOID}"
    echo -e "${CBLANC}===============================================================================${CVOID}"
}


###
# Affiche un message d'en-tête de niveau 2
# @param $1 : Message
# @param $2 : Valeur à inclure dans le message
##
function stdout_head2()
{
    logger_debug "stdout_head2 ($1, $2)"
    echo
    echo -e "${CVIOLET}$(printf "$1" "${CCYAN}$2${CVIOLET}")${CVOID}"
    echo -e "${CBLANC}-------------------------------------------------------------------------------${CVOID}"
}


###
# Affiche le message d'information de retour d'un traitement
# @param $1 : Valeur de retour
# @param $2 : Message
# @param $3 : Message de retour
##
function stdout_messageReturn()
{
	logger_debug "stdout_messageReturn ($1, $2, $3)"
    echo -en $(stdout_strpad "$2" 64 "." " :")
    if [[ ! -z $3 ]]; then
    	[[ $1 -eq 0 ]] && echo -e " ${CBLEU}$3${CVOID}" || echo -e " ${CROUGE}ERROR${CVOID}"
    else
    	[[ $1 -eq 0 ]] && echo -e " ${CVERT}OK${CVOID}" || echo -e " ${CROUGE}ERROR${CVOID}"
    fi
    return $1
}


###
# Affiche le contenu d'un fichier
# @param $1 : Valeur de retour
# @param $2 : Nom du fichier
##
function stdout_printFile()
{
    logger_debug "stdout_printFile ($1, $2)"
    cat $2
    return $1
}
