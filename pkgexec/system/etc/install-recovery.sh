#!/system/bin/sh

BOOT_LOG=/data/boot.log
[ -e $BOOT_LOG ] && mv $BOOT_LOG /data/boot_last.log

export PATH=/system/bin:$PATH

MODULES=""
loadmod() {
   if lsmod | grep -q "^$1"
   then
      echo "Kernel module $1 loaded" >> $BOOT_LOG
      MODULES="$MODULES $1"
   else
      if insmod /system/lib/modules/$1.ko
      then
         loadmod $1
      fi
   fi
}

EXTFS=""
loadmod jbd
loadmod ext3

if (echo $MODULES | grep 'jbd') && (echo $MODULES | grep 'ext3' )
then
   EXTFS=ext3
else
   loadmod ext2
   if echo $MODULES | grep 'ext2'
   then
      EXTFS=ext2
   fi
fi

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

# Check for existence of secondary device
if [ $EXTFS ] && mount -t $EXTFS -o noatime,nodiratime /dev/block//vold/179:2 /system/sd 2>> $BOOT_LOG
then
   relink_data app
   relink_data app-private
   relink_data dalvik-cache
fi
mount >> $BOOT_LOG

# Recreate app and app-private folders that are normally put
# into secondary storage if the current ones are not working.
recreate /data/app
recreate /data/app-private
recreate /data/dalvik-cache

exit 0
