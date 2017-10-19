#!/bin/bash

# Init
netctlAuto=`systemctl | grep netctl-auto | sed 's/.service.*/.service/g'`
wifimenucommand="wifi-menu"
wifimenucommandsuffix=""
chmodNewWifiMenu='true'
netctlProfilePath='/etc/netctl'

#make newlines the split character for arrays
IFS=$'\n'

if [[ ! -z $netctlAuto ]] ; then
    switchcommand="netctl-auto switch-to"
    stopallcommand="netctl-auto disable-all"
    wifimenucommandsuffix="systemctl restart $netctlAuto"
    restartcommand="systemctl restart $netctlAuto"
else 
    switchcommand="netctl switch-to"
    stopallcommand="netctl stop-all"
    restartcommand="systemctl restart $(systemctl | grep netctl | sed 's/.service.*/.service/g')"
fi

# add sudo if necessary
if [[ $EUID -ne 0 ]] ; then
    wifimenucommand="sudo $wifimenucommand"
    restartcommand="sudo $restartcommand"

    if [[ ! -z $wifimenucommandsuffix ]] ; then
        wifimenucommandsuffix="sudo $wifimenucommandsuffix"
    fi

    if [[ -z $netctlAuto ]] ; then 
        switchcommand="sudo $switchcommand"
        stopallcommand="sudo $stopallcommand"
    fi
fi


#finish splicing wifimenu together
if [ -z "$wifimenucommandsuffix" ]; then wifimenucommand="$wifimenucommand && $wifimenucommandsuffix"; fi
wifimenucommand="echo Lanuching wifi-menu... ; $wifimenucommand"

switchProfile () 
{
	if ! [ -e "/etc/netctl/$1" ] ; then
		echo "Error: profile: \"$1\" does not exist"
		exit 1
	elif ! [ -r "/etc/netctl/$1" ] ; then
		switchcommand="sudo $switchcommand"
	fi
	echo "Switching to $1..."
	eval $switchcommand $1
}
switchProfilePrompt () 
{
	echo "Switch to profile $1? (Y/n)"
	read userinput
	if [ -z $(echo "$userinput" | grep -E '[Nn][Oo]?') ]; then
		switchProfile $1
	fi
}

listAndChoose () 
{
    connections=( $(netctl-auto list) )
    current='0'
    for (( ii=0; ii<${#connections[@]}; ii++ ));
    do
        echo "[$(($ii + 1))]: ${connections[ii]}"
    done
    if `hash wifi-menu 2>/dev/null` ; then #supress hash error
        echo '[w] launch wifi-menu'
    fi
    echo '[e] exit'
    
    read userinput
    if [ -z "$userinput" ] ; then
	return
    elif [ -z $(echo $userinput | sed 's/[0-9]*//') ] && [ "$userinput" -le "${#connections[@]}" ]
        # if userinput is entirely numbers and a valid index and non-null
    then
	switchProfile $(echo ${connections[(($userinput - 1))]} | cut -c 3-)
    elif $(hash wifi-menu 2>/dev/null) && [[ "$userinput" == "w" || "$userinput" == "W" ]]; then
        eval $wifimenucommand
    else 
	switchHandler $userinput
    fi
}

switchHandler ()
{
    if [ -e "$netctlProfilePath/$1" ] && [ ! -d "$netctlProfilePath/$1" ] ; then
	switchProfile $1
    else 
	inputProfiles=( $(ls -p $netctlProfilePath | grep -v '/' | #List only non-directories
	grep -o '.*'$1'.*') $(grep -i -s -l "ESSID=.*$1.*" $netctlProfilePath/* | sed "s:$netctlProfilePath/::") )
	if [ ! -z $inputProfiles ] ; then
	    #remove duplicates
	    eval inputProfiles=( $(printf "%q\n" "${inputProfiles[@]}" | sort -u) )
	    matchingProfiles=()
	    for thing in ${inputProfiles[@]} ; do
		if [ ! -d "$thing" ] ; then
		    matchingProfiles+=("$thing")
		fi
	    done

	    #ask to switch to the first if it's the only one
	    if [ "${#matchingProfiles[@]}" -eq "1" ] ; then
		switchProfilePrompt "${matchingProfiles[0]}"
	    else
		echo "Possible matches:"
		for (( ii=0; ii<${#matchingProfiles[@]}; ii++ ));
		do
		    echo "[$(($ii + 1))]: ${matchingProfiles[ii]}"
		done
		echo '[w] launch wifi-menu'
		echo '[e] exit'
		read userinput
		if [ -z $(echo $userinput | sed 's/[0-9]*//') ] && [ ! -z "$userinput" ] && [ "$userinput" -le "${#matchingProfiles[@]}" ]
		    # if userinput is entirely numbers and a valid index and non-null
		then
		    switchProfile "${matchingProfiles[(($userinput - 1))]}"

		elif $(hash wifi-menu 2>/dev/null) && [[ "$userinput" == "w" || "$userinput" == "W" ]]; then
		    eval $wifimenucommand
		fi #by default do nothing
	    fi
	else
	    echo "No matching profiles found; launch wifi-menu? (Y/n)"
	    read userinput
	    if [ -z $(echo "$userinput" | grep -E '[Nn][Oo]?') ]; then
		eval $wifimenucommand
	    fi
	fi
    fi
}

if [[ -z $1 ]]; then
    listAndChoose
elif [[ "$1" == "restart" || "$1" == "r" ]]; then
    eval $restartcommand
elif [[ "$1" == "w" || "$1" == "menu" ]]; then
    eval $wifimenucommand
elif [[ "$1" == "ping" || "$1" == "p" ]]; then
    if [[ -z $2 ]]; then
	pingLocation='google.com'
    else
	pingLocation=$2
    fi
    while [[ ! `ping -c 1 -W 1 $pingLocation 2>/dev/null` ]]; do sleep 0.1; done
    echo Connected: $(ping -c 1 -w 0.5 $pingLocation 2>/dev/null | grep -o 'time=[0-9/.]* ms' | sed "s/time/Latency with $pingLocation/" | sed 's/=/ ~/')
else
    switchHandler $1
fi
