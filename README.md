Please note that this may brick your phone.  In which case you need to reflash it using an SBF.

Before you use this, install OpenRecovery first.

Root then sh install.sh

This was based on the apps2sd code, but now looks pretty far from it already :)

h1. Purpose
Please note that unlike the apps2sd code, this is an ALL OR NOTHING script.  It was meant to do a quick fix in case I made a mistake and had to RSD Lite my phone from scratch again.  Thankfully with OpenRecovery the amount of times I had to do that since was reduced to zero so the install script is not really well tested now.

h1. Improved bootup script.
The main problem I had with the Apps2SD code which was fixed with other tools such as Link2SD and App2Card is that removing or changing the SD card may cause the phone to go on a boot loop.  I have since made fixes to prevent that.

The changes are in the following file pkg/system/etc/install-recovery.sh
This gets put into /system/etc/

Also the mot_boot_mode has to be reverted back to the orignal file.  If you used the apps2sd script that would be the mot_boot_mode.bin

I am also using ext3 as the file system.  However, I am adding some detection to make sure that if the ext3.ko and jbd.ko files are not present in the proper folder, but the ext2.ko file is that I would still boot the ext2.ko as needed.
