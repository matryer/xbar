#!/usr/bin/env python

# USB Device Details
# BitBar plugin
#
# by Raemond Bergstrom-Wood
#
# Displays the device details user input usb devices

print "USB"
print '---'
import plistlib
import subprocess
def findDevices(itemList):
    for device in itemList:
        if '_items' in device:
            findDevices(device['_items'])
        elif 'Built-in_Device' in device and device['Built-in_Device'] == 'Yes':
            continue
        else:
            print "Name:\t\t\t" + device['_name'] + '| color=white'
            if 'manufacturer' in device:
                print "Manufacturer:\t" + device['manufacturer'] + '| color=white'
            print '---'

usbPlist = subprocess.check_output(['system_profiler', '-xml', 'SPUSBDataType'])
usbInfo = plistlib.readPlistFromString(usbPlist)
findDevices(usbInfo)
