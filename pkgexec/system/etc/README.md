This directory contains executables that go in the /system/etc/ directory.
Normally, nothing is executable in /system/etc, but for the XT720 one file
of note, install-recovery.sh when present and executable is run at start up.

Utilizing this technique (which I learned from Link2SD), I made
more general modifications for those who use the Apps2SD approach.

# Purpose

The original apps2sd approach which linked certain files into the sd card
folder works well as long as the SD card is kept inside.  However, once
the SD card is changed then problems such as unable to boot up may occur.

This project provides an alternative to the boot process that would allow
the card to be removed and still ensure the phone will still function
without performing recovery.

It also has the following features:

* automatic relinking of the files when the SD is replaced.  However,
  there is no guarantee that the apps will still function (there is
  an attempt made to do it though).
* automatic FAT fsck while on the bootup to reduce the time on the GUI
  recovery if recovery is needed.
* support for ext3 if the modules are present and the file system is
  mountable as ext3

# Installation

The install-recovery.sh should be copied into /system/etc

If you have been using the old apps2sd approach you need to put back
mod_boot_mode back to the original which was backed up to mot_boot_bin
by the original scripts.

# Untested scenarios

The following scenarios have not been tested, but they have been coded.

* Automatic recovery of applications if the SD has been removed and
  replaced.
* No dalvik-cache in the SD card.
* The mot_boot_mode is left with the original one from Apps2SD.  This
  may slow down the boot process.
