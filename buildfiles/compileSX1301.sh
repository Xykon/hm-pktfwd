#! /bin/bash
set -x

echo "Compiling for SX1308"

cd /opt/iotloragateway/dev/lora_gateway/libloragw || exit
make clean
make -j 4


cd /opt/iotloragateway/dev/packet_forwarder/ || exit
make clean
make -j 4

cp -R "/opt/iotloragateway/dev/packet_forwarder/lora_pkt_fwd/lora_pkt_fwd" "/opt/iotloragateway/packetforwarder/lora_pkt_fwd"
