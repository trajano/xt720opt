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

mkdir -p /sdcard/xt720opt
if unzip -o /sdcard/xt720opt.zip -d /sdcard/xt720opt
then
   rm /sdcard/xt720opt.zip
else
   echo "Problem extracting update file"
   exit 1
fi


