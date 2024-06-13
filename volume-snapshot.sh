#!/bin/bash
# =========================================================================== #
# Description:        Make automated snapshots of a volume using doctl
# Details:            Make snapshots and delete snapshots older than 4 days
# Made for:           DigitalOcean CTL: doctl, Linux.
# List volumes:       doctl compute volume list
# Volume ID:          5b4cc461-1056-11ef-9be5-0a58ac14c0dc
# Author:             WP Speed Expert
# Author URI:         https://wpspeedexpert.com
# GitHub URI:         https://github.com/WPSpeedExpert/doctl-volume-snapshot
# Version:            0.1.1
# Make executable:    chmod +x /home/wpspeedexpert/volume-snapshot.sh
# Crontab @daily:     0 1 * * * /home/wpspeedexpert/volume-snapshot.sh >/dev/null 2>&1
# =========================================================================== #
#
# Variables
LOGFILE=("/home/wpspeedexpert/volume-snapshot.log")
VolumeID=("5b4cc461-1056-11ef-9be5-0a58ac14c0dc")
#
# Make the log file empty
echo "[+] NOTICE: Start script"

# Truncate and write everything to the log file
truncate -s 0 ${LOGFILE}
exec &> ${LOGFILE}

# Log the date and time
echo "[+] NOTICE: Start script: $(date -u)"

# List the snapshots older than 3 days
echo "[+] NOTICE: List the snapshots older than 4 days."
snap=$(/usr/local/bin/doctl compute snapshot list --no-header --format ID,Name,CreatedAt,ResourceId | awk -F' ' -v date="$(date -d '4 days ago' '+%Y-%m-%d')" '$3 < date && $4 == "5b4cc461-1056-11ef-9be5-0a58ac14c0dc"' | awk '{print $1}')
echo $snap
if [ -z "$snap" ]; then
    echo "[+] WARNING: No snapshots older than 4 days."
else
    echo "[+] WARNING: Deleting snapshots older than 4 days."
   /usr/local/bin/doctl compute snapshot delete $snap --force
fi
# Create a new snapshot of the volume
echo "[+] NOTICE: Creating new snapshot..."
/usr/local/bin/doctl compute volume snapshot 5b4cc461-1056-11ef-9be5-0a58ac14c0dc --snapshot-name volume-production-`date +%Y-%m-%d`

# List all Snapshots
echo "[+] NOTICE: List all snapshots:"
/usr/local/bin/doctl compute snapshot list

# End of the script
echo "[+] NOTICE: End script: $(date -u)"

# Send email_notification
mail -s "[volume snapshot] report" brian@wpspeedexpert.com < ${LOGFILE}

# exit the script
exit 0
