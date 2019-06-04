
set conf(scriptDir) [file join [pwd] [file dirname [info script]]]
set conf(instanceDir) [file join [pwd] $conf(scriptDir) ..]
set conf(configDir) [file join [pwd] $conf(instanceDir) config]
set conf(installDir) [file join $conf(instanceDir) .. ..]

source [file join $conf(installDir) lib utils.tcl]

source [file join $conf(configDir) rc.npsd.conf]

set conf(triforkDomainDir) [file join $conf(triforkHome) domains default]
set conf(triforkExecutable) [file join $::conf(triforkDomainDir) bin trifork]
set conf(triforkLogDir) [file join $::conf(triforkDomainDir) logs default]
set conf(tmpDir) [file join $conf(instanceDir) tmp]
set conf(binDir) [file join $conf(instanceDir) bin]
set conf(webAppsDir) [file join $conf(instanceDir) webapps]


proc serviceName {app {title {}}} {
    set name "Fiona 7.0.1 "
    if {$title eq ""} {
        set title $app
    }
    append name $title
    if {$::conf(webAppSuffix) ne ""} {
        append name [format " (%s)" $::conf(webAppSuffix)]
    }
    return $name
}


proc _callTrifork {verbose stdoutVar actor action args} {
    upvar $stdoutVar data
    set executable $::conf(triforkExecutable)
    if {![isExecutable $executable]} {
        return 1
    }
    foreach {exitCode data} [eval __exec stdout $verbose\
            [cmdCaller] [list [file nativename $executable] $actor $action\
            -host $::conf(triforkJsr77HostAndPort)\
            -u$::conf(triforkUser) -p$::conf(triforkPassword)] $args\
            << "\n"] {}
    if {[string match {*Login Failed*} $data]} {
        error "The configured trifork credentials are invalid."
    }
    if {$verbose && $exitCode != 0} {
        puts $data
    }
    return [expr {$exitCode != 0}]
}


proc callTrifork {verbose actor action args} {
    if {[catch {
        set result [eval [list _callTrifork $verbose {} $actor $action] $args]
    } msg]} {
        eputs $msg
        set result 1
    }
    return $result
}


proc getTriforkCallOutput {stdoutVar actor action args} {
    upvar $stdoutVar data
    if {[catch {
        set result [eval [list _callTrifork 1 data $actor $action] $args]
    } msg]} {
        eputs $msg
        set result 1
    }
    return $result
}


proc readPid {pidFile} {
    set pid ""
    if {[file isfile $pidFile]} {
        if {[catch {
            set pid [string trim [readFile $pidFile]]
        } msg]} {
            error "Failed to read '$pidFile'"
        }
    }
    return $pid
}


proc checkUnixProcess {pidFile} {
    set pid [readPid $pidFile]
    if {$pid ne ""} {
        if {![catch {
            exec kill -WINCH $pid 2> /dev/null
        }]} {
            return 1
        }
        file delete -force $pidFile
    }
    return 0
}


proc pidFile {app} {
    set lcApp [string tolower $app]
    return [file join $::conf(tmpDir) ${lcApp}.pid]
}


proc startApp {app} {
    puts "Starting $app"
    if {[isWindows]} {
        return [_exec net start [serviceName $app]]
    } else {
        if {[catch {
            set isRunning [checkUnixProcess [pidFile $app]]
        } msg]} {
            eputs $msg
            return 1
        }
        if {$isRunning} {
            puts "$app is already running"
            return 0
        }
        set executable [file join $::conf(binDir) $app]
        if {![isExecutable $executable]} {
            return 1
        }
        return [_exec $executable]
    }
}


proc stopApp {app} {
    puts "Stopping $app"
    if {[isWindows]} {
        return [_exec net stop [serviceName $app]]
    } else {
        if {[catch {
            set pid [readPid [pidFile $app]]
        } msg]} {
            eputs $msg
            return 1
        }
        if {![checkUnixProcess [pidFile $app]]} {
            return 0
        }
        set start [clock seconds]
        while {[clock seconds] - $start < 60} {
            if {[catch {
                exec kill $pid 2> /dev/null >@stdout
            } msg]} {
                return 0
            }
            if {![file isfile [pidFile $app]]} {
                return 0
            }
            after 2000
        }
        catch {exec kill -9 $pid 2> /dev/null >@stdout}
        file delete -force [pidFile $app]
        return 1
    }
}


proc restartApp {app} {
    if {[lsearch -exact $::conf(webApps) $app] > -1} {
        puts "Restarting $app"
        return [callTrifork 1 system restart ${app}$::conf(webAppSuffix)]
    }
    if {[stopApp $app] != 0} {
        return 1
    }
    return [startApp $app]
}


proc statusApp {app} {
    if {[isWindows]} {
        eputs "The status command for APPs is not available with Windows."
        return 1
    } else {
        if {[catch {
            set isRunning [checkUnixProcess [pidFile $app]]
        } msg]} {
            eputs $msg
            return 1
        }
        puts -nonewline "$app is "
        if {$isRunning == 0} {
            puts -nonewline "not "
        }
        puts "running"
        return 0
    }
}


proc patchTriforkServiceIni {triforkServiceIni} {
    set infoparkJavaOptions {
; Infopark options
-Xmx256m
-Xms256m
-XX:MaxPermSize=128m

}
    set newContent ""
    set isInJavaOptions 0
    set containsInfoparkOptions 0
    foreach line [split [readFile $triforkServiceIni] "\n"] {
        set line [string trim $line]
        if {$line eq {[Java-Options]}} {
            set isInJavaOptions 1
        } elseif {$isInJavaOptions} {
            if {[regexp {^\[} $line]} {
                if {!$containsInfoparkOptions} {
                    append newContent $infoparkJavaOptions
                }
                set isInJavaOptions 0
            } elseif {[regexp {^; Infopark options} $line]} {
                set containsInfoparkOptions 1
            }
        }
        append newContent "$line\n"
    }
    if {$isInJavaOptions && !$containsInfoparkOptions} {
        append newContent $infoparkJavaOptions
    }
    writeFile $triforkServiceIni $newContent
}


proc serviceTrifork {serviceCommand} {
    set triforkBin [file join $::conf(triforkHome) domains default bin setDomainEnv.cmd]
    if {[catch {set triforkEnv [readFile $triforkBin]}] || ![regexp -line\
            {set JAVA_HOME=(.*?)$} $triforkEnv match javaHome]} {
        puts "failed to determine JAVA_HOME from $triforkBin"
        exit 1
    }
    set javaBin [file join [string trim $javaHome] bin java]
    set javaservice "javaservice"
    if {![catch {exec $javaBin -version 2>@1} description] &&
            [string match -nocase "* 64-bit *" $description]} {
        append javaservice "-x64"
    }
    set triforkServiceSetup [shortPath [file join\
            $::conf(triforkHome) server bin $javaservice]]
    set triforkServiceIni [shortPath [file join\
            $::conf(triforkDomainDir) bin service default service.ini]]
    if {$serviceCommand eq "/install"} {
        patchTriforkServiceIni $triforkServiceIni
    }
    foreach {exitCode data} [eval _exec [cmdCaller]\
            [list $triforkServiceSetup\
            [format "/file:%s" $triforkServiceIni]\
            $serviceCommand]] {}
    # Trifork 4.1.36 does always SIGABRT on exiting :(
    if {$exitCode == 1 || $exitCode == 40 || $exitCode eq "SIGABRT"} {
        return 0
    }
    # Tcl 8.5 returns signal exitCode differently
    if {$exitCode eq "unknown" && $data eq "signal"} {
        return 0
    }
    return 1
}


proc installServiceApp {app mode} {
    if {$app eq "trifork"} {
        return [serviceTrifork "/install"]
    }

    array set serviceTitleForApp {
            "CM" "Content Manager"
            "TE" "Template Engine"
            "SES" "Search Engine Server"
            }

    if {![info exists serviceTitleForApp($app)]} {
        eputs "Error: Cannot install service for app $app."
        return 1
    }
    set serviceTitle [serviceName $app $serviceTitleForApp($app)]
    puts "Installing [serviceName $app] service ..."
    return [_exec [file nativename [file join $::conf(binDir) Infoker.bat]]\
            install [serviceName $app] $serviceTitle $mode ""\
            [file nativename [file join $::conf(binDir) ${app}.bat]]]
}


proc uninstallServiceApp {app} {
    if {$app eq "trifork"} {
        return [serviceTrifork "/remove"]
    }

    puts "Uninstalling [serviceName $app] service ..."
    return [_exec [file nativename [file join $::conf(binDir) Infoker.bat]]\
            uninstall [serviceName $app]]
}


proc waitForTriforkStartup {} {
    puts "Waiting for Trifork server to start up ..."
    set start [clock seconds]
    while {[clock seconds] - $start < 240} {
        if {[catch {
            if {[isTriforkRunning]} {
                puts "The Trifork server is up and running."
                set result 0
            }
        } msg]} {
            eputs $msg
            set result 1
        }
        if {[info exists result]} {
            return $result
        }
        after 5000
    }
    eputs "The Trifork server did not come up."
    eputs "Tried to connect it for 240 seconds."
    eputs "Please check its log files in $::conf(triforkLogDir)."
    return 1
}


proc waitForTriforkShutDown {} {
    puts "Waiting for trifork server to shut down ..."
    set start [clock seconds]
    while {[clock seconds] - $start < 180} {
        after 5000
        if {![isTriforkRunning]} {
            # wait for the vm cleanup
            after 5000
            return 0
        }
    }
    eputs "The Trifork server did not shut down."
    eputs "Successfully connected it for 180 seconds."
}


proc startTrifork {} {
    puts "Starting trifork"
    after 5000
    if {[isWindows]} {
        if {[_exec net start TriforkServer] != 0} {
            return 1
        }
    } else {
        set executable $::conf(triforkExecutable)
        if {![isExecutable $executable]} {
            return 1
        }
        if {![file isdirectory $::conf(triforkLogDir)]} {
            if {[catch {
                file mkdir $::conf(triforkLogDir)
            }]} {
                eputs "Error: Cannot create trifork log directory"
                eputs "  $::conf(triforkLogDir)."
                return 1
            }
        }
        eval exec nohup [list $executable] $::conf(triforkArgs)\
                >> [list $::conf(triforkLogDir)/vm.stdout.log]\
                2>> [list $::conf(triforkLogDir)/vm.stderr.log] < /dev/null &
    }
    return [waitForTriforkStartup]
}


proc isTriforkRunning {} {
    if {[callTrifork 0 system list] == 0} {
        return 1
    }
    return 0
}


proc stopTrifork {} {
    puts "Stopping trifork"
    if {[isTriforkRunning]} {
        if {[isWindows]} {
            if {[_exec net stop TriforkServer] != 0} {
                return 1
            }
        } else {
            if {[callTrifork 0 server stop] != 0} {
                return 1
            }
        }
        return [waitForTriforkShutDown]
    }
    return 0
}


proc restartTrifork {} {
    if {[stopTrifork] != 0} {
        return 1
    }
    return [startTrifork]
}


proc statusTrifork {} {
    puts -nonewline "trifork is "
    if {[isTriforkRunning] == 0} {
        puts -nonewline "not "
    }
    puts "running"
    return 0
}


proc deploy {webapp dir {systemContainer ""}} {
    if {![file isdirectory $dir]} {
        eputs "Error: Directory $dir does not exist."
        return 1
    }
    if {$systemContainer eq ""} {
        append webapp $::conf(webAppSuffix)
        set systemContainer $webapp
        if {[getTriforkCallOutput output system list] != 0} {
            return 1
        }
        if {[regexp -line "\\y$systemContainer\\y\$" $output] == 0} {
            puts "Creating system container $systemContainer..."
            if {[callTrifork 1 system create $systemContainer] != 0} {
                return 1
            }
        }
    }
    puts "Deploying $webapp from $dir into system container $systemContainer..."
    set result [callTrifork 1 archive deploy -appname $webapp\
            -inplace $systemContainer [shortPath $dir]]
    if {$result == 0} {
        puts "$webapp successfully deployed."
    }
    return $result
}


proc undeploy {webapp dir {systemContainer ""}} {
    if {$systemContainer eq ""} {
        append webapp $::conf(webAppSuffix)
        set systemContainer $webapp
    }
    puts "Undeploying $webapp from system container $systemContainer..."
    return [callTrifork 1 archive undeploy $systemContainer $webapp]
}


proc usage {{command ""}} {
    if {$command ne ""} {
        eputs "Unknown option $command"
    } else {
        eputs "Wrong arguments"
    }
    eputs ""

    set baseName [file rootname [file tail [info script]]]
    eputs "Usage:"
    eputs "  $baseName {start|stop|restart|status} \[APP\]..."
    eputs "  $baseName {deploy|undeploy|restart} \[WEBAPP\]..."
    eputs "  $baseName trifork <trifork command>"
    eputs "  $baseName apps"
    eputs "  $baseName webapps"
    if {[isWindows]} {
        eputs "  $baseName installService \[{manual|automatic}\] \[APP\]..."
        eputs "  $baseName uninstallService \[APP\]..."
    }
    eputs ""
    eputs [format "Default APPs are: %s" [join $::conf(apps) ", "]]
    eputs [format "Default WEBAPPs are: %s" [join $::conf(webApps) ", "]]
    return
}


set exitCode 0
set command [lindex $argv 0]
set args [lrange $argv 1 end]
switch -- $command {
    "trifork" {
        if {[llength $args] < 2} {
            set executable $::conf(triforkExecutable)
            if {![isExecutable $executable]} {
                set exitCode 1
            } else {
                set exitCode [eval _exec [cmdCaller]\
                        [list [file nativename $executable]] $args]
            }
        } else {
            if {[set exitCode [eval getTriforkCallOutput output $args]] == 0} {
                puts $output
            }
        }
    }
    "start" -
    "stop" -
    "restart" -
    "status" {
        set apps $args
        if {![llength $apps]} {
            set apps $::conf(apps)
        }
        foreach app $apps {
            set call [format "%s%s" $command [string toupper $app 0 0]]
            if {![llength [info procs $call]]} {
                set call [list ${command}App $app]
            }
            if {[eval $call] != 0} {
                set exitCode 1
            }
        }
    }
    "installService" -
    "uninstallService" {
        if {![isWindows]} {
            usage $command
            set exitCode 1
        } else {
            set mode ""
            if {$command eq "installService"} {
                set mode [lindex $args 0]
                if {$mode ne "manual" && $mode ne "automatic"} {
                    set mode "manual"
                } else {
                    set args [lrange $args 1 end]
                }
            }
            set apps $args
            if {![llength $apps]} {
                set apps [lsearch -not -all -inline $::conf(apps) "trifork"]
            }
            foreach app $apps {
                if {[eval ${command}App $app $mode] != 0} {
                    set exitCode 1
                }
            }
        }
    }
    "deploy" -
    "undeploy" {
        set apps $args
        if {![llength $apps]} {
            set apps $::conf(webApps)
        }
        foreach app $apps {
            if {$app eq "ROOT"} {
                if {[$command $app [file join $::conf(installDir) share\
                        welcome] default] != 0} {
                    set exitCode 1
                }
            } elseif {[$command $app [file join\
                    $::conf(webAppsDir) $app]] != 0} {
                set exitCode 1
            }
        }
    }
    "apps" {
        puts $::conf(apps)
    }
    "webapps" {
        puts $::conf(webApps)
    }
    default {
        usage $command
        set exitCode 1
    }
}

exit $exitCode
