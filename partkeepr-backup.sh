#!/bin/sh

# PartKeepr Backup
# 
# Performs a backup of the PartKeepr database and relevent files (data and config).
# Creates a ZIP archive with a date-time stamped filename.
# Modify the associated pk-backup.property file with you system specifics.
#
# See README.md for further details and instructions.
# 
# License: MIT
# 
# Author: Darian, https://cabottechnologies.com
#
# Tested with:
# - PartKeepr 1.4.0 on Raspbian 9.13 (stretch)
#
# Requires:
# - 'zip' package.

echo "PartKeepr Backup 0.1"

# Source the script config file:
. ./partkeepr-backup.properties


backup_database() {
	local start=$(date +%s)
	local backup_file="${date_start}_partkeepr-database-backup.sql"

	printf "PartKeepr database backup started...\n" | tee -a $backup_path/$log_file
	res="$( ( mysqldump --opt --host=$database_host --user=$database_user --password=$database_pass $database_name > $backup_path/$backup_file ) 2>&1 )"
	if $res
	then
		printf "* Success\n" | tee -a $backup_path/$log_file
	else
		printf "* ERROR: $res\n" | tee -a $backup_path/$log_file
		return 1
	fi

    printf "Compressing backup to ZIP archive...\n" | tee -a $backup_path/$log_file
    # Zip the SQL file with maximum compression. This is CPU intensive, so nice 10 is used (low priority).
    res="$( nice -10 zip -j -m -q -T -9 "$backup_path/$backup_file.zip" "$backup_path/$backup_file" )"
	if $res
	then
		printf "* Success\n" | tee -a $backup_path/$log_file
	else
		printf "* ERROR: $res\n" | tee -a $backup_path/$log_file
		return 1
	fi

	# Print a backup summary...
	printf "PartKeepr database backup completed:\n" | tee -a $backup_path/$log_file
	printf "* File name:   $backup_file.zip\n" | tee -a $backup_path/$log_file
	local filesize=$(ls -lsah "$backup_path/$backup_file.zip" | awk '{print $6}')
	printf "* File size:   $filesize\n" | tee -a $backup_path/$log_file

	local dur_sec=$(( $(date +%s) - $start ))
	local hr=$(( $dur_sec / 3600 )) # Calculate hours.
	local min=$(( ($dur_sec % 3600) / 60 )) # Calculate remaining minutes.
	local sec=$(( $dur_sec % 60 )) # Calculate remaining seconds.
	min=$(printf "%02d" $min) # Ensure two digits (zero padding).
	sec=$(printf "%02d" $sec) # Ensure two digits (zero padding).
	printf "* Duration:    $hr:$min:$sec\n\n" | tee -a $backup_path/$log_file
}


backup_app_data() {
	local start=$(date +%s)
	local backup_file="${date_start}_partkeepr-data-backup.zip"

	printf "PartKeepr web data backup started...\n" | tee -a $backup_path/$log_file

    printf "Compressing web data to ZIP archive...\n" | tee -a $backup_path/$log_file
    # Zip the directory file maximum compression. This is CPU intensive, so nice 10 is used (low priority).
    res="$( nice -10 zip -q -r -T -9 "$backup_path/$backup_file" "$partkeepr_data_path" )"
	if $res
	then
		printf "* Success\n" | tee -a $backup_path/$log_file
	else
		printf "* ERROR: $res\n" | tee -a $backup_path/$log_file
		return 1
	fi

	# Print a backup summary...
	printf "PartKeepr web data backup completed:\n" | tee -a $backup_path/$log_file
	printf "* File name:   $backup_file\n" | tee -a $backup_path/$log_file
	local filesize=$(ls -lsah "$backup_path/$backup_file" | awk '{print $6}')
	printf "* File size:   $filesize\n" | tee -a $backup_path/$log_file

	local dur_sec=$(( $(date +%s) - $start ))
	local hr=$(( $dur_sec / 3600 )) # Calculate hours.
	local min=$(( ($dur_sec % 3600) / 60 )) # Calculate remaining minutes.
	local sec=$(( $dur_sec % 60 )) # Calculate remaining seconds.
	min=$(printf "%02d" $min) # Ensure two digits (zero padding).
	sec=$(printf "%02d" $sec) # Ensure two digits (zero padding).
	printf "* Duration:    $hr:$min:$sec\n\n" | tee -a $backup_path/$log_file
}


backup_app_config() {
	local start=$(date +%s)
	local backup_file="${date_start}_partkeepr-config-backup.zip"

	printf "PartKeepr web config backup started...\n" | tee -a $backup_path/$log_file

    printf "Compressing web config to ZIP archive...\n" | tee -a $backup_path/$log_file
    # Zip the directory file maximum compression. This is CPU intensive, so nice 10 is used (low priority).
    res="$( nice -10 zip -q -r -T -9 "$backup_path/$backup_file" "$partkeepr_config_path" )"
	if $res
	then
		printf "* Success\n" | tee -a $backup_path/$log_file
	else
		printf "* ERROR: $res\n" | tee -a $backup_path/$log_file
		return 1
	fi

	# Print a backup summary...
	printf "PartKeepr web config backup completed:\n" | tee -a $backup_path/$log_file
	printf "* File name:   $backup_file\n" | tee -a $backup_path/$log_file
	local filesize=$(ls -lsah "$backup_path/$backup_file" | awk '{print $6}')
	printf "* File size:   $filesize\n" | tee -a $backup_path/$log_file

	local dur_sec=$(( $(date +%s) - $start ))
	local hr=$(( $dur_sec / 3600 )) # Calculate hours.
	local min=$(( ($dur_sec % 3600) / 60 )) # Calculate remaining minutes.
	local sec=$(( $dur_sec % 60 )) # Calculate remaining seconds.
	min=$(printf "%02d" $min) # Ensure two digits (zero padding).
	sec=$(printf "%02d" $sec) # Ensure two digits (zero padding).
	printf "* Duration:    $hr:$min:$sec\n\n" | tee -a $backup_path/$log_file
}


# First initialise backup path
date_start=$(date +'%Y%m%d-%H%M%S')
backup_path="$backup_root_path/$(date +%Y%m)"
log_file="${date_start}_partkeepr-backup.log"

printf "* Backup path: $backup_path\n"
printf "* Log: $log_file\n\n"

# Create backup path and set permissions...
mkdir -p $backup_path
chmod 755 $backup_path


# Run backups
backup_database
backup_app_data
backup_app_config

printf "Backup finished\n\n"
