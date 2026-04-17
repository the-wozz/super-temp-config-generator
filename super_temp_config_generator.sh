#!/bin/bash

# Author: Zachary 'Woz'nicki
# What it do: Creates a temporary SUPER config file with customizable parameters.
# Requirements: SUPER 5.1.0-rc1 minimum
sDate=4/17/26
sVersion=1.0
sTitle="Super Temp Config Generator"

# Modfiable Variables
# Temporary Config Name, set as Jamf Pro script Parameter 4 in Options!
tempConfigName=$4
# Targeted macOS version, set as Jamf Pro script Parameter 5 in Options!
macOSVersionTarget=$5
# Verbose mode to show more information in logs| 1 - Enabled 0 - Disabled
verboseMode=$6;if [ $verboseMode -eq 1 ]; then /bin/echo "VERBOSE MODE ENABLED";fi
# DO NOT TOUCH VARS
tempConfigFullName=com.macjutsu.super.$tempConfigName.plist
superconfigsFolder=/Library/Management/super/configs
# SUPER plist version from the default SUPER plist location
superVersion=$(/usr/bin/defaults read /Library/Management/super/com.macjutsu.super.plist SuperVersion)
# SUPER binary version reporting (only available in SUPER 5+)
#superVersion=$(/usr/local/bin/super --version)
# For future use comaring SUPER versions
# superMajorVersion=$(/bin/echo $superVersion | cut -c 1-5)
# superMinorVersion=$(/bin/echo $superVersion | cut -c 7-9)
# End Variables

# Start of script
/bin/echo "$sTitle [version: $sVersion ($sDate)]"

# check if SUPER version is at least 5.1.0-rc1 [when temp config option was introduced]
    if [[ "$superVersion" == *"5.1."* ]]; then
        /bin/echo "[PASSED] SUPER version is at minimum required [5.1.x] (Installed: $superVersion)'."
    else
        /bin/echo "[FAILED] SUPER version does NOT meet minimum required version [5.1.x]. Can not continue. Exiting... Please install correct SUPER version on machine"
            exit 1
    fi

# Check if prior temp config file exists with the same name, delete if so
/bin/echo "Checking if prior $tempConfigFullName already exists..."
if [ -e "$superconfigsFolder/$tempConfigFullName" ]; then
    /bin/echo "FOUND: $superconfigsFolder/$tempConfigFullName. Deleting..."
        /bin/rm -rf $superconfigsFolder/$tempConfigFullName
fi

# Create our temporary SUPER conifg
/bin/echo "Creating temporary config file [$superconfigsFolder/$tempConfigFullName]"
    /usr/bin/touch $superconfigsFolder/$tempConfigFullName

# change the file permissions so the config is readable
/bin/echo "Changing file permisisons for our temp config plist..."
    /bin/chmod 755 $superconfigsFolder/$tempConfigFullName

# write contents to the temporary config file
/bin/echo "Creating contents of SUPER TEMPORARY Config File [Targeting macOS: $macOSVersionTarget]."

/bin/cat <<EOF > "$superconfigsFolder/$tempConfigFullName"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>ConfigTempOverride</key>
    <true/>
    <key>InstallMacOSMajorUpgrades</key>
    <true/>
    <key>InstallMacOSMajorVersionTarget</key>
    <string>$macOSVersionTarget</string>
  </dict>
</plist>
EOF

    # Check if file was created AND the size of the file is NOT empty (-s)
    if [ -s "$superconfigsFolder/$tempConfigFullName" ]; then
        /bin/echo "SUPER Temp config created! [$superconfigsFolder/$tempConfigFullName]"
            # verbose mode verify what was created
            if [ $verboseMode -eq 1 ]; then
                /bin/echo "VERBOSE LINE | Showing contents of SUPER temp config file [$superconfigsFolder/$tempConfigFullName]"
                /bin/cat $superconfigsFolder/$tempConfigFullName
            fi
    else
        /bin/echo "ERROR: SUPER Temp config NOT created!"
            exit 1
    fi
/bin/echo "SUCCESS! Exiting..."
    exit 0