#!/bin/sh

# set -x

BASEDIR=`cd "\`dirname \"$0\"\`" && /bin/pwd`
BASEDIR="$HOME/Infopark-CMS-Fiona-7.0.1-Linux"

LOG_FILE="${HOME}/npsinstall.log"
DEFAULT_LICENSE_PATH="${HOME}/license.xml"

# Configuration
DEFAULT_NPS_PATH="$HOME/CMS-Fiona-7.0.1"
PORT_LIST="3001 3002 3003 3011 3012 3013 3051 3052 3053 8080"

# see installTriforkLicense() for TRIFORK_LICENSE
# TRIFORK_PACKAGE_PATH=`ls "${BASEDIR}"/trifork-*-unix.zip`
# TRIFORK_VERSION=`echo "$TRIFORK_PACKAGE_PATH" | sed 's#.*/trifork-##;s#-unix.zip##'`
# TRIFORK_USER=administrator
# TRIFORK_PASSWORD=trifork

NPS_PACKAGE=$BASEDIR/data.zip

test -n "$1" && verbose=1

TEMP_DIR=${TMP:-/tmp}
test -d "$TEMP_DIR" || {
    error "Temporary directory '$TEMP_DIR' does not exist"
}


log()
{
    date=`date +'%Y-%m-%d %T %Z'`
    echo "$1" | sed -e "1s#^#[$date] #
        2,\$s#^#                          #" >> "$LOG_FILE"
}

echon ()
{
    eval "echo '$1' | tr -d '\012'"
}


_echo()
{
    withNL="${2:-1}"
    test $withNL -ne 0 && {
        echo $1
        true
    } || {
        echon "$1"
    }
}


_message()
{
    textWidth=80
    m=`echo $1`
    length=`expr length "$m"`
    while [ "$length" -gt $textWidth ]; do
        l=`expr substr "$m" 1 $textWidth`
        len=`expr match "$l" ".* "`
        test $len -lt 1 && {
            len=`expr match "$l" ".*/"`
        }
        test $len -lt 1 && {
            len=$textWidth
        }
        start=`expr $len + 1`
        _echo "`expr substr "$m" 1 $len`"
        length=`expr $length - $start + 1`
        m=`expr substr "$m" $start $length`
        len=`expr match "$m" " *"`
        test "$len" -gt 0 && {
            start=`expr $len + 1`
            length=`expr $length - $len`
            m=`expr substr "$m" $start $length`
        }
    done
    _echo "$m" $2
}


message()
{
    expr length "a" > /dev/null 2>&1 && {
        _message "$1" $2
        true
    } || {
        _echo "$1" $2
    }
    log "$1"
}


messagen()
{
    message "$1" 0
}


error()
{
    message
    message "Error: $1" 1>&2
    test -n "$2" && {
        message "Hint: $2" 1>&2
    }
}


warning()
{
    message
    message "Warning: $1"
    test -n "$2" && {
        message "Hint: $2"
    }
}


waitForReturnKey()
{
    messagen 'Press <return> to continue.'
    read anything
}


askYesNo()
{
    default="${2:-y}"
    while [ 1 ]; do
        message
        messagen "$1? (y/n) [$default]:"
        echon " "
        read answer

        wants_abort="${answer:-${default}}"
        case "$wants_abort" in
            y*|Y*)
                return 0
                ;;
            n*|N*)
                return 1
                ;;
            *)
                message "Invalid answer. Please answer 'yes' or 'no'."
                ;;
        esac
    done
}


step()
{
    message
    message "=== $1 ==="
    message
}


checkTools()
{
    message "Looking for 'unzip'..."
    unzip > /dev/null && {
        message "Found 'unzip'."
        true
    } || {
        error "You must have 'unzip' installed."
    }
}


checkJava()
{
    REQUIRED_JAVA_MAJOR_VERSION="1"
    REQUIRED_JAVA_MINOR_VERSION="6"
    message "Checking Java version ..."

    JAVA_VENDOR=`"$JAVA_HOME"/bin/java -jar "${BASEDIR}"/JavaVendor.jar 2>&1` && {
        JAVA_VERSION=`echo "$JAVA_VENDOR" | grep "java version" | sed 's#^[^0-9]*\([0-9]*[.][0-9]*\).*#\1#'`
        JAVA_MAJOR_VERSION=`echo "$JAVA_VERSION" | sed 's#[.][0-9]*##'`
        JAVA_MINOR_VERSION=`echo "$JAVA_VERSION" | sed 's#[0-9]*[.]##'`
        IS_SUN_JAVA=`echo "$JAVA_VENDOR" | grep -i 'java vendor.*Sun.*Microsystems' | wc -l`
        IS_ORACLE_JAVA=`echo "$JAVA_VENDOR" | grep -i 'java vendor.*Oracle.*Corporation' | wc -l`
        test "$IS_SUN_JAVA" -ge 1 -o "$IS_ORACLE_JAVA" -ge 1 &&
            test "$JAVA_MAJOR_VERSION" -eq "$REQUIRED_JAVA_MAJOR_VERSION" &&
            test "$JAVA_MINOR_VERSION" -ge "$REQUIRED_JAVA_MINOR_VERSION" &&
            "$JAVA_HOME"/bin/javac -help >/dev/null 2>&1 && {
                message "Found '$JAVA_VERSION' - excellent."
                return 0
            }
    }

    message
    message "################################################################################"
    message "Java Development Kit is missing or has the wrong version."
    message
    message "Please make sure that a genuine Sun Microsystems or Oracle Corporation JDK
            $REQUIRED_JAVA_MAJOR_VERSION.$REQUIRED_JAVA_MINOR_VERSION
            is installed and that JAVA_HOME is set in the environment."
    message "################################################################################"
    message
    return 1
}

# askJava must already have been executed. Returns 1 if the installation must be aborted.
checkPorts()
{
    message "Checking whether all needed TCP/IP port are free ..."
    $JAVA_HOME/bin/java -jar "${BASEDIR}"/CheckPorts.jar ${PORT_LIST} 2>&1 && {
        message "Yes, ok."
        return 0
    }
    message
    message "Some ports are used by other programs. Please make sure that these ports are free.
            Then restart the Fiona setup. If you want to install Fiona with a
            different set of ports"
    echon "  "
    message "- continue the setup and"
    echon "  "
    message "- manually change the configuration file afterwards."
    message "In this case, you have to start the servers manually using 'rc.npsd start'."
    askYesNo "Abort the installation now" && {
        return 1
    } || {
        PORTS_ARE_USED=1
        return 0
    }
}


prepareInstallation ()
{
    umask 0077
    step "Prerequisites"
    checkTools
    askNps
    checkJava
    #checkPorts || {
    #  message "Aborting."
    #  exit 1
    #}
}

askLicense()
{
    step "License"
    message "In order to install Fiona you need a valid license.xml."
    while [ 1 ]; do
        #messagen "Path of your Fiona license file
        #        [${DEFAULT_LICENSE_PATH}]:"
        #echon " "
        #read answer
        LICENSE_PATH=${DEFAULT_LICENSE_PATH}
        log "Using license from $LICENSE_PATH"
        test -r "$LICENSE_PATH" || {
            message "There is no valid Fiona license in ${LICENSE_PATH}"
            continue
        }
        break
    done
}


askNps()
{
    step "Fiona installation path"
    while [ 1 ]; do
        #message
        #messagen "Where should Fiona be installed?
        #        [$DEFAULT_NPS_PATH]:"
        #echon " "
        #read answer || exit 1
        #install_dir="${answer:-$DEFAULT_NPS_PATH}"
        install_dir=$DEFAULT_NPS_PATH
        test -r "$install_dir" && test `ls -A "$install_dir" | wc -l` -gt 0 && {
            message "The directory or file $install_dir already exists."
            message "It is harmful to install one Fiona over another
                    one."
            message "Please choose another directory or remove $install_dir
                    before you proceed."
            continue
            true
        } || {
            test -r "$install_dir" || {
                message "Creating directory: $install_dir"
                mkdir -p "$install_dir" || {
                    message "Cannot create $install_dir."
                    message "Please choose another directory."
                    continue
                }
            }
        }

        NPS_INSTALL_PATH=`cd "$install_dir" && /bin/pwd`
        NPS_INSTANCE_PATH="${NPS_INSTALL_PATH}"/instance/default
        break
    done
}


askTrifork()
{
    step "Trifork installation path"
    proposedTriforkPath="$HOME/trifork-$TRIFORK_VERSION"
    checkTrifork "$proposedTriforkPath" || proposedTriforkPath=""
    trifork_ok=

    until [ "$trifork_ok" ]; do
        message "Fiona needs the Trifork Enterprise Application Server."
        test -n "$proposedTriforkPath" && {
            askYesNo "Do you want to use the trifork installed in '$proposedTriforkPath'" && trifork_path="$proposedTriforkPath"
            proposedTriforkPath=""
        } || {
            #message "Enter the path of an already installed Trifork server."
            #message "Leave this field empty to install a Trifork server."
            #echon "Trifork path []: "
            #read trifork_path
            trifork_path=""
        }
        test -n "$trifork_path" && {
            checkTrifork "$trifork_path" && {
                message
                message "Found a Trifork in $trifork_path."
                message
                message "Important:"
                message "Setup assumes that this Trifork still has got the same
                        configuration (port, admin password) as a freshly
                        installed one."
                message
                message "THE TRIFORK SERVER MUST NOT BE RUNNING AT THIS MOMENT."
                message
                message "If it is running, please stop it now, then proceed
                        with the installation."
                message
                message
                waitForReturnKey
                TRIFORK_INSTALLED=1
                trifork_ok=1
                TRIFORK_HOME="$trifork_path"
                return
            } || {
                message "Cannot find a Trifork in '$trifork_path'.
                        Please try again."
            }
            true
        } || {
            TRIFORK_INSTALLED=
            trifork_ok=1
        }
    done
}

installTrifork ()
{
    step "Trifork installation"
    triforkHomeFile="$TEMP_DIR"/triforkHome.txt.$$
    triforkTmp=unpack-trifork.$$
    (
        test -f "$TRIFORK_PACKAGE_PATH" || {
            error "There is no $TRIFORK_PACKAGE_PATH archive - exiting."
        }
        cd "$TEMP_DIR"
        rm -rf "$triforkTmp"
        mkdir "$triforkTmp" || {
            error "Cannot create temporary directory '$TEMP_DIR/$triforkTmp'
                    - exiting."
        }
        echo "TRIFORM TMP PATH: $triforkTmp"
        cd "$triforkTmp"

        message "Unpacking the Trifork archive ..."
        unzip -oq "$TRIFORK_PACKAGE_PATH"

        cd trifork-* || {
            error "Cannot change directory to '$TEMP_DIR/$triforkTmp/trifork-*'"
        }
        # make local gnutar wrapper available
        originalPath="$PATH"
        PATH="$BASEDIR":"$PATH"
        export PATH
        cp ~/install_trifork.sh install && chmod +x install
        . ./install
        PATH="$originalPath"
        export PATH
        cd ../..
        rm -rf "$triforkTmp"
        # INSTALL_DIR was set by the sourced(!) Trifork installer
        echo "TRIFORK_HOME=\"$INSTALL_DIR\"" > "$triforkHomeFile"
        true
    ) || {
        code=$?
        rm -f "$triforkHomeFile"
        exit $code
    }
    . "$triforkHomeFile"
    rm -f "$triforkHomeFile"
    message "Trifork installed."
}


checkTrifork()
{
    trifork_dir="$1"
    test -n "$trifork_dir" || return 1
    test -f "$trifork_dir"/server/bin/eas || return 1
    return 0
}


patchBootScript()
{
    rcScript="${NPS_INSTALL_PATH}"/boot/"nps"
    message "Patching boot script $rcScript"
    sed -e "s#__NPS_USER__#`id | sed 's#^uid=[0-9]*(\([^)]*\)).*$#\1#'`#"\
            < "$rcScript" |\
            sed -e "s#__NPS_BASE_DIR__#${NPS_INSTALL_PATH}#" > "$rcScript.new"
    mv "$rcScript.new" "$rcScript"
    chmod 755 "$rcScript"
}


installNps()
{
    step "Fiona installation"
    message "Unpacking files into $NPS_INSTALL_PATH"
    mkdir -p "${NPS_INSTALL_PATH}" || {
        error "Cannot create Fiona directory."
    }
    unzip -oq "$NPS_PACKAGE" -d "${NPS_INSTALL_PATH}"

    message "Copying Fiona license"
    cp "$LICENSE_PATH" "${NPS_INSTANCE_PATH}"/config/license.xml

    patchBootScript
}


installTriforkLicense()
{
    message "Copying trifork license"
    TRIFORK_LICENSE="${NPS_INSTANCE_PATH}/config/trifork.license.txt.web-only"
    test -f "${TRIFORK_HOME}/server/license/license.txt" && {
        message "A Trifork license already exists in ${TRIFORK_HOME}."
        message "We do not replace it."
        true
    } || {
        cp "${TRIFORK_LICENSE}" "${TRIFORK_HOME}/server/license/license.txt"
    }
}


patchRcScriptForTrifork()
{
    rcScript="${NPS_INSTANCE_PATH}/config/rc.npsd.conf"
    message "Patching start script $rcScript"
    (
        sed -e "s#set conf(triforkHome).*\$#set conf(triforkHome) \"$TRIFORK_HOME\"#" < "$rcScript" > "$rcScript.new" || exit 1
        mv "$rcScript.new" "$rcScript" || exit 1
    ) || {
        /bin/rm -f "$rcScript.new"
        error "Failed to change conf(triforkHome) in '$rcScript'"
    }
    chmod 700 "$rcScript"
}


initializeNPS()
{
    step "Importing initial content into default instance"
    "$NPS_INSTANCE_PATH"/bin/CM -restore "$NPS_INSTALL_PATH"/share/initDump || exit 1
}


startNPS()
{
    step "Fiona startup"
    test -n "$PORTS_ARE_USED" && {
        message "Fiona cannot be started because its
                standard ports are used by other server processes."
        message
        message "Please stop other services or change the ports in server.xml."
        message
        message "After that you can start Fiona and Trifork with"
        echon "  "
        message "$NPS_INSTANCE_PATH/bin/rc.npsd start"
        message
        message "After the first start of Trifork you must deploy the GUI with"
        echon "  "
        message "$NPS_INSTANCE_PATH/bin/rc.npsd deploy"
        echon "  "
        message "$NPS_INSTANCE_PATH/bin/rc.npsd deploy ROOT"
        message
        return 1
    }
    test -n "$JAVA_IS_MISSING" && {
        message "Fiona cannot be started because no suitable JDK was
                found. You may start the CM, SES or TE servers manually with"
        echon "  "
        message "$NPS_INSTANCE_PATH/bin/rc.npsd start CM SES TE"
        message
        return 1
    }
    "$NPS_INSTANCE_PATH/bin/rc.npsd" start &&\
            "$NPS_INSTANCE_PATH/bin/rc.npsd" deploy &&\
            "$NPS_INSTANCE_PATH/bin/rc.npsd" deploy ROOT || {
        warning "Fiona could not be started."
        return 1
    }
    return 0
}


indexObjectsIfPossible()
{
    "$NPS_INSTANCE_PATH"/bin/CM -single << EOD || {
if {[::nps::isTrue [systemConfig getTexts indexing.advancedSearch.isActive]]} {
    puts "\n=== Search engine initialization ===\n"
    indexAllObjects
}
exit 0
EOD
        error "Failed to index content"
    }
    return 0
}


cleanUp()
{
    message "cleaning up"
    cd "$TEMP_DIR"
    test "$triforkTmp" && rm -rf "$triforkTmp"
    exit
}


main()
{
    echo "" > "$LOG_FILE"
    message
    message "Welcome to the installation of Fiona 7.0.1"
    message
    message "The log file for this installation is $LOG_FILE."
    message "You can abort the installation at any time by pressing CTRL-C."

    prepareInstallation
    askLicense
    #askTrifork
    #test "$TRIFORK_INSTALLED" || {
    #    installTrifork
    #}

    installNps
    #installTriforkLicense
    #patchRcScriptForTrifork

    initializeNPS
    startNPS
    #indexObjectsIfPossible

    step "Installation finished"
    message "Fiona is now installed in ${NPS_INSTALL_PATH}."
    message
    message "To proceed, please point your web browser to
            http://`hostname`:8080/"
}


## trapping SIGINT (2) and SIGTERM (15)
trap cleanUp 2 15
main
