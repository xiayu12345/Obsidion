#!/bin/sh
# Tmall 7045:2018: idle = keyboard only (voice key); record = bind USB-Audio briefly
PHY_TH=/sys/devices/platform/soc@3000000/4101000.ehci0-controller/phy_threshold
HOST=/sys/devices/platform/soc@3000000/soc@3000000:usbc0@0/usb_host

tmall_wait() {
  i=0
  while [ $i -lt 30 ]; do
    [ -e /sys/bus/usb/devices/2-1 ] && return 0
    i=$((i+1)); sleep 1
  done
  return 1
}

tmall_idle() {
  echo -1 > /sys/module/usbcore/parameters/autosuspend 2>/dev/null
  echo 100 > /sys/module/usbhid/parameters/kbpoll 2>/dev/null
  echo 0 > /sys/module/usbhid/parameters/mousepoll 2>/dev/null
  [ -e /sys/bus/usb/devices/2-1 ] || return 1
  echo on > /sys/bus/usb/devices/2-1/power/control 2>/dev/null
  echo -n "2-1:1.0" > /sys/bus/usb/drivers/snd-usb-audio/unbind 2>/dev/null
  echo -n "2-1:1.1" > /sys/bus/usb/drivers/snd-usb-audio/unbind 2>/dev/null
  echo -n "2-1:1.4" > /sys/bus/usb/drivers/usbhid/unbind 2>/dev/null
  echo -n "2-1:1.3" > /sys/bus/usb/drivers/usbhid/unbind 2>/dev/null
  echo -n "2-1:1.3" > /sys/bus/usb/drivers/usbhid/bind 2>/dev/null
  echo idle: kbd only, kbpoll=100
  ls -l /sys/bus/usb/devices/2-1:1.*/driver 2>/dev/null
}

tmall_record() {
  sec=${1:-5}
  out=${2:-/tmp/tmall_voice.wav}
  [ -e /sys/bus/usb/devices/2-1 ] || { echo no device; return 1; }
  echo -n "2-1:1.0" > /sys/bus/usb/drivers/snd-usb-audio/bind 2>/dev/null
  echo -n "2-1:1.1" > /sys/bus/usb/drivers/snd-usb-audio/bind 2>/dev/null
  sleep 1
  grep -q Mouse /proc/asound/cards || { echo no usb audio card; tmall_idle; return 1; }
  echo recording ${sec}s -> $out
  arecord -D hw:Mouse,0 -f S16_LE -r 16000 -c 1 -d "$sec" "$out"
  rc=$?
  tmall_idle
  ls -l "$out" 2>/dev/null
  return $rc
}

case "$1" in
  idle) tmall_wait && tmall_idle ;;
  record) tmall_wait && tmall_record "$2" "$3" ;;
  *) echo "usage: $0 idle|record [sec] [outfile]" ;;
esac
