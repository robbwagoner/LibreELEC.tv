#!/bin/bash

# This script mounts Linux RAID MD devices to /var/media/{LABEL}
# Called by udev when a RAID device is added

MD_DEVICE="/dev/$1"
MOUNT_BASE="/var/media"
KODI_NOTIFY="/usr/bin/kodi-notify.sh"
TOUCH_FILE="/tmp/mount-md-${MD_DEVICE##*/}.mounted"
IS_TTY=false

# Check if the script is being run in a terminal
if test -t 0 ; then
    IS_TTY=true
fi

# Function to print debug messages if running in a terminal
debug(){
    if ${IS_TTY} ; then
        echo -e "\e[1;34m$@\e[0m"  # Blue text for debug messages
    fi
}

# Log function to handle both logging and debugging
log() {
    logger -t mount-md "$@"
    debug "$@"
}

# Check if device is already mounted
if grep -q "${MD_DEVICE}" /proc/mounts; then
    # If a touch file exists, exit early
    if [ -f "${TOUCH_FILE}" ]; then
        crontab -r # Clear any existing crontab entries to avoid duplicates
        exit 0
    fi
    log "${MD_DEVICE} already mounted (cached)."
    ${KODI_NOTIFY} "Mount Successful" "${MD_DEVICE} already mounted (cached)" 20000 info ;
    touch "${TOUCH_FILE}"
    exit 0
fi

# Exit if device doesn't exist
if [ ! -b "${MD_DEVICE}" ]; then
    log "Device ${MD_DEVICE} does not exist"
    exit 1
fi

# Wait a moment for device to be fully available
sleep 2

# Try to get filesystem label
LABEL=$(blkid -s LABEL -o value "${MD_DEVICE}")
if [ -z "${LABEL}" ]; then
    # If no label, use device name
    LABEL=$(basename "${MD_DEVICE}")
fi

SYSTEMD_UNIT_NAME="var-media-${LABEL}.mount"
debug "Systemd unit name: ${SYSTEMD_UNIT_NAME}"

# Create mount point
MOUNT_POINT="${MOUNT_BASE}/${LABEL}"
mkdir -p "${MOUNT_POINT}"

# Mount with retries - due to Systemd bug 1741
MOUNT_TRIES=1
MOUNT_TRIES_MAX=3

until [[ ${MOUNT_TRIES} -ge ${MOUNT_TRIES_MAX} ]] ; do
    log "Attempting to mount ${MD_DEVICE} at ${MOUNT_POINT} [${MOUNT_TRIES}/${MOUNT_TRIES_MAX}]"
    # mount -o defaults,noatime "${MD_DEVICE}" "${MOUNT_POINT}"
    systemd-mount --options noatime "${MD_DEVICE}" "${MOUNT_POINT}"
    MOUNT_TRIES=$(( MOUNT_TRIES + 1 )) # busybox shell-compatible increment
    sleep 1 # Give it a moment to settle

    log "Unit '${SYSTEMD_UNIT_NAME}' status: $(systemctl is-active ${SYSTEMD_UNIT_NAME})"

    if systemctl is-active --quiet "${SYSTEMD_UNIT_NAME}" ; then
        touch ${TOUCH_FILE}
        log "Successfully mounted ${MD_DEVICE} at ${MOUNT_POINT}"
        ${KODI_NOTIFY} "Mount MD Successful" "Mounted ${MD_DEVICE} at ${MOUNT_POINT}" 20000 info
        chmod 755 "${MOUNT_POINT}"
        printenv >/tmp/mount-md-${MD_DEVICE##*/}.env
        exit 0
    else
        log "Systemd unit ${SYSTEMD_UNIT_NAME} is not active; doing systemd daemon-reload to handle Systemd bug 1741."
        systemctl daemon-reload
    fi
    sleep 1
done

log "Failed to mount ${MD_DEVICE} at ${MOUNT_POINT} after ${MOUNT_TRIES_MAX} attempts."
${KODI_NOTIFY} "Mount MD Failed" "Failed to mount ${MD_DEVICE} at ${MOUNT_POINT} after ${MOUNT_TRIES_MAX} attempts." 20000 error

# Work around this Systemd bug from 2015 using crontab:
# https://www.bentasker.co.uk/posts/documentation/linux/480-disk-automatically-unmounts-immediately-after-mounting.html
# https://blog.thomasdamgaard.dk/posts/2023/02/15/how-to-fix-linux-unmounting-filesystem-immediately-after-mounting/
# https://github.com/systemd/systemd/issues/1741
echo "* * * * * $0 ${MD_DEVICE}" | crontab -
exit 2
