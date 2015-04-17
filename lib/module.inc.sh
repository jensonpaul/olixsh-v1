###
# Librairies de gestion des modules
# ==============================================================================
# @package olixsh
# @author Olivier
# @created 22/05/2014
##



OLIX_MODULE_NAME_CONFIG="module.conf.sh"



###
# Retourne le nom du script a executer
# @param $1 : Nom du module
##
function module_getScript()
{
	echo -n "${OLIX_ROOT}/modules/${1/:/-}/${1/:/-}.sh"
}


###
# Execute le module
# @param $1 : Nom du module
##
function module_execute()
{
	local SCRIPT=$(module_getScript "$1")
	logger_debug "module_execute ($1) -> ${SCRIPT}"

	if module_isExist "$1"; then
        source ${SCRIPT}
        core_exit 0
    fi
    logger_warning "Le module ${SCRIPT} est inexistant"
    core_exit 1
}


###
# Affiche le menu des fonctionnalités
##
function module_printList()
{
    logger_debug "module_printList ()"

    while read I; do
        local FIRST=${I:0:1}
        if [[ ${FIRST} == "-" ]]; then
            local SUBMENU=${I:1}
            echo -en ${Cjaune}$(stdout_strpad " ${SUBMENU/-/:} ${CVOID}" "30" ".")
            if module_isExistConfiguration ${SUBMENU}; then
                source ./modules/${SUBMENU}/${OLIX_MODULE_NAME_CONFIG}
                echo -e " : ${OLIX_MODULE_LABEL}"
            else
                echo -e " : ${Crouge}Pas de description${CVOID}"
            fi
        else
            echo -e "${Cvert}${I} ${CVOID}"
        fi
    done < ./modules/modules.lst
}


###
# Affiche le menu des fonctionnalités de olixsh
# @return OLIX_MODULE : choix de la fonctionnalité
##
function module_readChoice()
{
    logger_debug "module_readChoice ()"

    while true; do
        stdout_printVersion
        echo
        echo -e "${CVIOLET} Liste des modules de ${CCYAN}oliXsh${CVOID}"
        echo -e "${CBLANC}===============================================================================${CVOID}"
        module_printList
        echo -e "${Cvert}Quitter ${CVOID}"
        echo -e " ${Cjaune}quit${CVOID} .................. : Quitter"
        echo -en "${Cjaune}Ton choix ${CJAUNE}[q]${CVOID} : "
        read OLIX_MODULE
        case ${OLIX_MODULE} in
            q|quit)              OLIX_MODULE=""; break;;
            *)                   [ "${OLIX_MODULE}" == "" ] && break;;
        esac
        if module_isExist "${OLIX_MODULE}"; then break; fi
    done
}


###
# Affiche l'aide du module
# @param $1 : Nom du module
##
function module_printUsage()
{
	logger_debug "module_printUsage ($1)"
	source ${OLIX_ROOT}/modules/${1/:/-}/${OLIX_MODULE_NAME_CONFIG}

	stdout_printUsage "$1" "${OLIX_MODULE_DESCRIPTION}"
	echo
	echo -e "${Cviolet}PARAMETER${CVOID}"
	for J in $(seq 1 $((${#OLIX_MODULE_PARAMETER[@]}))); do
		echo -e "  ${OLIX_MODULE_PARAMETER[$J]}"
	done
}


###
# Test si un fichier de configuration d'un module existe
# @param $1 : Nom du module
##
function module_isExistConfiguration()
{
    logger_debug "module_isExistConfiguration ($1)"
    [[ -r ${OLIX_ROOT}/modules/${1/:/-}/${OLIX_MODULE_NAME_CONFIG} ]] && return 0
    return 1
}


###
# Test si le module existe
# @param $1 : Nom du module
##
function module_isExist()
{
    logger_debug "module_isExist ($1)"
    [[ -r $(module_getScript "$1") ]] && return 0
    return 1
}