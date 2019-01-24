# thngs

This repository contains code for rmtly Incorporated's IoT devices (hereafter referred to as "thngs").

```shell
- client/
  - blank/    # files for blanking device so new code can be sent
  - firmware/ # NodeMCU firmware files
  - mqtt/     # files used to create an MQTT-based client
  - nghtlght/ # a thng that acts as a night-light
  - esptool   # a tool for flashing firmware
  - luatool   # a tool to write a single file to the client
  - flash.sh  # entry point to sending new lua code; run from thng directory
```

## Flashing firmware

1. change to `client` directory
2. `./esptool erase && sleep 30 && ./esptool flash master`

## Flashing client code

1. change to device type directory, e.g. `nghtlght`
2. `../flash.sh`

To flash just a subset of files, e.g. on subsequent runs when you've only modified some files:

`../flash.sh <file> [<file> [<file> [...]]]`

E.g.

`../flash.sh ../mqtt/config.lua app.lua`
