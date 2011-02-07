#!/system/bin/sh

BOOT_LOG=/data/boot.log
[ -e $BOOT_LOG ] && mv $BOOT_LOG /data/boot_last.log

export PATH=/system/bin:$PATH

EXTFS=""
if insmod /system/lib/modules/jbd.ko && insmod /system/lib/modules/ext3.ko
then
   EXTFS=ext3
elif insmod /system/lib/modules/ext2.ko
then
   EXTFS=ext2
fi

relink() {
   # Relinks the directory from one place to another
   # $1 = source (usually in internal memory)
   # $2 = target (usually in sd card)
   if [ -e "$2" ] && [ \! "$1" -ef "$2" ]
   then
      echo "relinking '$1' to '$2'" >> $BOOT_LOG
      cp -fr "$1"/* "$2"
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
if [ $EXTFS ] && mount -t $EXTFS-o noatime,nodiratime /dev/block//vold/179:2 /system/sd 2>> $BOOT_LOG
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
