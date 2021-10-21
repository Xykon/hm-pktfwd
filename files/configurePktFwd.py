# Configure Packet Forwarder Program
# Configures the packet forwarder based on the YAML File and Env Variables
import sentry_sdk
import subprocess
import os
import json
from time import sleep

print("Starting Packet Forwarder Container")

# Sentry Diagnostics Code
sentry_key = os.getenv('SENTRY_PKTFWD')
if(sentry_key):
    balena_id = os.getenv('BALENA_DEVICE_UUID')
    balena_app = os.getenv('BALENA_APP_NAME')
    sentry_sdk.init(sentry_key, environment=balena_app)
    sentry_sdk.set_user({"id": balena_id})

with open("/var/pktfwd/diagnostics", 'w') as diagOut:
    diagOut.write("true")

print("Frequency Checking")

regionID = None
while(regionID is None):
    # While no region specified

    # Otherwise get region from miner
    try:
        regionOverride = str(os.environ['REGION_OVERRIDE'])
        if(regionOverride):
            regionID = regionOverride
            break
    except KeyError:
        print("No Region Override Specified")

    # Check to see if there is a region override
    try:
        with open("/var/pktfwd/region", 'r') as regionOut:
            regionFile = regionOut.read()

            if(len(regionFile) > 3):
                print("Frequency: " + str(regionFile))
                regionID = str(regionFile).rstrip('\n')
                break
        print("Invalid Contents")
        sleep(30)
        print("Try loop again")
    except FileNotFoundError:
        print("File Not Detected, Sleeping")
        sleep(60)


# Start the Module

print("Starting Module")
print("Sleeping 5 seconds")
sleep(5)

# Region dictionary
regionList = {
    "AS923_1": "AS923-1-global_conf.json",
    "AS923_2": "AS923-2-global_conf.json",
    "AS923_3": "AS923-3-global_conf.json",
    "AS923_4": "AS923-4-global_conf.json",
    "AU915": "AU-global_conf.json",
    "CN470": "CN-global_conf.json",
    "EU868": "EU-global_conf.json",
    "IN865": "IN-global_conf.json",
    "KR920": "KR-global_conf.json",
    "RU864": "RU-global_conf.json",
    "US915": "US-global_conf.json"
}

# Configuration function


def writeRegionConfSx1301(regionId):
    regionconfFile = "/opt/iotloragateway/packet_forwarder/sx1301/lora_templates_sx1301/"+regionList[regionId]
    with open(regionconfFile) as regionconfJFile:
        newGlobal = json.load(regionconfJFile)
    globalPath = "/opt/iotloragateway/packet_forwarder/sx1301/global_conf.json"

    with open(globalPath, 'w') as jsonOut:
        json.dump(newGlobal, jsonOut)


# Log the amount of times it has failed starting
failTimes = 0

while True:

    print("Starting")

    subprocess.call(['/opt/iotloragateway/packet_forwarder/reset-v2.sh'])
    sleep(2)

    print("SX1308")
    print("Frequency " + regionID)
    writeRegionConfSx1301(regionID)
    os.system("/opt/iotloragateway/packet_forwarder/sx1301/lora_pkt_fwd")
    print("Software crashed, restarting")
    failTimes += 1

    if(failTimes == 5):
        with open("/var/pktfwd/diagnostics", 'w') as diagOut:
            diagOut.write("false")

# Sleep forever
