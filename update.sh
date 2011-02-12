#!/system/bin/sh

if which busybox > /dev/null
then
   true
else
   # Install busybox, copy to data first as /sdcard files are not executable
   echo "Installing busybox..."
   if [ ! -e busybox ]
   then
      echo "'busybox' was not found, update aborted."
      exit 1
   fi
   cp busybox /data/busybox
   chmod 755 /data/busybox
   
   # Find the system partition
   SYS_PARTITION=`mount | /data/busybox grep "^.* /system " | /data/busybox awk ' { print $1 } '`
   mount -t yaffs2 -o rw,remount $SYS_PARTITION /system
   cp busybox /system/xbin
   chmod 755 /system/xbin/busybox
   /system/xbin/busybox --install -s /system/xbin/
   mount -t yaffs2 -o ro,remount $SYS_PARTITION /system
fi

if [ \! -e ../xt720opt.zip ]
then
   echo "No update file found"
   exit 1
fi

# remove package folders to make sure there are no old files
rm -r pkg*

if busybox unzip -o ../xt720opt.zip
then
   rm ../xt720opt.zip
else
   echo "Problem extracting update file"
   exit 1
fi

sh install-update.sh
