cd /sdcard/xt720opt
UPDATED_FILES=""

cat_cp() {
   dest=`echo "$1" | sed 's/^pkgexec//' | sed 's/^pkg//'`
   if [ \! -e $dest ]
   then
      cat $1 > $dest
      UPDATED_FILES="$UPDATED_FILES $dest"
   else
      src_md5=`md5sum < $1`
      dest_md5=`md5sum < $dest`
      if [ $src_md5 \!= $dest_md5 ]
      then
         echo "updating $dest"
         UPDATED_FILES="$UPDATED_FILES $dest"
      fi
   fi
}

# Remount system partion as read-write
mount -t yaffs2 -o rw,remount /dev/block/mtdblock6 /system

# Remove app2sd or app2card modifications
if [ -x /system/bin/mot_boot_mode.bin ]
then
   MOT_BOOT_MODE_MD5=`md5sum < /system/bin/mot_boot_mode.bin`
   if [ $MOT_BOOT_MODE_MD5 = "79a0b50bfca7b2edb08024732c905d93" ]
   then
      mv /system/bin/mot_boot_mode.bin /system/bin/mot_boot_mode
   fi
fi

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
# TODO some future updates I may want to delete the files in which case I will put the code here.

# Prevent any file loss at this time
sync

# Remount as read-only
mount -t yaffs2 -o ro,remount /dev/block/mtdblock6 /system

# If some files are updated, we should reboot the MediaServer if we are running on the phone mode or tell the user to reboot
# Maybe if I have another JIT update.
