oliXsh : Shell Tools for Ubuntu Server and manager of projects
==============================================================


Installation d'oliXsh
---------------------

Récupérer les sources depuis le dépôt Git :
``` bash
git clone https://github.com/sabinus52/olixsh.git
```

Exécution du script pour l'installation dans le système
```
sudo ./olixsh install:olixsh
```

Puis suivre les instructions
Un fichier de configuration */etc/olix* a été créé. Celui-ci contiendra le lien vers le fichier de configuration complet


Configuration de oliXsh
-----------------------

Lors de l'installation un exemple de fichier de configuration a été créé.

``` bash
###
# Nom du serveur
##
OLIX_CONF_SERVER_NAME="#NAME#"

###
# Environnement
##
OLIX_CONF_SERVER_ENVIRONNEMENT="developpement"

###
# Configuration MySQL
##
OLIX_CONF_SERVER_MYSQL_HOST="#MYSQLHOST#"
OLIX_CONF_SERVER_MYSQL_PORT="#MYSQLPORT#"
OLIX_CONF_SERVER_MYSQL_USER="#MYSQLUSER#"
OLIX_CONF_SERVER_MYSQL_PASS="#MYSQLPASS#"

###
# Configuration de base de la sauvegarde
##
OLIX_CONF_SERVER_BACKUP_PURGE=
OLIX_CONF_SERVER_BACKUP_COMPRESS=
OLIX_CONF_SERVER_BACKUP_REPOSITORY=
OLIX_CONF_SERVER_BACKUP_REPORT_TYPE=
OLIX_CONF_SERVER_BACKUP_REPORT_REPO=
OLIX_CONF_SERVER_BACKUP_REPORT_MAIL=
OLIX_CONF_SERVER_BACKUP_FTP_SYNC=
OLIX_CONF_SERVER_BACKUP_FTP_HOST=
OLIX_CONF_SERVER_BACKUP_FTP_USER=
OLIX_CONF_SERVER_BACKUP_FTP_PASS=
OLIX_CONF_SERVER_BACKUP_FTP_PATH=

###
# Fichier de configuration pour l'install d'Ubuntu
##
OLIX_CONF_SERVER_INSTALL=

###
# Utilisateur système propriétaire des fichiers de config, projets, etc
##
OLIX_CONF_SERVER_INSTALL_USER_NAME=
OLIX_CONF_SERVER_INSTALL_USER_PARAM=
OLIX_CONF_SERVER_INSTALL_PERMISSION=

###
# Emplacement de la configuration distante pour installation
##
OLIX_CONF_SERVER_INSTALL_REMOTE_CONF=
OLIX_CONF_SERVER_INSTALL_REMOTE_PORT="22"
```

Une commande est mise en place pour récupérer la configuration complète depuis un autre server :
``` bash
olixsh install:config
```


Installation et configuration d'un projet
-----------------------------------------

### Préambule

Il faut créer les fichiers nécessaires pour l'installation d'un projet.
Tous les fichiers seront créer dans *config/project/[project]*
* **config** : Dossier racine de toute le configuration
* **[project]** : Nom de code du projet

### Fichier de configuration principale project.conf

Le fichier *project.conf* contient toute la configuration du projet

Voici les différentes parties
``` bash
###
# PROJET oTop Voyages
##

OLIX_CONF_PROJECT_CODE=""
OLIX_CONF_PROJECT_NAME=""
OLIX_CONF_PROJECT_PATH=

OLIX_CONF_PROJECT_MYSQL_USER=""
OLIX_CONF_PROJECT_MYSQL_PASS=""
OLIX_CONF_PROJECT_MYSQL_BASE=""

# Installation du projet
OLIX_CONF_PROJECT_INSTALL_APT=
OLIX_CONF_PROJECT_INSTALL_FILE_EXCLUDE="/tmp/\*\*.\*|/var/\*\*.\*"
OLIX_CONF_PROJECT_INSTALL_BASE_EXCLUDE=

# Synchro et mise en prod
OLIX_CONF_PROJECT_SYNCFILE_EXCLUDE="/tmp/\*\*.\* /var/\*\*.\*"

# Backup
OLIX_CONF_PROJECT_BACKUP_PURGE=
OLIX_CONF_PROJECT_BACKUP_COMPRESS=
OLIX_CONF_PROJECT_BACKUP_REPOSITORY="$OLIX_CONF_SERVER_BACKUP_REPOSITORY/xxx"
OLIX_CONF_PROJECT_BACKUP_REPORT_TYPE=
OLIX_CONF_PROJECT_BACKUP_REPORT_REPO="$OLIX_CONF_SERVER_BACKUP_REPORT_REPO/xxx"
OLIX_CONF_PROJECT_BACKUP_REPORT_MAIL=

OLIX_CONF_PROJECT_BACKUP_FILE_EXCLUDE="tmp/\*\*.\*|var/\*\*.\*"
OLIX_CONF_PROJECT_BACKUP_PATH_EXTRA=""

OLIX_CONF_PROJECT_BACKUP_FTP_SYNC=
OLIX_CONF_PROJECT_BACKUP_FTP_HOST=
OLIX_CONF_PROJECT_BACKUP_FTP_USER=
OLIX_CONF_PROJECT_BACKUP_FTP_PASS=
OLIX_CONF_PROJECT_BACKUP_FTP_PATH="$OLIX_CONF_SERVER_BACKUP_FTP_PATH/xxx"

OLIX_CONF_PROJECT_BACKUP_BASE_EXCLUDE=
OLIX_CONF_PROJECT_BACKUP_BASE_INCLUDE=
```


### Fichiers supplémentaires

* **install[SUFFIX].sh** : Script personnalisé qui remplace l'installation des sources et de la base
* **crontab[SUFFIX]** : Taches planifiées du projet
* **logrotate[SUFFIX]** : Rotation des log du projet
* **vhost[SUFFIX].conf** : Virtualhost apache du projet
* __*.crt__ : liste des certificats

**[SUFFIX]** peut avoir plusieurs valeurs avec en priorité : 

* **.versionsys.env** (ex .12.04.production) : Pour une version d'ubuntu spécifique et dans un environnement spécifique
* **.env** (ex .production) : Pour  un environnement spécifique
* **.versionsys** (ex .14.04) : Pour une version d'ubuntu spécifique
* vide dans ce cas, ce fichier sera pris en compte dans tous les environnements

**La valeur de l'environnement est définie dans le variable _OLIX_CONF_SERVER_ENVIRONNEMENT_ du fichier de configuration du serveur**


