#!/usr/bin/env python


import sys
import requests
import re
import os
from urlparse import urlparse



if len(sys.argv) < 6:
    print "ERROR: TOOLCHAIN_ID, BEARER, PROJECT_NAME, or IDS_URL are not defined."
    exit(1)
    
    
TOOLCHAIN_ID = sys.argv[1]
BEARER = sys.argv[2]
PROJECT_NAME = sys.argv[3]
OUTPUT_FILE = sys.argv[4]
IDS_URL = sys.argv[5]
DRA_SERVICE_NAME = 'draservicebroker'
DRA_PRESENT = False
ORGANIZATION_GUID = ''
CF_CONTROLLER = ''
DRA_SERVER = ''
DLMS_SERVER = ''
IDS_URL = urlparse(IDS_URL)

#print IDS_URL.scheme + "://" + IDS_URL.netloc.replace( 'devops', 'devops-api' )
IDS_URL = IDS_URL.scheme + "://" + IDS_URL.netloc.replace( 'devops', 'devops-api' )
#print IDS_URL

try:
    r = requests.get( IDS_URL + '/v1/toolchains/' + TOOLCHAIN_ID + '?include=metadata', headers={ 'Authorization': BEARER })
    
    data = r.json()
    #print data
    if r.status_code == 200:
        
        for items in data[ 'items' ]:
            #print items[ 'name' ]
            if items[ 'name' ] == PROJECT_NAME:
                #print items[ 'name' ]
                #print items[ 'organization_guid' ]
                ORGANIZATION_GUID = items[ 'organization_guid' ]
                
                for services in items[ 'services' ]:
                    #print services[ 'service_id' ]
                    if services[ 'service_id' ] == DRA_SERVICE_NAME:
                        DRA_PRESENT = True
                        CF_CONTROLLER = services[ 'parameters' ][ 'cf_controller' ]
                        DRA_SERVER = services[ 'parameters' ][ 'dra_server' ]
                        DLMS_SERVER = services[ 'parameters' ][ 'dlms_server' ]
                        #Test case
                        #services[ 'dashboard_url' ]='https://da.oneibmcloud.com/dalskdjl/ljalkdj/'
                        #print services[ 'dashboard_url' ]
                        #urlRegex = re.compile(r'http\w*://\S+?/');
                        #mo = urlRegex.search(services[ 'dashboard_url' ])
                        #DRA_SERVER = mo.group()[:-1]
    else:
        #ERROR response from toolchain API
        print 'ERROR:', r.status_code, '-', data
        #print 'DRA was disabled for this session.'
except requests.exceptions.RequestException as e:
    print 'ERROR: ', e
    #print 'DRA was disabled for this session.'
    


        
        
if DRA_PRESENT:
    f = open(OUTPUT_FILE,'w')
    f.write(ORGANIZATION_GUID)
    f.write('\n')
    f.write(CF_CONTROLLER)
    f.write('\n')
    f.write(DRA_SERVER)
    f.write('\n')
    f.write(DLMS_SERVER)
    f.close()
    exit(0)
else:
    exit(1)