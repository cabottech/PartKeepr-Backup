# PartKeepr Backup

A Linux shell script that creates a backup of a [PartKeepr](https://github.com/partkeepr/PartKeepr) database and important web files. Backups are conveniently compressed using zip to date-time-stamped filenames.

Tested with [PartKeepr 1.4.0 on Raspbian 9.13 (stretch)](https://wiki.partkeepr.org/wiki/PartKeepr_1.4.0_installation_on_a_Raspberry_Pi)

- Author: [Cabot Technologies](https://cabottechnologies.com)
- Licence: MIT (see the LICENSE file)

## Installation

This script is intended to work with [PartKeepr 1.4.0 on Raspbian 9.13 (stretch)](https://wiki.partkeepr.org/wiki/PartKeepr_1.4.0_installation_on_a_Raspberry_Pi). Ensure this is installed and running.

Install prerequisites:

```
$ sudo apt-get update
$ sudo apt-get install git zip
```

Change the the home directory and clone from git:

```
$ cd ~
$ git clone https://github.com/cabottech/PartKeepr-Backup.git
```

Change to the new app directory and set permissions to execute the script:

```
$ cd PartKeepr-Backup
$ chmod +x partkeepr-backup.sh
```

Set the database and file properties (see [Configuration](##Configuration) for details):
```
$ nano partkeepr-backup.properties
```

## Configuration

Settings can be modified in the `partkeepr-backup.properties` file.

You'll need to set the database connection and file locations properties specific to your system and installation.

Ensure the user has permissions to read/write to the `backup_root_path`.

Note: it is recommended that 'backup_root_path' be set to a location *not* on the SD card. A safer location for backups would be a mounted USB drive, or mounted network folder. This ensures that in the event of SD card corruption or fault, the backups aren't also lost.

## How to use

### From command-line

Run a backup:
```
$ ./partkeepr-backup.sh
```

### From cron

To automate the backup each day:

```
$ crontab -e
```

Add the following line to schedule a backup at 2:15AM each day. Adjust to your install path if needed:

```
15 2 * * * cd /home/pi/PartKeepr-Backup && /bin/sh ./partkeepr-backup.sh
```

## What is does

When the script `partkeepr-backup.sh` is run (i.e. from command-line or cronjob), backups are created, archived to ZIP, and stored as date-time-stamped files.

### Backup location

Upon execution the backup path is created based on the 'backup_root_path' property. A 'Year-Month' subdirectory is created to help to keep backups organised.

Example:

- `/home/pi/PartKeepr-Backup/backups/202009/`

The backups and log will be stored in this directory.

### Database backup

A backup of the database is done using mysqldump. This creates an SQL export of the entire PartKeepr database. This is then ZIP archived and given a date-time specific filename.

Example:

- `20200905-100952_partkeepr-database-backup.sql.zip`

### Filesystem backup

The data and config web directories are ZIP archived and given date-time specific filenames.

Example:

- `20200905-100952_partkeepr-data-backup.sql.zip`
- `20200905-100952_partkeepr-config-backup.sql.zip`

### Backup log

A log of the backup process is written to the backup location.

Example:

- `20200905-100952_partkeepr-backup.log`

This log details the date of the backup, files written, backup size, and duration.

Example log output:

```
PartKeepr Backup 0.1.1

Database backup:
Retrieving database SQL...
* Success
Compressing backup to ZIP archive...
* Success
Database backup summary:
* File name:   20200906-121932_partkeepr-database-backup.sql.zip
* File size:   55K
* Duration:    0:00:01

Web data backup:
Compressing web data to ZIP archive...
* Success
Web data backup summary:
* File name:   20200906-121932_partkeepr-data-backup.zip
* File size:   15M
* Duration:    0:00:05

Web config backup:
Compressing web config to ZIP archive...
* Success
Web config backup summary:
* File name:   20200906-121932_partkeepr-config-backup.zip
* File size:   20K
* Duration:    0:00:00
```

## Notes / improvements / to-do

- Currently backups are full snapshots, not incremental. This is nice and simple, but uses much more backup storage. It may be worth automatically removing old backups? For the time being backup storage need to be managed by the user.
- An example of how to backup to network location (with auto-mount) would be nice too.
- Send backup error notifications via syslog/mail?
- Add a step-by-step guide for backup recovery.
