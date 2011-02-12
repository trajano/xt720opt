cd /sdcard/xt720opt
. lib/func.sh

UPDATED_FILES=""

# sets up backup folders
BACKUP_DIR=/sdcard/xt720opt.backup/`date +"%Y-%m-%dT%H.%M.%S"`
busybox mkdir -p $BACKUP_DIR

SYS_PARTITION=`mount | busybox grep "^.* /system " | busybox awk ' { print $1 } '`

cat_cp() {
   dest=`echo "$1" | sed 's#^pkg[^/]*##'`
   if [ \! -e $dest ]
   then
      cp -f $1 $dest || die "unable to copy to $dest"
      UPDATED_FILES="$UPDATED_FILES $dest"
   else
      if diff -q $1 $dest
      then
         true
      else
         echo "updating $dest"
         busybox mkdir -p $BACKUP_DIR/$dest
         rmdir $BACKUP_DIR/$dest
         cp $dest $BACKUP_DIR/$dest || die "unable to backup to $BACKUP_DIR/$dest"
         cp -f $1 $dest || die "unable to copy to $dest"
         UPDATED_FILES="$UPDATED_FILES $dest"
      fi
   fi
}

do_update() {
   for file in `find pkg -type f -print`
   do
      cat_cp $file
      chmod 644 $file
   done
   for file in `find pkgexec -type f -print`
   do
      cat_cp $file
      chmod 755 $file
   done
   
   # Update files that should only be updated in OpenRecovery mode
   if [ "$INIT_DIR" = "/sdcard/OpenRecovery/init" ]
   then
      echo "In Openrecovery mode, updating pkgrecovery files"
      for file in `find pkgrecovery -type f -print`
      do
         cat_cp $file
         chmod 644 $file
      done
      for file in `find pkgrecoveryexec -type f -print`
      do
         cat_cp $file
         chmod 755 $file
      done
   fi
   
   # TODO some future updates I may want to delete the files in which case I will put the code here.
   
   # Reinstall busybox if updated
   if echo $UPDATED_FILES | grep /system/xbin/busybox
   then
      /system/xbin/busybox --install -s /system/xbin/
   fi
   
   # Remove dalvik-cache if dexopt or dalvik vm is updated
   if (echo $UPDATED_FILES | grep -q /system/bin/davikvm) || (echo $UPDATED_FILES | grep -q /system/bin/dexopt)
   then
      [ -e /system/sd/dalvik-cache ] && rm -r /system/sd/dalvik-cache/*
      [ -e /sddata/dalvik-cache ] && rm -r /sddata/dalvik-cache/*
      [ -e /data/dalvik-cache ] && rm -r /data/dalvik-cache/*
   fi
}

# Remount system partion as read-write
mount -t yaffs2 -o rw,remount $SYS_PARTITION /system

# Remove app2sd or app2card modifications
if [ -x /system/bin/mot_boot_mode.bin ]
then
   MOT_BOOT_MODE_MD5=`md5sum < /system/bin/mot_boot_mode.bin`
   if [ $MOT_BOOT_MODE_MD5 = "79a0b50bfca7b2edb08024732c905d93" ]
   then
      mv /system/bin/mot_boot_mode.bin /system/bin/mot_boot_mode
   fi
fi

# Prevent any file loss at this time
sync

# Remount as read-only
mount -t yaffs2 -o ro,remount $SYS_PARTITION /system

# If some files are updated, we should reboot the MediaServer if we are running on the phone mode or tell the user to reboot
# Maybe if I have another JIT update.
