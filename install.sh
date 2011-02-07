#!/system/bin/sh

set_prop() {
   # Sets a property in the given prop file
   # $1 = prop file
   # $2 = prop name
   # $3 = prop value
   
   if grep -q "^$2=$3\$" $1
   then
      true
   elif grep -q "^$2=" $1
   then
      grep -v "^$2=" $1 > $1~
      echo $2=$3 >> $1~
      mv $1~ $1
   else
      echo $2=$3 >> $1
   fi
}

# Allow write to the FS
mount -t yaffs2 -o rw,remount /dev/block/mtdblock6 /system
cp apns-wind-conf.xml /system/etc/apns-conf.xml
# Install Busybox
cat busybox > /system/xbin/busybox
chmod 755 /system/xbin/busybox

# Install BUSYBOX
/system/xbin/busybox --install -s /system/xbin/

# prep_ext3_partition
cp -f pkg/system/lib/modules/jbd.ko /system/lib/modules
cp -f pkg/system/lib/modules/ext3.ko /system/lib/modules

insmod /system/lib/modules/jbd.ko
insmod /system/lib/modules/ext3.ko

mkdir /system/sd
mount -t ext3 /dev/block/mmcblk0p2 /system/sd
if [ $? -ne 0 ]
then
   echo "Unable to mount ext3 partition"
   exit 1
fi
#mv /system/bin/mot_boot_mode  /system/bin/mot_boot_mode.bin

#copy over modified boot-up script
cp -f pkg/system/etc/install-recovery.sh /system/etc/install-recovery.sh
chmod 777 /system/etc/install-recovery.sh

# move_apps_to_sd()
#remove original directories from data and create links to new directories
echo "Copying apps to sd, please wait ..."
cp -fr /data/app /system/sd
chmod 777 /system/sd/app

rm -r /data/app
ln -s /system/sd/app /data/app
chmod 777 /data/app

cp -fr /data/app-private  /system/sd
chmod 777 /system/sd/app-private

rm -r /data/app-private
ln -s /system/sd/app-private /data/app-private
chmod 777 /data/app-private

cp -fr /data/dalvik-cache /system/sd
chmod 777 /system/sd/dalvik-cache

rm -r /data/dalvik-cache/*
ln -s /system/sd/dalvik-cache /data/dalvik-cache
chmod 777 /data/dalvik-cache
cat pkg/system/build.prop > /system/build.prop

mkdir /data/jit
mkdir /data/jit/dalbk

cp /system/build.prop /data/jit/dalbk/
cp /system/bin/dalvikvm /data/jit/dalbk/
cp /system/lib/libdvm.so /data/jit/dalbk/
cp /system/lib/libnativehelper.so /data/jit/dalbk/

cp -f /sdcard/apps2sd/jit/bin/dalvikvm /system/bin/
cp -f /sdcard/apps2sd/jit/bin/dexopt /system/bin/
cp -f /sdcard/apps2sd/jit/bin/logcat /system/bin/

chmod 755 /system/bin/dalvikvm
chmod 755 /system/bin/dexopt
chmod 755 /system/bin/logcat

cp -f /sdcard/apps2sd/jit/lib/libcutils.so /system/lib/
cp -f /sdcard/apps2sd/jit/lib/libdvm.so /system/lib/
cp -f /sdcard/apps2sd/jit/lib/libm.so /system/lib/
cp -f /sdcard/apps2sd/jit/lib/libz.so /system/lib/
cp -f /sdcard/apps2sd/jit/lib/libdl.so /system/lib/
cp -f /sdcard/apps2sd/jit/lib/liblog.so /system/lib/
cp -f /sdcard/apps2sd/jit/lib/libnativehelper.so /system/lib/

chmod 644 /system/lib/libcutils.so
chmod 644 /system/lib/libdvm.so
chmod 644 /system/lib/libm.so
chmod 644 /system/lib/libz.so
chmod 644 /system/lib/libdl.so
chmod 644 /system/lib/liblog.so
chmod 644 /system/lib/libnativehelper.so

# http://forum.xda-developers.com/showthread.php?t=701698
rm /system/app/Facebook.apk
rm /system/app/Email.apk
rm /system/app/MotoCAL.apk

# Corporate Calendar
rm /system/app/MotoGAL.apk

rm /system/app/MagicSmokeWallpapers.apk

rm /system/app/LatinImeTutorial.apk
