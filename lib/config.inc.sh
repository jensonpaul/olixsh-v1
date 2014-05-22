###
# Gestion de la configuration des différents fichier
# ==============================================================================
# @package olixsh
# @author Olivier
# @created 16/05/2014
##



###
# Vérifie que la valeur de la configuration n'est pas vide
# @param $1 : Clé de la configuration (variable)
# @param $2 : Valeur par défaut
##
function config_require()
{
	local VALUE
    logger_debug "config_require ($1, $2)"
    eval "VALUE=\"\$$1\""

    if [[ -z "${VALUE}" ]]; then
        [[ -z $3 ]] && return
        config_warning "$1" "$2"
        eval "$1=\"\$2\""
    fi
}


###
# Vérifie que la valeur de la configuration n'est pas vide
# @param $1 : Clé de la configuration principale (variable)
# @param $2 : Clé de la configuration secondaire (variable)
# @param $3 : Valeur par défaut
##
function config_require2()
{
	local VALUE
    logger_debug "config_require ($1, $2, $3)"
    eval "VALUE=\"\$$1\""

    if [[ -z "${VALUE}" ]]; then

    	eval "VALUE=\"\$$2\""

    	if [[ -z "${VALUE}" ]]; then
            [[ -z $3 ]] && return
    		config_warning "$1 ou $2" "$3"
        	eval "$1=\"\$3\""
        else
        	eval "$1=\"\$$2\""
        fi
    fi
}


###
# Indique un avertissement pour la configuration
# @param $1 : Clé de la configuration (variable)
# @param $2 : Valeur par défaut
##
function config_warning()
{
    logger_debug "conf_warning ($1, $2)"
    logger_warning "La configuration $1 n'est pas renseignée, utilisation de la valeur \"$2\"."  
}