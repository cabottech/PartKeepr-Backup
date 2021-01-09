#!/bin/sh

# PartKeepr-Backup
# 
# A Linux shell script that creates a backup of a PartKeepr database and
# important web files. Backups are conveniently compressed using zip to
# date-time-stamped filenames.
#
# Configure by modifying the partkeepr-backup.property file. See README.md for
# further details and instructions.
#
# Tested with PartKeepr 1.4.0 on Raspbian 9.13 (stretch) -
# https://wiki.partkeepr.org/wiki/PartKeepr_1.4.0_installation_on_a_Raspberry_Pi
#
# - Author: Cabot Technologies - https://cabottechnologies.com
# - Licence: MIT (see the LICENSE file)


ver="0.1.3"
echo "PartKeepr Backup $ver"

# Source the script settings
. ./partkeepr-backup.properties


backup_database() {
	local start=$(date +%s)
	local backup_file="${date_start}_partkeepr-database-backup.sql"

	echo "Database backup:" | tee -a "$backup_path/$log_file"
	echo "Retrieving database SQL..." | tee -a "$backup_path/$log_file"
	res="$( ( mysqldump --opt --host=$database_host --user=$database_user --password=$database_pass $database_name > "$backup_path/$backup_file" ) 2>&1 )"
	if $res
	then
		echo "* Success" | tee -a "$backup_path/$log_file"
	else
		echo "* ERROR: $res" | tee -a "$backup_path/$log_file"
		return 1
	fi

	echo "Compressing backup to ZIP archive..." | tee -a "$backup_path/$log_file"
	# Zip with maximum compression. Run at low priority.
	res="$( nice -n 10 zip -j -m -q -T -9 "$backup_path/$backup_file.zip" "$backup_path/$backup_file" )"
	if $res
	then
		echo "* Success" | tee -a "$backup_path/$log_file"
	else
		echo "* ERROR: $res" | tee -a "$backup_path/$log_file"
		return 1
	fi

	echo "Database backup summary:" | tee -a "$backup_path/$log_file"
	backup_summary "$backup_file.zip" "$start"
}


backup_app_data() {
	local start=$(date +%s)
	local backup_file="${date_start}_partkeepr-data-backup.zip"

	echo "Web data backup:" | tee -a "$backup_path/$log_file"
	echo "Compressing web data to ZIP archive..." | tee -a "$backup_path/$log_file"
	# Zip with maximum compression. Run at low priority.
	res="$( nice -n 10 zip -q -r -T -9 "$backup_path/$backup_file" "$partkeepr_data_path" )"
	if $res
	then
		echo "* Success" | tee -a "$backup_path/$log_file"
	else
		echo "* ERROR: $res" | tee -a "$backup_path/$log_file"
		return 1
	fi

	echo "Web data backup summary:" | tee -a "$backup_path/$log_file"
	backup_summary "$backup_file" "$start"
}


backup_app_config() {
	local start=$(date +%s)
	local backup_file="${date_start}_partkeepr-config-backup.zip"

	echo "Web config backup:" | tee -a "$backup_path/$log_file"
	echo "Compressing web config to ZIP archive..." | tee -a "$backup_path/$log_file"
	# Zip with maximum compression. Run at low priority.
	res="$( nice -n 10 zip -q -r -T -9 "$backup_path/$backup_file" "$partkeepr_config_path" )"
	if $res
	then
		echo "* Success" | tee -a "$backup_path/$log_file"
	else
		echo "* ERROR: $res" | tee -a "$backup_path/$log_file"
		return 1
	fi

	echo "Web config backup summary:" | tee -a "$backup_path/$log_file"
	backup_summary "$backup_file" "$start"
}


# Prints/logs a backup file summary
# $1 is the filename
# $2 is the start time - i.e. '$(date +%s)'
# Requires the global variable $backup_path be set.
backup_summary() {
	echo "* File name:   $1" | tee -a "$backup_path/$log_file"
	local filesize=$(ls -lsah "$backup_path/$1" | awk '{print $6}')
	echo "* File size:   $filesize" | tee -a "$backup_path/$log_file"

	local dur_sec=$(( $(date +%s) - $2 ))
	local hr=$(( dur_sec / 3600 )) # Calculate hours.
	local min=$(( (dur_sec % 3600) / 60 )) # Calculate remaining minutes.
	local sec=$(( dur_sec % 60 )) # Calculate remaining seconds.
	min=$(printf "%02d" $min) # Ensure two digits (zero padding).
	sec=$(printf "%02d" $sec) # Ensure two digits (zero padding).
	echo "* Duration:    $hr:$min:$sec\n" | tee -a "$backup_path/$log_file"
}


# First initialise backup path
date_start=$(date +'%Y%m%d-%H%M%S')
backup_path="$backup_root_path/$(date +%Y%m)"
log_file="${date_start}_partkeepr-backup.log"

echo "PartKeepr Backup $ver\n" > "$backup_path/$log_file"
echo "* Backup path: $backup_path"
echo "* Log: $log_file\n"

# Create backup path...
mkdir -p "$backup_path"

# Run backups
backup_database
backup_app_data
backup_app_config

echo "PartKeepr backup finished\n"
