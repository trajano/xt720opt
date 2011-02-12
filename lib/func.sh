# Provides functions used for the installer and update scriptsA

die() {
   # Terminates with an error message
   echo $*
   exit 1
}

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

merge_prop() {
    # Merges the properties in a given prop file with another prop file.
    # $1 = prop file to update
    # $2 = prop file to read the latest values from
    eval `grep -v '^#' $2 | grep -v "^[[:space:]]*$" | sed 's/^\([^=]*\)=\(.*\)$/set_prop "'$1'" "\1" "\2" ; /' `
}
