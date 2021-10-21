#!/usr/bin/env bash

WAIT_GPIO() {
    sleep 0.1
}

IOT_SK_SX1301_RESET_PIN=23
IOT_SK_SX1257_RESET_PIN=2
IOT_SK_EN_PIN=13
IOT_SK_FEM_PIN=25

if [ ! -d "/sys/class/gpio/gpio$IOT_SK_SX1301_RESET_PIN" ]; then
    echo "$IOT_SK_SX1301_RESET_PIN" > /sys/class/gpio/export
fi
if [ ! -d "/sys/class/gpio/gpio$IOT_SK_SX1257_RESET_PIN" ]; then
    echo "$IOT_SK_SX1257_RESET_PIN" > /sys/class/gpio/export
fi
if [ ! -d "/sys/class/gpio/gpio$IOT_SK_EN_PIN" ]; then
    echo "$IOT_SK_EN_PIN" > /sys/class/gpio/export
fi
if [ ! -d "/sys/class/gpio/gpio$IOT_SK_FEM_PIN" ]; then
    echo "$IOT_SK_FEM_PIN" > /sys/class/gpio/export
fi

echo "out" > /sys/class/gpio/gpio$IOT_SK_EN_PIN/direction; WAIT_GPIO
echo "out" > /sys/class/gpio/gpio$IOT_SK_SX1301_RESET_PIN/direction; WAIT_GPIO
echo "out" > /sys/class/gpio/gpio$IOT_SK_SX1257_RESET_PIN/direction; WAIT_GPIO
echo "out" > /sys/class/gpio/gpio$IOT_SK_FEM_PIN/direction; WAIT_GPIO

echo "1" > /sys/class/gpio/gpio$IOT_SK_EN_PIN/value; WAIT_GPIO
echo "1" > /sys/class/gpio/gpio$IOT_SK_SX1257_RESET_PIN/value; WAIT_GPIO
echo "0" > /sys/class/gpio/gpio$IOT_SK_SX1257_RESET_PIN/value; WAIT_GPIO
echo "1" > /sys/class/gpio/gpio$IOT_SK_SX1301_RESET_PIN/value; WAIT_GPIO
echo "0" > /sys/class/gpio/gpio$IOT_SK_SX1301_RESET_PIN/value; WAIT_GPIO
echo "1" > /sys/class/gpio/gpio$IOT_SK_FEM_PIN/value; WAIT_GPIO
