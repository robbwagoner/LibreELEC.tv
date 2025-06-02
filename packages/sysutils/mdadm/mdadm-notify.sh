#!/bin/bash
#
# This file is used by mdadm.conf PROGRAM to rely on kodi-notify.sh for notifications.
#
# See "Monitor Mode" in mdadm(8) for details. http://linux.die.net/man/8/mdadm

case ${1} in
    NewArray)
        TITLE="New RAID Array Detected"
        MESSAGE="A new RAID array has been detected: ${2}"
        ICON="info"
        ;;
    ArrayStarted)
        TITLE="RAID Array Started"
        MESSAGE="The RAID array has been started: ${2}"
        ICON="info"
        ;;
    ArrayStopped)
        TITLE="RAID Array Stopped"
        MESSAGE="The RAID array has been stopped: ${2}"
        ICON="info"
        ;;
    ArrayResyncing)
        TITLE="RAID Array Resyncing"
        MESSAGE="The RAID array is resyncing: ${2}"
        ICON="info"
        ;;
    DeviceDisappeared)
        TITLE="RAID Device Disappeared"
        MESSAGE="A RAID device has disappeared: ${2}"
        ICON="error"
        ;;
    RebuildStarted)
        TITLE="RAID Rebuild Started"
        MESSAGE="Rebuilding RAID array: ${2}"
        ICON="warning"
        ;;
    RebuildFinished)
        TITLE="RAID Rebuild Finished"
        MESSAGE="Rebuilding RAID array finished: ${2}"
        ICON="warning"
        ;;
    Fail)
        TITLE="RAID Device Failure"
        MESSAGE="A RAID device has failed: ${2}"
        ICON="error"
        ;;
    DegradedArray)
        TITLE="RAID Array Degraded"
        MESSAGE="The RAID array is degraded: ${2}"
        ICON="error"
        ;;
    *)
        TITLE="MDADM Notification"
        MESSAGE="Unhandled event type: ${1} (${2})"
        ICON="warning"
        ;;
esac
logger -t mdadm-notify "${TITLE}: ${MESSAGE}"
/usr/bin/kodi-notify.sh ${TITLE} ${MESSAGE} 30000 ${ICON}
