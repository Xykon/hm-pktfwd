# Packet Forwarder Docker File
# (C) Nebra Ltd 2019
# Licensed under the MIT License.

####################################################################################################
################################## Stage: builder ##################################################

FROM balenalib/raspberry-pi-debian:buster-build as builder

# Move to correct working directory
WORKDIR /opt/iotloragateway/dev

# Copy python dependencies for `pip install` later
COPY requirements.txt requirements.txt

# This will be the path that venv uses for installation below
ENV PATH="/opt/iotloragateway/dev/venv/bin:$PATH"

# Install build tools
# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        automake \
        libtool \
        autoconf \
        git \
        ca-certificates \
        pkg-config \
        build-essential \
        python3 \
        python3-pip \
        python3-venv && \
    # Because the PATH is already updated above, this command creates a new venv AND activates it
    python3 -m venv /opt/iotloragateway/dev/venv && \
    # Given venv is active, this `pip` refers to the python3 variant
    pip install --no-cache-dir -r requirements.txt

# Clone the lora gateway and packet forwarder repos
RUN git clone https://github.com/NebraLtd/lora_gateway.git
RUN git clone https://github.com/NebraLtd/packet_forwarder.git

# Create folder needed by packetforwarder compiler
RUN mkdir -p /opt/iotloragateway/packetforwarder

COPY ./buildfiles/compileSX1301.sh compileSX1301.sh

# Compile for sx1301 concentrator on all the necessary SPI buses
RUN ./compileSX1301.sh

FROM balenalib/raspberry-pi-debian:buster-run as runner

# Start in sx1301 directory
WORKDIR /opt/packet_forwarder

# Install python3-venv and python3-rpi.gpio
# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get -y install \
        python3-venv \
        python3-rpi.gpio && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy sx1301 packetforwader from builder
COPY --from=builder /opt/iotloragateway/packetforwarder .

# Copy sx1301 regional config templates
COPY lora_templates lora_templates/

# Use EU config as initial default
COPY lora_templates/local_conf.json local_conf.json
COPY lora_templates/US-global_conf.json global_conf.json

WORKDIR /opt/iotloragateway/packet_forwarder
COPY files/* .

COPY files/run_pkt.sh .
COPY files/configurePktFwd.py .
COPY files/reset-v2.sh .
RUN chmod +x reset-v2.sh
RUN chmod +x run_pkt.sh
RUN chmod +x configurePktFwd.py
COPY files/reset_lgw.sh .
RUN chmod +x reset_lgw.sh

# Run run_pkt script
ENTRYPOINT ["sh", "/opt/iotloragateway/packet_forwarder/run_pkt.sh"]
