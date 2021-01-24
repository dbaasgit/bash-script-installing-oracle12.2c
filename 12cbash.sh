#!/bin/bash

##################################################
#         CONFIGURATION SECTION                  #
##################################################

# ** location of the database source files
SOURCEPATH=/u02/software/oracle12.2c
# ** name of the first source file
SOURCE=linuxx64_12201_database.zip
# ** working directory for extracting the source
WORKDIR=/u01/stage
# ** the oracle top directory
ORATOPDIR=/u03/app
# ** the oracle inventory
ORAINVDIR=${ORATOPDIR}/oraInventory
# ** the ORACLE_BASE to use
ORACLE_BASE=${ORATOPDIR}/product
# ** the ORACLE_HOME to use
ORACLE_HOME=${ORACLE_BASE}/12.2.0.1
# ** base directory for the oracle database files
ORABASEDIR=/u03/oradata
# the ORACLE_SID to use
ORACLE_SID=BASH
# ** the owner of the oracle software
ORAOWNER=oracle
# ** the primary installation group
ORAINSTGROUP=oinstall
# ** the dba group
ORADBAGROUP=dba
# ** the oper group
ORAOPERGROUP=dba
# ** the backup dba group
ORABACKUPDBA=dba
# ** the dataguard dba group
ORADGBAGROUP=dba
# ** the transparent data encryption group
ORAKMBAGROUP=dba


##################################################
#        MAIN SECTION                            # 
##################################################

PFILE=${ORACLE_HOME}/dbs/init${ORACLE_SID}.ora

# print the header
_header() {
   echo "*** ---------------------------- ***"
   echo "*** -- starting oracle 12c setup ***"
   echo "*** ---------------------------- ***"
}

# print simple log messages to screen
_log() {
   echo "****** $1 "
}

# check for the current os user
_check_user() {
    if [ $(id -un) != "${1}" ]; then
        _log "you must run this as ${1}"
        exit 0
    fi

}

# create the user and the groups
_create_user_and_groups() {
    _log "*** checking for group: ${ORAINSTGROUP} "
    getent group ${ORAINSTGROUP}
    if [ "$?" -ne "0" ]; then
        /usr/sbin/groupadd ${ORAINSTGROUP} 2> /dev/null || :
    fi
    _log "*** checking for group: ${ORADBAGROUP} "
    getent group ${ORADBAGROUP}
    if [ "$?" -ne "0" ]; then
        /usr/sbin/groupadd ${ORADBAGROUP} 2> /dev/null || :
    fi
    _log "*** checking for group: ${ORAOPERGROUP} "
    getent group ${ORAOPERGROUP}
    if [ "$?" -ne "0" ]; then
        /usr/sbin/groupadd ${ORAOPERGROUP} 2> /dev/null || :
    fi
    _log "*** checking for group: ${ORABACKUPDBA} "
    getent group ${ORABACKUPDBA}
    if [ "$?" -ne "0" ]; then
        /usr/sbin/groupadd ${ORABACKUPDBA} 2> /dev/null || :
    fi
    _log "*** checking for group: ${ORADGBAGROUP} "
    getent group ${ORADGBAGROUP}
    if [ "$?" -ne "0" ]; then
        /usr/sbin/groupadd ${ORADGBAGROUP} 2> /dev/null || :
    fi
    _log "*** checking for group: ${ORAKMBAGROUP} "
    getent group ${ORAKMBAGROUP}
    if [ "$?" -ne "0" ]; then
        /usr/sbin/groupadd ${ORAKMBAGROUP} 2> /dev/null || :
    fi
    _log "*** checking for user: ${ORAOWNER} "
    getent passwd ${ORAOWNER}
    if [ "$?" -ne "0" ]; then
        /usr/sbin/useradd -g ${ORAINSTGROUP} -G ${ORADBAGROUP},${ORAOPERGROUP},${ORABACKUPDBA},${ORADGBAGROUP},${ORAKMBAGROUP} \
                          -c "oracle software owner" -m -d /home/${ORAOWNER} -s /bin/bash ${ORAOWNER}
    fi
}

# create the directories
_create_dirs() {
    _log "*** creating: ${WORKDIR} "
    mkdir -p ${WORKDIR}
    chown ${ORAOWNER}:${ORAINSTGROUP} ${WORKDIR}
    _log "*** creating: ${ORATOPDIR} "
    mkdir -p ${ORATOPDIR}
    chown ${ORAOWNER}:${ORAINSTGROUP} ${ORATOPDIR}
    _log "*** creating: ${ORACLE_BASE} "
    mkdir -p ${ORACLE_BASE}
    chown ${ORAOWNER}:${ORAINSTGROUP} ${ORACLE_BASE}
    _log "*** creating: ${ORACLE_HOME} "
    mkdir -p ${ORACLE_HOME}
    chown ${ORAOWNER}:${ORAINSTGROUP} ${ORACLE_HOME}
    _log "*** creating: ${ORABASEDIR} "
    mkdir -p ${ORABASEDIR}
    chown ${ORAOWNER}:${ORAINSTGROUP} ${ORABASEDIR}
    _log "*** creating: ${ORABASEDIR}/${ORACLE_SID} "
    mkdir -p ${ORABASEDIR}/${ORACLE_SID}
    chown ${ORAOWNER}:${ORAINSTGROUP} ${ORABASEDIR}/${ORACLE_SID}
    _log "*** creating: ${ORABASEDIR}/${ORACLE_SID}/rdo1 "
    mkdir -p ${ORABASEDIR}/${ORACLE_SID}/rdo1
    _log "*** creating: ${ORABASEDIR}/${ORACLE_SID}/rdo2 "
    mkdir -p ${ORABASEDIR}/${ORACLE_SID}/rdo2
    _log "*** creating: ${ORABASEDIR}/${ORACLE_SID}/dbf "
    mkdir -p ${ORABASEDIR}/${ORACLE_SID}/dbf
    _log "*** creating: ${ORABASEDIR}/${ORACLE_SID}/arch "
    mkdir -p ${ORABASEDIR}/${ORACLE_SID}/arch
    _log "*** creating: ${ORABASEDIR}/${ORACLE_SID}/admin "
    mkdir -p ${ORABASEDIR}/${ORACLE_SID}/admin
    _log "*** creating: ${ORABASEDIR}/${ORACLE_SID}/admin/adump "
    mkdir -p ${ORABASEDIR}/${ORACLE_SID}/admin/adump
    _log "*** creating: ${ORABASEDIR}/${ORACLE_SID}/pdbseed "
    mkdir -p ${ORABASEDIR}/${ORACLE_SID}/pdbseed
    chown -R ${ORAOWNER}:${ORADBAGROUP} ${ORABASEDIR}/${ORACLE_SID}
}

# extract the source files
_extract_sources() {
    cp ${SOURCEPATH}/${SOURCE} ${WORKDIR}
    #cp ${SOURCEPATH}/${SOURCE2} ${WORKDIR}
    chown ${ORAOWNER}:${ORAINSTGROUP} ${WORKDIR}/*
    _log "*** extracting: ${SOURCE} "
    su - ${ORAOWNER} -c "unzip -d ${WORKDIR} ${WORKDIR}/${SOURCE}"
    #_log "*** extracting: ${SOURCE2} "
    #su - ${ORAOWNER} -c "unzip -d ${WORKDIR} ${WORKDIR}/${SOURCE2}"
}

# install required software
#_install_required_software() {
 #   _log "*** installing required software "
  #  yum install -y binutils compat-libcap1 compat-libstdc++-33 gcc gcc-c++ glibc glibc-devel ksh \
   #                libgcc libstdc++ libstdc++-devel libaio libaio-devel libXext libXtst libX11 libXau libxcb libXi make sysstat
#}

# install oracle software
_install_oracle_software() {
    _log "*** installing oracle software"
    su -  ${ORAOWNER} -c "cd ${WORKDIR}/database; ./runInstaller oracle.install.option=INSTALL_DB_SWONLY \
    ORACLE_BASE=${ORACLE_BASE} \
    ORACLE_HOME=${ORACLE_HOME} \
    UNIX_GROUP_NAME=${ORAINSTGROUP}  \
    oracle.install.db.OSDBA_GROUP=${ORADBAGROUP} \
    oracle.install.db.OSBACKUPDBA_GROUP=${ORAOPERGROUP} \
    oracle.install.db.OSDGDBA_GROUP=${ORABACKUPDBA}  \
    oracle.install.db.DGDBA_GROUP=${ORADGBAGROUP}  \
    oracle.install.db.OSKMDBA_GROUP=${ORAKMBAGROUP}  \
	oracle.install.db.OSRACDBA_GROUP=${ORADBAGROUP} \
    FROM_LOCATION=../stage/products.xml \
    INVENTORY_LOCATION=${ORAINVDIR} \
	SECURITY_UPDATES_VIA_MYORACLESUPPORT=false \
    SELECTED_LANGUAGES=en \
    oracle.install.db.InstallEdition=EE \
	DECLINE_SECURITY_UPDATES=true  -silent -ignoreSysPrereqs -ignorePrereq -waitForCompletion"
    ${ORAINVDIR}/orainstRoot.sh
    ${ORACLE_HOME}/root.sh
}


_header
_check_user "oracle"
_create_user_and_groups
_create_dirs
_extract_sources
_install_oracle_software
