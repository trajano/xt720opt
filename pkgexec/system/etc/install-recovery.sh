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

ALL_PERMISSIONS=<<EOT
<item name="android.permission.ACCESS_CHECKIN_PROPERTIES" />
<item name="android.permission.ACCESS_COARSE_LOCATION" />
<item name="android.permission.ACCESS_FINE_LOCATION" />
<item name="android.permission.ACCESS_LOCATION_EXTRA_COMMANDS" />
<item name="android.permission.ACCESS_MOCK_LOCATION" />
<item name="android.permission.ACCESS_NETWORK_STATE" />
<item name="android.permission.ACCESS_SURFACE_FLINGER" />
<item name="android.permission.ACCESS_WIFI_STATE" />
<item name="android.permission.ACCOUNT_MANAGER" />
<item name="android.permission.AUTHENTICATE_ACCOUNTS" />
<item name="android.permission.BATTERY_STATS" />
<item name="android.permission.BIND_APPWIDGET" />
<item name="android.permission.BIND_INPUT_METHOD" />
<item name="android.permission.BLUETOOTH" />
<item name="android.permission.BLUETOOTH_ADMIN" />
<item name="android.permission.BROADCAST_PACKAGE_REMOVED" />
<item name="android.permission.BROADCAST_SMS" />
<item name="android.permission.BROADCAST_STICKY" />
<item name="android.permission.BROADCAST_WAP_PUSH" />
<item name="android.permission.CALL_PHONE" />
<item name="android.permission.CALL_PRIVILEGED" />
<item name="android.permission.CAMERA" />
<item name="android.permission.CHANGE_COMPONENT_ENABLED_STATE" />
<item name="android.permission.CHANGE_CONFIGURATION" />
<item name="android.permission.CHANGE_NETWORK_STATE" />
<item name="android.permission.CHANGE_WIFI_MULTICAST_STATE" />
<item name="android.permission.CHANGE_WIFI_STATE" />
<item name="android.permission.CLEAR_APP_CACHE" />
<item name="android.permission.CLEAR_APP_USER_DATA" />
<item name="android.permission.CONTROL_LOCATION_UPDATES" />
<item name="android.permission.DELETE_CACHE_FILES" />
<item name="android.permission.DELETE_PACKAGES" />
<item name="android.permission.DEVICE_POWER" />
<item name="android.permission.DIAGNOSTIC" />
<item name="android.permission.DISABLE_KEYGUARD" />
<item name="android.permission.DUMP" />
<item name="android.permission.EXPAND_STATUS_BAR" />
<item name="android.permission.FACTORY_TEST" />
<item name="android.permission.FLASHLIGHT" />
<item name="android.permission.FORCE_BACK" />
<item name="android.permission.GET_ACCOUNTS" />
<item name="android.permission.GET_PACKAGE_SIZE" />
<item name="android.permission.GET_TASKS" />
<item name="android.permission.GLOBAL_SEARCH" />
<item name="android.permission.HARDWARE_TEST" />
<item name="android.permission.INJECT_EVENTS" />
<item name="android.permission.INSTALL_LOCATION_PROVIDER" />
<item name="android.permission.INSTALL_PACKAGES" />
<item name="android.permission.INTERNAL_SYSTEM_WINDOW" />
<item name="android.permission.INTERNET" />
<item name="android.permission.MANAGE_ACCOUNTS" />
<item name="android.permission.MANAGE_APP_TOKENS" />
<item name="android.permission.MASTER_CLEAR" />
<item name="android.permission.MODIFY_AUDIO_SETTINGS" />
<item name="android.permission.MODIFY_PHONE_STATE" />
<item name="android.permission.MOUNT_FORMAT_FILESYSTEMS" />
<item name="android.permission.MOUNT_UNMOUNT_FILESYSTEMS" />
<item name="android.permission.PERSISTENT_ACTIVITY" />
<item name="android.permission.PROCESS_OUTGOING_CALLS" />
<item name="android.permission.READ_CALENDAR" />
<item name="android.permission.READ_CONTACTS" />
<item name="android.permission.READ_FRAME_BUFFER" />
<item name="android.permission.READ_HISTORY_BOOKMARKS" />
<item name="android.permission.READ_INPUT_STATE" />
<item name="android.permission.READ_LOGS" />
<item name="android.permission.READ_PHONE_STATE" />
<item name="android.permission.READ_SMS" />
<item name="android.permission.READ_SYNC_SETTINGS" />
<item name="android.permission.READ_SYNC_STATS" />
<item name="android.permission.REBOOT" />
<item name="android.permission.RECEIVE_BOOT_COMPLETED" />
<item name="android.permission.RECEIVE_MMS" />
<item name="android.permission.RECEIVE_SMS" />
<item name="android.permission.RECEIVE_WAP_PUSH" />
<item name="android.permission.RECORD_AUDIO" />
<item name="android.permission.REORDER_TASKS" />
<item name="android.permission.RESTART_PACKAGES" />
<item name="android.permission.SEND_SMS" />
<item name="android.permission.SET_ACTIVITY_WATCHER" />
<item name="android.permission.SET_ALARM" />
<item name="android.permission.SET_ALWAYS_FINISH" />
<item name="android.permission.SET_ANIMATION_SCALE" />
<item name="android.permission.SET_DEBUG_APP" />
<item name="android.permission.SET_ORIENTATION" />
<item name="android.permission.SET_PREFERRED_APPLICATIONS" />
<item name="android.permission.SET_PROCESS_LIMIT" />
<item name="android.permission.SET_TIME" />
<item name="android.permission.SET_TIME_ZONE" />
<item name="android.permission.SET_WALLPAPER" />
<item name="android.permission.SET_WALLPAPER_HINTS" />
<item name="android.permission.SIGNAL_PERSISTENT_PROCESSES" />
<item name="android.permission.STATUS_BAR" />
<item name="android.permission.SUBSCRIBED_FEEDS_READ" />
<item name="android.permission.SUBSCRIBED_FEEDS_WRITE" />
<item name="android.permission.SYSTEM_ALERT_WINDOW" />
<item name="android.permission.UPDATE_DEVICE_STATS" />
<item name="android.permission.USE_CREDENTIALS" />
<item name="android.permission.USE_SIP" />
<item name="android.permission.VIBRATE" />
<item name="android.permission.WAKE_LOCK" />
<item name="android.permission.WRITE_APN_SETTINGS" />
<item name="android.permission.WRITE_CALENDAR" />
<item name="android.permission.WRITE_CONTACTS" />
<item name="android.permission.WRITE_EXTERNAL_STORAGE" />
<item name="android.permission.WRITE_GSERVICES" />
<item name="android.permission.WRITE_HISTORY_BOOKMARKS" />
<item name="android.permission.WRITE_SECURE_SETTINGS" />
<item name="android.permission.WRITE_SETTINGS" />
<item name="android.permission.WRITE_SMS" />
<item name="android.permission.WRITE_SYNC_SETTINGS" />
EOT

fix_permissions() {
   chown system.system /data/app/*.apk
   chown system.system /data/app-private/*.apk
   
   # all the APKs in the data are not going to work unless they had no special permissions to begin with.
   # go through all the installed apps and reapply the permissions but we can put in ALL the permissions.
   
   # All possible permissions (except for BRICK)
   allperms=`grep '^<item .* package=.*' /data/system/packages.xml  | grep -v BRICK | sed 's/ package=".*"//'`
   allperms="$allperms
   $ALL_PERMISSIONS"
   allperms=`echo $allperms | sort -u | tr -d '\n'`
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

# Check for existence of secondary device
if [ $EXTFS ] && mount -t $EXTFS -o noatime,nodiratime /dev/block//vold/179:2 /system/sd 2>> $BOOT_LOG
then
   relink_data app
   relink_data app-private
   relink_data dalvik-cache
   fix_permissions
fi
mount >> $BOOT_LOG

# Recreate app and app-private folders that are normally put
# into secondary storage if the current ones are not working.
recreate /data/app
recreate /data/app-private
recreate /data/dalvik-cache

exit 0
