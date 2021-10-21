#!/bin/sh

#set -x
#set -v


IOT_SK_SX1301_RESET_PIN=23
IOT_SK_SX1257_RESET_PIN=2
IOT_SK_EN_PIN=13
IOT_SK_FEM_PIN=25
IOT_SK_CE0_PIN=8


echo "Accessing concentrator reset pin through GPIO$IOT_SK_SX1301_RESET_PIN..."

WAIT_GPIO() {
    sleep 0.1
}

iot_sk_init() {
    # setup GPIO 7
    echo "$IOT_SK_SX1301_RESET_PIN" > /sys/class/gpio/export; WAIT_GPIO
    echo "$IOT_SK_SX1257_RESET_PIN" > /sys/class/gpio/export; WAIT_GPIO
    echo "$IOT_SK_EN_PIN" > /sys/class/gpio/export; WAIT_GPIO
    echo "$IOT_SK_FEM_PIN" > /sys/class/gpio/export; WAIT_GPIO
#    echo "$IOT_SK_CE0_PIN" > /sys/class/gpio/export; WAIT_GPIO

    # set GPIO 7 as output
    echo "out" > /sys/class/gpio/gpio$IOT_SK_EN_PIN/direction; WAIT_GPIO
    echo "out" > /sys/class/gpio/gpio$IOT_SK_SX1301_RESET_PIN/direction; WAIT_GPIO
    echo "out" > /sys/class/gpio/gpio$IOT_SK_SX1257_RESET_PIN/direction; WAIT_GPIO
    echo "out" > /sys/class/gpio/gpio$IOT_SK_FEM_PIN/direction; WAIT_GPIO
#    echo "out" > /sys/class/gpio/gpio$IOT_SK_CE0_PIN/direction; WAIT_GPIO

    # write output for SX1301 reset
    echo "1" > /sys/class/gpio/gpio$IOT_SK_EN_PIN/value; WAIT_GPIO
    echo "1" > /sys/class/gpio/gpio$IOT_SK_SX1257_RESET_PIN/value; WAIT_GPIO
    echo "0" > /sys/class/gpio/gpio$IOT_SK_SX1257_RESET_PIN/value; WAIT_GPIO
    echo "1" > /sys/class/gpio/gpio$IOT_SK_SX1301_RESET_PIN/value; WAIT_GPIO
    echo "0" > /sys/class/gpio/gpio$IOT_SK_SX1301_RESET_PIN/value; WAIT_GPIO
    echo "1" > /sys/class/gpio/gpio$IOT_SK_FEM_PIN/value; WAIT_GPIO
#    echo "1" > /sys/class/gpio/gpio$IOT_SK_CE0_PIN/value; WAIT_GPIO
#    echo "0" > /sys/class/gpio/gpio$IOT_SK_CE0_PIN/value; WAIT_GPIO

    # set GPIO 7 as input
#    echo "in" > /sys/class/gpio/gpio$IOT_SK_SX1301_RESET_PIN/direction; WAIT_GPIO
#    echo "in" > /sys/class/gpio/gpio$IOT_SK_SX1257_RESET_PIN/direction; WAIT_GPIO
#    echo "in" > /sys/class/gpio/gpio$IOT_SK_CE0_PIN/direction; WAIT_GPIO
}

iot_sk_term() {
    # cleanup GPIO 7
    if [ -d /sys/class/gpio/gpio$IOT_SK_SX1301_RESET_PIN ]
    then
        echo "$IOT_SK_SX1301_RESET_PIN" > /sys/class/gpio/unexport; WAIT_GPIO
    fi
    if [ -d /sys/class/gpio/gpio$IOT_SK_SX1257_RESET_PIN ]
    then
        echo "$IOT_SK_SX1257_RESET_PIN" > /sys/class/gpio/unexport; WAIT_GPIO
    fi
    if [ -d /sys/class/gpio/gpio$IOT_SK_EN_PIN ]
    then
        echo "$IOT_SK_EN_PIN" > /sys/class/gpio/unexport; WAIT_GPIO
    fi
    if [ -d /sys/class/gpio/gpio$IOT_SK_FEM_PIN ]
    then
        echo "$IOT_SK_FEM_PIN" > /sys/class/gpio/unexport; WAIT_GPIO
    fi
}


case "$1" in
    start)
    iot_sk_term
    iot_sk_init
    ;;
    stop)
    iot_sk_term
    ;;
    *)
    echo "Usage: $0 {start|stop} [<gpio number>] [<gpio number>]"
    exit 1
    ;;
esac

exit 0
