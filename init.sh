#!/bin/bash

#********************************************************************************
# Copyright 2016 IBM
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#********************************************************************************

##################################################
# Colors
##################################################
export green='\e[0;32m'
export red='\e[0;31m'
export label_color='\e[0;33m'
export no_color='\e[0m' # No Color

##################################################
# Simple function to only run command if DEBUG=1
##################################################
debugme() {
  [[ $EXTENSION_DEBUG = 1 ]] && "$@" || :
}

set +e
set +x 




##################################################
# Build Grunt-Idra call
#
#   $1  Tool
#   $2  Log file location
#   $3  Environment
#   $4  Module
#   $5  Stage
##################################################
function dra_commands {
    echo -e "${no_color}"
    dra_grunt_command=""
    
    if [ -n "$1" ] && [ "$1" != " " ]; then
    
        dra_grunt_command="grunt --gruntfile=node_modules/grunt-idra3/idra.js -tool=$1"
        dra_grunt_command="$dra_grunt_command -testResult=$2"
        dra_grunt_command="$dra_grunt_command -env=$3"
        dra_grunt_command="$dra_grunt_command -stage=$5"
        
        debugme echo -e "dra_grunt_command with tool, log, env, & stage: \n\t$dra_grunt_command"
        
        if [ -n "$4" ] && [ "$4" != " " ]; then
        
            debugme echo -e "\tModule: '$4' is defined and not empty"
            dra_grunt_command="$dra_grunt_command -module=$4"
            debugme echo -e "\tdra_grunt_command: \n\t\t$dra_grunt_command"
            
        else
            debugme echo -e "\tModule: '$4' is not defined or is empty"
            debugme echo -e "${no_color}"
        fi
        
        
        debugme echo -e "FINAL dra_grunt_command: $dra_grunt_command"
        debugme echo -e "${no_color}"
        
        
        eval "$dra_grunt_command --no-color"
        GRUNT_RESULT=$?
        
        debugme echo "GRUNT_RESULT: $GRUNT_RESULT"
        
        if [ $GRUNT_RESULT -ne 0 ]; then
            exit 1
        fi
    else
        debugme echo "Event: '$1' is not defined or is empty"
    fi
    
    echo -e "${no_color}"
}


#################################################
# Call the Open Toolchain API to retrieve
#   Organization ID
#   DRA Server
#   If the DRA Broker is present
#################################################
function callOpenToolchainAPI {
    OUTPUT_FILE='draserver.txt'
    ${EXT_DIR}/dra-check.py ${PIPELINE_TOOLCHAIN_ID} "${$TOOLCHAIN_TOKEN}" "${IDS_PROJECT_NAME}" "${OUTPUT_FILE}"
    TOOLCHAIN_CALL_RESULT=$?

    #
    # Retrieve variables from toolchain API
    #
    DRA_CHECK_OUTPUT=`cat ${OUTPUT_FILE}`
    IFS=$'\n' read -rd '' -a dradataarray <<< "$DRA_CHECK_OUTPUT"
    rm ${OUTPUT_FILE}
    
    #
    # Export variables
    #
    export CF_ORGANIZATION_ID=${dradataarray[0]}
    #export DRA_SERVER=${dradataarray[1]}
    export DRA_PRESENT=$TOOLCHAIN_CALL_RESULT
    
}








#################################################
# Print the 'DRA is active' or 'DRA must be added' messages
#################################################
function printInitialDRAMessage {
    #0 = DRA is present
    #1 = DRA not present or there was an error with the http call (err msg will show)
    #echo $RESULT

    if [ $DRA_PRESENT -eq 0 ]; then
        debugme echo "DRA is present";

        echo -e "${green}"
        echo "**********************************************************************"
        echo "Deployment Risk Analytics (DRA) is active."
        echo "**********************************************************************"
        echo -e "${no_color}"
    else  
        debugme echo "DRA is NOT present";

        echo -e "${red}"
        echo "*******************************************************************************************"
        echo "In order to use this job extension, please add Deployment Risk Analytics to this toolchain."
        echo "*******************************************************************************************"
        echo -e "${no_color}"

        exit 1
    fi
}


#################################################
# Install DRA dependencies
#################################################
function installDRADependencies {
    npm install grunt-idra3
    npm install grunt
    npm install grunt-cli
}




export -f debugme
export -f dra_commands
export -f callOpenToolchainAPI
export -f printInitialDRAMessage
export -f installDRADependencies
