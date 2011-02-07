#!/system/bin/sh
if [ \! `which unzip` ]
then
   echo "unzip is not available"
   exit 1
fi

if [ \! -e /sdcard/xt720opt.zip ]
then
   echo "No update file found"
   exit 1
fi

# remove package folders to make sure there are no old files
if [ -x /sdcard/xt720opt/pkg ]
then
   rm -r /sdcard/xt720opt/pkg
fi
if [ -x /sdcard/xt720opt/pkgexec ]
then
   rm -r /sdcard/xt720opt/pkgexec
fi

if [ \! -x /sdcard/xt720opt ]
then
   mkdir /sdcard/xt720opt
fi

if unzip -o /sdcard/xt720opt.zip -d /sdcard/xt720opt
then
   rm /sdcard/xt720opt.zip
else
   echo "Problem extracting update file"
   exit 1
fi

sh /sdcard/xt720opt/install-update.sh
