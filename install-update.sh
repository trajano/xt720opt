#!/system/sh
cd /sdcard/xt720opt
. lib/func.sh

UPDATED_FILES=""

# sets up backup folders
BACKUP_DIR=/sdcard/xt720opt.backup/`date +"%Y-%m-%dT%H.%M.%S"`
busybox mkdir -p $BACKUP_DIR

SYS_PARTITION=`mount | busybox grep "^.* /system " | busybox awk ' { print $1 } '`

unpkg() {
   # outputs the path with no pkg prefix
   echo "$1" | sed 's#^pkg[^/]*##'
}
backup() {
    busybox mkdir -p "$BACKUP_DIR/$1"
    rmdir "$BACKUP_DIR/$1"
    cp "$dest" "$BACKUP_DIR/$1" || die "unable to backup to $BACKUP_DIR/$dest"
}
cat_cp() {
   dest=`unpkg $1`
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
	 backup $dest
         cp -f $1 $dest || die "unable to copy to $dest"
         UPDATED_FILES="$UPDATED_FILES $dest"
      fi
   fi
}

do_update() {
   if [ ! -e pkg/ignore ]
   then
      for file in `find pkg -type f -print`
      do
         cat_cp $file
         chmod 644 $file
      done
   fi
   
   if [ ! -e pkgprop/ignore ]
   then
      for file in `find pkgprop -type f -print`
      do
         merge_prop `unpkg $file` $file
      done
   fi
   
   if [ ! -e pkgdelete/ignore ]
   then
      for file in `find pkgdelete -name "*.md5" -type f -print`
      do
         f=`unpkg $file | sed 's/\.md5$//'`
	 if [ -e "$f" ]
	 then 
	     md5sum < "$f" > "/tmp/t.md5"
	     if diff -aqw "/tmp/t.md5" "$file"
	     then
		 backup $f
		 rm $f
	     fi
	     rm "/tmp/t.md5"
	 fi
      done
   fi
   
   if [ ! -e pkgexec/ignore ]
   then
      for file in `find pkgexec -type f -print`
      do
         cat_cp $file
         chmod 755 $file
      done
   fi
   
   # Update files that should only be updated in OpenRecovery mode
   if [ "$INIT_DIR" = "/sdcard/OpenRecovery/init" ]
   then
      echo "In Openrecovery mode, updating pkgrecovery files"
      if [ ! -e pkgrecovery/ignore ]
      then
         for file in `find pkgrecovery -type f -print`
         do
            cat_cp $file
            chmod 644 $file
         done
      fi
      
      if [ ! -e pkgrecoveryexec/ignore ]
      then
         for file in `find pkgrecoveryexec -type f -print`
         do
            cat_cp $file
            chmod 755 $file
         done
      fi
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

do_update
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
