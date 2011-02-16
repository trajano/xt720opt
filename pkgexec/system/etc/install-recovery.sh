#!/system/bin/sh
# Don't do anything for now
exit

BOOT_LOG=/data/boot.log
[ -e $BOOT_LOG ] && mv $BOOT_LOG /data/boot_last.log
echo "Booting" `date` > $BOOT_LOG

export PATH=/system/bin:$PATH

loadmod() {
   # Will load a kernel module if it is not loaded already
   while [ $# -gt 1 ]
   do
      loadmod $1
      if [ ! $? ]
      then
         return 1
      fi
      shift
   done
   
   if lsmod | grep -q "^$1"
   then
      echo "Kernel module $1 loaded" >> $BOOT_LOG
      return 0;
   else
      if insmod /system/lib/modules/$1.ko 2>> $BOOT_LOG
      then
         loadmod $1
      else
         return 1;
      fi
   fi
}

relink() {
   # Relinks the directory from one place to another
   # $1 = source (usually in internal memory)
   # $2 = target (usually in sd card)
   # $3 = if specified, then no copy is performed
   if [ -e "$2" ] && [ \! "$1" -ef "$2" ]
   then
      echo "relinking '$1' to '$2'" >> $BOOT_LOG
      if [ $3 ]
      then
         mkdir "$2"
      else
         cp -fr "$1"/* "$2"
      fi
      chmod 777 "$2"
      rm -r "$1"
      ln -s "$2" "$1"
   fi
}

fix_permissions() {
   chown system.system /data/app/*.apk
   chown system.system /data/app-private/*.apk
   
   # all the APKs in the data are not going to work unless they had no special permissions to begin with.
   # go through all the installed apps and reapply the permissions but we can put in ALL the permissions.
   # However, the permissions will fix themselves to the proper values afterwards.
   
   # All possible permissions assigned to the shell
   allperms=`grep 'uid="shell"' platform.xml | sed 's/^.*\(name="[^[:space:]]*"\).*$/<item \1 \/>/' | sort -u | tr -d '\n'`
   
   # Backup the packages.xml file before modifications.
   cp -f /data/system/packages.xml /data/system/packages.backup.xml
   sed "s#<perms />#<perms>$allperms</perms>#" /data/system/packages.backup.xml > /data/system/packages.xml
}

recreate() {
   # $1 = path to recreate
   if [ \! -x "$1" ]
   then
      echo "recreating '$1'" >> $BOOT_LOG
      rm -r "$1"
      mkdir "$1"
      chmod 777 "$1"
   fi
   
}

relink_data() {
   # Convenience function to move the data
   relink /data/$1 /system/sd/$1
}

if (loadmod jbd ext3) && mount -t ext3 -o noatime,nodiratime /dev/block//vold/179:2 /system/sd 2>> $BOOT_LOG
then
   relink_data app
   relink_data app-private
   relink_data dalvik-cache
   fix_permissions
elif (loadmod ext2) && mount -t ext2 -o noatime,nodiratime /dev/block//vold/179:2 /system/sd 2>> $BOOT_LOG
then
   relink_data app
   relink_data app-private
   relink_data dalvik-cache
   fix_permissions
   
fi

mount >> $BOOT_LOG

# Check the file system here rather than wait for the GUI,
# though slower to boot to the GUI, it is faster as there is
# no other GUI to show.
if [ -e /dev/block//vold/179:1 ]
then
   /system/bin/fsck_msdos -y /dev/block//vold/179:1 >> $BOOT_LOG
fi

# Recreate app and app-private folders that are normally put
# into secondary storage if the current ones are not working.
recreate /data/app
recreate /data/app-private
recreate /data/dalvik-cache

echo "Finish" `date` >> $BOOT_LOG
exit 0
